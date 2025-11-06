package sit.chat2date.cp25ssi2.controllers;

import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import sit.chat2date.cp25ssi2.clients.SmsmktClient;
import sit.chat2date.cp25ssi2.dto.OtpSendRequest;
import sit.chat2date.cp25ssi2.dto.OtpValidateRequest;

@RestController
@RequestMapping("/api/otp")
@RequiredArgsConstructor
public class OtpController {

  private final SmsmktClient client;

  @PostMapping("/send")
  public Map<String, Object> send(@RequestBody OtpSendRequest body) {
    String token = client.send(body.getPhone(), body.getRefCode());
    return Map.of("token", token);
  }

  @PostMapping("/validate")
  public Map<String, Object> validate(@RequestBody OtpValidateRequest body) {
    boolean ok = client.validate(body.getToken(), body.getOtp_code(), body.getRefCode());
    return Map.of("valid", ok);
  }
}
