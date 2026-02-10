package dev.masterhesse.diglearn.level.importing;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import dev.masterhesse.diglearn.level.persistence.LevelEntity;
import dev.masterhesse.diglearn.level.persistence.LevelRepository;
import dev.masterhesse.diglearn.level.persistence.LevelTestCaseEntity;
import dev.masterhesse.diglearn.level.persistence.LevelTestCaseRepository;
import dev.masterhesse.diglearn.level.persistence.LevelTestStepEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class LevelImportService {

    private final LevelRepository levelRepository;
    private final LevelTestCaseRepository testCaseRepository;
    private final ObjectMapper objectMapper;
    private final LevelsImportProperties props;

    public LevelImportService(
        LevelRepository levelRepository,
        LevelTestCaseRepository testCaseRepository,
        ObjectMapper objectMapper,
        LevelsImportProperties props) {
        this.levelRepository = levelRepository;
        this.testCaseRepository = testCaseRepository;
        this.objectMapper = objectMapper;
        this.props = props;
    }

    @Transactional
    public LevelImportModels.ImportReport importAll() throws IOException {
        if (!props.isEnabled()) {
            return new LevelImportModels.ImportReport(0, 0, List.of("levels.import.enabled=false"));
        }

        Path dir = Paths.get(props.getDir()).toAbsolutePath().normalize();
        if (!Files.exists(dir) || !Files.isDirectory(dir)) {
            throw new IllegalStateException("levels dir not found: " + dir);
        }

        List<Path> files;
        try (var s = Files.list(dir)) {
            files = s.filter(p -> p.getFileName().toString().toLowerCase(Locale.ROOT).endsWith(".json"))
                    .sorted(Comparator.comparing(p -> p.getFileName().toString()))
                    .toList();
        }

        if (files.isEmpty()) {
            throw new IllegalStateException("No level json files found in: " + dir);
        }

        Set<String> importedCodes = new HashSet<>();
        List<String> warnings = new ArrayList<>();
        int importedOrUpdated = 0;

        for (Path file : files) {
            String content = Files.readString(file, StandardCharsets.UTF_8);
            LevelImportModels.LevelFile lf = objectMapper.readValue(content, LevelImportModels.LevelFile.class);

            validate(lf, file.toString());

            if (!importedCodes.add(lf.code())) {
                throw new IllegalArgumentException("Duplicate level code in directory: " + lf.code());
            }

            upsert(lf);
            importedOrUpdated++;
        }

        int deleted = 0;
        if (props.isDeleteMissing()) {
            for (LevelEntity level : levelRepository.findAll()) {
                if (!importedCodes.contains(level.getCode())) {
                    levelRepository.delete(level);
                    deleted++;
                }
            }
        }

        return new LevelImportModels.ImportReport(importedOrUpdated, deleted, warnings);
    }

    private void upsert(LevelImportModels.LevelFile lf) {
        // ⚠️ 不要用 findDetailByCode（它 join fetch 多个集合时，会把 List(bag) 装配出重复元素）
        Optional<LevelEntity> existingOpt = levelRepository.findById(lf.code());

        LevelEntity level = existingOpt.orElseGet(() -> {
            LevelEntity n = new LevelEntity();
            n.setCode(lf.code());
            return n;
        });

        // --- Level 基本字段：存在则更新，不存在则新增 ---
        level.setTitle(lf.title());
        level.setDescription(lf.description());
        JsonNode tempc = lf.templateCircuit();
        JsonNode devices = lf.devices();

        level.setDevices(devices == null ? null : devices.toString());

        if (tempc == null && devices != null && !devices.isNull()) {
            var obj = objectMapper.createObjectNode();
            obj.set("devices", devices);
            obj.putArray("connectors");
            obj.set("subcircuits", objectMapper.createObjectNode());
            tempc = obj;
        }
        level.setTemplateCircuitJson(tempc == null ? null : tempc.toString());

        // ElementCollection：保留集合实例，clear 再 add
        level.getAllowedComponents().clear();
        if (lf.allowedComponents() != null) {
            level.getAllowedComponents().addAll(lf.allowedComponents());
        }

        level.getKpIds().clear();
        if (lf.kpIds() != null) {
            level.getKpIds().addAll(lf.kpIds());
        }

        // --- TestCases：按 (level_code, order_index) 合并/更新 ---
        Map<Integer, LevelTestCaseEntity> existingCasesByOrder = new HashMap<>();
        for (LevelTestCaseEntity tc : level.getTestCases()) {
            Integer oi = tc.getOrderIndex();
            if (oi == null) continue;

            LevelTestCaseEntity prev = existingCasesByOrder.put(oi, tc);
            if (prev != null) {
                throw new IllegalStateException("Corrupted DB: duplicate testCase.orderIndex=" + oi
                        + " for level=" + lf.code());
            }
        }

        List<LevelImportModels.TestCase> sortedCases = new ArrayList<>(lf.testCases());
        sortedCases.sort(Comparator.comparing(LevelImportModels.TestCase::orderIndex));

        for (LevelImportModels.TestCase tcFile : sortedCases) {
            Integer orderIndex = tcFile.orderIndex();

            LevelTestCaseEntity tc = existingCasesByOrder.get(orderIndex);
            if (tc == null) {
                tc = new LevelTestCaseEntity();
                tc.setOrderIndex(orderIndex);
                level.addTestCase(tc);
                existingCasesByOrder.put(orderIndex, tc);
            }

            tc.setName(tcFile.name());

            // --- Steps：按 (test_case_id, step_index) 合并/更新 ---
            Map<Integer, LevelTestStepEntity> existingStepsByIndex = new HashMap<>();
            for (LevelTestStepEntity s : tc.getSteps()) {
                Integer si = s.getStepIndex();
                if (si == null) continue;

                LevelTestStepEntity prev = existingStepsByIndex.put(si, s);
                if (prev != null) {
                    throw new IllegalStateException("Corrupted DB: duplicate stepIndex=" + si
                            + " for level=" + lf.code() + ", testCase.orderIndex=" + orderIndex);
                }
            }

            List<LevelImportModels.TestStep> sortedSteps = new ArrayList<>(tcFile.steps());
            sortedSteps.sort(Comparator.comparing(LevelImportModels.TestStep::stepIndex));

            Set<Integer> incomingStepIndexes = new HashSet<>();

            for (LevelImportModels.TestStep sFile : sortedSteps) {
                Integer stepIndex = sFile.stepIndex();
                incomingStepIndexes.add(stepIndex);

                LevelTestStepEntity step = existingStepsByIndex.get(stepIndex);
                if (step == null) {
                    step = new LevelTestStepEntity();
                    step.setStepIndex(stepIndex);
                    tc.addStep(step);
                    existingStepsByIndex.put(stepIndex, step);
                }

                step.setInputsJson(sFile.inputs().toString());
                step.setExpectedJson(sFile.expected().toString());
            }

            tc.getSteps().removeIf(s ->
                    s.getStepIndex() != null && !incomingStepIndexes.contains(s.getStepIndex())
            );
        }

        levelRepository.save(level);
    }

    private void validate(LevelImportModels.LevelFile lf, String source) {
        if (lf == null) throw new IllegalArgumentException("Empty json: " + source);

        if (lf.code() == null || lf.code().isBlank()) {
            throw new IllegalArgumentException("code missing: " + source);
        }
        if (lf.title() == null || lf.title().isBlank()) {
            throw new IllegalArgumentException("title missing: " + source);
        }
        if (lf.testCases() == null || lf.testCases().isEmpty()) {
            throw new IllegalArgumentException("testCases empty: " + source);
        }
        if (lf.templateCircuit() == null && lf.devices() == null) {
            throw new IllegalArgumentException("templateCircuit or devices missing: " + source);
        }
        if (lf.devices() != null && !lf.devices().isObject()) {
            throw new IllegalArgumentException("devices must be a JSON object: " + source);
        }

        // testCase orderIndex 唯一
        var dupCaseOrder = lf.testCases().stream()
                .collect(Collectors.groupingBy(LevelImportModels.TestCase::orderIndex, Collectors.counting()))
                .entrySet().stream()
                .filter(e -> e.getKey() == null || e.getValue() > 1)
                .map(Map.Entry::getKey)
                .toList();
        if (!dupCaseOrder.isEmpty()) {
            throw new IllegalArgumentException("Invalid/duplicate testCase.orderIndex " + dupCaseOrder + " in " + source);
        }

        for (LevelImportModels.TestCase tc : lf.testCases()) {
            if (tc.steps() == null || tc.steps().isEmpty()) {
                throw new IllegalArgumentException("testCase.steps empty (orderIndex=" + tc.orderIndex() + "): " + source);
            }

            // stepIndex 唯一且非空
            var dupStepIndex = tc.steps().stream()
                    .collect(Collectors.groupingBy(LevelImportModels.TestStep::stepIndex, Collectors.counting()))
                    .entrySet().stream()
                    .filter(e -> e.getKey() == null || e.getValue() > 1)
                    .map(Map.Entry::getKey)
                    .toList();
            if (!dupStepIndex.isEmpty()) {
                throw new IllegalArgumentException("Invalid/duplicate stepIndex " + dupStepIndex
                        + " (testCase.orderIndex=" + tc.orderIndex() + ") in " + source);
            }

            for (LevelImportModels.TestStep step : tc.steps()) {
                requireObjectNode(step.inputs(), "inputs", source, tc.orderIndex(), step.stepIndex());
                requireObjectNode(step.expected(), "expected", source, tc.orderIndex(), step.stepIndex());
            }
        }
    }

    private void requireObjectNode(JsonNode node, String field, String source, Integer tcOrder, Integer stepIndex) {
        if (node == null || !node.isObject()) {
            throw new IllegalArgumentException(field + " must be a JSON object "
                    + "(testCase.orderIndex=" + tcOrder + ", stepIndex=" + stepIndex + "): " + source);
        }
    }
}