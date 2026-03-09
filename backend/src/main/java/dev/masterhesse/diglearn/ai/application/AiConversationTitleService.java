package dev.masterhesse.diglearn.ai.application;

import dev.masterhesse.diglearn.ai.provider.LlmAnswer;
import dev.masterhesse.diglearn.ai.provider.LlmChatOptions;
import dev.masterhesse.diglearn.ai.provider.LlmGateway;
import dev.masterhesse.diglearn.ai.provider.LlmPrompt;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Locale;

@Service
@RequiredArgsConstructor
public class AiConversationTitleService {

    private final LlmGateway llmGateway;

    public String maybeGenerateTitle(String currentTitle, String firstUserMessage, String scene, String preferredModel) {
        if (isUserVisibleTitleReady(currentTitle)) {
            return currentTitle;
        }
        return generateTitle(firstUserMessage, scene, preferredModel);
    }

    public String generateTitle(String firstUserMessage, String scene, String preferredModel) {
        String normalized = normalize(firstUserMessage);

        if (normalized.isBlank()) {
            return truncate(defaultTitle(scene), 24);
        }

        String ruleTitle = ruleBasedTitle(normalized, scene);

        // 简短消息直接走规则，减少一次模型调用
        if (normalized.length() <= 16 && isGoodEnough(ruleTitle)) {
            return truncate(ruleTitle, 24);
        }

        try {
            String llmTitle = llmGenerateTitle(normalized, preferredModel);
            String cleaned = cleanupTitle(llmTitle);
            if (isGoodEnough(cleaned)) {
                return truncate(cleaned, 24);
            }
        } catch (Exception ignored) {
            // fail-safe: 回退到规则标题
        }

        if (isGoodEnough(ruleTitle)) {
            return truncate(ruleTitle, 24);
        }

        return truncate(defaultTitle(scene), 24);
    }

    private String llmGenerateTitle(String userMessage, String preferredModel) {
        String system = """
                你是“会话标题生成器”。
                请根据用户的首条消息，生成一个简短、准确、自然的中文标题。

                要求：
                1. 只输出标题，不要解释
                2. 不要带引号、书名号、编号
                3. 长度尽量控制在 8-18 个汉字
                4. 如果是学习辅导，突出知识点或任务目标
                5. 如果是仿真关卡问题，突出关卡主题或题型
                6. 如果用户是在求推荐，标题尽量突出“推荐对象”
                """;

        String user = "用户首条消息：\n" + userMessage;

        LlmAnswer answer = llmGateway.chat(
                new LlmPrompt(system, user),
                new LlmChatOptions(preferredModel, false, 0.2, 48)
        );

        return answer == null ? null : answer.content();
    }

    private String ruleBasedTitle(String text, String scene) {
        if (text == null || text.isBlank()) {
            return defaultTitle(scene);
        }

        String s = text
                .replace("\r\n", "\n")
                .replace('\n', ' ')
                .replaceAll("\\s+", " ")
                .trim();

        s = s.replaceAll("^(请问|帮我|麻烦你|请帮我|可以帮我|能不能帮我)\\s*", "");
        s = s.replaceAll("^(解释一下|讲解一下|分析一下|总结一下|看看|分析|推荐一下|推荐)\\s*", "");
        s = s.replaceAll("[？?。.，,!！；;：:]+$", "").trim();

        if (s.isBlank()) {
            return defaultTitle(scene);
        }

        if (s.length() <= 16) {
            return s;
        }

        String[] keywords = {
                "组合逻辑", "时序逻辑", "触发器", "寄存器", "多路选择器", "译码器", "编码器",
                "状态机", "卡诺图", "真值表", "仿真", "关卡", "推荐", "复习", "学习计划",
                "与门", "或门", "非门", "加法器", "计数器", "电路"
        };

        for (String keyword : keywords) {
            if (s.contains(keyword)) {
                if (s.contains("推荐")) return keyword + "推荐";
                if (s.contains("解释") || s.contains("讲解")) return keyword + "讲解";
                if (s.contains("怎么做") || s.contains("思路")) return keyword + "解题思路";
                return keyword + "相关问题";
            }
        }

        return truncate(s, 16);
    }

    private String cleanupTitle(String text) {
        if (text == null) return null;

        String s = text.trim();
        s = s.replaceAll("^标题[:：]\\s*", "");
        s = s.replaceAll("^[\"“”'‘’《》【】]+", "");
        s = s.replaceAll("[\"“”'‘’《》【】]+$", "");
        s = s.replaceAll("^\\d+[.、]\\s*", "");
        s = s.replaceAll("\\s+", " ").trim();

        return s;
    }

    private boolean isUserVisibleTitleReady(String title) {
        if (title == null || title.isBlank()) return false;

        String s = title.trim();
        return !s.equals("新会话")
                && !s.equals("新对话")
                && !s.equals("学习问答");
    }

    private boolean isGoodEnough(String title) {
        return title != null && !title.isBlank() && title.trim().length() >= 4;
    }

    private String normalize(String s) {
        if (s == null) return "";
        return s.trim();
    }

    private String truncate(String s, int max) {
        if (s == null) return "";
        if (s.length() <= max) return s;
        return s.substring(0, max).trim();
    }

    private String defaultTitle(String scene) {
        if (scene == null || scene.isBlank()) {
            return "学习问答";
        }

        String key = scene.trim().toUpperCase(Locale.ROOT);
        return switch (key) {
            case "QUESTION_EXPLAIN" -> "题目讲解";
            case "RECOMMENDATION_EXPLAIN" -> "推荐解读";
            case "SIM_LEVEL_EXPLAIN" -> "仿真关卡讲解";
            case "SIM_LEVEL_RECOMMEND" -> "仿真关卡推荐";
            default -> "学习问答";
        };
    }
}