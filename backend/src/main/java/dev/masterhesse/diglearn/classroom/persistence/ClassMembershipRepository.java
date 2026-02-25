package dev.masterhesse.diglearn.classroom.persistence;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ClassMembershipRepository extends JpaRepository<ClassMembershipEntity, UUID> {

    Optional<ClassMembershipEntity> findByClassIdAndStudentId(UUID classId, String studentId);

    List<ClassMembershipEntity> findByClassIdAndStatusOrderByRequestedAtAsc(UUID classId, ClassMembershipStatus status);
    List<ClassMembershipEntity> findByClassIdAndStatus(UUID classId, ClassMembershipStatus status);

    List<ClassMembershipEntity> findByStudentIdOrderByRequestedAtDesc(String studentId);

    long deleteByClassId(UUID classId);
    long deleteByClassIdAndStudentId(UUID classId, String studentId);
}