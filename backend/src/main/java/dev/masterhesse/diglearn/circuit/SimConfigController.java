package dev.masterhesse.diglearn.circuit;

import org.hibernate.mapping.Component;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import org.springframework.web.bind.annotation.RequestParam;


@RestController
public class SimConfigController {
    
    @GetMapping("/api/sim/component-policy")
    public ComponentPolicyResponse componentPolicy() {
        return new ComponentPolicyResponse(List.of("And", "Or", "Not"));
    }
    
    public record ComponentPolicyResponse(List<String> allowedComponents) {}
}
