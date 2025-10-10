package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "user_has_interest")
public class UserHasInterest {
    @EmbeddedId
    private UserHasInterestId id;

    @MapsId("userUserid")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_userId", nullable = false)
    private User userUser;

    @MapsId("interestInterestid")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "interest_interestId", nullable = false)
    private Interest interestInterest;

}