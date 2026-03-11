package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.Message;
import sit.chat2date.cp25ssi2.entities.PlaceConfirmation;
import sit.chat2date.cp25ssi2.enums.ConfirmationStatus;

import java.util.Optional;

public interface PlaceConfirmationRepository extends JpaRepository<PlaceConfirmation, Long> {
    // ลบ _Id ออก เพราะ match คือ Integer อยู่แล้ว
    Optional<PlaceConfirmation> findFirstByMatchAndStatusOrderByConfirmIdDesc(Integer matchId, ConfirmationStatus status);
}
