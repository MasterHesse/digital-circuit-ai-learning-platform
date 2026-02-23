package dev.masterhesse.diglearn.question.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.*;

import java.io.Serializable;
import java.util.UUID;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@EqualsAndHashCode
@Embeddable
public class TagKpMapId implements Serializable {

    @Column(name = "tag_id", nullable = false)
    private UUID tagId;

    @Column(name = "kp_id", nullable = false, length = 64)
    private String kpId;
}