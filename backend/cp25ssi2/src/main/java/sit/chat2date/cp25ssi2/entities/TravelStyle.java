package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "travelstyle")
public class TravelStyle {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "travelId", nullable = false)
    private Integer id;

    @Column(name = "travelStyle", nullable = false, length = 50)
    private String travelStyle;

}