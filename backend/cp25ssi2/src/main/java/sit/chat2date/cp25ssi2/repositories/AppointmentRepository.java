package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import sit.chat2date.cp25ssi2.entities.Appointment;
import sit.chat2date.cp25ssi2.enums.AppointmentStatus;

import java.util.List;
import java.util.Optional;

public interface AppointmentRepository extends JpaRepository<Appointment, Integer> {

    List<Appointment> findByMatch_Id(Integer roomId);

    Optional<Appointment> findTopByMatch_IdOrderByCreatedAtDesc(Integer roomId);

    List<Appointment> findByMatch_IdAndStatus(Integer roomId, AppointmentStatus status);

    boolean existsByMatch_IdAndStatusIn(Integer roomId, List<AppointmentStatus> statuses);

    /**
     * Find an appointment by its ID, joining the match so we can verify room
     * membership.
     */
    @Query("SELECT a FROM Appointment a JOIN FETCH a.match WHERE a.appointmentId = :appointmentId")
    Optional<Appointment> findByIdWithMatch(@Param("appointmentId") Integer appointmentId);

    Optional<Appointment> findFirstByMatch_IdOrderByCreatedAtDesc(Integer matchId);
}
