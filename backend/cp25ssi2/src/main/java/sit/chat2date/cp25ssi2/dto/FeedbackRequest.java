package sit.chat2date.cp25ssi2.dto;

import sit.chat2date.cp25ssi2.enums.ActionType;

public class FeedbackRequest {
    private String actorUserId;  // คนกด like/dislike
    private String targetUserId; // เป้าหมาย
    private ActionType action;   // like | dislike

    public String getActorUserId() { return actorUserId; }
    public String getTargetUserId() { return targetUserId; }
    public ActionType getAction() { return action; }

    public void setActorUserId(String actorUserId) { this.actorUserId = actorUserId; }
    public void setTargetUserId(String targetUserId) { this.targetUserId = targetUserId; }
    public void setAction(ActionType action) { this.action = action; }
}
