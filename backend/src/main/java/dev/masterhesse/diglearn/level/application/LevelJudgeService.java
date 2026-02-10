package dev.masterhesse.diglearn.level.application;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import dev.masterhesse.diglearn.judge.CircuitSpec;
import dev.masterhesse.diglearn.judge.CircuitValidator;
import dev.masterhesse.diglearn.judge.SimpleBooleanJudgeEvaluator;
import dev.masterhesse.diglearn.level.api.LevelJudgeApiModels;
import dev.masterhesse.diglearn.level.persistence.LevelEntity;
import dev.masterhesse.diglearn.level.persistence.LevelPassRecordEntity;
import dev.masterhesse.diglearn.level.persistence.LevelPassRecordRepository;
import dev.masterhesse.diglearn.level.persistence.LevelRepository;
import dev.masterhesse.diglearn.level.persistence.LevelTestCaseEntity;
import dev.masterhesse.diglearn.level.persistence.LevelTestCaseRepository;
import dev.masterhesse.diglearn.level.persistence.LevelTestStepEntity;
import dev.masterhesse.diglearn.user.persistence.AppUserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;

@Service
public class LevelJudgeService {

    private final AppUserRepository userRepo;
    private final LevelRepository levelRepo;
    private final LevelTestCaseRepository testCaseRepo;
    private final LevelPassRecordRepository passRepo; // 若你要记录通关
    private final ObjectMapper om;

    private final SimpleBooleanJudgeEvaluator evaluator = new SimpleBooleanJudgeEvaluator();

    public LevelJudgeService(AppUserRepository userRepo,
                            LevelRepository levelRepo,
                            LevelTestCaseRepository testCaseRepo,
                            LevelPassRecordRepository passRepo,
                            ObjectMapper om) {
        this.userRepo = userRepo;
        this.levelRepo = levelRepo;
        this.testCaseRepo = testCaseRepo;
        this.passRepo = passRepo;
        this.om = om;
    }

    public String resolveUserId(String reqUserId, String userIdHeader) {
        String a = trimToNull(reqUserId);
        String b = trimToNull(userIdHeader);

        if (a == null && b == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "userId is required (body.userId or X-User-Id)");
        }
        if (a != null && b != null && !a.equals(b)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "conflicting userId (body vs header)");
        }

        String userId = (a != null) ? a : b;

        // 必须来自 user 表
        if (!userRepo.existsById(userId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "unknown userId: " + userId);
        }
        return userId;
    }

    @Transactional
    public LevelJudgeApiModels.JudgeResponse judge(String levelCode, String userId, JsonNode circuitNode) {
        LevelEntity level = levelRepo.findDetailByCode(levelCode)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "level not found: " + levelCode));

        List<LevelTestCaseEntity> testCases = testCaseRepo.findAllByLevelCodeWithSteps(levelCode);
        testCases.sort(Comparator.comparing(LevelTestCaseEntity::getOrderIndex, Comparator.nullsLast(Integer::compareTo)));

        if (testCases.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "level has no test cases: " + levelCode);
        }

        CircuitSpec circuit = parseCircuit(circuitNode);

        // ✅ 新增：电路结构校验 + allowedComponents 限制
        Set<String> allowedComponents = readAllowedComponents(level);
        try {
            CircuitValidator.validate(circuit, allowedComponents);
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, e.getMessage());
        }

        // 校验：step inputs 只能给 Button；且所有 Button 都必须给值
        Set<String> buttonIds = new HashSet<>();
        for (var e : circuit.devices().entrySet()) {
            if ("Button".equals(e.getValue().type())) buttonIds.add(e.getKey());
        }

        for (LevelTestCaseEntity tc : testCases) {
            if (tc.getOrderIndex() == null) {
                throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "testCase.orderIndex is null");
            }

            List<LevelTestStepEntity> steps = tc.getSteps();
            steps.sort(Comparator.comparing(LevelTestStepEntity::getStepIndex, Comparator.nullsLast(Integer::compareTo)));

            for (LevelTestStepEntity step : steps) {
                if (step.getStepIndex() == null) {
                    throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "testStep.stepIndex is null");
                }

                Map<String, Integer> inputs = read01Map(step.getInputsJson(), "inputs_json");
                Map<String, Integer> expected = read01Map(step.getExpectedJson(), "expected_json");

                // inputs 覆盖所有 Buttons
                for (String bid : buttonIds) {
                    if (!inputs.containsKey(bid)) {
                        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "missing input for Button: " + bid);
                    }
                }
                // inputs 不允许塞非 Button 的 id
                for (String k : inputs.keySet()) {
                    CircuitSpec.DeviceSpec d = circuit.devices().get(k);
                    if (d == null) {
                        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "inputs_json contains unknown device id: " + k);
                    }
                    if (!"Button".equals(d.type())) {
                        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "inputs_json key is not a Button: " + k);
                    }
                }

                Map<String, Integer> allOut;
                try {
                    allOut = evaluator.evaluateAll(circuit, inputs);
                } catch (IllegalArgumentException e) {
                    // 电路不完整/不合法（缺线、类型不支持等） -> 400
                    throw new ResponseStatusException(HttpStatus.BAD_REQUEST, e.getMessage());
                }

                Map<String, Integer> actual = new LinkedHashMap<>();
                for (String outId : expected.keySet()) {
                    Integer v = allOut.get(outId);
                    if (v == null) {
                        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "expected_json references unknown output device: " + outId);
                    }
                    actual.put(outId, v);
                }

                if (!expected.equals(actual)) {
                    JsonNode inputsNode = om.valueToTree(inputs);
                    JsonNode expectedNode = om.valueToTree(expected);
                    JsonNode actualNode = om.valueToTree(actual);

                    return new LevelJudgeApiModels.JudgeResponse(
                            levelCode,
                            userId,
                            false,
                            "Mismatch at testCase=" + tc.getOrderIndex() + ", step=" + step.getStepIndex(),
                            new LevelJudgeApiModels.Failure(tc.getOrderIndex(), step.getStepIndex(), inputsNode, expectedNode, actualNode),
                            null
                    );
                }
            }
        }

        // 可选：记录通关（取决于你 LevelPassRecordEntity/Repository 的实现）
        passRepo.upsertPass(userId, levelCode);

        LevelPassRecordEntity rec = passRepo.findByUserIdAndLevelCode(userId, levelCode)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.INTERNAL_SERVER_ERROR,
                        "pass record upserted but not found (userId=" + userId + ", levelCode=" + levelCode + ")"
                ));

        LevelJudgeApiModels.PassRecord passRecord = mapPassRecord(rec);

        return new LevelJudgeApiModels.JudgeResponse(
                levelCode,
                userId,
                true,
                "Passed.",
                null,
                passRecord
        );
    }

    private Set<String> readAllowedComponents(LevelEntity level) {
        // LevelEntity.allowedComponents 是 ElementCollection(Set<String>)，不是 JSON 字符串
        return trimToNull(level.getAllowedComponents());
    }

    private LevelJudgeApiModels.PassRecord mapPassRecord(LevelPassRecordEntity e) {
        // 注意：这里的构造参数顺序/字段名请按你项目的 LevelJudgeApiModels.PassRecord 定义调整
        return new LevelJudgeApiModels.PassRecord(
                e.getUserId(),
                e.getLevelCode(),
                e.getFirstPassedAt(),
                e.getLastPassedAt(),
                e.getPassCount()
        );
    }

    @Transactional(readOnly = true)
    public LevelJudgeApiModels.PassStatusResponse getPassStatus(String levelCode, String userId) {
        if (!levelRepo.existsById(levelCode)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "level not found: " + levelCode);
        }
        if (!userRepo.existsById(userId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "unknown userId: " + userId);
        }

        var opt = passRepo.findByUserIdAndLevelCode(userId, levelCode);
        boolean passed = opt.isPresent();
        LevelJudgeApiModels.PassRecord passRecord = opt.map(this::mapPassRecord).orElse(null);

        return new LevelJudgeApiModels.PassStatusResponse(levelCode, userId, passed, passRecord);
    }

    private CircuitSpec parseCircuit(JsonNode node) {
        if (node == null || node.isNull()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "circuit is required");
        }
        try {
            // 兼容 DigitalJS 单输入端口命名（in/out）
            // DigitalJS: 单输入用 "in"，多输入用 "in1..inN"
            // 当前后端 validator/evaluator 只接受 "in1..inN"，所以这里把 "in" 归一化为 "in1"
            JsonNode normalized = normalizeDigitalJsInputPortAliases(node);
            return om.treeToValue(normalized, CircuitSpec.class);
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "invalid circuit json: " + e.getMessage());
        }
    }

    /**
     * 把 DigitalJS 的单输入端口别名归一化：
     * - connector.to.port == "in"  -> "in1"
     *
     * 仅在不歧义时转换：
     * - 如果某 device 明确声明 inputs>1，仍然禁止使用 "in"
     * - 如果同一 device 的连线里出现过 in2+，也禁止再出现 "in"
     */
    private JsonNode normalizeDigitalJsInputPortAliases(JsonNode raw) {
        JsonNode copy = raw.deepCopy();
        if (copy != null && copy.isObject()) {
            normalizeDigitalJsInputPortAliasesInCircuit((ObjectNode) copy);
        }
        return copy;
    }

    private void normalizeDigitalJsInputPortAliasesInCircuit(ObjectNode circuitObj) {
        Map<String, Integer> declaredInputs = readDeclaredInputs(circuitObj);
        Set<String> hasIn2Plus = new HashSet<>();

        JsonNode connectorsNode = circuitObj.get("connectors");
        if (connectorsNode != null && connectorsNode.isArray()) {
            // pass 1: 记录哪些 device 用到了 in2+（说明它一定是多输入语义）
            for (JsonNode c : connectorsNode) {
                if (c == null || !c.isObject()) continue;
                JsonNode to = c.get("to");
                if (to == null || !to.isObject()) continue;

                String toId = textOrNull(to.get("id"));
                String toPort = textOrNull(to.get("port"));
                Integer idx = parseIndexedPort(toPort, "in");
                if (toId != null && idx != null && idx >= 2) {
                    hasIn2Plus.add(toId);
                }
            }

            // pass 2: 归一化 "in" -> "in1"
            for (JsonNode c : connectorsNode) {
                if (c == null || !c.isObject()) continue;

                ObjectNode connObj = (ObjectNode) c;
                JsonNode toNode = connObj.get("to");
                if (toNode == null || !toNode.isObject()) continue;

                ObjectNode toObj = (ObjectNode) toNode;
                String toPort = textOrNull(toObj.get("port"));
                if (!"in".equals(toPort)) continue;

                String toId = textOrNull(toObj.get("id"));
                Integer nInputs = (toId != null) ? declaredInputs.get(toId) : null;

                if (nInputs != null && nInputs > 1) {
                    throw new ResponseStatusException(
                            HttpStatus.BAD_REQUEST,
                            "invalid to.port: in (device " + toId + " has inputs=" + nInputs + ", use in1..in" + nInputs + ")"
                    );
                }
                if (toId != null && hasIn2Plus.contains(toId)) {
                    throw new ResponseStatusException(
                            HttpStatus.BAD_REQUEST,
                            "invalid to.port: in (device " + toId + " also uses in2+ elsewhere; use in1..inN consistently)"
                    );
                }

                // ✅ 接受 DigitalJS 单输入写法：in -> in1
                toObj.put("port", "in1");
            }
        }

        // 递归处理子电路
        JsonNode subs = circuitObj.get("subcircuits");
        if (subs != null && subs.isObject()) {
            Iterator<Map.Entry<String, JsonNode>> it = subs.fields();
            while (it.hasNext()) {
                Map.Entry<String, JsonNode> e = it.next();
                JsonNode sub = e.getValue();
                if (sub != null && sub.isObject()) {
                    normalizeDigitalJsInputPortAliasesInCircuit((ObjectNode) sub);
                }
            }
        }
    }

    private Map<String, Integer> readDeclaredInputs(ObjectNode circuitObj) {
        Map<String, Integer> m = new HashMap<>();
        JsonNode devicesNode = circuitObj.get("devices");
        if (devicesNode != null && devicesNode.isObject()) {
            Iterator<Map.Entry<String, JsonNode>> it = devicesNode.fields();
            while (it.hasNext()) {
                Map.Entry<String, JsonNode> e = it.next();
                JsonNode dev = e.getValue();
                if (dev == null || !dev.isObject()) continue;

                Integer inputs = intOrNull(dev.get("inputs"));
                if (inputs != null) {
                    m.put(e.getKey(), inputs);
                }
            }
        }
        return m;
    }

    private Integer intOrNull(JsonNode n) {
        if (n == null || n.isNull()) return null;
        if (!n.isIntegralNumber()) return null;
        return n.asInt();
    }

    private String textOrNull(JsonNode n) {
        if (n == null || n.isNull()) return null;
        String s = n.asText(null);
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private Integer parseIndexedPort(String port, String prefix) {
        if (port == null) return null;
        if (!port.startsWith(prefix)) return null;
        String rest = port.substring(prefix.length());
        if (rest.isEmpty()) return null; // "in" / "out" 这种无编号形式
        try {
            return Integer.parseInt(rest);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Map<String, Integer> read01Map(String json, String field) {
        String t = trimToNull(json);
        if (t == null) return Map.of();

        try {
            Map<String, Integer> m = om.readValue(t, new TypeReference<Map<String, Integer>>() {});
            if (m == null) return Map.of();
            for (var e : m.entrySet()) {
                Integer v = e.getValue();
                if (v == null || (v != 0 && v != 1)) {
                    throw new ResponseStatusException(
                            HttpStatus.BAD_REQUEST,
                            "value must be 0/1 at " + field + "." + e.getKey() + " (got " + v + ")"
                    );
                }
            }
            return m;
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "invalid " + field + ": " + e.getMessage());
        }
    }

    private String trimToNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isBlank() ? null : t;
    }

    // 重载：用于 LevelEntity.getAllowedComponents() 这种 Set<String>
    private Set<String> trimToNull(Set<String> set) {
        if (set == null || set.isEmpty()) return Set.of();

        Set<String> out = new LinkedHashSet<>();
        for (String s : set) {
            String t = trimToNull(s);
            if (t != null) out.add(t);
        }
        return out;
    }
}