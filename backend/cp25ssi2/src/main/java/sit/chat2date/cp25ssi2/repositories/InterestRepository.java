package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import sit.chat2date.cp25ssi2.entities.Interest;

import java.util.List;

public interface InterestRepository extends JpaRepository<Interest, Integer> {
    @Query(value = """
        SELECT it.interest
        FROM user_has_interest uhi
        JOIN interest it ON uhi.interest_interestId = it.interestId
        WHERE uhi.user_userId = :userId
        """, nativeQuery = true)
    List<String> findInterestsByUserId(@Param("userId") String userId);
}
