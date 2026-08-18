package sit.chat2date.cp25ssi2.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MatchEventPayload {
    private Integer matchId; // roomId for navigating to chat
    private String selfUserId;
    private String selfName;
    private String selfAvatarUrl;
    private String partnerUserId;
    private String partnerName;
    private String partnerAvatarUrl;
    private String matchedAt;
}
