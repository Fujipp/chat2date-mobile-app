package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "lifestyle")
public class Lifestyle {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "lifestyleId", nullable = false)
    private Integer id;

    @Column(name = "lifestyle", nullable = false, length = 50)
    private String lifestyle;

}