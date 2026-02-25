// src/main/java/dev/masterhesse/diglearn/classroom/persistence/ClassroomEntity.java
package dev.masterhesse.diglearn.classroom.persistence;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(
        name = "classes",
        indexes = {
                @Index(name = "idx_classes_teacher", columnList = "teacher_id")
        }
)
public class ClassroomEntity {

    @Id
    @Column(name = "id", nullable = false)
    private UUID id;

    @Column(name = "name", nullable = false, length = 200)
    private String name;

    @Column(name = "teacher_id", nullable = false, length = 128)
    private String teacherId; // userId(UUID字符串)

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @PrePersist
    void prePersist() {
        if (id == null) id = UUID.randomUUID();
        if (createdAt == null) createdAt = Instant.now();
    }
}