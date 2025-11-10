package sit.chat2date.cp25ssi2.dto;

public class FeedbackResponse {
    private String response; // "match" | "notmatch"

    public FeedbackResponse() {}
    public FeedbackResponse(String response) { this.response = response; }
    public String getResponse() { return response; }
    public void setResponse(String response) { this.response = response; }
}
