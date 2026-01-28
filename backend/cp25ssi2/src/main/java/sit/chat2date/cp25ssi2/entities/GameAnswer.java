package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.GenericGenerator;


@Getter
@Setter
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "gameAnswer")
public class GameAnswer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String userId;

    @ManyToOne
    @JoinColumn(name = "questionId")
    private GameQuestions question;

    @ManyToOne
    @JoinColumn(name = "gameId")
    private GameSession gameSession;

    private String selectedOption;
    private Boolean isCorrect;
}
