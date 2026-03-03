package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "post_trip_reviews")
public class PostTripReview {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "reviewId", nullable = false)
    private Integer reviewId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    @JoinColumn(name = "appointmentId", nullable = false)
    private Appointment appointment;

    @Column(name = "reviewerId", nullable = false, length = 36)
    private String reviewerId;

    @Column(name = "targetUserId", nullable = false, length = 36)
    private String targetUserId;

    @Column(name = "isSatisfied", nullable = false)
    private Boolean isSatisfied;

    @Column(name = "wantToContinue")
    private Boolean wantToContinue;

    @Column(name = "wantToUnmatch")
    private Boolean wantToUnmatch;

    @ColumnDefault("CURRENT_TIMESTAMP")
    @Column(name = "createdAt", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
