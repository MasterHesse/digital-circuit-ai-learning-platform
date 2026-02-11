package dev.masterhesse.diglearn.sim.persistence;

import jakarta.persistence.*;

import java.util.UUID;

@Entity
@Table(
        name = "level_test_steps",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_test_step_index",
                        columnNames = {"test_case_id", "step_index"}
                )
        }
)
public class LevelTestStepEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id")
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "test_case_id", nullable = false)
    private LevelTestCaseEntity testCase;

    @Column(name = "step_index", nullable = false)
    private Integer stepIndex;

    @Column(name = "inputs_json", nullable = false, columnDefinition = "text")
    private String inputsJson;

    @Column(name = "expected_json", nullable = false, columnDefinition = "text")
    private String expectedJson;

    // ===== getters / setters =====

    public UUID getId() {
        return id;
    }

    public LevelTestCaseEntity getTestCase() {
        return testCase;
    }

    public void setTestCase(LevelTestCaseEntity testCase) {
        this.testCase = testCase;
    }

    public Integer getStepIndex() {
        return stepIndex;
    }

    public void setStepIndex(Integer stepIndex) {
        this.stepIndex = stepIndex;
    }

    public String getInputsJson() {
        return inputsJson;
    }

    public void setInputsJson(String inputsJson) {
        this.inputsJson = inputsJson;
    }

    public String getExpectedJson() {
        return expectedJson;
    }

    public void setExpectedJson(String expectedJson) {
        this.expectedJson = expectedJson;
    }
}