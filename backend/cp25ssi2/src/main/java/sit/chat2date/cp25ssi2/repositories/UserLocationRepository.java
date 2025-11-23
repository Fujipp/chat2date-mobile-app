package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.PreferenceMatch;
import sit.chat2date.cp25ssi2.entities.UserLocation;

public interface UserLocationRepository extends JpaRepository<UserLocation, Integer> {
    UserLocation findByUser_UserId(String userId);
    UserLocation findFirstByUser_UserId(String userId);
}
