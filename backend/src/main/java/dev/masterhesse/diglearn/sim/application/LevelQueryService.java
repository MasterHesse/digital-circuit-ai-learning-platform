package dev.masterhesse.diglearn.sim.application;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import dev.masterhesse.diglearn.sim.api.LevelApiModels;
import dev.masterhesse.diglearn.sim.persistence.LevelEntity;
import dev.masterhesse.diglearn.sim.persistence.LevelRepository;
import dev.masterhesse.diglearn.sim.persistence.LevelTestCaseEntity;
import dev.masterhesse.diglearn.sim.persistence.LevelTestCaseRepository;
import dev.masterhesse.diglearn.sim.persistence.LevelTestStepEntity;
import jakarta.transaction.Transactional;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;


import java.util.List;

@Service
public class LevelQueryService {

    private final LevelRepository levelRepository;
    private final ObjectMapper objectMapper;
    private final LevelTestCaseRepository testCaseRepository;

    public LevelQueryService(LevelRepository levelRepository, ObjectMapper objectMapper, LevelTestCaseRepository testCaseRepository) {
        this.levelRepository = levelRepository;
        this.objectMapper = objectMapper;
        this.testCaseRepository = testCaseRepository;
    }

    public List<LevelApiModels.LevelSummary> listSummaries() {
        return levelRepository.findAllByOrderByCodeAsc()
                .stream()
                .map(l -> new LevelApiModels.LevelSummary(l.getCode(), l.getTitle()))
                .toList();
    }

    @Transactional
    public LevelApiModels.LevelDetail getDetail(String code) {
        LevelEntity level = levelRepository.findDetailByCode(code)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Level not found: " + code));

        List<LevelTestCaseEntity> tcs = testCaseRepository.findAllByLevelCodeWithSteps(code);
        tcs.sort(java.util.Comparator.comparing(LevelTestCaseEntity::getOrderIndex));

        return new LevelApiModels.LevelDetail(
                level.getCode(),
                level.getTitle(),
                level.getDescription(),
                level.getAllowedComponents(),
                level.isAllowCycles(),
                level.getKpIds(),
                parseJsonOrNull(level.getTemplateCircuitJson()),
                parseJsonOrNull(level.getDevices()),
                tcs.stream().map(this::mapTestCase).toList()
        );
    }

    private LevelApiModels.TestCase mapTestCase(LevelTestCaseEntity tc) {
        return new LevelApiModels.TestCase(
                tc.getOrderIndex(),
                tc.getName(),
                tc.getSteps().stream().map(this::mapStep).toList()
        );
    }

    private LevelApiModels.TestStep mapStep(LevelTestStepEntity step) {
        return new LevelApiModels.TestStep(
                step.getStepIndex(),
                parseJsonOrNull(step.getInputsJson()),
                parseJsonOrNull(step.getExpectedJson())
        );
    }

    private JsonNode parseJsonOrNull(String json) {
        if (json == null || json.isBlank()) return null;
        try {
            return objectMapper.readTree(json);
        } catch (Exception e) {
            // DB 中存了坏 JSON 的话，直接报 500 比“悄悄吞掉”更好定位问题
            throw new IllegalStateException("Invalid JSON in DB: " + json, e);
        }
    }
}