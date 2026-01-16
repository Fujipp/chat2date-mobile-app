package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.GenericGenerator;

import java.util.UUID;

@Getter
@Setter
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "reportEvidence")
public class ReportEvidence {
    @Id
    @GeneratedValue(generator = "uuid2")
    @GenericGenerator(name = "uuid2", strategy = "uuid2")
    @Column(name = "evidenceId", nullable = false)
    private String evidenceId;

    @Column(name = "reportId", nullable = false)
    private String reportId;

    @Column(name = "evidenceUrl", columnDefinition = "JSON")
    private String evidenceUrl;

    @ManyToOne
    @JoinColumn(name = "reportId", referencedColumnName = "reportId", insertable = false, updatable = false)
    private Report report;
}
