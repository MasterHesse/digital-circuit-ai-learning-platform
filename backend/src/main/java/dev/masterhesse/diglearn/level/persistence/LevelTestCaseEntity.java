package dev.masterhesse.diglearn.level.persistence;

import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(
        name = "level_test_cases",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_level_test_case_order",
                        columnNames = {"level_code", "order_index"}
                )
        }
)
public class LevelTestCaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id")
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "level_code", nullable = false)
    private LevelEntity level;

    @Column(name = "order_index", nullable = false)
    private Integer orderIndex;

    @Column(name = "name", length = 200)
    private String name;

    @OneToMany(
            mappedBy = "testCase",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    @OrderBy("stepIndex ASC")
    private List<LevelTestStepEntity> steps = new ArrayList<>();

    // ===== helpers =====

    public void addStep(LevelTestStepEntity step) {
        if (step == null) return;
        step.setTestCase(this);
        this.steps.add(step);
    }

    public void removeStep(LevelTestStepEntity step) {
        if (step == null) return;
        this.steps.remove(step);
        step.setTestCase(null);
    }

    // ===== getters / setters =====

    public UUID getId() {
        return id;
    }

    public LevelEntity getLevel() {
        return level;
    }

    public void setLevel(LevelEntity level) {
        this.level = level;
    }

    public Integer getOrderIndex() {
        return orderIndex;
    }

    public void setOrderIndex(Integer orderIndex) {
        this.orderIndex = orderIndex;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<LevelTestStepEntity> getSteps() {
        return steps;
    }

    public void setSteps(List<LevelTestStepEntity> steps) {
        this.steps = (steps == null) ? new ArrayList<>() : steps;
    }
}