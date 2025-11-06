package sit.chat2date.cp25ssi2.dto;

import lombok.Data;

@Data
public class OtpSendRequest {
  private String phone;    // 08xxxxxxxx
  private String refCode;  // optional
}
