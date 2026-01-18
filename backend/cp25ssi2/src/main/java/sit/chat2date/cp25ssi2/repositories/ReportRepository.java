package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.Report;

import java.util.List;
import java.util.Optional;

public interface ReportRepository extends JpaRepository<Report, String> {

    List<Report> findByReporterId(String reporterId);

    List<Report> findByTargetUserId(String targetUserId);

    Optional<Report> findByReporterIdAndTargetUserId(String reporterId, String targetUserId);

    boolean existsByReporterIdAndTargetUserId(String reporterId, String targetUserId);
}
