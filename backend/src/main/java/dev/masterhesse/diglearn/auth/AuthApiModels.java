package dev.masterhesse.diglearn.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public final class AuthApiModels {
    private AuthApiModels() {}

    public record RegisterRequest(
            @NotBlank String username,
            @NotBlank @Email String email,
            @NotBlank @Size(min = 8, max = 72) String password,
            String name,
            String desiredRole
    ) {}

    public record LoginRequest(
            @NotBlank String login, // username 或 email；也允许 @username
            @NotBlank @Size(max = 72) String password,
            boolean rememberMe
    ) {}

    public record MeResponse(
            String userId,
            String username,
            String email,
            String name,
            String role
    ) {}
}