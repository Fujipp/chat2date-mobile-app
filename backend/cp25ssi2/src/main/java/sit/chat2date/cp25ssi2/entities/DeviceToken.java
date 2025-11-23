package sit.chat2date.cp25ssi2.entities;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "devicetoken")
public class DeviceToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer devicetokenId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "userId", nullable = false)
    private User user;

    @Column(name = "fcmToken", nullable = false, length = 512)
    private String fcmToken;

    @Column(name = "platform", length = 20)
    private String platform; // android / ios

    @Column(name = "createdAt", insertable = false, updatable = false)
    private Instant createdAt;

    // ==== Getter / Setter ====
    public Integer getDevicetokenId() {
        return devicetokenId;
    }

    public void setDevicetokenId(Integer devicetokenId) {
        this.devicetokenId = devicetokenId;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getFcmToken() {
        return fcmToken;
    }

    public void setFcmToken(String fcmToken) {
        this.fcmToken = fcmToken;
    }

    public String getPlatform() {
        return platform;
    }

    public void setPlatform(String platform) {
        this.platform = platform;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
