package sit.chat2date.cp25ssi2.dto;

import lombok.Builder;
import lombok.Getter;
import sit.chat2date.cp25ssi2.enums.ContactMessageStatus;

import java.time.LocalDateTime;

@Getter
@Builder
public class ContactMessageResponse {
    private Integer contactId;
    private String userId;
    private String contactName;
    private String contactEmail;
    private String subject;
    private String message;
    private ContactMessageStatus status;
    private LocalDateTime repliedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}