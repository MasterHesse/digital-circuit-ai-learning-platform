package dev.masterhesse.diglearn.judge;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;
import java.util.Map;

@JsonIgnoreProperties(ignoreUnknown = true)
public record CircuitSpec(
        Map<String, DeviceSpec> devices,
        List<ConnectorSpec> connectors
) {
    @JsonIgnoreProperties(ignoreUnknown = true)
    public record DeviceSpec(
            String type,
            Integer inputs,
            Integer bits,
            String label
    ) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record ConnectorSpec(Endpoint from, Endpoint to) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Endpoint(String id, String port) {}
}