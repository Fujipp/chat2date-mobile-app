package sit.chat2date.cp25ssi2.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.GenericGenerator;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "relationship_stats")
public class RelationshipStats {
    @Id
    @Column(name = "relationshipId", nullable = false)
    private Integer relationshipId;

    @ColumnDefault("0")
    @Column(name = "score", nullable = false)
    private Integer score;

    @ColumnDefault("0")
    @Column(name = "streakDays", nullable = false)
    private Integer streakDays;

    @ColumnDefault("false")
    @Column(name = "isFirstMessageBonus", nullable = false)
    private Boolean isFirstMessageBonus;

    @ColumnDefault("0")
    @Column(name = "dailyMessageCount", nullable = false)
    private Integer dailyMessageCount;

    @ColumnDefault("false")
    @Column(name = "isDailyMessageBonus", nullable = false)
    private Boolean isDailyMessagesBonus;

    @Column(name = "dailyDate")
    private LocalDate dailyDate;

    @ColumnDefault("CURRENT_TIMESTAMP")
    @Column(name = "createdAt", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @ColumnDefault("CURRENT_TIMESTAMP")
    @Column(name = "updatedAt", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (updatedAt == null) {
            updatedAt = LocalDateTime.now();
        }
        if (score == null) {
            score = 0;
        }
        if (streakDays == null) {
            streakDays = 0;
        }
        if (isFirstMessageBonus == null) {
            isFirstMessageBonus = false;
        }
        if (dailyMessageCount == null) {
            dailyMessageCount = 0;
        }
    }

    @OneToOne
    @JoinColumn(name = "relationshipId", referencedColumnName = "matchId", insertable = false, updatable = false)
    @JsonIgnore
    private Match match;

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
