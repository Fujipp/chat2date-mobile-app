package sit.chat2date.cp25ssi2.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class GameCheckResponse {
    private boolean canPlay;
    private String gameStatus;
    private String gameId;
    private Long remainingSeconds;
}