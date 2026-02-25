package dev.masterhesse.diglearn.auth;

import java.util.Locale;

public final class AuthNormalization {
    private AuthNormalization() {}

    public static String normalizeLogin(String raw) {
        String s = raw == null ? "" : raw.trim();
        if (s.startsWith("@")) s = s.substring(1);
        return s.toLowerCase(Locale.ROOT);
    }

    public static String normalizeUsername(String raw) {
        String u = raw == null ? "" : raw.trim();
        if (u.startsWith("@")) u = u.substring(1);
        return u.toLowerCase(Locale.ROOT);
    }

    public static String normalizeEmail(String raw) {
        return raw == null ? "" : raw.trim().toLowerCase(Locale.ROOT);
    }
}