package sit.chat2date.cp25ssi2.dto;

import lombok.Builder;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GameStartResponse {
    private String gameId;
    private List<GameQuestionDTO> questions;
    private Integer relationshipScore;
    private String myAvatar;
    private String partnerAvatar;
}
