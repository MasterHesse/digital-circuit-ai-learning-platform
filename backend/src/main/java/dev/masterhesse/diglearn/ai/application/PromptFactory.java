package dev.masterhesse.diglearn.ai.application;

import dev.masterhesse.diglearn.ai.api.AiApiModels;
import dev.masterhesse.diglearn.ai.domain.AiScene;
import dev.masterhesse.diglearn.ai.domain.RetrievedChunk;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.util.List;

@Component
public class PromptFactory {

    public String buildSystemPrompt(AiScene scene) {
        AiScene actualScene = scene == null ? AiScene.GENERAL_QA : scene;

        return switch (actualScene) {
            case GENERAL_QA -> """
                    你是 DigLearn 的数字电路学习助教。
                    你的任务是：
                    1. 用简洁、清楚、教学化的方式解释概念
                    2. 优先依据给定资料回答
                    3. 如果资料不足，要明确说明“不确定”或“当前资料不足”
                    4. 不要伪造来源
                    5. 不要直接泄露未作答题目的完整标准答案
                    6. 回答时尽量给出下一步学习建议
                    """;
            case QUESTION_EXPLAIN -> """
                    你是 DigLearn 的题目讲解助教。
                    请重点解释思路、相关知识点、易错点，不要直接给出过度完整的抄答案式回复。
                    """;
            case RECOMMENDATION_EXPLAIN -> """
                    你是 DigLearn 的学习规划助教。
                    请根据推荐内容说明为什么推荐、建议先学什么、下一步做什么。
                    """;
        };
    }

    public String buildUserPrompt(
            AiApiModels.AiChatRequest request,
            String learningContext,
            String conversationContext,
            List<RetrievedChunk> chunks
    ) {
        StringBuilder sb = new StringBuilder();

        sb.append("[当前问题]\n")
                .append(request.message().trim())
                .append("\n\n");

        if (StringUtils.hasText(learningContext)) {
            sb.append("[当前用户画像]\n")
                    .append(learningContext.trim())
                    .append("\n\n");
        }

        if (StringUtils.hasText(conversationContext)) {
            sb.append("[当前会话历史]\n")
                    .append(conversationContext.trim())
                    .append("\n\n");
        }

        sb.append("[教学资料]\n");
        if (chunks == null || chunks.isEmpty()) {
            sb.append("无\n\n");
        } else {
            for (int i = 0; i < chunks.size(); i++) {
                RetrievedChunk c = chunks.get(i);
                sb.append(i + 1)
                        .append(". [")
                        .append(c.sourceType())
                        .append("] ")
                        .append(c.title())
                        .append(" / ")
                        .append(c.sourceId())
                        .append("\n")
                        .append(c.text() == null ? "" : c.text())
                        .append("\n\n");
            }
        }

        sb.append("""
                [回答要求]
                1. 优先依据“教学资料”回答；
                2. 如果“会话历史”与“当前问题”冲突，以当前问题为准；
                3. 如果资料不足，请明确说明“当前资料不足”；
                4. 只有当问题涉及学习建议、学习路径、推荐内容、讲解深度调整时，才参考“用户画像”；
                5. 不要伪造用户学习记录；
                6. 输出尽量分点；
                7. 最后补一个“下一步建议”。
                """);

        return sb.toString();
    }
}