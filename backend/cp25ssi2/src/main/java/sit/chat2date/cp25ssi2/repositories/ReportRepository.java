package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.Report;
import sit.chat2date.cp25ssi2.enums.ReportStatus;

import java.util.List;
import java.util.Optional;

public interface ReportRepository extends JpaRepository<Report, Integer> {

    List<Report> findByReporterId(String reporterId);

    List<Report> findByTargetUserId(String targetUserId);

    Optional<Report> findByReporterIdAndTargetUserId(String reporterId, String targetUserId);

    boolean existsByReporterIdAndTargetUserId(String reporterId, String targetUserId);

    Page<Report> findByStatus(ReportStatus status, Pageable pageable);

    /**
     * Check if report exists between two users (in either direction)
     * Used to disable chat when one user has reported the other
     */
    boolean existsByReporterIdAndTargetUserIdOrReporterIdAndTargetUserId(
            String reporterId1, String targetUserId1,
            String reporterId2, String targetUserId2);
}
