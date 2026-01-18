package sit.chat2date.cp25ssi2.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MatchDTO {
    private String matchId;
    private String partnerId;
    private String partnerName;
    private String partnerImage;
    private String type; // "new" or "old"
}
