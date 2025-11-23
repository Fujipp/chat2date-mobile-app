package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import sit.chat2date.cp25ssi2.entities.LifeStyle;
import sit.chat2date.cp25ssi2.entities.TravelStyle;

import java.util.List;

public interface LifeStyleRepository extends JpaRepository<LifeStyle, Integer> {
    @Query(value = """
        SELECT ls.lifeStyle
        FROM user_has_lifestyle uhl
        JOIN lifestyle ls ON uhl.lifestyle_lifestyleId = ls.lifestyleId
        WHERE uhl.user_userId = :userId
        """, nativeQuery = true)
    List<String> findLifeStylesByUserId(@Param("userId") String userId);
}
