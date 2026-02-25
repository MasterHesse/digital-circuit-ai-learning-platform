package dev.masterhesse.diglearn.classroom.persistence;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ClassroomRepository extends JpaRepository<ClassroomEntity, UUID> {
    Optional<ClassroomEntity> findByIdAndTeacherId(UUID id, String teacherId);
    List<ClassroomEntity> findByTeacherIdOrderByCreatedAtDesc(String teacherId);
}