package dev.masterhesse.diglearn.auth;

import dev.masterhesse.diglearn.user.persistence.AppUserEntity;
import dev.masterhesse.diglearn.user.persistence.AppUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AppUserDetailsService implements UserDetailsService {

    private final AppUserRepository repo;

    @Override
    public UserDetails loadUserByUsername(String login) throws UsernameNotFoundException {
        String key = AuthNormalization.normalizeLogin(login);

        AppUserEntity u = (key.contains("@") ? repo.findByEmail(key) : repo.findByUsername(key))
                .orElseThrow(() -> new UsernameNotFoundException("user not found"));

        return new UserPrincipal(
                u.getUserId(),
                u.getUsername(),
                u.getEmail(),
                u.getName(),
                u.getPasswordHash(),
                u.getRole(),
                u.isEnabled()
        );
    }
}