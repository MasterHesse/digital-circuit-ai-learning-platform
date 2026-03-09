package dev.masterhesse.diglearn.ai.application;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import dev.masterhesse.diglearn.ai.api.AiApiModels;
import dev.masterhesse.diglearn.ai.domain.AiMessageRole;
import dev.masterhesse.diglearn.ai.domain.AiScene;
import dev.masterhesse.diglearn.ai.persistence.AiConversationEntity;
import dev.masterhesse.diglearn.ai.persistence.AiConversationMessageEntity;
import dev.masterhesse.diglearn.ai.persistence.AiConversationMessageRepository;
import dev.masterhesse.diglearn.ai.persistence.AiConversationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;

@Service
@RequiredArgsConstructor
public class AiConversationService {

    private final AiConversationRepository conversationRepository;
    private final AiConversationMessageRepository messageRepository;
    private final ObjectMapper objectMapper;

    @Transactional
    public AiConversationEntity requireOrCreateForChat(String userId, AiApiModels.AiChatRequest request) {
        String uid = requireUserId(userId);

        if (StringUtils.hasText(request.conversationId())) {
            return requireOwnedConversation(uid, request.conversationId().trim());
        }

        AiConversationEntity entity = new AiConversationEntity();
        entity.setConversationId(UUID.randomUUID().toString());
        entity.setUserId(uid);
        entity.setScene(request.scene() == null ? AiScene.GENERAL_QA : request.scene());
        entity.setTitle(buildTitle(request.message(), null));
        return conversationRepository.save(entity);
    }

    @Transactional
    public AiApiModels.AiConversationSummary createConversation(String userId, AiApiModels.CreateConversationRequest request) {
        String uid = requireUserId(userId);

        AiConversationEntity entity = new AiConversationEntity();
        entity.setConversationId(UUID.randomUUID().toString());
        entity.setUserId(uid);
        entity.setScene(request != null && request.scene() != null ? request.scene() : AiScene.GENERAL_QA);
        entity.setTitle(buildTitle(null, request == null ? null : request.title()));
        entity = conversationRepository.save(entity);

        return toSummary(entity);
    }

    @Transactional(readOnly = true)
    public List<AiApiModels.AiConversationSummary> listConversations(String userId) {
        String uid = requireUserId(userId);
        return conversationRepository.findByUserIdAndDeletedFalseOrderByUpdatedAtDesc(uid).stream()
                .map(this::toSummary)
                .toList();
    }

    @Transactional(readOnly = true)
    public AiApiModels.AiConversationDetail getConversationDetail(String userId, String conversationId) {
        AiConversationEntity conversation = requireOwnedConversation(requireUserId(userId), conversationId);

        List<AiApiModels.AiConversationMessage> messages =
                messageRepository.findByConversationIdOrderByCreatedAtAsc(conversation.getConversationId()).stream()
                        .map(this::toMessageDto)
                        .toList();

        return new AiApiModels.AiConversationDetail(
                conversation.getConversationId(),
                conversation.getTitle(),
                conversation.getScene(),
                conversation.getCreatedAt(),
                conversation.getUpdatedAt(),
                messages
        );
    }

    @Transactional
    public void deleteConversation(String userId, String conversationId) {
        AiConversationEntity conversation = requireOwnedConversation(requireUserId(userId), conversationId);
        conversation.setDeleted(true);
        conversationRepository.save(conversation);
    }

    @Transactional(readOnly = true)
    public List<AiConversationMessageEntity> loadRecentMessages(String userId, String conversationId, int limit) {
        AiConversationEntity conversation = requireOwnedConversation(requireUserId(userId), conversationId);

        List<AiConversationMessageEntity> desc = messageRepository
                .findByConversationIdOrderByCreatedAtDesc(conversation.getConversationId(), PageRequest.of(0, Math.max(1, limit)))
                .getContent();

        List<AiConversationMessageEntity> asc = new ArrayList<>(desc);
        Collections.reverse(asc);
        return asc;
    }

    @Transactional
    public void appendExchange(
            String userId,
            String conversationId,
            String userMessageContent,
            String assistantContent,
            String reasoning,
            String model,
            String provider,
            boolean fallback,
            List<AiApiModels.AiSourceRef> sources,
            List<String> usedContexts
    ) {
        AiConversationEntity conversation = requireOwnedConversation(requireUserId(userId), conversationId);

        AiConversationMessageEntity userMsg = new AiConversationMessageEntity();
        userMsg.setMessageId(UUID.randomUUID().toString());
        userMsg.setConversationId(conversation.getConversationId());
        userMsg.setUserId(userId);
        userMsg.setRole(AiMessageRole.USER);
        userMsg.setContent(userMessageContent);
        userMsg.setFallback(false);
        userMsg.setSourcesJson("[]");
        userMsg.setUsedContextsJson("[]");
        messageRepository.save(userMsg);

        AiConversationMessageEntity assistantMsg = new AiConversationMessageEntity();
        assistantMsg.setMessageId(UUID.randomUUID().toString());
        assistantMsg.setConversationId(conversation.getConversationId());
        assistantMsg.setUserId(userId);
        assistantMsg.setRole(AiMessageRole.ASSISTANT);
        assistantMsg.setContent(assistantContent);
        assistantMsg.setReasoning(reasoning);
        assistantMsg.setModel(model);
        assistantMsg.setProvider(provider);
        assistantMsg.setFallback(fallback);
        assistantMsg.setSourcesJson(writeJson(sources == null ? List.of() : sources));
        assistantMsg.setUsedContextsJson(writeJson(usedContexts == null ? List.of() : usedContexts));
        messageRepository.save(assistantMsg);

        if (!StringUtils.hasText(conversation.getTitle()) || "新对话".equals(conversation.getTitle())) {
            conversation.setTitle(buildTitle(userMessageContent, null));
        }
        conversationRepository.save(conversation);
    }

    public AiConversationEntity requireOwnedConversation(String userId, String conversationId) {
        if (!StringUtils.hasText(conversationId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "conversationId is required");
        }
        return conversationRepository.findByConversationIdAndUserIdAndDeletedFalse(conversationId.trim(), userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "conversation not found: " + conversationId));
    }

    private AiApiModels.AiConversationSummary toSummary(AiConversationEntity entity) {
        return new AiApiModels.AiConversationSummary(
                entity.getConversationId(),
                entity.getTitle(),
                entity.getScene(),
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }

    private AiApiModels.AiConversationMessage toMessageDto(AiConversationMessageEntity entity) {
        return new AiApiModels.AiConversationMessage(
                entity.getMessageId(),
                entity.getRole().name().toLowerCase(Locale.ROOT),
                entity.getContent(),
                entity.getReasoning(),
                entity.getModel(),
                entity.getProvider(),
                entity.isFallback(),
                readSources(entity.getSourcesJson()),
                readStringList(entity.getUsedContextsJson()),
                entity.getCreatedAt()
        );
    }

    private List<AiApiModels.AiSourceRef> readSources(String json) {
        if (!StringUtils.hasText(json)) return List.of();
        try {
            return objectMapper.readValue(json, new TypeReference<List<AiApiModels.AiSourceRef>>() {});
        } catch (Exception e) {
            return List.of();
        }
    }

    private List<String> readStringList(String json) {
        if (!StringUtils.hasText(json)) return List.of();
        try {
            return objectMapper.readValue(json, new TypeReference<List<String>>() {});
        } catch (Exception e) {
            return List.of();
        }
    }

    private String writeJson(Object value) {
        try {
            return objectMapper.writeValueAsString(value);
        } catch (Exception e) {
            throw new IllegalStateException("Failed to write json", e);
        }
    }

    private String buildTitle(String firstMessage, String customTitle) {
        String value = StringUtils.hasText(customTitle) ? customTitle.trim() : firstMessage == null ? "" : firstMessage.trim();
        if (!StringUtils.hasText(value)) return "新对话";

        value = value.replaceAll("\\s+", " ");
        return value.length() <= 40 ? value : value.substring(0, 40) + "…";
    }

    private String requireUserId(String userId) {
        if (!StringUtils.hasText(userId)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "login required");
        }
        return userId.trim();
    }
}