package sit.chat2date.cp25ssi2.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import sit.chat2date.cp25ssi2.enums.ReportStatus;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReportDetailResponse {
    private Integer reportId;
    private String reporterId;
    private String targetUserId;
    private String reason;
    private String anotherReason;
    private String description;
    private ReportStatus status;
    private Boolean isNotified;
    private LocalDateTime createdAt;
    private List<String> evidenceUrls;

    // Reporter user info
    private UserBasicInfo reporter;

    // Target user info
    private UserBasicInfo targetUser;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserBasicInfo {
        private String userId;
        private String email;
        private String phoneNumber;
        private String firstname;
        private String lastname;
        private String nickname;
        private Integer age;
        private String sex;
        private String accountStatus;
        private Boolean isBlacklist;
        private Integer behaviorScore;
        private String profilePhotoUrl;
    }
}
