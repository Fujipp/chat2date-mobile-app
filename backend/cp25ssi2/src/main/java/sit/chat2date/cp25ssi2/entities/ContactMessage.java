package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import jakarta.validation.constraints.Size;
import lombok.*;
import org.hibernate.annotations.ColumnDefault;
import sit.chat2date.cp25ssi2.enums.ContactMessageStatus;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "contact_messages")
public class ContactMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "contactId", nullable = false)
    private Integer contactId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "userId", nullable = false)
    private User user;

    @Size(max = 100)
    @Column(name = "contactName", length = 100)
    private String contactName;

    @Size(max = 100)
    @Column(name = "contactEmail", length = 100)
    private String contactEmail;

    @Size(max = 100)
    @Column(name = "subject", nullable = false, length = 100)
    private String subject;

    @Column(name = "message", nullable = false, columnDefinition = "TEXT")
    private String message;

    @Enumerated(EnumType.STRING)
    @ColumnDefault("'NEW'")
    @Column(name = "status", nullable = false)
    private ContactMessageStatus status = ContactMessageStatus.NEW;

    @Column(name = "repliedAt")
    private LocalDateTime repliedAt;

    @Builder.Default
    @Column(name = "createdAt", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now(java.time.ZoneOffset.UTC);

    @Builder.Default
    @Column(name = "updatedAt", nullable = false)
    private LocalDateTime updatedAt = LocalDateTime.now(java.time.ZoneOffset.UTC);
}