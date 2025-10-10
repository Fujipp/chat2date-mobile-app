package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "emergencycontact", schema = "chat2date")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EmergencyContact {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "emergencyId")
    private Integer emergencyId;

    @Column(name = "telephoneNumber", nullable = false, length = 10)
    private String telephoneNumber;

    @ManyToOne
    @JoinColumn(name = "userId", nullable = false)
    private User user;
}