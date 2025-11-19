package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import sit.chat2date.cp25ssi2.enums.PreferenceLevel;

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
    @Enumerated(EnumType.STRING)
    @Column(name = "interestedGender", nullable = false)
    private PreferenceLevel interestedGender;

    @Lob
    @Enumerated(EnumType.STRING)
    @Column(name = "interestedTravelStyle", nullable = false)
    private PreferenceLevel interestedTravelStyle;

    @Lob
    @Enumerated(EnumType.STRING)
    @Column(name = "interestedLifeStyle", nullable = false)
    private PreferenceLevel interestedLifeStyle;

    @Lob
    @Enumerated(EnumType.STRING)
    @Column(name = "interestedInterest", nullable = false)
    private PreferenceLevel interestedInterest;

    @Column(name = "interestedAgeMin", nullable = false)
    private Integer interestedAgeMin;

    @Column(name = "interestedAgeMax", nullable = false)
    private Integer interestedAgeMax;

    @Column(name = "interestedDistanceMin", nullable = false)
    private Integer interestedDistanceMin;

    @Column(name = "interestedDistanceMax", nullable = false)
    private Integer interestedDistanceMax;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    @JoinColumn(name = "userId", nullable = false)
    private User user;

}