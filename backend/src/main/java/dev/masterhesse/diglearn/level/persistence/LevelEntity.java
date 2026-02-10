package dev.masterhesse.diglearn.level.persistence;

import jakarta.persistence.*;

import java.util.*;

@Entity
@Table(name = "levels")
public class LevelEntity {

    @Id
    @Column(name = "code", nullable = false, length = 64)
    private String code;

    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Column(name = "description", columnDefinition = "text")
    private String description;

    @Column(name = "template_circuit_json", columnDefinition = "text")
    private String templateCircuitJson;

    @Column(name = "devices", columnDefinition = "text")
    private String devices;

    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(
            name = "level_allowed_components",
            joinColumns = @JoinColumn(name = "level_code", referencedColumnName = "code")
    )
    @Column(name = "component", nullable = false, length = 64)
    private Set<String> allowedComponents = new LinkedHashSet<>();

    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(
            name = "level_kp_ids",
            joinColumns = @JoinColumn(name = "level_code", referencedColumnName = "code")
    )
    @Column(name = "kp_id", nullable = false, length = 64)
    private Set<String> kpIds = new LinkedHashSet<>();

    @OneToMany(
            mappedBy = "level",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    @OrderBy("orderIndex ASC")
    private List<LevelTestCaseEntity> testCases = new ArrayList<>();

    // ===== helpers =====

    public void addTestCase(LevelTestCaseEntity testCase) {
        if (testCase == null) return;
        testCase.setLevel(this);
        this.testCases.add(testCase);
    }

    public void removeTestCase(LevelTestCaseEntity testCase) {
        if (testCase == null) return;
        this.testCases.remove(testCase);
        testCase.setLevel(null);
    }

    // ===== getters / setters =====

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getTemplateCircuitJson() {
        return templateCircuitJson;
    }

    public void setTemplateCircuitJson(String templateCircuitJson) {
        this.templateCircuitJson = templateCircuitJson;
    }

    public String getDevices() {
        return devices;
    }

    public void setDevices(String devices) {
        this.devices = devices;
    }

    public Set<String> getAllowedComponents() {
        return allowedComponents;
    }

    public void setAllowedComponents(Set<String> allowedComponents) {
        this.allowedComponents = (allowedComponents == null) ? new LinkedHashSet<>() : allowedComponents;
    }

    public Set<String> getKpIds() {
        return kpIds;
    }

    public void setKpIds(Set<String> kpIds) {
        this.kpIds = (kpIds == null) ? new LinkedHashSet<>() : kpIds;
    }

    public List<LevelTestCaseEntity> getTestCases() {
        return testCases;
    }

    public void setTestCases(List<LevelTestCaseEntity> testCases) {
        this.testCases = (testCases == null) ? new ArrayList<>() : testCases;
    }
}