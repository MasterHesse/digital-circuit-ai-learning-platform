package dev.masterhesse.diglearn.knowledgepoint.dto;

public record PrereqDto(
    String kpId,
    String title,
    String category,
    Integer difficulty,
    Integer depth
) {
}
