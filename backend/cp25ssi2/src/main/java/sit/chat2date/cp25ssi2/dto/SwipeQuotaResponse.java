package sit.chat2date.cp25ssi2.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class SwipeQuotaResponse {
    private int currentCount;     // ปัดไปแล้วกี่ครั้ง
    private int remainingCount;
    @JsonProperty("isRestricted")
    private boolean isRestricted; // โดนจำกัดอยู่หรือไม่
    private LocalDateTime unlockAt; // เวลาที่จะปลดล็อก (ไทย)
    private String message;       // ข้อความแจ้ง User (เช่น "เหลืออีก 3 ครั้ง")
}
