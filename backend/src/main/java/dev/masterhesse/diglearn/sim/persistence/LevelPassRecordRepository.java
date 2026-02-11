package dev.masterhesse.diglearn.sim.persistence;

import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface LevelPassRecordRepository extends JpaRepository<LevelPassRecordEntity, Long> {

    Optional<LevelPassRecordEntity> findByUserIdAndLevelCode(String userId, String levelCode);

    @Modifying
    @Query(value = """
        INSERT INTO level_pass_records (user_id, level_code, first_passed_at, last_passed_at, pass_count)
        VALUES (:userId, :levelCode, now(), now(), 1)
        ON CONFLICT (user_id, level_code)
        DO UPDATE SET
            last_passed_at = now(),
            pass_count = level_pass_records.pass_count + 1
        """, nativeQuery = true)
    int upsertPass(@Param("userId") String userId, @Param("levelCode") String levelCode);
}