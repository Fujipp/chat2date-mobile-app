package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.GenericGenerator;
import sit.chat2date.cp25ssi2.enums.AccountStatus;
import sit.chat2date.cp25ssi2.enums.Provider;
import sit.chat2date.cp25ssi2.enums.Role;
import sit.chat2date.cp25ssi2.enums.Sex;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "user")
public class User {
    @Id
    @GeneratedValue(generator = "uuid2")
    @GenericGenerator(name = "uuid2", strategy = "uuid2")
    @Column(name = "userId", nullable = false)
    private String userId;

    @Size(max = 100)
    @Column(name = "email", length = 100)
    private String email;

    @Size(max = 10)
    @Column(name = "phoneNumber", length = 10)
    private String phoneNumber;

    @Enumerated(EnumType.STRING)
    @Column(name = "provider", nullable = false)
    private Provider provider;

    @Size(max = 50)
    @Column(name = "firstname", nullable = false, length = 50)
    private String firstname;

    @Size(max = 50)
    @Column(name = "lastname", nullable = false, length = 50)
    private String lastname;

    @Size(max = 30)
    @Column(name = "nickname", nullable = false, length = 30)
    private String nickname;

    @Size(max = 13)
    @Column(name = "cardId", nullable = false, length = 13)
    private String cardId;


    @Column(name = "birthday", nullable = false)
    private LocalDate birthday;

    @Enumerated(EnumType.STRING)
    @Column(name = "sex", nullable = false)
    private Sex sex;

    @ColumnDefault("100")
    @Column(name = "behaviorScore", nullable = false)
    private Integer behaviorScore = 100;

    @ColumnDefault("0")
    @Column(name = "isBlacklist", nullable = false)
    private Boolean isBlacklist = false;

    @Enumerated(EnumType.STRING)
    @Column(name = "accountStatus", nullable = false)
    private AccountStatus accountStatus = AccountStatus.PENDING;

    @NotNull
    @Column(name = "version", nullable = false)
    private Integer version;

    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false)
    private Role role;

    @Column(name = "delete_flag")
    private Boolean deleteFlag = false;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;
}