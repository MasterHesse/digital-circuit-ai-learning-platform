package dev.masterhesse.diglearn.question.api;

import dev.masterhesse.diglearn.question.application.TagService;
import dev.masterhesse.diglearn.question.persistence.TagEntity;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/tags")
public class TagController {

    private final TagService tagService;

    @GetMapping
    public List<TagResponse> list() {
        return tagService.list().stream().map(TagResponse::from).toList();
    }

    @GetMapping("/{id}")
    public TagResponse get(@PathVariable UUID id) {
        return TagResponse.from(tagService.get(id));
    }

    @PostMapping
    public TagResponse create(@RequestBody TagCreateRequest req) {
        TagEntity e = tagService.create(req.name, req.description);
        return TagResponse.from(e);
    }

    @PutMapping("/{id}")
    public TagResponse update(@PathVariable UUID id, @RequestBody TagUpdateRequest req) {
        TagEntity e = tagService.update(id, req.name, req.description);
        return TagResponse.from(e);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable UUID id) {
        tagService.delete(id);
    }

    @Data
    public static class TagCreateRequest {
        public String name;
        public String description;
    }

    @Data
    public static class TagUpdateRequest {
        public String name;
        public String description;
    }

    @Data
    public static class TagResponse {
        public UUID id;
        public String name;
        public String description;

        public static TagResponse from(TagEntity e) {
            TagResponse r = new TagResponse();
            r.id = e.getId();
            r.name = e.getName();
            r.description = e.getDescription();
            return r;
        }
    }
}