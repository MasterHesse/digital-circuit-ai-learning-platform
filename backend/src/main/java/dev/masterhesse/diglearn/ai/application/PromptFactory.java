package dev.masterhesse.diglearn.ai.application;

import dev.masterhesse.diglearn.ai.api.AiApiModels;
import dev.masterhesse.diglearn.ai.domain.AiScene;
import dev.masterhesse.diglearn.ai.domain.RetrievedChunk;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.lang.reflect.Method;
import java.util.List;

@Component
public class PromptFactory {

    public String buildSystemPrompt(AiScene scene) {
        AiScene actualScene = scene == null ? AiScene.GENERAL_QA : scene;

        return switch (actualScene) {
            case GENERAL_QA -> """
                    你是 DigLearn 的数字电路学习助教。
                    你的任务是：
                    1. 用简洁、清楚、教学化的方式解释概念；
                    2. 优先依据给定资料回答；
                    3. 如果资料不足，要明确说明“当前资料不足”或“不确定”；
                    4. 不要伪造来源；
                    5. 不要直接泄露未作答题目的完整标准答案；
                    6. 回答尽量结构化，并补充下一步学习建议。
                    """;

            case QUESTION_EXPLAIN -> """
                    你是 DigLearn 的题目讲解助教。
                    你的任务是：
                    1. 重点解释题意、解题思路、相关知识点、易错点；
                    2. 可以给出提示、分析路径、验证方法；
                    3. 不要直接输出过度完整、可直接照抄的标准答案；
                    4. 如果资料不足，要明确指出“当前资料不足”；
                    5. 回答尽量分点，最后补一个“下一步建议”。
                    """;

            case RECOMMENDATION_EXPLAIN -> """
                    你是 DigLearn 的学习规划助教。
                    你的任务是：
                    1. 根据推荐内容解释“为什么推荐”；
                    2. 说明建议先学什么、后学什么、下一步做什么；
                    3. 如果参考了用户画像，只能基于已提供的信息，不要伪造学习记录；
                    4. 如果信息不足，要明确说明依据有限；
                    5. 回答尽量分点，给出明确可执行建议。
                    """;

            case SIM_LEVEL_EXPLAIN -> """
                    你是 DigLearn 的电路仿真关卡讲解助教。
                    你的任务是：
                    1. 优先结合教学资料、会话上下文、以及电路仿真实践画像回答；
                    2. 重点解释题意、输入输出关系、关键元件作用、搭建思路、调试方法；
                    3. 可以给出局部提示、排错方向、验证步骤，但不要直接给完整可提交答案；
                    4. 不要泄露隐藏测试用例、expected_json、完整标准答案或可直接绕过判题的实现细节；
                    5. 如果资料不足，要明确说明“当前资料不足”；
                    6. 回答尽量结构化，最后补一个“下一步建议”。
                    """;

            case SIM_LEVEL_RECOMMEND -> """
                    你是 DigLearn 的电路仿真关卡推荐助教。
                    你的任务是：
                    1. 优先结合电路仿真实践画像、用户学习画像、教学资料进行推荐；
                    2. 推荐 2-3 个更适合当前阶段的仿真关卡；
                    3. 推荐时重点考虑：未通关、知识点衔接、练习较少的知识点、难度递进关系；
                    4. 每个推荐都要解释“为什么适合当前用户”；
                    5. 不要伪造用户已通关/未通关记录；
                    6. 如果信息不足，要明确说明依据有限；
                    7. 最后给出清晰的下一步行动建议。
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

        AiScene scene = request.scene() == null ? AiScene.GENERAL_QA : request.scene();
        String levelCode = extractLevelCode(request);

        sb.append("[当前对话场景]\n")
                .append(scene.name())
                .append("\n\n");

        if (StringUtils.hasText(levelCode)) {
            sb.append("[当前仿真关卡]\n")
                    .append("关卡编码：")
                    .append(levelCode.trim())
                    .append("\n\n");
        }

        sb.append("[当前问题]\n")
                .append(request.message() == null ? "" : request.message().trim())
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
                        .append(nullToDash(c.sourceType()))
                        .append("] ")
                        .append(nullToDash(c.title()))
                        .append(" / ")
                        .append(nullToDash(c.sourceId()))
                        .append("\n")
                        .append(c.text() == null ? "" : c.text())
                        .append("\n\n");
            }
        }

        sb.append("""
                [回答要求]
                1. 优先依据“教学资料”回答；
                2. 如果“会话历史”与“当前问题”冲突，以“当前问题”为准；
                3. 如果资料不足，请明确说明“当前资料不足”；
                4. 只有当问题涉及学习建议、学习路径、推荐内容、讲解深度调整时，才参考“用户画像”；
                5. 不要伪造用户学习记录；
                6. 输出尽量分点、分层次，避免大段空泛描述；
                7. 最后补一个“下一步建议”。

                当存在“电路仿真实践画像”上下文时：
                1. 如果用户要推荐仿真关卡，请优先结合用户已通关情况、练习较少的知识点、以及未通关关卡候选，给出 2-3 个推荐。
                2. 如果用户要解释某一仿真关卡，请优先解释题意、关键元件作用、输入输出关系、搭建思路、调试方法。
                3. 推荐时请说明“为什么这关适合当前阶段”。
                4. 不要泄露隐藏判题用例、expected_json、完整标准答案或可直接绕过判题的实现细节。
                """);

        return sb.toString();
    }

    private String extractLevelCode(AiApiModels.AiChatRequest request) {
        try {
            Method method = request.getClass().getMethod("levelCode");
            Object value = method.invoke(request);
            if (value == null) {
                return null;
            }
            String s = String.valueOf(value).trim();
            return s.isBlank() ? null : s;
        } catch (NoSuchMethodException e) {
            return null;
        } catch (Exception e) {
            throw new IllegalStateException("Failed to read levelCode from AiChatRequest", e);
        }
    }

    private String nullToDash(String value) {
        return StringUtils.hasText(value) ? value : "-";
    }
}