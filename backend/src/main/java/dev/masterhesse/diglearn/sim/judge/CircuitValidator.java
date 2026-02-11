package dev.masterhesse.diglearn.sim.judge;

import java.util.*;
import java.util.regex.Pattern;

public final class CircuitValidator {

    private static final Pattern IN_PORT = Pattern.compile("^in[1-9][0-9]*$");

    private CircuitValidator() {}

// CircuitValidator.java
    public static void validate(CircuitSpec c, Set<String> allowedComponents, boolean allowCycles) {
        if (c == null) throw bad("circuit is required");
        if (c.devices() == null || c.devices().isEmpty()) throw bad("circuit.devices is empty");
        if (c.connectors() == null) throw bad("circuit.connectors is required");

        // devices (原逻辑不变)
        for (var e : c.devices().entrySet()) {
            String id = e.getKey();
            CircuitSpec.DeviceSpec d = e.getValue();
            if (id == null || id.isBlank()) throw bad("device id is blank");
            if (d == null || d.type() == null || d.type().isBlank()) throw bad("device " + id + " has empty type");

            if (d.bits() != null && d.bits() != 1) {
                throw bad("only bits=1 supported (deviceId=" + id + ")");
            }

            if (allowedComponents != null && !allowedComponents.isEmpty() && !allowedComponents.contains(d.type())) {
                throw bad("device type not allowed: " + d.type() + " (deviceId=" + id + ")");
            }

            if (("And".equals(d.type()) || "Or".equals(d.type()) || "Nand".equals(d.type()) || "Nor".equals(d.type())
                    || "Xor".equals(d.type()) || "Xnor".equals(d.type()))
                    && d.inputs() != null && d.inputs() < 2) {
                throw bad(d.type() + ".inputs must be >= 2 (deviceId=" + id + ")");
            }
        }

        // connectors (原逻辑不变)
        Set<String> drivenPins = new HashSet<>();
        for (CircuitSpec.ConnectorSpec k : c.connectors()) {
            if (k == null || k.from() == null || k.to() == null) throw bad("connector has null endpoint");

            String fromId = k.from().id();
            String fromPort = k.from().port();
            String toId = k.to().id();
            String toPort = k.to().port();

            if (!c.devices().containsKey(fromId)) throw bad("connector.from.id not found: " + fromId);
            if (!c.devices().containsKey(toId)) throw bad("connector.to.id not found: " + toId);

            if (!"out".equals(fromPort)) {
                throw bad("only from.port=out is allowed (got: " + fromPort + ")");
            }

            if (toPort == null || !IN_PORT.matcher(toPort).matches()) {
                throw bad("invalid to.port: " + toPort + " (only in1..inN allowed)");
            }

            CircuitSpec.DeviceSpec dst = c.devices().get(toId);
            int maxIn = maxInputs(dst);
            int idx = Integer.parseInt(toPort.substring(2));
            if (idx > maxIn) {
                throw bad("input port out of range: " + toId + "." + toPort + " (max in" + maxIn + ")");
            }

            String pinKey = toId + "#" + toPort;
            if (!drivenPins.add(pinKey)) {
                throw bad("multiple wires drive the same input pin: " + pinKey);
            }
        }

        // ✅ 仅当不允许环时才检查
        if (!allowCycles) {
            if (hasCycle(c)) throw bad("cycle detected in circuit");
        }
    }

    // 保持旧签名兼容旧调用
    public static void validate(CircuitSpec c, Set<String> allowedComponents) {
        validate(c, allowedComponents, false);
    }

    private static int maxInputs(CircuitSpec.DeviceSpec d) {
        if (d == null || d.type() == null) return 0;
        return switch (d.type()) {
            case "Button" -> 0;
            case "Lamp", "Not", "Repeater" -> 1;
            case "And", "Or", "Nand", "Nor", "Xor", "Xnor" -> (d.inputs() == null ? 2 : d.inputs());
            default -> Integer.MAX_VALUE; // 其它类型若存在，先不在 validator 这里限制
        };
    }

    private static boolean hasCycle(CircuitSpec c) {
        Map<String, Integer> indeg = new HashMap<>();
        Map<String, List<String>> g = new HashMap<>();
        for (String id : c.devices().keySet()) {
            indeg.put(id, 0);
            g.put(id, new ArrayList<>());
        }
        for (CircuitSpec.ConnectorSpec k : c.connectors()) {
            String u = k.from().id();
            String v = k.to().id();
            if (u.equals(v)) return true;
            g.get(u).add(v);
            indeg.put(v, indeg.get(v) + 1);
        }
        ArrayDeque<String> q = new ArrayDeque<>();
        for (var e : indeg.entrySet()) if (e.getValue() == 0) q.add(e.getKey());

        int visited = 0;
        while (!q.isEmpty()) {
            String u = q.removeFirst();
            visited++;
            for (String v : g.get(u)) {
                indeg.put(v, indeg.get(v) - 1);
                if (indeg.get(v) == 0) q.add(v);
            }
        }
        return visited != c.devices().size();
    }

    private static IllegalArgumentException bad(String msg) {
        return new IllegalArgumentException(msg);
    }
}