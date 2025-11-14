package sit.chat2date.cp25ssi2.clients;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import sit.chat2date.cp25ssi2.utils.UserFactory;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.repositories.UserRepository;
import sit.chat2date.cp25ssi2.services.JwtTokenUtil;

@Component
@RequiredArgsConstructor
public class SmsmktClient {

    private final RestTemplate restTemplate;
    private final JwtTokenUtil jwtTokenUtil;
    private final UserRepository userRepository;
    private final UserFactory userFactory;

    @Value("${smsmkt.apiKey}")
    String apiKey;
    @Value("${smsmkt.secretKey}")
    String secretKey;
    @Value("${smsmkt.projectKey}")
    String projectKey;

    private HttpHeaders headersJson() {
        HttpHeaders h = new HttpHeaders();
        h.add("api_key", apiKey);
        h.add("secret_key", secretKey);
        h.setContentType(MediaType.APPLICATION_JSON);
        return h;
    }

    /**
     * ส่ง OTP -> คืน token
     */
    public String send(String phone08, String refCode) {
        var url = "https://portal-otp.smsmkt.com/api/otp-send";
        var payload = new HashMap<String, Object>();
        payload.put("project_key", projectKey);
        payload.put("phone", normalizePhone(phone08));  // 08xxxxxxxx
        if (refCode != null && !refCode.isBlank()) payload.put("ref_code", refCode);

        var req = new HttpEntity<>(payload, headersJson());
        ResponseEntity<Map> res = restTemplate.postForEntity(url, req, Map.class);

        if (res.getStatusCode() != HttpStatus.OK) {
            throw new RuntimeException("SMSMKT HTTP " + res.getStatusCode());
        }
        Map<?, ?> m = res.getBody();
        if (m == null || !"000".equals(m.get("code"))) {
            throw new RuntimeException("SMSMKT error: " + (m != null ? m.get("detail") : "null"));
        }
        Map<?, ?> result = (Map<?, ?>) m.get("result");
        var token = result != null ? String.valueOf(result.get("token")) : null;
        if (token == null || token.isBlank()) {
            throw new RuntimeException("No token from SMSMKT");
        }
        return token;
    }

    /**
     * ตรวจ OTP -> true/false
     */
    public Map<String, Object> validate(String token, String otpCode, String refCode, String phoneNumber) {
        // URL ของ OTP validate API
//        String url = "https://portal-otp.smsmkt.com/api/otp-validate";
//
//        // สร้าง payload
//        Map<String, Object> payload = new HashMap<>();
//        payload.put("token", token);
//        payload.put("otp_code", otpCode);
//        if (refCode != null && !refCode.isBlank()) {
//            payload.put("ref_code", refCode);
//        }
//
//        // ส่ง request ไปยัง OTP API
//        HttpEntity<Map<String, Object>> req = new HttpEntity<>(payload, headersJson());
//        ResponseEntity<Map> res = restTemplate.postForEntity(url, req, Map.class);
//
//        // ตรวจสอบ response
        boolean valid = true;
//        if (res.getStatusCode() == HttpStatus.OK && res.getBody() != null) {
//            Map<?, ?> body = res.getBody();
//            if ("000".equals(body.get("code"))) {
//                Map<?, ?> result = (Map<?, ?>) body.get("result");
//                Object status = (result != null) ? result.get("status") : null;
//                valid = (status instanceof Boolean) ? (Boolean) status : true;
//            }
//        }

        Optional<User> userOptional = userRepository.findByPhoneNumber(phoneNumber);
        User user = new User();
        if (valid) {
            if (userOptional.isEmpty()) {
                user = userFactory.createPhoneUser(phoneNumber);
                user = userRepository.save(user);
            }
        }
        String jwtToken = jwtTokenUtil.generateToken(phoneNumber);

        Map<String, Object> response = new HashMap<>();
        if (valid) {
            if (userOptional.isEmpty()) {
                response.put("accessToken", jwtToken);
                response.put("user", user);
            }  else {
                response.put("accessToken", jwtToken);
                response.put("user", userOptional.get());
            }
        }

        return response;
    }

    private String normalizePhone(String phone) {
        if (phone == null) return "";
        var p = phone.replaceAll("\\D", "");
        if (p.startsWith("66")) p = "0" + p.substring(2);
        return p;
    }
}
