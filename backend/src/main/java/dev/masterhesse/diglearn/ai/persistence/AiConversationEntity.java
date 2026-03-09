package dev.masterhesse.diglearn.ai.persistence;

import dev.masterhesse.diglearn.ai.domain.AiScene;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(
        name = "ai_conversations",
        indexes = {
                @Index(name = "idx_ai_conversations_user_updated", columnList = "user_id, updated_at"),
                @Index(name = "idx_ai_conversations_deleted", columnList = "deleted")
        }
)
@Getter
@Setter
public class AiConversationEntity {

    @Id
    @Column(name = "conversation_id", nullable = false, length = 64)
    private String conversationId;

    @Column(name = "user_id", nullable = false, length = 128)
    private String userId;

    @Enumerated(EnumType.STRING)
    @Column(name = "scene", nullable = false, length = 32)
    private AiScene scene = AiScene.GENERAL_QA;

    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Column(name = "deleted", nullable = false)
    private boolean deleted = false;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @PrePersist
    public void prePersist() {
        Instant now = Instant.now();
        if (createdAt == null) createdAt = now;
        if (updatedAt == null) updatedAt = now;
    }

    @PreUpdate
    public void preUpdate() {
        updatedAt = Instant.now();
    }
}