package dev.masterhesse.diglearn.circuit.sim;

import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class SimpleBooleanCircuitEvaluator {

    public ParsedCircuit parse(JsonNode circuit) {
        if (circuit == null || circuit.isNull()) {
            throw new CircuitEvaluationException("circuit is null");
        }

        JsonNode devicesNode = circuit.get("devices");
        if (devicesNode == null || !devicesNode.isObject()) {
            throw new CircuitEvaluationException("circuit.devices missing or not an object");
        }

        Map<String, DeviceSpec> devices = new LinkedHashMap<>();
        devicesNode.fields().forEachRemaining(e -> {
            String id = e.getKey();
            JsonNode dn = e.getValue();

            String type = text(dn.get("type"));
            if (type == null || type.isBlank()) {
                throw new CircuitEvaluationException("device '" + id + "' missing type");
            }

            int bits = dn.hasNonNull("bits") ? dn.get("bits").asInt(1) : 1;
            if (bits != 1) {
                throw new CircuitEvaluationException("device '" + id + "' bits=" + bits + " not supported (only bits=1)");
            }

            int inputs;
            if ("And".equals(type) || "Or".equals(type)) {
                inputs = dn.hasNonNull("inputs") ? dn.get("inputs").asInt(2) : 2;
                if (inputs < 2) {
                    throw new CircuitEvaluationException("device '" + id + "' inputs must be >= 2");
                }
            } else if ("Not".equals(type) || "Lamp".equals(type)) {
                inputs = 1;
            } else if ("Button".equals(type)) {
                inputs = 0;
            } else {
                // 不认识的类型：先记录下来，真正用到时 evaluate 会报 unsupported
                inputs = dn.hasNonNull("inputs") ? dn.get("inputs").asInt(0) : 0;
            }

            devices.put(id, new DeviceSpec(id, type, bits, inputs));
        });

        Map<String, Map<String, IncomingWire>> incoming = new HashMap<>();

        JsonNode connectorsNode = circuit.get("connectors");
        if (connectorsNode != null && !connectorsNode.isNull()) {
            if (!connectorsNode.isArray()) {
                throw new CircuitEvaluationException("circuit.connectors must be an array");
            }

            for (JsonNode c : connectorsNode) {
                JsonNode from = c.get("from");
                JsonNode to = c.get("to");
                if (from == null || to == null) {
                    throw new CircuitEvaluationException("connector missing from/to");
                }

                String fromId = text(from.get("id"));
                String fromPort = text(from.get("port"));
                String toId = text(to.get("id"));
                String toPort = text(to.get("port"));

                if (fromId == null || toId == null) {
                    throw new CircuitEvaluationException("connector from.id/to.id required");
                }
                if (!devices.containsKey(fromId)) {
                    throw new CircuitEvaluationException("connector from.id not found: " + fromId);
                }
                if (!devices.containsKey(toId)) {
                    throw new CircuitEvaluationException("connector to.id not found: " + toId);
                }
                if (toPort == null || toPort.isBlank()) {
                    throw new CircuitEvaluationException("connector to.port required");
                }

                String canonicalToPort = canonicalizeInputPort(devices.get(toId).type(), toPort);

                incoming.computeIfAbsent(toId, k -> new HashMap<>());
                Map<String, IncomingWire> byPort = incoming.get(toId);

                if (byPort.containsKey(canonicalToPort)) {
                    throw new CircuitEvaluationException("multiple wires connected to " + toId + "." + canonicalToPort);
                }

                byPort.put(canonicalToPort, new IncomingWire(fromId, fromPort));
            }
        }

        return new ParsedCircuit(devices, incoming);
    }

    /** 只计算 outputsToRead 相关的子图（多余未连接器件不会导致失败） */
    public Map<String, Boolean> evaluateOutputs(
            ParsedCircuit circuit,
            Map<String, Boolean> buttonStates,
            Set<String> outputsToRead
    ) {
        Objects.requireNonNull(circuit, "circuit");
        Objects.requireNonNull(buttonStates, "buttonStates");
        Objects.requireNonNull(outputsToRead, "outputsToRead");

        Map<String, Boolean> cache = new HashMap<>();
        Set<String> visiting = new HashSet<>();

        Map<String, Boolean> out = new LinkedHashMap<>();
        for (String outId : outputsToRead) {
            if (!circuit.devices.containsKey(outId)) {
                throw new CircuitEvaluationException("expected output device not found: " + outId);
            }
            boolean v = evalDevice(outId, circuit, buttonStates, cache, visiting);
            out.put(outId, v);
        }
        return out;
    }

    private boolean evalDevice(
            String id,
            ParsedCircuit circuit,
            Map<String, Boolean> buttonStates,
            Map<String, Boolean> cache,
            Set<String> visiting
    ) {
        Boolean cached = cache.get(id);
        if (cached != null) return cached;

        if (!visiting.add(id)) {
            throw new CircuitEvaluationException("cycle detected at device: " + id);
        }

        DeviceSpec d = circuit.devices.get(id);
        if (d == null) throw new CircuitEvaluationException("device not found: " + id);

        boolean value;
        switch (d.type) {
            case "Button" -> value = buttonStates.getOrDefault(id, false);

            case "And" -> {
                value = true;
                for (int i = 1; i <= d.inputs; i++) {
                    String src = sourceForInput(id, "in" + i, circuit);
                    value &= evalDevice(src, circuit, buttonStates, cache, visiting);
                }
            }

            case "Or" -> {
                value = false;
                for (int i = 1; i <= d.inputs; i++) {
                    String src = sourceForInput(id, "in" + i, circuit);
                    value |= evalDevice(src, circuit, buttonStates, cache, visiting);
                }
            }

            case "Not" -> {
                String src = sourceForInput(id, "in", circuit);
                value = !evalDevice(src, circuit, buttonStates, cache, visiting);
            }

            case "Lamp" -> {
                String src = sourceForInput(id, "in", circuit);
                value = evalDevice(src, circuit, buttonStates, cache, visiting);
            }

            default -> throw new CircuitEvaluationException("unsupported device type: " + d.type + " (id=" + id + ")");
        }

        visiting.remove(id);
        cache.put(id, value);
        return value;
    }

    private String sourceForInput(String targetId, String inputPort, ParsedCircuit circuit) {
        Map<String, IncomingWire> byPort = circuit.incoming.get(targetId);
        if (byPort == null) {
            throw new CircuitEvaluationException("device " + targetId + " has no incoming wires (needed " + inputPort + ")");
        }
        IncomingWire wire = byPort.get(inputPort);
        if (wire == null) {
            throw new CircuitEvaluationException("missing wire for " + targetId + "." + inputPort);
        }
        return wire.fromId;
    }

    /** 兼容：Not/Lamp 支持 in 或 in1；And/Or 支持用 in 当作 in1 */
    private static String canonicalizeInputPort(String deviceType, String port) {
        if (port == null) return null;

        if ("Not".equals(deviceType) || "Lamp".equals(deviceType)) {
            if ("in1".equals(port)) return "in";
            if ("in".equals(port)) return "in";
        }
        if ("And".equals(deviceType) || "Or".equals(deviceType)) {
            if ("in".equals(port)) return "in1";
        }
        return port;
    }

    private static String text(JsonNode n) {
        if (n == null || n.isNull()) return null;
        return n.asText();
    }

    public static final class CircuitEvaluationException extends RuntimeException {
        public CircuitEvaluationException(String message) { super(message); }
    }

    public record ParsedCircuit(
            Map<String, DeviceSpec> devices,
            Map<String, Map<String, IncomingWire>> incoming
    ) {}

    public record DeviceSpec(String id, String type, int bits, int inputs) {}

    public record IncomingWire(String fromId, String fromPort) {}
}