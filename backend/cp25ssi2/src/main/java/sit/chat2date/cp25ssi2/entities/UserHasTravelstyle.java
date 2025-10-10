package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "user_has_travelstyle")
public class UserHasTravelstyle {
    @EmbeddedId
    private UserHasTravelstyleId id;

    @MapsId("userUserid")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_userId", nullable = false)
    private User userUser;

    @MapsId("travelstyleTravelid")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "travelstyle_travelId", nullable = false)
    private TravelStyle travelstyleTravel;

}