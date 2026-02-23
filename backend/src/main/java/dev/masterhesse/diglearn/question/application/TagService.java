package dev.masterhesse.diglearn.question.application;

import dev.masterhesse.diglearn.question.persistence.TagEntity;
import dev.masterhesse.diglearn.question.persistence.TagRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TagService {

    private final TagRepository tagRepository;

    public List<TagEntity> list() {
        return tagRepository.findAll();
    }

    public TagEntity get(UUID id) {
        return tagRepository.findById(id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "tag not found: " + id));
    }

    public TagEntity create(String name, String description) {
        String normalized = normalizeName(name);

        if (tagRepository.existsByNameIgnoreCase(normalized)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "tag exists: " + normalized);
        }

        TagEntity e = TagEntity.builder()
            .name(normalized)
            .description(blankToNull(description))
            .build();

        return tagRepository.save(e);
    }

    public TagEntity update(UUID id, String name, String description) {
        TagEntity e = get(id);

        String normalized = normalizeName(name);
        if (!e.getName().equalsIgnoreCase(normalized) && tagRepository.existsByNameIgnoreCase(normalized)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "tag exists: " + normalized);
        }

        e.setName(normalized);
        e.setDescription(blankToNull(description));
        return tagRepository.save(e);
    }

    public void delete(UUID id) {
        TagEntity e = get(id);
        tagRepository.delete(e);
    }

    private static String normalizeName(String s) {
        if (s == null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "name is required");
        String t = s.trim();
        if (t.isEmpty()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "name is required");
        return t.toUpperCase(); // 先简单粗暴；你也可以加正则限制 [A-Z0-9_]+
    }

    private static String blankToNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }
}