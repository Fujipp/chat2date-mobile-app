package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.SosIncident;
import sit.chat2date.cp25ssi2.enums.SosStatus;

import java.util.List;
import java.util.Optional;

public interface SosIncidentRepository extends JpaRepository<SosIncident, Integer> {
    Optional<SosIncident> findFirstByReporterIdOrderByIncidentIdDesc(String reporterId);
}
