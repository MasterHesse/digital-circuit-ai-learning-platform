package dev.masterhesse.diglearn.sim.judge;

import java.util.*;

public final class SimpleBooleanJudgeEvaluator {

    public Map<String, Integer> evaluateAll(CircuitSpec c, Map<String, Integer> buttonInputs) {
        Objects.requireNonNull(c, "circuit");
        Objects.requireNonNull(buttonInputs, "buttonInputs");

        // destId -> (inX -> srcId)
        Map<String, Map<String, String>> inSrc = new HashMap<>();
        for (String id : c.devices().keySet()) inSrc.put(id, new HashMap<>());
        for (CircuitSpec.ConnectorSpec k : c.connectors()) {
            inSrc.get(k.to().id()).put(k.to().port(), k.from().id());
        }

        List<String> order = topoOrder(c);

        Map<String, Integer> out = new HashMap<>();
        for (String id : order) {
            CircuitSpec.DeviceSpec d = c.devices().get(id);
            String type = d.type();

            switch (type) {
                case "Button" -> out.put(id, require01(buttonInputs.get(id), "inputs_json." + id));
                case "Lamp" -> out.put(id, readIn(id, "in1", inSrc, out));
                case "Not" -> {
                    int x = readIn(id, "in1", inSrc, out);
                    out.put(id, x == 0 ? 1 : 0);
                }
                case "And" -> out.put(id, fold(id, d.inputs(), inSrc, out, 1, (a, b) -> a & b));
                case "Or" -> out.put(id, fold(id, d.inputs(), inSrc, out, 0, (a, b) -> a | b));
                case "Nand" -> {
                    int v = fold(id, d.inputs(), inSrc, out, 1, (a, b) -> a & b);
                    out.put(id, v == 0 ? 1 : 0);
                }
                case "Nor" -> {
                    int v = fold(id, d.inputs(), inSrc, out, 0, (a, b) -> a | b);
                    out.put(id, v == 0 ? 1 : 0);
                }
                case "Xor" -> out.put(id, fold(id, d.inputs(), inSrc, out, 0, (a, b) -> a ^ b));
                case "Xnor" -> {
                    int v = fold(id, d.inputs(), inSrc, out, 0, (a, b) -> a ^ b);
                    out.put(id, v == 0 ? 1 : 0);
                }
                default -> throw new IllegalArgumentException("unsupported device type: " + type + " (deviceId=" + id + ")");
            }
        }
        return out;
    }

    private interface IntOp { int apply(int a, int b); }

    private int fold(String id, Integer inputs,
                     Map<String, Map<String, String>> inSrc, Map<String, Integer> out,
                     int init, IntOp op) {
        int n = (inputs == null ? 2 : inputs);
        int acc = init;
        for (int i = 1; i <= n; i++) {
            acc = op.apply(acc, readIn(id, "in" + i, inSrc, out));
        }
        return acc;
    }

    private int readIn(String deviceId, String port,
                       Map<String, Map<String, String>> inSrc,
                       Map<String, Integer> out) {
        String src = inSrc.get(deviceId).get(port);
        if (src == null) throw new IllegalArgumentException("missing wire for " + deviceId + "." + port);
        Integer v = out.get(src);
        if (v == null) throw new IllegalArgumentException("upstream not computed for " + deviceId + "." + port + " from " + src);
        return v;
    }

    private List<String> topoOrder(CircuitSpec c) {
        Map<String, Integer> indeg = new HashMap<>();
        Map<String, List<String>> g = new HashMap<>();
        for (String id : c.devices().keySet()) {
            indeg.put(id, 0);
            g.put(id, new ArrayList<>());
        }
        for (CircuitSpec.ConnectorSpec k : c.connectors()) {
            String u = k.from().id();
            String v = k.to().id();
            if (!u.equals(v)) {
                g.get(u).add(v);
                indeg.put(v, indeg.get(v) + 1);
            }
        }
        ArrayDeque<String> q = new ArrayDeque<>();
        for (var e : indeg.entrySet()) if (e.getValue() == 0) q.add(e.getKey());

        List<String> order = new ArrayList<>();
        while (!q.isEmpty()) {
            String u = q.removeFirst();
            order.add(u);
            for (String v : g.get(u)) {
                indeg.put(v, indeg.get(v) - 1);
                if (indeg.get(v) == 0) q.add(v);
            }
        }
        if (order.size() != c.devices().size()) throw new IllegalArgumentException("cycle detected in circuit");
        return order;
    }

    private int require01(Integer v, String where) {
        if (v == null || (v != 0 && v != 1)) {
            throw new IllegalArgumentException("value must be 0/1 at " + where + " (got " + v + ")");
        }
        return v;
    }
}