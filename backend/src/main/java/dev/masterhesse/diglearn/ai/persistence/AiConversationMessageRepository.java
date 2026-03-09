package dev.masterhesse.diglearn.ai.persistence;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AiConversationMessageRepository extends JpaRepository<AiConversationMessageEntity, String> {

    List<AiConversationMessageEntity> findByConversationIdOrderByCreatedAtAsc(String conversationId);

    Page<AiConversationMessageEntity> findByConversationIdOrderByCreatedAtDesc(String conversationId, Pageable pageable);
}