package sit.chat2date.cp25ssi2.dto;

import lombok.Data;
import sit.chat2date.cp25ssi2.enums.ActionType;

@Data
public class FeedbackRequest {
    private String targetUserId; // เป้าหมาย
    private ActionType action;   // like | dislike


}
