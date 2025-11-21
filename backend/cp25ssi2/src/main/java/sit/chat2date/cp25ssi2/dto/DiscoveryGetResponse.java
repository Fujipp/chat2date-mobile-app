package sit.chat2date.cp25ssi2.dto;

public class DiscoveryGetResponse {
    private UserSummaryDTO user;

    public DiscoveryGetResponse() {}
    public DiscoveryGetResponse(UserSummaryDTO user) { this.user = user; }

    public UserSummaryDTO getUser() { return user; }
    public void setUser(UserSummaryDTO user) { this.user = user; }
}
