package dev.masterhesse.diglearn.sim.importing;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

@Component
public class LevelImportRunner implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(LevelImportRunner.class);

    private final LevelImportService importService;
    private final LevelsImportProperties props;

    public LevelImportRunner(LevelImportService importService, LevelsImportProperties props) {
        this.importService = importService;
        this.props = props;
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        if (!props.isEnabled()) {
            log.info("Level import disabled (levels.import.enabled=false).");
            return;
        }

        LevelImportModels.ImportReport report = importService.importAll();
        log.info("Levels imported/updated={}, deleted={}, warnings={}",
                report.importedOrUpdated(), report.deleted(), report.warnings());
    }
}