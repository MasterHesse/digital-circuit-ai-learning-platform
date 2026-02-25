// dev.masterhesse.diglearn.auth.AuthController.java
package dev.masterhesse.diglearn.auth;

import dev.masterhesse.diglearn.user.persistence.AppUserEntity;
import dev.masterhesse.diglearn.user.persistence.AppUserRepository;
import dev.masterhesse.diglearn.user.persistence.TeacherRequestRepository;
import dev.masterhesse.diglearn.user.persistence.TeacherRequestStatus;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.authentication.*;
import org.springframework.security.core.*;
import org.springframework.security.core.context.*;
import org.springframework.security.web.authentication.rememberme.PersistentTokenBasedRememberMeServices;
import org.springframework.security.web.context.SecurityContextRepository;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;
    private final AuthenticationManager authenticationManager;
    private final SecurityContextRepository securityContextRepository;
    private final PersistentTokenBasedRememberMeServices rememberMeServices;

    // ✅ 为了区分：用户不存在/驳回 vs 密码错误 vs 审核中
    private final AppUserRepository userRepo;
    private final TeacherRequestRepository teacherRequestRepo;

    @GetMapping("/csrf")
    public CsrfToken csrf(CsrfToken token) {
        return token;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public AuthApiModels.MeResponse register(@Valid @RequestBody AuthApiModels.RegisterRequest req) {
        return authService.register(req);
    }

    private ResponseEntity<String> fail(
            HttpStatus status,
            String message,
            HttpServletRequest request,
            HttpServletResponse response
    ) {
        // 清理旧 remember-me cookie（如果有）
        rememberMeServices.loginFail(request, response);
        return ResponseEntity.status(status).contentType(MediaType.TEXT_PLAIN).body(message);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(
            @Valid @RequestBody AuthApiModels.LoginRequest req,
            HttpServletRequest request,
            HttpServletResponse response
    ) {
        // ① 预检查：用于你要的文案区分
        String key = AuthNormalization.normalizeLogin(req.login());
        AppUserEntity u = (key.contains("@") ? userRepo.findByEmail(key) : userRepo.findByUsername(key))
                .orElse(null);

        if (u == null) {
            // ✅ 401 -> “用户不存在/审核被驳回”
            return fail(HttpStatus.UNAUTHORIZED, "用户不存在/审核被驳回", request, response);
        }

        if (!u.isEnabled()) {
            // ✅ 423 -> “审核中”
            var st = teacherRequestRepo.findById(u.getUserId()).map(tr -> tr.getStatus()).orElse(null);
            if (st == TeacherRequestStatus.PENDING) {
                return fail(HttpStatus.LOCKED, "账号仍在审核中，请等待管理员审核通过后再登录", request, response);
            }
            return fail(HttpStatus.LOCKED, "账号已被禁用", request, response);
        }

        // ② 再做密码校验 + 写入 session（标准 Spring Security 流程）
        try {
            Authentication auth = authenticationManager.authenticate(
                    UsernamePasswordAuthenticationToken.unauthenticated(req.login(), req.password())
            );

            SecurityContext context = SecurityContextHolder.createEmptyContext();
            context.setAuthentication(auth);
            SecurityContextHolder.setContext(context);
            securityContextRepository.saveContext(context, request, response);

            if (req.rememberMe()) {
                rememberMeServices.loginSuccess(request, response, auth);
            } else {
                rememberMeServices.loginFail(request, response);
            }

            UserPrincipal p = (UserPrincipal) auth.getPrincipal();
            return ResponseEntity.ok(new AuthApiModels.MeResponse(
                    p.userId(), p.username(), p.email(), p.name(), p.role().name()
            ));
        } catch (BadCredentialsException ex) {
            // ✅ 401 -> “密码错误”
            return fail(HttpStatus.UNAUTHORIZED, "密码错误", request, response);
        } catch (DisabledException ex) {
            // 兜底（理论上被 enabled 预检查拦住）
            return fail(HttpStatus.LOCKED, "账号仍在审核中，请等待管理员审核通过后再登录", request, response);
        } catch (AuthenticationException ex) {
            return fail(HttpStatus.UNAUTHORIZED, "登录失败", request, response);
        }
    }

    @GetMapping("/me")
    public AuthApiModels.MeResponse me(Authentication auth) {
        if (auth == null || !(auth.getPrincipal() instanceof UserPrincipal p)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "not logged in");
        }
        return new AuthApiModels.MeResponse(p.userId(), p.username(), p.email(), p.name(), p.role().name());
    }
}