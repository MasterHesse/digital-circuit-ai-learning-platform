package dev.masterhesse.diglearn.ai.application.profile;

import dev.masterhesse.diglearn.sim.persistence.LevelEntity;
import dev.masterhesse.diglearn.sim.persistence.LevelRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class SimPromptContextService {

    private final SimPracticeProfileService simPracticeProfileService;
    private final SimLevelRecommendationService simLevelRecommendationService;
    private final LevelRepository levelRepository;

    @Transactional(readOnly = true)
    public String buildCombinedPrompt(String userId, String levelCode) {
        List<String> sections = new ArrayList<>();

        String profilePrompt = buildProfilePrompt(userId);
        if (hasText(profilePrompt)) {
            sections.add(profilePrompt);
        }

        String recommendationPrompt = buildRecommendationPrompt(userId, 3);
        if (hasText(recommendationPrompt)) {
            sections.add(recommendationPrompt);
        }

        String levelExplainPrompt = buildLevelExplainPrompt(levelCode);
        if (hasText(levelExplainPrompt)) {
            sections.add(levelExplainPrompt);
        }

        if (sections.isEmpty()) {
            return null;
        }

        sections.add("""
                
                - 如果用户要推荐仿真关卡，优先依据：未通关、知识点衔接、练习较少的知识点。
                - 如果用户要解释某一关卡，重点解释题意、元器件作用、解题思路、调试方法。
                - 不要直接泄露隐藏测试用例、expected_json、判题细节或完整标准答案。
                - 推荐时优先给出 2-3 个候选，并说明为什么适合当前用户。
                """);

        return String.join("\n\n", sections);
    }

    @Transactional(readOnly = true)
    public String buildProfilePrompt(String userId) {
        if (!hasText(userId)) {
            return null;
        }

        SimPracticeProfile p = simPracticeProfileService.buildProfile(userId);
        if (p.passedLevelCount() == 0) {
            return """
                    
                    - 暂无通关记录。
                    - 如果用户询问从哪里开始，可优先推荐最基础、最靠前的关卡。
                    """;
        }

        StringBuilder sb = new StringBuilder();
        sb.append("\n");
        sb.append("- 已通关关卡数：").append(p.passedLevelCount()).append("\n");
        sb.append("- 累计通关次数：").append(p.totalPassCount()).append("\n");

        if (hasText(p.mostRecentlyPassedLevelCode())) {
            sb.append("- 最近通关关卡：").append(p.mostRecentlyPassedLevelCode());
            if (p.mostRecentlyPassedAt() != null) {
                sb.append("（").append(p.mostRecentlyPassedAt()).append("）");
            }
            sb.append("\n");
        }

        if (!p.strongTopics().isEmpty()) {
            sb.append("- 较强知识点：");
            sb.append(String.join("；", p.strongTopics().stream()
                    .map(x -> x.topic() + "(关卡" + x.uniquePassedLevels() + "，通关" + x.totalPassCount() + "次)")
                    .toList()));
            sb.append("\n");
        }

        if (!p.weakTopics().isEmpty()) {
            sb.append("- 练习较少知识点：");
            sb.append(String.join("；", p.weakTopics().stream()
                    .map(x -> x.topic() + "(关卡" + x.uniquePassedLevels() + "，通关" + x.totalPassCount() + "次)")
                    .toList()));
            sb.append("\n");
        }

        if (!p.recentlyPassedLevels().isEmpty()) {
            sb.append("- 最近完成关卡：");
            sb.append(String.join(", ", p.recentlyPassedLevels()));
            sb.append("\n");
        }

        return sb.toString().trim();
    }

    @Transactional(readOnly = true)
    public String buildRecommendationPrompt(String userId, int limit) {
        if (!hasText(userId)) {
            return null;
        }

        List<RecommendedSimLevel> recs = simLevelRecommendationService.recommend(userId, limit);
        if (recs.isEmpty()) {
            return """
                    
                    - 当前没有可推荐的未通关关卡。
                    """;
        }

        StringBuilder sb = new StringBuilder();
        sb.append("\n");

        int i = 1;
        for (RecommendedSimLevel rec : recs) {
            sb.append(i++)
                    .append(". ")
                    .append(rec.levelCode())
                    .append(" - ")
                    .append(rec.title());

            if (hasText(rec.reason())) {
                sb.append("：").append(rec.reason());
            }
            sb.append("\n");
        }

        return sb.toString().trim();
    }

    @Transactional(readOnly = true)
    public String buildLevelExplainPrompt(String levelCode) {
        if (!hasText(levelCode)) {
            return null;
        }

        Optional<LevelEntity> opt = levelRepository.findDetailByCode(levelCode.trim());
        if (opt.isEmpty()) {
            return null;
        }

        LevelEntity level = opt.get();

        StringBuilder sb = new StringBuilder();
        sb.append("\n");
        sb.append("- 关卡编号：").append(nullToDash(level.getCode())).append("\n");
        sb.append("- 关卡标题：").append(nullToDash(level.getTitle())).append("\n");
        sb.append("- 关卡描述：").append(nullToDash(level.getDescription())).append("\n");
        sb.append("- 允许元件：").append(joinOrDash(level.getAllowedComponents())).append("\n");
        sb.append("- 是否允许环路：").append(level.isAllowCycles() ? "是" : "否").append("\n");
        sb.append("- 关联知识点：").append(joinOrDash(level.getKpIds())).append("\n");
        sb.append("- 是否带模板电路：").append(hasText(level.getTemplateCircuitJson()) ? "是" : "否").append("\n");
        sb.append("- 是否带设备配置：").append(hasText(level.getDevices()) ? "是" : "否").append("\n");
        sb.append("- 讲解时请重点帮助用户理解题意、输入输出关系、解题思路和调试方法。");

        return sb.toString().trim();
    }

    private String joinOrDash(Collection<String> items) {
        if (items == null || items.isEmpty()) return "-";
        List<String> out = new ArrayList<>();
        for (String s : items) {
            if (s == null) continue;
            String t = s.trim();
            if (!t.isBlank()) {
                out.add(t);
            }
        }
        return out.isEmpty() ? "-" : String.join(", ", out);
    }

    private String nullToDash(String s) {
        return hasText(s) ? s.trim() : "-";
    }

    private boolean hasText(String s) {
        return s != null && !s.isBlank();
    }
}