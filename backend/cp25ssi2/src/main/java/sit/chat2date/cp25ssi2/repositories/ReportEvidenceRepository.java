package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.ReportEvidence;

import java.util.List;

public interface ReportEvidenceRepository extends JpaRepository<ReportEvidence, Integer> {

    List<ReportEvidence> findByReportId(Integer reportId);
}
