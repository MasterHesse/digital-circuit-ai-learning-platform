package dev.masterhesse.diglearn.ai.api;

import dev.masterhesse.diglearn.ai.application.RagIndexingService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/ai")
@RequiredArgsConstructor
public class AiAdminController {

    private final RagIndexingService ragIndexingService;

    @PostMapping("/reindex")
    public AiApiModels.ReindexResponse reindex() {
        return ragIndexingService.reindexLearningCorpus();
    }
}