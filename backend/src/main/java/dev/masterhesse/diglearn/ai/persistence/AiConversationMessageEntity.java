package dev.masterhesse.diglearn.ai.persistence;

import dev.masterhesse.diglearn.ai.domain.AiMessageRole;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(
        name = "ai_conversation_messages",
        indexes = {
                @Index(name = "idx_ai_conv_msg_conversation_created", columnList = "conversation_id, created_at"),
                @Index(name = "idx_ai_conv_msg_user", columnList = "user_id")
        }
)
@Getter
@Setter
public class AiConversationMessageEntity {

    @Id
    @Column(name = "message_id", nullable = false, length = 64)
    private String messageId;

    @Column(name = "conversation_id", nullable = false, length = 64)
    private String conversationId;

    @Column(name = "user_id", nullable = false, length = 128)
    private String userId;

    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false, length = 16)
    private AiMessageRole role;

    @Column(name = "content", nullable = false, columnDefinition = "text")
    private String content;

    @Column(name = "reasoning", columnDefinition = "text")
    private String reasoning;

    @Column(name = "model_name", length = 100)
    private String model;

    @Column(name = "provider_name", length = 100)
    private String provider;

    @Column(name = "fallback", nullable = false)
    private boolean fallback = false;

    @Column(name = "sources_json", columnDefinition = "text")
    private String sourcesJson;

    @Column(name = "used_contexts_json", columnDefinition = "text")
    private String usedContextsJson;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) {
            createdAt = Instant.now();
        }
    }
}