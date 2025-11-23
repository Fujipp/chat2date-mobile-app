package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.DeviceToken;
import sit.chat2date.cp25ssi2.entities.User;

import java.util.List;
import java.util.Optional;

public interface DeviceTokenRepository extends JpaRepository<DeviceToken, Integer> {

    List<DeviceToken> findByUser(User user);

    Optional<DeviceToken> findByUserAndFcmToken(User user, String fcmToken);

    void deleteByUserAndFcmToken(User user, String fcmToken);
}
