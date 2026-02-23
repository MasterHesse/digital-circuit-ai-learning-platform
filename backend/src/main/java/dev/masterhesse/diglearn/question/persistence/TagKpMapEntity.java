package dev.masterhesse.diglearn.question.persistence;

import jakarta.persistence.*;
import lombok.*;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor @Builder
@Entity
@Table(
    name = "tag_kp_map",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_tag_kp_map_tag_kp", columnNames = {"tag_id", "kp_id"})
    },
    indexes = {
        @Index(name = "idx_tag_kp_map_tag_id", columnList = "tag_id"),
        @Index(name = "idx_tag_kp_map_kp_id", columnList = "kp_id")
    }
)
public class TagKpMapEntity {

    @EmbeddedId
    private TagKpMapId id;

    @MapsId("tagId")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
        name = "tag_id",
        nullable = false,
        foreignKey = @ForeignKey(name = "fk_tag_kp_map_tag")
    )
    private TagEntity tag;

    @Column(name = "weight", nullable = false)
    private int weight;
}