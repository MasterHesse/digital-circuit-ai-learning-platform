// src/main/java/dev/masterhesse/diglearn/question/api/QuestionController.java
package dev.masterhesse.diglearn.question.api;

import dev.masterhesse.diglearn.knowledgepoint.application.KpGraphService;
import dev.masterhesse.diglearn.practice.application.QuestionSubmissionService;
import dev.masterhesse.diglearn.practice.domain.PracticeMode;
import dev.masterhesse.diglearn.practice.persistence.QuestionAttemptRepository;
import dev.masterhesse.diglearn.question.domain.QuestionStatus;
import dev.masterhesse.diglearn.question.domain.QuestionType;
import dev.masterhesse.diglearn.question.persistence.QuestionEntity;
import dev.masterhesse.diglearn.question.persistence.QuestionRepository;
import dev.masterhesse.diglearn.question.persistence.QuestionTagMapEntity;
import dev.masterhesse.diglearn.question.persistence.QuestionTagMapId;
import dev.masterhesse.diglearn.question.persistence.QuestionTagMapRepository;
import dev.masterhesse.diglearn.shared.application.UserGuard;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/questions")
public class QuestionController {

    private final QuestionRepository questionRepository;
    private final QuestionTagMapRepository questionTagMapRepository;
    private final QuestionAttemptRepository attemptRepository;

    private final QuestionSubmissionService submissionService;
    private final KpGraphService kpGraphService;
    private final UserGuard userGuard;

    // ---------- DTOs ----------
    public record QuestionCreateRequest(
            @NotNull QuestionType type,
            @NotNull String stem,
            @Min(1) @Max(5) short difficulty,
            Map<String, Object> content,
            Map<String, Object> solution,
            String explanation
    ) {}

    public record QuestionResponse(
            UUID id,
            QuestionType type,
            QuestionStatus status,
            String stem,
            short difficulty,
            String lang,
            Map<String, Object> content,
            Map<String, Object> solution,
            String explanation
    ) {}

    public record TagMapping(UUID tagId, Integer weight) {}
    public record SetTagsRequest(List<TagMapping> mappings) {}

    public record SubmitRequest(
            @NotNull PracticeMode mode,
            String contextKpId,
            UUID sourceQuestionId,
            Map<String, Object> answer
    ) {}

    // ---------- CRUD-ish ----------
    @PostMapping
    public QuestionResponse create(@RequestBody QuestionCreateRequest req) {
        if (req.stem() == null || req.stem().trim().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "stem is required");
        }
        if (req.content() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "content is required");
        }

        var q = new QuestionEntity();
        q.setType(req.type());
        q.setStem(req.stem().trim());
        q.setDifficulty(req.difficulty());
        q.setContent(req.content());
        q.setSolution(req.solution());
        q.setExplanation(req.explanation());
        q.setStatus(QuestionStatus.DRAFT);

        questionRepository.save(q);

        return new QuestionResponse(
                q.getId(), q.getType(), q.getStatus(), q.getStem(), q.getDifficulty(), q.getLang(),
                q.getContent(), null, q.getExplanation()
        );
    }

    @PostMapping("/{id}/publish")
    public QuestionResponse publish(@PathVariable("id") UUID id) {
        var q = questionRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "question not found: " + id));
        q.setStatus(QuestionStatus.PUBLISHED);
        questionRepository.save(q);

        return new QuestionResponse(
                q.getId(), q.getType(), q.getStatus(), q.getStem(), q.getDifficulty(), q.getLang(),
                q.getContent(), null, q.getExplanation()
        );
    }

    /**
     * 题目详情：
     * - 默认不返回 solution
     * - includeSolution=true 时：只有在该用户提交过（attempt exists）才返回 solution
     */
    @GetMapping("/{id}")
    public QuestionResponse get(
            @RequestHeader(value = "X-User-Id", required = false) String userIdHeader,
            @PathVariable("id") UUID id,
            @RequestParam(value = "includeSolution", required = false, defaultValue = "false") boolean includeSolution
    ) {
        var q = questionRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "question not found: " + id));

        Map<String, Object> sol = null;
        if (includeSolution) {
            String userId = userGuard.requireValidUserId(userIdHeader);
            boolean attempted = attemptRepository.existsByUserIdAndQuestionId(userId, id);
            if (attempted) sol = q.getSolution();
        }

        return new QuestionResponse(
                q.getId(), q.getType(), q.getStatus(), q.getStem(), q.getDifficulty(), q.getLang(),
                q.getContent(), sol, q.getExplanation()
        );
    }

    // ---------- Tags binding ----------
    @Transactional
    @PutMapping("/{id}/tags")
    public List<QuestionTagMapEntity> setTags(@PathVariable("id") UUID id, @RequestBody SetTagsRequest req) {
        // ensure question exists
        questionRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "question not found: " + id));

        List<TagMapping> mappings = (req == null || req.mappings() == null) ? List.of() : req.mappings();

        questionTagMapRepository.deleteAllByQuestionId(id);

        List<QuestionTagMapEntity> saved = new ArrayList<>();
        for (TagMapping m : mappings) {
            if (m == null || m.tagId() == null) continue;
            int w = (m.weight() == null) ? 1 : Math.max(1, m.weight());
            var e = QuestionTagMapEntity.of(new QuestionTagMapId(id, m.tagId()), w);
            saved.add(questionTagMapRepository.save(e));
        }
        return saved;
    }

    // ---------- Submit (unlock solution) ----------
    @PostMapping("/{id}/submit")
    public QuestionSubmissionService.SubmitResult submit(
            @RequestHeader("X-User-Id") String userId,
            @PathVariable("id") UUID id,
            @Valid @RequestBody SubmitRequest req
    ) {
        if (req == null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "request body is required");
        return submissionService.submit(
                userId,
                id,
                req.mode(),
                req.contextKpId(),
                req.sourceQuestionId(),
                req.answer()
        );
    }

    // ---------- KP trace ----------
    @GetMapping("/{id}/kp-trace")
    public KpGraphService.KpTraceResponse kpTrace(
            @PathVariable("id") UUID id,
            @RequestParam(value = "depth", required = false, defaultValue = "3") int depth
    ) {
        List<String> kpIds = questionRepository.findKpIdsByQuestionId(id);
        return kpGraphService.trace(kpIds, depth);
    }
}