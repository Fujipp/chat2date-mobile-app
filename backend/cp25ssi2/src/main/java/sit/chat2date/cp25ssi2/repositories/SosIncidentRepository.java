package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.SosIncident;
import sit.chat2date.cp25ssi2.enums.SosStatus;

import java.util.List;

public interface SosIncidentRepository extends JpaRepository<SosIncident, Integer> {

    List<SosIncident> findByAppointment_AppointmentId(Integer appointmentId);

    List<SosIncident> findByReporterId(String reporterId);

    List<SosIncident> findByTargetUserId(String targetUserId);

    List<SosIncident> findByStatus(SosStatus status);
}
