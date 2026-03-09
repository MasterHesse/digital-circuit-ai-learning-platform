package dev.masterhesse.diglearn.ai.persistence;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface AiConversationRepository extends JpaRepository<AiConversationEntity, String> {

    Optional<AiConversationEntity> findByConversationIdAndUserIdAndDeletedFalse(String conversationId, String userId);

    List<AiConversationEntity> findByUserIdAndDeletedFalseOrderByUpdatedAtDesc(String userId);
}