package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import sit.chat2date.cp25ssi2.enums.ConfirmAction;
import sit.chat2date.cp25ssi2.enums.ConfirmationStatus;

@Entity
@Getter
@Setter
@Table(name = "place_confirmations")
public class PlaceConfirmation {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long confirmId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "roomId", referencedColumnName = "matchId", nullable = false)
    private Match match;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "placeId", referencedColumnName = "placeId", nullable = false)
    private Place place;

    private ConfirmAction user1Confirmed = ConfirmAction.BLANK;

    private ConfirmAction user2Confirmed = ConfirmAction.BLANK;

    @Enumerated(EnumType.STRING)
    private ConfirmationStatus status = ConfirmationStatus.PENDING;
}
