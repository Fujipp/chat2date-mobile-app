package sit.chat2date.cp25ssi2.dto;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Data
@Getter
@Setter
public class RecommendationResponse {
    private String roomId;
    private String mode;
    private String leaderId;
    private int winningIndex;
    private List<PlaceDTO> places; // Place คือ Model ของร้านค้าที่คุณมี

    // Constructor, Getter, Setter
    public RecommendationResponse() {}

    public RecommendationResponse(String roomId, String mode, String leaderId, int winningIndex, List<PlaceDTO> places) {
        this.roomId = roomId;
        this.mode = mode;
        this.leaderId = leaderId;
        this.winningIndex = winningIndex;
        this.places = places;
    }

}
