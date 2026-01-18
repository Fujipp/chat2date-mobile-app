package sit.chat2date.cp25ssi2.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import sit.chat2date.cp25ssi2.enums.ChatAccessActionType;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatAccessStatusResponse {
    private String roomId;
    private List<RoomMember> roomMember;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RoomMember {
        private String userId;
        private ChatAccessActionType type;
    }
}
