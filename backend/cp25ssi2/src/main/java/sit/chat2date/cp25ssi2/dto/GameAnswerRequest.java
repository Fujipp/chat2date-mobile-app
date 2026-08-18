package sit.chat2date.cp25ssi2.dto;

import lombok.Data;

@Data
public class GameAnswerRequest {
    private String userId;
    private String gameId;
    private String questionId;
    private String selectedOption;
}
