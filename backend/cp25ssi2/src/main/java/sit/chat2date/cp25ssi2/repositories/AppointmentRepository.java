package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.Appointment;
import sit.chat2date.cp25ssi2.enums.AppointmentStatus;

import java.util.List;
import java.util.Optional;

public interface AppointmentRepository extends JpaRepository<Appointment, Integer> {

    List<Appointment> findByMatch_Id(Integer roomId);

    Optional<Appointment> findTopByMatch_IdOrderByCreatedAtDesc(Integer roomId);

    List<Appointment> findByMatch_IdAndStatus(Integer roomId, AppointmentStatus status);

    boolean existsByMatch_IdAndStatusIn(Integer roomId, List<AppointmentStatus> statuses);
}
