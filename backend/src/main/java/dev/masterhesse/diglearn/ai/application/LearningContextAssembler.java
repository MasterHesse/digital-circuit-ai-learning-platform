package dev.masterhesse.diglearn.ai.application;

import org.springframework.stereotype.Service;

@Service
public class LearningContextAssembler {

    public String build(String userId) {
        if (userId == null || userId.isBlank()) {
            return """
                    当前请求未携带用户身份，按匿名学习者处理。
                    第一批骨架暂未接入真实学习进度。
                    后续将在这里接入：
                    - user_question_state
                    - question_attempts
                    - level_pass_records
                    - 知识点前置链
                    """;
        }

        return """
                当前用户ID：%s
                第一批骨架暂未接入真实学习进度。
                后续将在这里接入：
                - user_question_state
                - question_attempts
                - level_pass_records
                - 知识点前置链
                """.formatted(userId);
    }
}