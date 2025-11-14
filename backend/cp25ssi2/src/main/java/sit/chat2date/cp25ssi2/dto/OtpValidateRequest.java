package sit.chat2date.cp25ssi2.dto;

import lombok.Data;
import sit.chat2date.cp25ssi2.enums.Role;

@Data
public class OtpValidateRequest {
    private String phoneNumber;
    private String token;    // จาก otp-send
    private String otpCode; // โค้ดที่ผู้ใช้กรอก
    private String refCode;  // optional
}
