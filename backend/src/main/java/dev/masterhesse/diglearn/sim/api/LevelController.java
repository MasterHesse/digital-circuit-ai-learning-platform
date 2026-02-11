package dev.masterhesse.diglearn.sim.api;

import org.springframework.web.bind.annotation.*;

import dev.masterhesse.diglearn.sim.application.LevelQueryService;

import java.util.List;

@RestController
@RequestMapping("/api/levels")
public class LevelController {

    private final LevelQueryService levelQueryService;

    public LevelController(LevelQueryService levelQueryService) {
        this.levelQueryService = levelQueryService;
    }

    @GetMapping
    public List<LevelApiModels.LevelSummary> listLevels() {
        return levelQueryService.listSummaries();
    }

    @GetMapping("/{code}")
    public LevelApiModels.LevelDetail getLevel(@PathVariable String code) {
        return levelQueryService.getDetail(code);
    }
}