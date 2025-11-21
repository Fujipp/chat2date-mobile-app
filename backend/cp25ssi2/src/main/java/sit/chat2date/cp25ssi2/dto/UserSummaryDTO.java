package sit.chat2date.cp25ssi2.dto;

public class UserSummaryDTO {
    private String id;
    private String phone;

    public UserSummaryDTO() {}
    public UserSummaryDTO(String id, String phone) {
        this.id = id; this.phone = phone;
    }

    public String getId() { return id; }
    public String getPhone() { return phone; }

    public void setId(String id) { this.id = id; }
    public void setPhone(String phone) { this.phone = phone; }
}
