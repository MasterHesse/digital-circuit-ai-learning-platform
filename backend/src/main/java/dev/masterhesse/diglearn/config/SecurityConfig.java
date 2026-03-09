package dev.masterhesse.diglearn.config;

import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.*;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.*;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.factory.PasswordEncoderFactories;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.*;
import org.springframework.security.web.authentication.rememberme.*;
import org.springframework.security.web.context.*;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
import org.springframework.security.web.csrf.CsrfTokenRequestAttributeHandler;
import org.springframework.web.cors.*;

import javax.sql.DataSource;
import java.util.List;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {

  private static final String REMEMBER_ME_KEY = "diglearn-remember-me-key-change-me";
  private static final int REMEMBER_ME_30_DAYS = 30 * 24 * 60 * 60;

  @Bean
  PasswordEncoder passwordEncoder() {
    return PasswordEncoderFactories.createDelegatingPasswordEncoder(); // 默认 bcrypt
  }

  @Bean
  AuthenticationManager authenticationManager(AuthenticationConfiguration cfg) throws Exception {
    return cfg.getAuthenticationManager();
  }

  @Bean
  SecurityContextRepository securityContextRepository() {
    return new HttpSessionSecurityContextRepository();
  }

  @Bean
  PersistentTokenRepository persistentTokenRepository(DataSource dataSource) {
    JdbcTokenRepositoryImpl repo = new JdbcTokenRepositoryImpl();
    repo.setDataSource(dataSource);
    repo.setCreateTableOnStartup(false); // 第一次启动建 persistent_logins 表；建好后建议改回 false
    return repo;
  }

  @Bean
  PersistentTokenBasedRememberMeServices rememberMeServices(
      org.springframework.security.core.userdetails.UserDetailsService userDetailsService,
      PersistentTokenRepository tokenRepository
  ) {
    PersistentTokenBasedRememberMeServices services =
        new PersistentTokenBasedRememberMeServices(REMEMBER_ME_KEY, userDetailsService, tokenRepository);

    services.setTokenValiditySeconds(REMEMBER_ME_30_DAYS);
    services.setCookieName("diglearn_remember_me");
    services.setParameter("rememberMe");
    return services;
  }

  @Bean
  CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration cfg = new CorsConfiguration();
    cfg.setAllowedOrigins(List.of("http://localhost:5173")); // 如需 127.0.0.1 也加上
    cfg.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
    cfg.setAllowedHeaders(List.of("Accept", "Content-Type", "X-XSRF-TOKEN", "X-User-Id", "Authorization"));
    cfg.setAllowCredentials(true);

    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", cfg);
    return source;
  }

  @Bean
  SecurityFilterChain securityFilterChain(
      HttpSecurity http,
      CorsConfigurationSource corsConfigurationSource,
      PersistentTokenBasedRememberMeServices rememberMeServices
  ) throws Exception {

    CsrfTokenRequestAttributeHandler requestHandler = new CsrfTokenRequestAttributeHandler();

    return http
        .cors(cors -> cors.configurationSource(corsConfigurationSource))
        .csrf(csrf -> csrf
            .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
            .csrfTokenRequestHandler(requestHandler)
            .ignoringRequestMatchers("/api/ai/**")
            .ignoringRequestMatchers("/api/admin/materials/**")
            .ignoringRequestMatchers("/api/admin/ai/**")
        )
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/actuator/health").permitAll()
            .requestMatchers("/swagger-ui/**").permitAll()
            .requestMatchers("/v3/api-docs/**").permitAll()
            .requestMatchers(HttpMethod.GET, "/api/auth/csrf").permitAll()
            .requestMatchers(HttpMethod.POST, "/api/auth/register").permitAll()
            .requestMatchers(HttpMethod.POST, "/api/auth/login").permitAll()
            .requestMatchers("/api/ai/**").permitAll()
            .requestMatchers("/api/admin/materials/**").permitAll()
            .requestMatchers("/api/admin/ai/**").permitAll()
            .requestMatchers("/api/users/**").hasRole("ADMIN")
            .anyRequest().authenticated()
        )
        .httpBasic(basic -> basic.disable())
        .formLogin(form -> form.disable())
        .rememberMe(rm -> rm.rememberMeServices(rememberMeServices))
        .logout(logout -> logout
            .logoutUrl("/api/auth/logout")
            .deleteCookies("JSESSIONID", "diglearn_remember_me")
            .logoutSuccessHandler((req, res, auth) -> res.setStatus(HttpServletResponse.SC_NO_CONTENT))
        )
        .exceptionHandling(eh -> eh
            .authenticationEntryPoint((req, res, ex) -> res.sendError(HttpServletResponse.SC_UNAUTHORIZED))
            .accessDeniedHandler((req, res, ex) -> res.sendError(HttpServletResponse.SC_FORBIDDEN))
        )
        .build();
  }

}