// src/main/java/dev/masterhesse/diglearn/practice/application/QuestionSubmissionService.java
package dev.masterhesse.diglearn.practice.application;

import dev.masterhesse.diglearn.practice.domain.PracticeMode;
import dev.masterhesse.diglearn.practice.persistence.QuestionAttemptEntity;
import dev.masterhesse.diglearn.practice.persistence.QuestionAttemptRepository;
import dev.masterhesse.diglearn.practice.persistence.UserQuestionStateEntity;
import dev.masterhesse.diglearn.practice.persistence.UserQuestionStateRepository;
import dev.masterhesse.diglearn.question.domain.QuestionType;
import dev.masterhesse.diglearn.question.persistence.QuestionEntity;
import dev.masterhesse.diglearn.question.persistence.QuestionRepository;
import dev.masterhesse.diglearn.shared.application.UserGuard;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.*;

@Service
@RequiredArgsConstructor
public class QuestionSubmissionService {

    private final UserGuard userGuard;
    private final QuestionRepository questionRepository;
    private final QuestionAttemptRepository attemptRepository;
    private final UserQuestionStateRepository stateRepository;

    public record SubmitResult(
            UUID attemptId,
            boolean graded,
            Boolean isCorrect,
            Map<String, Object> solution,
            String explanation,
            List<String> kpIds
    ) {}

    @Transactional
    public SubmitResult submit(
            String userIdHeader,
            UUID questionId,
            PracticeMode mode,
            String contextKpId,
            UUID sourceQuestionId,
            Map<String, Object> answer
    ) {
        String userId = userGuard.requireValidUserId(userIdHeader);
        if (questionId == null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "questionId is required");
        if (mode == null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "mode is required");
        if (answer == null) answer = Map.of();

        QuestionEntity q = questionRepository.findById(questionId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "question not found: " + questionId));

        // 判分（客观题自动判；简答题 Demo：graded=false）
        boolean graded = false;
        Boolean isCorrect = null;

        // SINGLE_CHOICE
        if (q.getType() == QuestionType.SINGLE_CHOICE) {
            String expected = firstString(q.getSolution(),
                    "correctOptionId", "answer", "correct", "expected",
                    "correctOptionIds" // 兼容有人把单选存成数组
            );
            String got = firstString(answer,
                    "selectedOptionId", "answer", "selectedOptionIds"
            );

            if (expected == null || got == null) {
                graded = false;
                isCorrect = null;
            } else {
                graded = true;
                isCorrect = expected.equals(got);
            }
        }

        // MULTI_CHOICE
        else if (q.getType() == QuestionType.MULTI_CHOICE) {
            Set<String> expected = setOfStrings(q.getSolution(), "correctOptionIds");

            if (expected.isEmpty()) {
                // 兼容 solution.answer = ["A","B"] 或 "A"
                expected = setOfStrings(q.getSolution(), "answer");
                if (expected.isEmpty()) {
                    String one = firstString(q.getSolution(), "correctOptionId", "answer");
                    if (one != null) expected = Set.of(one);
                }
            }

            Set<String> got = setOfStrings(answer, "selectedOptionIds");
            if (got.isEmpty()) {
                got = setOfStrings(answer, "answer");
                if (got.isEmpty()) {
                    String one = firstString(answer, "selectedOptionId", "answer");
                    if (one != null) got = Set.of(one);
                }
            }

            if (expected.isEmpty() || got.isEmpty()) {
                graded = false;
                isCorrect = null;
            } else {
                graded = true;
                isCorrect = expected.equals(got);
            }
        }

        // 记录 attempt（作为“解锁答案”凭证）
        var att = new QuestionAttemptEntity();
        att.setUserId(userId);
        att.setQuestionId(questionId);
        att.setMode(mode);
        att.setContextKpId(contextKpId);
        att.setSourceQuestionId(sourceQuestionId);
        att.setUserAnswer(answer);
        att.setIsCorrect(isCorrect);
        attemptRepository.save(att);

        // 更新错题池（只对 graded 且错误的客观题）
        if (Boolean.FALSE.equals(isCorrect)) {
            UserQuestionStateEntity st = stateRepository.findByUserIdAndQuestionId(userId, questionId)
                    .orElseGet(() -> {
                        var e = new UserQuestionStateEntity();
                        e.setUserId(userId);
                        e.setQuestionId(questionId);
                        return e;
                    });

            st.setWrongCount(st.getWrongCount() + 1);
            st.setLastWrongAt(Instant.now());
            st.setLastAttemptAt(Instant.now());
            st.setMastered(false);
            stateRepository.save(st);
        } else {
            // 仅更新 lastAttemptAt（不自动“已掌握”，由学生手动点）
            stateRepository.findByUserIdAndQuestionId(userId, questionId).ifPresent(st -> {
                st.setLastAttemptAt(Instant.now());
                stateRepository.save(st);
            });
        }

        // 提交后返回标准答案 + 解析（满足“提交后才能看答案”）
        List<String> kpIds = questionRepository.findKpIdsByQuestionId(questionId);

        return new SubmitResult(
                att.getId(),
                graded,
                isCorrect,
                q.getSolution(),
                q.getExplanation(),
                kpIds
        );
    }

    private static String firstString(Map<String, Object> m, String... keys) {
        if (m == null) return null;
        for (String k : keys) {
            Object v = m.get(k);
            if (v == null) continue;

            if (v instanceof Collection<?> c) {
                for (Object x : c) {
                    if (x == null) continue;
                    String s = String.valueOf(x).trim();
                    if (!s.isBlank()) return s;
                }
            } else {
                String s = String.valueOf(v).trim();
                if (!s.isBlank()) return s;
            }
        }
        return null;
    }

    private static Set<String> setOfStrings(Map<String, Object> m, String key) {
        if (m == null) return Set.of();
        Object v = m.get(key);
        if (v == null) return Set.of();

        if (v instanceof Collection<?> c) {
            Set<String> out = new HashSet<>();
            for (Object x : c) {
                if (x == null) continue;
                String s = String.valueOf(x).trim();
                if (!s.isBlank()) out.add(s);
            }
            return out;
        }
        return Set.of();
    }
}