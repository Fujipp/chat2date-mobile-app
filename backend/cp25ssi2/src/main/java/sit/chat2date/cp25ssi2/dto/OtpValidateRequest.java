package sit.chat2date.cp25ssi2.dto;

import lombok.Data;

@Data
public class OtpValidateRequest {
  private String token;    // จาก otp-send
  private String otp_code; // โค้ดที่ผู้ใช้กรอก
  private String refCode;  // optional
}
