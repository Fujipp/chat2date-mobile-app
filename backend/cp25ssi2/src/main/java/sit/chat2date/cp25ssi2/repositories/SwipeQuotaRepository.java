package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import sit.chat2date.cp25ssi2.entities.SwipeQuota;

import java.util.Optional;

@Repository
public interface SwipeQuotaRepository extends JpaRepository<SwipeQuota, Integer> {
    Optional<SwipeQuota> findByUserId(String userId);
}
