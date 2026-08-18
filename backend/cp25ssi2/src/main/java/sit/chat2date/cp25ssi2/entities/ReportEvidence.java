package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "report_evidences")
public class ReportEvidence {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "evidenceId", nullable = false)
    private Integer evidenceId;

    @Column(name = "reportId", nullable = false)
    private Integer reportId;

    @Column(name = "evidenceUrl", columnDefinition = "JSON")
    private String evidenceUrl;

    @ManyToOne
    @JoinColumn(name = "reportId", referencedColumnName = "reportId", insertable = false, updatable = false)
    private Report report;
}
