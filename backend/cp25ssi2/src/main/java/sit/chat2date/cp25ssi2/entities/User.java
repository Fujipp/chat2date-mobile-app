package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.ColumnDefault;

import java.time.LocalDate;

@Getter
@Setter
@Entity
@Table(name = "user")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "userId", nullable = false)
    private Integer userId;

    @Column(name = "email", length = 100)
    private String email;

    @Column(name = "phoneNumber", length = 10)
    private String phoneNumber;

    @ColumnDefault("0")
    @Column(name = "isVerify", nullable = false)
    private Boolean isVerify = false;

    @Lob
    @Column(name = "provider", nullable = false)
    private String provider;

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

    @Lob
    @Column(name = "sex", nullable = false)
    private String sex;

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