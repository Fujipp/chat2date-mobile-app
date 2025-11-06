package sit.chat2date.cp25ssi2.clients;

import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
@RequiredArgsConstructor
public class SmsmktClient {

  private final RestTemplate restTemplate;

  @Value("${smsmkt.apiKey}")    String apiKey;
  @Value("${smsmkt.secretKey}") String secretKey;
  @Value("${smsmkt.projectKey}") String projectKey;

  private HttpHeaders headersJson() {
    HttpHeaders h = new HttpHeaders();
    h.add("api_key", apiKey);
    h.add("secret_key", secretKey);
    h.setContentType(MediaType.APPLICATION_JSON);
    return h;
  }

  /** ส่ง OTP -> คืน token */
  public String send(String phone08, String refCode) {
    var url = "https://portal-otp.smsmkt.com/api/otp-send";
    var payload = new java.util.HashMap<String, Object>();
    payload.put("project_key", projectKey);
    payload.put("phone", normalizePhone(phone08));  // 08xxxxxxxx
    if (refCode != null && !refCode.isBlank()) payload.put("ref_code", refCode);

    var req = new HttpEntity<>(payload, headersJson());
    ResponseEntity<Map> res = restTemplate.postForEntity(url, req, Map.class);

    if (res.getStatusCode() != HttpStatus.OK) {
      throw new RuntimeException("SMSMKT HTTP " + res.getStatusCode());
    }
    Map<?,?> m = res.getBody();
    if (m == null || !"000".equals(m.get("code"))) {
      throw new RuntimeException("SMSMKT error: " + (m != null ? m.get("detail") : "null"));
    }
    Map<?,?> result = (Map<?,?>) m.get("result");
    var token = result != null ? String.valueOf(result.get("token")) : null;
    if (token == null || token.isBlank()) {
      throw new RuntimeException("No token from SMSMKT");
    }
    return token;
  }

  /** ตรวจ OTP -> true/false */
  public boolean validate(String token, String otpCode, String refCode) {
    var url = "https://portal-otp.smsmkt.com/api/otp-validate";
    var payload = new java.util.HashMap<String, Object>();
    payload.put("token", token);
    payload.put("otp_code", otpCode);
    if (refCode != null && !refCode.isBlank()) payload.put("ref_code", refCode);

    var req = new HttpEntity<>(payload, headersJson());
    ResponseEntity<Map> res = restTemplate.postForEntity(url, req, Map.class);

    if (res.getStatusCode() != HttpStatus.OK) return false;
    Map<?,?> m = res.getBody();
    if (m == null || !"000".equals(m.get("code"))) return false;

    Object status = ((Map<?,?>) m.get("result")).get("status");
    return (status instanceof Boolean) ? (Boolean) status : true; // กันกรณี API ไม่ส่ง status
  }

  private String normalizePhone(String phone) {
    if (phone == null) return "";
    var p = phone.replaceAll("\\D", "");
    if (p.startsWith("66")) p = "0" + p.substring(2);
    return p;
  }
}
