package dev.masterhesse.diglearn.level.api;

import dev.masterhesse.diglearn.level.application.LevelJudgeService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/levels")
public class LevelJudgeController {

    private final LevelJudgeService service;

    public LevelJudgeController(LevelJudgeService service) {
        this.service = service;
    }

    @PostMapping("/{code}/judge")
    public LevelJudgeApiModels.JudgeResponse judge(
            @PathVariable("code") String code,
            @RequestHeader(value = "X-User-Id", required = false) String userIdHeader,
            @Valid @RequestBody LevelJudgeApiModels.JudgeRequest req
    ) {
        String userId = service.resolveUserId(req.userId(), userIdHeader);
        return service.judge(code, userId, req.circuit());
    }

    @GetMapping("/{code}/pass")
    public LevelJudgeApiModels.PassStatusResponse passStatus(
            @PathVariable("code") String code,
            @RequestHeader(value = "X-User-Id", required = false) String userIdHeader,
            @RequestParam(value = "userId", required = false) String userIdParam
    ) {
        String userId = service.resolveUserId(userIdParam, userIdHeader);
        return service.getPassStatus(code, userId);
    }
}