// src/main/java/dev/masterhesse/diglearn/question/persistence/QuestionEntity.java
package dev.masterhesse.diglearn.question.persistence;

import dev.masterhesse.diglearn.question.domain.QuestionPool;
import dev.masterhesse.diglearn.question.domain.QuestionStatus;
import dev.masterhesse.diglearn.question.domain.QuestionType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(
        name = "questions",
        indexes = {
                @Index(name = "idx_questions_type",       columnList = "type"),
                @Index(name = "idx_questions_status",     columnList = "status"),
                @Index(name = "idx_questions_difficulty", columnList = "difficulty"),
                // 新增：推荐查询和章节查询都会按 pool 过滤，建索引避免全表扫描
                @Index(name = "idx_questions_pool",       columnList = "question_pool")
        }
)
public class QuestionEntity {

    @Id
    @Column(name = "id", nullable = false)
    private UUID id;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false, length = 40)
    private QuestionType type;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private QuestionStatus status = QuestionStatus.DRAFT;

    @Column(name = "stem", nullable = false, columnDefinition = "text")
    private String stem;

    @Column(name = "difficulty", nullable = false)
    private short difficulty; // 1..5

    @Column(name = "lang", nullable = false, length = 10)
    private String lang = "zh-CN";

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "content", nullable = false, columnDefinition = "jsonb")
    private Map<String, Object> content;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "solution", columnDefinition = "jsonb")
    private Map<String, Object> solution;

    @Column(name = "explanation", columnDefinition = "text")
    private String explanation;

    /**
     * 题目所属题池。
     *
     * DDL 说明（ddl-auto: update）：
     *   - 若 demo.sql Section 0 的幂等 Migration 先于应用启动执行，
     *     该列已携带 DEFAULT 'SUPPLEMENT' NOT NULL 约束，Hibernate 跳过 ALTER。
     *   - 若应用先启动（全新库），Hibernate 会执行：
     *       ALTER TABLE questions ADD COLUMN question_pool varchar(20) not null default 'SUPPLEMENT'
     *     columnDefinition 中的 default 子句在 PostgreSQL 方言下会被正确带入 ALTER TABLE，
     *     存量行自动填充为 'SUPPLEMENT'，不会产生 NOT NULL 违反。
     */
    @Enumerated(EnumType.STRING)
    @Column(
            name = "question_pool",
            nullable = false,
            length = 20,
            columnDefinition = "varchar(20) not null default 'SUPPLEMENT'"
    )
    private QuestionPool questionPool = QuestionPool.SUPPLEMENT;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    public QuestionEntity() {
    }

    @PrePersist
    void prePersist() {
        Instant now = Instant.now();
        if (id == null)                              id          = UUID.randomUUID();
        if (status == null)                          status      = QuestionStatus.DRAFT;
        if (lang == null || lang.isBlank())          lang        = "zh-CN";
        if (questionPool == null)                    questionPool = QuestionPool.SUPPLEMENT;
        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    void preUpdate() {
        updatedAt = Instant.now();
    }

    // ---- getters / setters ----

    public UUID getId()                        { return id; }
    public void setId(UUID id)                 { this.id = id; }

    public QuestionType getType()              { return type; }
    public void setType(QuestionType type)     { this.type = type; }

    public QuestionStatus getStatus()          { return status; }
    public void setStatus(QuestionStatus s)    { this.status = s; }

    public String getStem()                    { return stem; }
    public void setStem(String stem)           { this.stem = stem; }

    public short getDifficulty()               { return difficulty; }
    public void setDifficulty(short d)         { this.difficulty = d; }

    public String getLang()                    { return lang; }
    public void setLang(String lang)           { this.lang = lang; }

    public Map<String, Object> getContent()    { return content; }
    public void setContent(Map<String, Object> c) { this.content = c; }

    public Map<String, Object> getSolution()   { return solution; }
    public void setSolution(Map<String, Object> s){ this.solution = s; }

    public String getExplanation()             { return explanation; }
    public void setExplanation(String e)       { this.explanation = e; }

    public QuestionPool getQuestionPool()              { return questionPool; }
    public void setQuestionPool(QuestionPool pool)     { this.questionPool = pool; }

    public Instant getCreatedAt()              { return createdAt; }
    public void setCreatedAt(Instant t)        { this.createdAt = t; }

    public Instant getUpdatedAt()              { return updatedAt; }
    public void setUpdatedAt(Instant t)        { this.updatedAt = t; }
}