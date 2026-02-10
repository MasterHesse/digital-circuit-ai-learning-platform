package dev.masterhesse.diglearn.user;

import jakarta.validation.constraints.NotBlank;

public final class UserApiModels {
    private UserApiModels() {}

    public record UserCreateRequest(
            String userId,      // 可选；不传则后端生成 UUID
            @NotBlank String name
    ) {}

    public record UserResponse(String userId, String name) {}
}