package sit.chat2date.cp25ssi2.dto;

public class DiscoveryGetResponse {
    private UserSummaryDto user;

    public DiscoveryGetResponse() {}
    public DiscoveryGetResponse(UserSummaryDto user) { this.user = user; }

    public UserSummaryDto getUser() { return user; }
    public void setUser(UserSummaryDto user) { this.user = user; }
}
