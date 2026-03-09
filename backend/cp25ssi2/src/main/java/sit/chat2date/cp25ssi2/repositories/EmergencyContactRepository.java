package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.EmergencyContact;

import java.util.List;

public interface EmergencyContactRepository extends JpaRepository<EmergencyContact, Integer> {
    List<EmergencyContact> findByUser_UserId(String userId);
}
