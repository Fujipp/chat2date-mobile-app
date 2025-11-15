package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "user_has_lifestyle")
public class UserHasLifestyle {
    @EmbeddedId
    private UserHasLifestyleId id;

    @MapsId("userUserid")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_userId", nullable = false)
    private User userUser;

    @MapsId("lifestyleLifestyleid")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "lifestyle_lifestyleId", nullable = false)
    private LifeStyle lifestyleLifestyle;

}