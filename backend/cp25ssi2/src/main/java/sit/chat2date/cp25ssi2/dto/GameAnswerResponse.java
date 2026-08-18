package sit.chat2date.cp25ssi2.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class GameAnswerResponse {
    private Boolean isCorrect;
    private String correctAnswer;
    private Integer totalScore;
    private Boolean isGameOver;
}
