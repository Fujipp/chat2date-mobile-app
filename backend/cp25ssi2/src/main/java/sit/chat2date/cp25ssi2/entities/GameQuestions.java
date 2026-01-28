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
@Table(name = "gameQuestions")
public class GameQuestions {
    @Id
    @GeneratedValue(generator = "uuid2")
    @GenericGenerator(name = "uuid2", strategy = "uuid2")
    @Column(name = "questionId", nullable = false)
    private String questionId;

    @Column(name = "gameId", nullable = false)
    private String gameId;

    @Column(name = "question", nullable = false, columnDefinition = "TEXT")
    private String question;

    @Column(name = "options", columnDefinition = "JSON")
    private String options;

    @Column(name = "correctAnswer")
    private String correctAnswer;

    @ManyToOne
    @JoinColumn(name = "gameId", referencedColumnName = "gameId", insertable = false, updatable = false)
    private GameSession gameSession;
}
