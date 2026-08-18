package sit.chat2date.cp25ssi2.entities;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
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

    @Column(name = "roomId")
    private Integer match; // เก็บเป็น Integer (roomId) ตามเดิม

    @Column(name = "placeId")
    private String place; // เก็บเป็น String (UUID) หรือ Integer ตามที่คุณออกแบบ

    @Enumerated(EnumType.STRING)
    @Column(name = "user1Confirmed")
    private ConfirmAction user1Confirmed = ConfirmAction.BLANK;

    @Enumerated(EnumType.STRING)
    @Column(name = "user2Confirmed")
    private ConfirmAction user2Confirmed = ConfirmAction.BLANK;

    @Enumerated(EnumType.STRING)
    private ConfirmationStatus status = ConfirmationStatus.PENDING;
}
