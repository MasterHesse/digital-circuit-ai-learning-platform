// File: IterativeBooleanJudgeEvaluator.java
package dev.masterhesse.diglearn.sim.judge;

import java.util.*;

public final class IterativeBooleanJudgeEvaluator {

    public Map<String, Integer> evaluateStep(CircuitSpec c,
                                            Map<String, Integer> buttonInputs,
                                            Map<String, Integer> prevStateOrNull) {
        Objects.requireNonNull(c, "circuit");
        Objects.requireNonNull(buttonInputs, "buttonInputs");

        // destId -> (inX -> srcId)
        Map<String, Map<String, String>> inSrc = new HashMap<>();
        for (String id : c.devices().keySet()) inSrc.put(id, new HashMap<>());
        for (CircuitSpec.ConnectorSpec k : c.connectors()) {
            inSrc.get(k.to().id()).put(k.to().port(), k.from().id());
        }

        // 确定性顺序（避免迭代在不同 JVM/HashMap 顺序下出现差异）
        List<String> ids = new ArrayList<>(c.devices().keySet());
        Collections.sort(ids);

        // 初值：上一 step 的稳定态；若没有则全 0
        Map<String, Integer> cur = new HashMap<>();
        for (String id : ids) cur.put(id, 0);
        if (prevStateOrNull != null) {
            for (String id : ids) {
                Integer v = prevStateOrNull.get(id);
                if (v != null) cur.put(id, require01(v, "prevState." + id));
            }
        }

        // Buttons 在整个 step 内固定
        for (String id : ids) {
            CircuitSpec.DeviceSpec d = c.devices().get(id);
            if ("Button".equals(d.type())) {
                cur.put(id, require01(buttonInputs.get(id), "inputs_json." + id));
            }
        }

        int maxIter = Math.max(50, ids.size() * 20);
        Set<String> seen = new HashSet<>();

        for (int iter = 0; iter < maxIter; iter++) {
            String sig = signature(ids, cur);
            if (!seen.add(sig)) {
                throw new IllegalArgumentException("circuit did not converge (oscillation detected)");
            }

            Map<String, Integer> next = new HashMap<>(cur);

            for (String id : ids) {
                CircuitSpec.DeviceSpec d = c.devices().get(id);
                String type = d.type();

                switch (type) {
                    case "Button" -> { /* fixed */ }

                    case "Lamp" -> next.put(id, readIn(id, "in1", inSrc, cur));

                    case "Repeater" -> next.put(id, readIn(id, "in1", inSrc, cur)); // ✅ 最小语义：缓冲器

                    case "Not" -> {
                        int x = readIn(id, "in1", inSrc, cur);
                        next.put(id, x == 0 ? 1 : 0);
                    }

                    case "And" -> next.put(id, fold(id, d.inputs(), inSrc, cur, 1, (a, b) -> a & b));
                    case "Or"  -> next.put(id, fold(id, d.inputs(), inSrc, cur, 0, (a, b) -> a | b));

                    case "Nand" -> {
                        int v = fold(id, d.inputs(), inSrc, cur, 1, (a, b) -> a & b);
                        next.put(id, v == 0 ? 1 : 0);
                    }
                    case "Nor" -> {
                        int v = fold(id, d.inputs(), inSrc, cur, 0, (a, b) -> a | b);
                        next.put(id, v == 0 ? 1 : 0);
                    }
                    case "Xor" -> next.put(id, fold(id, d.inputs(), inSrc, cur, 0, (a, b) -> a ^ b));
                    case "Xnor" -> {
                        int v = fold(id, d.inputs(), inSrc, cur, 0, (a, b) -> a ^ b);
                        next.put(id, v == 0 ? 1 : 0);
                    }

                    default -> throw new IllegalArgumentException("unsupported device type: " + type + " (deviceId=" + id + ")");
                }
            }

            if (next.equals(cur)) return next; // ✅ 收敛到稳定态
            cur = next;
        }

        throw new IllegalArgumentException("circuit did not converge within " + maxIter + " iterations");
    }

    private interface IntOp { int apply(int a, int b); }

    private int fold(String id, Integer inputs,
                     Map<String, Map<String, String>> inSrc,
                     Map<String, Integer> cur,
                     int init, IntOp op) {
        int n = (inputs == null ? 2 : inputs);
        int acc = init;
        for (int i = 1; i <= n; i++) {
            acc = op.apply(acc, readIn(id, "in" + i, inSrc, cur));
        }
        return acc;
    }

    private int readIn(String deviceId, String port,
                       Map<String, Map<String, String>> inSrc,
                       Map<String, Integer> cur) {
        String src = inSrc.get(deviceId).get(port);
        if (src == null) throw new IllegalArgumentException("missing wire for " + deviceId + "." + port);
        Integer v = cur.get(src);
        if (v == null) throw new IllegalArgumentException("upstream not available for " + deviceId + "." + port + " from " + src);
        return require01(v, "wire:" + src + "->" + deviceId + "." + port);
    }

    private int require01(Integer v, String where) {
        if (v == null || (v != 0 && v != 1)) {
            throw new IllegalArgumentException("value must be 0/1 at " + where + " (got " + v + ")");
        }
        return v;
    }

    private String signature(List<String> ids, Map<String, Integer> cur) {
        StringBuilder sb = new StringBuilder(ids.size());
        for (String id : ids) sb.append(cur.getOrDefault(id, 0));
        return sb.toString();
    }
}