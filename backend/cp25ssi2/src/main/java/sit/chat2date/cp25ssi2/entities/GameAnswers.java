package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import lombok.*;


@Getter
@Setter
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "game_answers")
public class GameAnswers {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String userId;

    @ManyToOne
    @JoinColumn(name = "questionId")
    private GameQuestions question;

    @ManyToOne
    @JoinColumn(name = "gameId")
    private GameSessions gameSessions;

    private String selectedOption;
    private Boolean isCorrect;
}
