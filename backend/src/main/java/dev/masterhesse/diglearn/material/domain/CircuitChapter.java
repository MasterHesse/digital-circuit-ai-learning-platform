package dev.masterhesse.diglearn.material.domain;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public enum CircuitChapter {
    FND("基础", 1),
    BOOL("布尔代数", 2),
    COMB("组合逻辑", 3),
    ARITH("算术逻辑", 4),
    SEQ("时序逻辑", 5),
    TIM("时序分析", 6),
    FSM("有限状态机", 7),
    MEM("存储系统", 8);

    private static final Pattern KP_ID_PATTERN = Pattern.compile("^DC-([A-Z]+)-\\d{2}$");

    private final String displayName;
    private final int sortOrder;

    CircuitChapter(String displayName, int sortOrder) {
        this.displayName = displayName;
        this.sortOrder = sortOrder;
    }

    public String getDisplayName() {
        return displayName;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public static List<CircuitChapter> orderedValues() {
        return List.of(values());
    }

    public static CircuitChapter fromKpId(String kpId) {
        if (kpId == null || kpId.isBlank()) {
            throw new IllegalArgumentException("kpId is blank");
        }

        Matcher matcher = KP_ID_PATTERN.matcher(kpId.trim());
        if (!matcher.matches()) {
            throw new IllegalArgumentException("Invalid kpId format: " + kpId);
        }

        return CircuitChapter.valueOf(matcher.group(1));
    }
}