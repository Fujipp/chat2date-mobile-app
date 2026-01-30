package sit.chat2date.cp25ssi2.dto;

import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class GameResumeResponse {
    private String gameId;
    private String status;
    private Integer totalScore;
    private List<GameQuestionDTO> questions;
    private List<String> myAnsweredQuestionIds;

    private String myAvatar;
    private String partnerAvatar;
    private Integer relationshipScore;
}