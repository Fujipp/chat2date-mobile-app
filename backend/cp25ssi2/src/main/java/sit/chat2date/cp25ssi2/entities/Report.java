package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.GenericGenerator;
import sit.chat2date.cp25ssi2.enums.ReportStatus;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "report")
public class Report {
    @Id
    @GeneratedValue(generator = "uuid2")
    @GenericGenerator(name = "uuid2", strategy = "uuid2")
    @Column(name = "reportId", nullable = false)
    private String reportId;

    @Column(name = "reporterId", nullable = false)
    private String reporterId;

    @Column(name = "targetUserId", nullable = false)
    private String targetUserId;

    @Column(name = "reason", nullable = false)
    private String reason;

    @Column(name = "anotherReason", columnDefinition = "TEXT")
    private String anotherReason;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private ReportStatus status;

    @ColumnDefault("false")
    @Column(name = "isNotified", nullable = false)
    private Boolean isNotified;

    @ColumnDefault("CURRENT_TIMESTAMP")
    @Column(name = "createdAt", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (isNotified == null) {
            isNotified = false;
        }
        if (status == null) {
            status = ReportStatus.PENDING;
        }
    }
}
