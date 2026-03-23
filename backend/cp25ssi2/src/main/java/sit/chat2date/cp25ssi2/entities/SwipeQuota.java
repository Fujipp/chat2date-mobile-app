package sit.chat2date.cp25ssi2.entities;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;

@Entity
@Table(name = "swipe_quota")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SwipeQuota {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "quotaId")
    private Integer quotaId;

    @Column(name = "userId", nullable = false, unique = true, length = 36)
    private String userId;

    @Column(name = "swipeCount", nullable = false)
    private int swipeCount = 0;

    @Column(name = "swipeDate")
    private LocalDate swipeDate;

    @Column(name = "restrictUntil")
    private LocalDateTime restrictUntil;

    @Column(name = "lastReportAt")
    private LocalDate lastReportAt;
}
