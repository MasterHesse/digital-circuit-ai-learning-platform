package dev.masterhesse.diglearn.ai.application;

import dev.masterhesse.diglearn.classroom.persistence.ClassMembershipEntity;
import dev.masterhesse.diglearn.classroom.persistence.ClassMembershipRepository;
import dev.masterhesse.diglearn.classroom.persistence.ClassMembershipStatus;
import dev.masterhesse.diglearn.practice.persistence.QuestionAttemptRepository;
import dev.masterhesse.diglearn.practice.persistence.UserQuestionStateRepository;
import dev.masterhesse.diglearn.user.UserRole;
import dev.masterhesse.diglearn.user.persistence.AppUserEntity;
import dev.masterhesse.diglearn.user.persistence.AppUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class LearningContextAssembler {

    public record LearningContextPayload(
            String promptText,
            List<String> usedContexts
    ) {
    }

    private final AppUserRepository appUserRepository;
    private final ClassMembershipRepository classMembershipRepository;
    private final QuestionAttemptRepository questionAttemptRepository;
    private final UserQuestionStateRepository userQuestionStateRepository;

    public LearningContextPayload build(String userId, boolean useProfileContext) {
        if (!useProfileContext || !StringUtils.hasText(userId)) {
            return new LearningContextPayload("", List.of());
        }

        AppUserEntity user = appUserRepository.findById(userId.trim()).orElse(null);
        if (user == null) {
            return new LearningContextPayload("", List.of());
        }

        StringBuilder sb = new StringBuilder();
        LinkedHashSet<String> used = new LinkedHashSet<>();

        appendBasicProfile(sb, user);
        used.add("PROFILE_BASIC");

        if (user.getRole() == UserRole.STUDENT) {
            boolean hasClassroom = appendClassroomProfile(sb, user.getUserId());
            if (hasClassroom) used.add("PROFILE_CLASSROOM");
        }

        boolean hasPractice = appendPracticeProfile(sb, user.getUserId());
        if (hasPractice) used.add("PROFILE_PRACTICE");

        appendDiagnosis(sb, user.getUserId());

        return new LearningContextPayload(sb.toString().trim(), new ArrayList<>(used));
    }

    private void appendBasicProfile(StringBuilder sb, AppUserEntity user) {
        sb.append("[用户基础画像]\n")
                .append("- 用户ID：").append(user.getUserId()).append("\n")
                .append("- 姓名：").append(nullSafe(user.getName())).append("\n")
                .append("- 用户名：").append(nullSafe(user.getUsername())).append("\n")
                .append("- 角色：").append(user.getRole() == null ? "UNKNOWN" : user.getRole().name()).append("\n\n");
    }

    private boolean appendClassroomProfile(StringBuilder sb, String userId) {
        List<ClassMembershipEntity> memberships = classMembershipRepository.findByStudentIdOrderByRequestedAtDesc(userId);
        if (memberships.isEmpty()) {
            sb.append("[班级画像]\n")
                    .append("- 当前无班级申请/加入记录\n\n");
            return false;
        }

        long approved = memberships.stream().filter(m -> m.getStatus() == ClassMembershipStatus.APPROVED).count();
        long pending = memberships.stream().filter(m -> m.getStatus() == ClassMembershipStatus.PENDING).count();
        long rejected = memberships.stream().filter(m -> m.getStatus() == ClassMembershipStatus.REJECTED).count();

        Optional<ClassMembershipEntity> latestApproved = memberships.stream()
                .filter(m -> m.getStatus() == ClassMembershipStatus.APPROVED)
                .findFirst();

        sb.append("[班级画像]\n")
                .append("- 已加入班级数：").append(approved).append("\n")
                .append("- 待审核申请数：").append(pending).append("\n")
                .append("- 被拒绝申请数：").append(rejected).append("\n");

        latestApproved.ifPresent(m -> sb.append("- 最近一个已加入班级ID：").append(m.getClassId()).append("\n"));

        sb.append("\n");
        return true;
    }

    private boolean appendPracticeProfile(StringBuilder sb, String userId) {
        long attempts = questionAttemptRepository.countByUserIdAndIsCorrectIsNotNull(userId);
        long correct = questionAttemptRepository.countByUserIdAndIsCorrectTrue(userId);
        int accuracy = attempts == 0 ? 0 : (int) Math.round(correct * 100.0 / attempts);
        long wrongPool = userQuestionStateRepository.countByUserIdAndMasteredFalseAndWrongCountGreaterThan(userId, 0);

        List<UserQuestionStateRepository.RecommendedRow> weakRows =
                userQuestionStateRepository.findRecommended(userId).stream().limit(5).toList();

        sb.append("[练习画像]\n")
                .append("- 累计有效作答：").append(attempts).append("\n")
                .append("- 当前正确率：").append(accuracy).append("%\n")
                .append("- 当前错题池数量：").append(wrongPool).append("\n");

        if (!weakRows.isEmpty()) {
            sb.append("- 当前重点错题示例：\n");
            for (UserQuestionStateRepository.RecommendedRow row : weakRows) {
                sb.append("  - ")
                        .append(trimStem(row.getStem()))
                        .append("（wrongCount=")
                        .append(row.getWrongCount())
                        .append(", difficulty=")
                        .append(row.getDifficulty())
                        .append("）\n");
            }
        }

        sb.append("\n");
        return attempts > 0 || wrongPool > 0 || !weakRows.isEmpty();
    }

    private void appendDiagnosis(StringBuilder sb, String userId) {
        long attempts = questionAttemptRepository.countByUserIdAndIsCorrectIsNotNull(userId);
        long correct = questionAttemptRepository.countByUserIdAndIsCorrectTrue(userId);
        int accuracy = attempts == 0 ? 0 : (int) Math.round(correct * 100.0 / attempts);
        long wrongPool = userQuestionStateRepository.countByUserIdAndMasteredFalseAndWrongCountGreaterThan(userId, 0);

        sb.append("[画像解读]\n");
        if (attempts == 0) {
            sb.append("- 该用户目前练习记录较少，建议从基础章节练习开始。\n");
        } else {
            if (accuracy < 60) {
                sb.append("- 该用户当前正确率偏低，建议优先复盘错题与基础概念。\n");
            } else if (accuracy < 80) {
                sb.append("- 该用户已有一定基础，建议通过针对性巩固提升稳定性。\n");
            } else {
                sb.append("- 该用户基础较稳定，可适当提高讲解深度与练习难度。\n");
            }

            if (wrongPool > 0) {
                sb.append("- 当前仍存在错题池，学习建议应优先覆盖薄弱点。\n");
            }
        }
        sb.append("\n");
    }

    private String trimStem(String stem) {
        String s = stem == null ? "" : stem.replaceAll("\\s+", " ").trim();
        if (s.length() <= 60) return s;
        return s.substring(0, 60) + "…";
    }

    private String nullSafe(String value) {
        return StringUtils.hasText(value) ? value.trim() : "未提供";
    }
}