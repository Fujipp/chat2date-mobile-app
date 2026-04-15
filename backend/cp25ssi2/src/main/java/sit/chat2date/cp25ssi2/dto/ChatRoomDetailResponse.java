package sit.chat2date.cp25ssi2.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatRoomDetailResponse {
    private RoomInfo room;
    private List<ChatMessageDTO> chat;
    private PartnerInfo partner;
    private Integer relationshipScore;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RoomInfo {
        private String roomId;
        private Boolean isRead;
        private Boolean isChatDisabled; // true if report exists between users
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PartnerInfo {
        private String senderName;
        private List<String> senderImage;
        private List<Integer> interests;
        private List<Integer> lifeStyles;
        private List<Integer> travelStyles;
        private Double distance;
    }
}
