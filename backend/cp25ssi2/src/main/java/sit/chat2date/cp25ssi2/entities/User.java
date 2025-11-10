package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.GenericGenerator;
import sit.chat2date.cp25ssi2.enums.Provider;
import sit.chat2date.cp25ssi2.enums.Sex;

import java.time.LocalDate;
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

    @Column(name = "email", length = 100)
    private String email;

    @Column(name = "phoneNumber", length = 10)
    private String phoneNumber;

    @ColumnDefault("0")
    @Column(name = "isVerify", nullable = false)
    private Boolean isVerify = false;

    @Enumerated(EnumType.STRING)
    @Column(name = "provider", nullable = false)
    private Provider provider;

    @Column(name = "firstname", nullable = false, length = 50)
    private String firstname;

    @Column(name = "lastname", nullable = false, length = 50)
    private String lastname;

    @Column(name = "nickname", nullable = false, length = 30)
    private String nickname;

    @Column(name = "cardId", nullable = false, length = 13)
    private String cardId;

    @Column(name = "birthday", nullable = false)
    private LocalDate birthday;

    @Column(name = "age", nullable = false)
    private Integer age;

    @Enumerated(EnumType.STRING)
    @Column(name = "sex", nullable = false)
    private Sex sex;

    @ColumnDefault("0")
    @Column(name = "faceVerify", nullable = false)
    private Boolean faceVerify = false;

    @ColumnDefault("100")
    @Column(name = "behaviorScore", nullable = false)
    private Integer behaviorScore = 100;

    @ColumnDefault("0")
    @Column(name = "isBlacklist", nullable = false)
    private Boolean isBlacklist = false;

    @ColumnDefault("'PENDING'")
    @Column(name = "accountStatus", nullable = false)
    private String accountStatus = "PENDING";

    @Column(name = "version", nullable = false)
    private Integer version;

    @Lob
    @Column(name = "role", nullable = false)
    private String role;

}