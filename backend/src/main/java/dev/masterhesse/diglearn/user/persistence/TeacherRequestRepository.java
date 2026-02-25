package dev.masterhesse.diglearn.user.persistence;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TeacherRequestRepository extends JpaRepository<TeacherRequestEntity, String> {
    List<TeacherRequestEntity> findByStatusOrderByRequestedAtAsc(TeacherRequestStatus status);
}