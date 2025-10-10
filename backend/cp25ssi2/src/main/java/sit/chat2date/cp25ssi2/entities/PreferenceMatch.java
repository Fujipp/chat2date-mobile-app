package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

@Getter
@Setter
@Entity
@Table(name = "preferencematch")
public class PreferenceMatch {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "preferenceId", nullable = false)
    private Integer id;

    @Lob
    @Column(name = "interestedGender", nullable = false)
    private String interestedGender;

    @Lob
    @Column(name = "interestedTravelStyle", nullable = false)
    private String interestedTravelStyle;

    @Lob
    @Column(name = "interestedLifeStyle", nullable = false)
    private String interestedLifeStyle;

    @Lob
    @Column(name = "interestedInterest", nullable = false)
    private String interestedInterest;

    @Column(name = "interestedAgeMin", nullable = false)
    private Integer interestedAgeMin;

    @Column(name = "interestedAgeMax", nullable = false)
    private Integer interestedAgeMax;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    @JoinColumn(name = "userId", nullable = false)
    private User user;

}