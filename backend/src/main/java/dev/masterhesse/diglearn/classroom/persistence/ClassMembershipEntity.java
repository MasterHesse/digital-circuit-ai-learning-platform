// src/main/java/dev/masterhesse/diglearn/classroom/persistence/ClassMembershipEntity.java
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
        name = "class_membership",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_class_membership", columnNames = {"class_id", "student_id"})
        },
        indexes = {
                @Index(name = "idx_cm_class_status", columnList = "class_id,status"),
                @Index(name = "idx_cm_student_status", columnList = "student_id,status")
        }
)
public class ClassMembershipEntity {

    @Id
    @Column(name = "id", nullable = false)
    private UUID id;

    @Column(name = "class_id", nullable = false)
    private UUID classId;

    @Column(name = "student_id", nullable = false, length = 128)
    private String studentId; // userId(UUID字符串)

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 16)
    private ClassMembershipStatus status = ClassMembershipStatus.PENDING;

    @Column(name = "requested_at", nullable = false)
    private Instant requestedAt;

    @Column(name = "decided_at")
    private Instant decidedAt;

    @Column(name = "decided_by", length = 128)
    private String decidedBy; // teacherId

    @PrePersist
    void prePersist() {
        if (id == null) id = UUID.randomUUID();
        if (requestedAt == null) requestedAt = Instant.now();
    }
}