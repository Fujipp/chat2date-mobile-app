package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.ColumnDefault;
import sit.chat2date.cp25ssi2.enums.ChatAccessActionType;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "chat_access_logs")
public class ChatAccessLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "chatAccessId", nullable = false)
    private Long chatAccessId;

    @Column(name = "userId", nullable = false)
    private String userId;

    @Column(name = "roomId", nullable = false)
    private Integer roomId;

    @Enumerated(EnumType.STRING)
    @Column(name = "actionType", nullable = false)
    private ChatAccessActionType actionType;

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
