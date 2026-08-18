package sit.chat2date.cp25ssi2.dto;

import lombok.Data;

@Data
public class OtpSendRequest {
  private String phoneNumber;    // 08xxxxxxxx
  private String refCode;
  private String deviceId;// optional
}
