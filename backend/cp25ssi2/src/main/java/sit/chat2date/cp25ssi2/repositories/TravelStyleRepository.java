package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import sit.chat2date.cp25ssi2.entities.TravelStyle;

import java.util.List;

public interface TravelStyleRepository extends JpaRepository<TravelStyle, Integer> {
    @Query(value = """
    SELECT ts.travelStyle
    FROM user_has_travelstyle uht
    JOIN travelstyle ts ON uht.travelstyle_travelId  = ts.travelId
    WHERE uht.user_userId = :userId
    """, nativeQuery = true)
    List<String> findTravelStylesByUserId(@Param("userId") String userId);

}
