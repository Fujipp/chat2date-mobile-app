package sit.chat2date.cp25ssi2.dto;

public class FeedbackResponse {

    // "match" | "notmatch"
    private String status;

    // true = เกิด match แล้ว
    private boolean matched;

    // userId ของคนที่เราไปกด like/dislike
    private String targetUserId;

    // ชื่อไว้โชว์หน้าบ้าน เช่น "กีกี้ ใจดี"
    private String targetName;

    public FeedbackResponse() {
    }

    public FeedbackResponse(String status, boolean matched, String targetUserId, String targetName) {
        this.status = status;
        this.matched = matched;
        this.targetUserId = targetUserId;
        this.targetName = targetName;
    }

    // getter/setter ทั้งชุด
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public boolean isMatched() { return matched; }
    public void setMatched(boolean matched) { this.matched = matched; }

    public String getTargetUserId() { return targetUserId; }
    public void setTargetUserId(String targetUserId) { this.targetUserId = targetUserId; }

    public String getTargetName() { return targetName; }
    public void setTargetName(String targetName) { this.targetName = targetName; }
}
