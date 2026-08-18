package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.GenericGenerator;
import sit.chat2date.cp25ssi2.enums.GameSessionStatus;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "game_sessions")
public class GameSessions {
    @Id
    @GeneratedValue(generator = "uuid2")
    @GenericGenerator(name = "uuid2", strategy = "uuid2")
    @Column(name = "gameId", nullable = false)
    private String gameId;

    @Column(name = "roomId", nullable = false)
    private String roomId;

    @ColumnDefault("0")
    @Column(name = "totalScore", nullable = false)
    private Integer totalScore;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private GameSessionStatus status;

    @Column(name = "targetScore", nullable = false)
    private Integer targetScore;

    @ColumnDefault("CURRENT_TIMESTAMP")
    @Column(name = "createdAt", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (totalScore == null) {
            totalScore = 0;
        }
        if (status == null) {
            status = GameSessionStatus.ACTIVE;
        }
    }
}
