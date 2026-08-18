package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import sit.chat2date.cp25ssi2.enums.SosStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "sos_incidents")
public class SosIncident {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "incidentId", nullable = false)
    private Integer incidentId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    @JoinColumn(name = "appointmentId", nullable = false)
    private Appointment appointment;

    @Column(name = "reporterId", nullable = false, length = 36)
    private String reporterId;

    @Column(name = "targetUserId", nullable = false, length = 36)
    private String targetUserId;

    @Column(name = "latitude", nullable = false, precision = 11, scale = 8)
    private BigDecimal latitude;

    @Column(name = "longitude", nullable = false, precision = 11, scale = 8)
    private BigDecimal longitude;

    @Column(name = "calledNumber", nullable = false, length = 15)
    private String calledNumber;

    @Enumerated(EnumType.STRING)
    @ColumnDefault("'NEW'")
    @Column(name = "status", nullable = false)
    private SosStatus status;

    @ColumnDefault("CURRENT_TIMESTAMP")
    @Column(name = "createdAt", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (status == null) {
            status = SosStatus.NEW;
        }
    }
}
