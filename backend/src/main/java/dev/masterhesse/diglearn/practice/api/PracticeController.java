// src/main/java/dev/masterhesse/diglearn/practice/api/PracticeController.java
package dev.masterhesse.diglearn.practice.api;

import dev.masterhesse.diglearn.practice.application.PracticeService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/practice")
public class PracticeController {

    private final PracticeService practiceService;

    // 章节练习列表（Demo：BOOL 六节）
    @GetMapping("/chapters")
    public List<PracticeService.ChapterRow> chapters(
            @RequestHeader("X-User-Id") String userId,
            @RequestParam(value = "category", required = false, defaultValue = "BOOL") String category
    ) {
        return practiceService.listChapters(userId, category);
    }

    // 某一章题目列表（不带答案）
    @GetMapping("/chapters/{kpId}/questions")
    public List<PracticeService.QuestionRow> chapterQuestions(
            @RequestHeader("X-User-Id") String userId,
            @PathVariable("kpId") String kpId
    ) {
        return practiceService.listChapterQuestions(userId, kpId);
    }

    // 推荐（错题池）
    @GetMapping("/recommended")
    public List<PracticeService.RecommendedRow> recommended(@RequestHeader("X-User-Id") String userId) {
        return practiceService.listRecommended(userId);
    }

    // 推荐题目：已掌握
    @PostMapping("/recommended/{questionId}/mastered")
    public void mastered(
            @RequestHeader("X-User-Id") String userId,
            @PathVariable("questionId") UUID questionId
    ) {
        practiceService.markMastered(userId, questionId);
    }

    // 巩固练习：从某道错题触发，推荐 N 道相关题（首次不显示答案，提交后显示）
    @GetMapping("/reinforcement/{sourceQuestionId}")
    public List<PracticeService.QuestionRow> reinforcement(
            @RequestHeader("X-User-Id") String userId,
            @PathVariable("sourceQuestionId") UUID sourceQuestionId,
            @RequestParam(value = "count", required = false, defaultValue = "2") int count
    ) {
        return practiceService.reinforcement(userId, sourceQuestionId, count);
    }
}