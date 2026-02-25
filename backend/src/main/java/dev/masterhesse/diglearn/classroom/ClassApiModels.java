package dev.masterhesse.diglearn.classroom;

import dev.masterhesse.diglearn.classroom.persistence.ClassMembershipStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.Instant;
import java.util.UUID;

public class ClassApiModels {

    public record CreateClassRequest(
            @NotBlank @Size(max = 200) String name
    ) {}

    public record ClassResponse(
            UUID id,
            String name,
            String teacherId,
            Instant createdAt
    ) {}

    public record MembershipResponse(
            UUID membershipId,
            UUID classId,
            String studentId,
            ClassMembershipStatus status,
            Instant requestedAt,
            Instant decidedAt,
            String decidedBy
    ) {}

    public record UserProfileResponse(
            String userId,
            String username,
            String email,
            String name
    ) {}

    public record JoinRequestResponse(
            UUID membershipId,
            UUID classId,
            Instant requestedAt,
            UserProfileResponse student
    ) {}

    public record ProgressResponse(
            long attemptedCount,
            long masteredCount,
            long unmasteredWrongCount,
            long totalWrongCount,
            Instant lastAttemptAt
    ) {}

    public record StudentProgressResponse(
            UUID membershipId,
            UUID classId,
            Instant approvedAt,
            UserProfileResponse student,
            ProgressResponse progress
    ) {}

    public record RecommendedQuestionResponse(
            UUID questionId,
            int wrongCount,
            Instant lastWrongAt,
            String stem,
            String type,
            short difficulty
    ) {}

    public record UpdateClassRequest(
            @NotBlank @Size(max = 200) String name
    ) {}

    public record MembershipSummary(
            UUID membershipId,
            ClassMembershipStatus status,
            Instant requestedAt,
            Instant decidedAt
    ) {}

    public record ClassDetailResponse(
            ClassResponse clazz,
            UserProfileResponse teacher,
            MembershipSummary myMembership // STUDENT: 可能为 null；TEACHER: 通常为 null
    ) {}

    public record MyClassResponse(
            UUID classId,
            String name,
            String teacherId,
            Instant createdAt,
            UserProfileResponse teacher,
            MembershipSummary membership
    ) {}
}