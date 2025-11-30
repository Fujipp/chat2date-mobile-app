package sit.chat2date.cp25ssi2.clients;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.TimeUnit;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import sit.chat2date.cp25ssi2.dto.UserDTO;
import sit.chat2date.cp25ssi2.enums.AccountStatus;
import sit.chat2date.cp25ssi2.exceptions.TooManyRequestException;
import sit.chat2date.cp25ssi2.exceptions.UnprocessableEntityException;
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
    @Autowired
    private StringRedisTemplate redis;

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
    public String send(String phone08, String refCode, String deviceId) {
        String phone = normalizePhone(phone08);

        String key = "otp:lock:" + phone + ":" + deviceId;
        if (redis.hasKey(key)) {
            long waitSec = Optional.ofNullable(redis.getExpire(key, TimeUnit.SECONDS)).orElse(60L);
            throw new TooManyRequestException("กรุณารออีก " + waitSec + " วินาที ก่อนขอ OTP ใหม่");
        }
        redis.opsForValue().set(key, "1", 60, TimeUnit.SECONDS);
        var url = "https://portal-otp.smsmkt.com/api/otp-send";
        var payload = new HashMap<>();
        payload.put("project_key", projectKey);
        payload.put("phone", normalizePhone(phone08));  // 08xxxxxxxx
        if (refCode != null && !refCode.isBlank()) payload.put("ref_code", refCode);

        var req = new HttpEntity<>(payload, headersJson());
        ResponseEntity<Map> res = restTemplate.postForEntity(url, req, Map.class);

        var token = getString(res);
        return token;
    }

    private static String getString(ResponseEntity<Map> res) {
        if (res.getStatusCode() != HttpStatus.OK) {
            throw new UnprocessableEntityException("SMSMKT HTTP " + res.getStatusCode());
        }

        Map<?, ?> m = res.getBody();
        if (m == null || !"000".equals(m.get("code"))) {
            throw new UnprocessableEntityException("SMSMKT error: " + (m != null ? m.get("detail") : "null"));
        }
        Map<?, ?> result = (Map<?, ?>) m.get("result");
        var token = result != null ? String.valueOf(result.get("token")) : null;
        if (token == null || token.isBlank()) {
            throw new UnprocessableEntityException("No token from SMSMKT");
        }
        return token;
    }

    /**
     * ตรวจ OTP -> true/false
     */
    public Map<String, Object> validate(String token, String otpCode, String refCode, String phoneNumber, boolean onLogin) {
        // URL ของ OTP validate API
        String url = "https://portal-otp.smsmkt.com/api/otp-validate";

        // สร้าง payload
        Map<String, Object> payload = new HashMap<>();
        payload.put("token", token);
        payload.put("otp_code", otpCode);
        if (refCode != null && !refCode.isBlank()) {
            payload.put("ref_code", refCode);
        }

        // ส่ง request ไปยัง OTP API
        HttpEntity<Map<String, Object>> req = new HttpEntity<>(payload, headersJson());
        ResponseEntity<Map> res = restTemplate.postForEntity(url, req, Map.class);

        if (res.getStatusCode() != HttpStatus.OK || res.getBody() == null) {
            throw new UnprocessableEntityException("SMSMKT HTTP " + res.getStatusCode());
        }

//        // ตรวจสอบ response
        boolean valid = false;
        if (res.getStatusCode() == HttpStatus.OK && res.getBody() != null) {
            Map<?, ?> body = res.getBody();
            if ("000".equals(body.get("code"))) {
                Map<?, ?> result = (Map<?, ?>) body.get("result");
                Object status = (result != null) ? result.get("status") : null;
                valid = (status instanceof Boolean) ? (Boolean) status : true;
            }
        }

        Optional<User> userOptional = userRepository.findByPhoneNumber(phoneNumber);
        User user = new User();
        if (valid) {
            if (userOptional.isEmpty()) {
                user = userFactory.createPhoneUser(phoneNumber);
                user = userRepository.save(user);
            }
        }
        String jwtToken = jwtTokenUtil.generateToken(phoneNumber);
        String jwtRefreshToken = jwtTokenUtil.generateRefreshToken(phoneNumber);
        UserDTO userDto;

        Map<String, Object> response = new LinkedHashMap<>();
        if (valid) {
            if (userOptional.isEmpty()) {
                userDto = UserDTO.builder()
                        .id(user.getUserId())
                        .email(user.getEmail())
                        .phoneNumber(user.getPhoneNumber())
                        .accountStatus(user.getAccountStatus() != null ? user.getAccountStatus().toString() : null)
                        .version(user.getVersion())
                        .build();
                response.put("user", userDto);
            } else {
                if (onLogin && userOptional.get().getAccountStatus() == AccountStatus.ACTIVE) {
                    response.put("user", userOptional);
                } else {
                    userDto = UserDTO.builder()
                            .id(userOptional.get().getUserId())
                            .email(userOptional.get().getEmail())
                            .phoneNumber(userOptional.get().getPhoneNumber())
                            .accountStatus(userOptional.get().getAccountStatus() != null ? userOptional.get().getAccountStatus().toString() : null)
                            .version(userOptional.get().getVersion())
                            .build();
                    response.put("user", userDto);
                }

            }
            response.put("accessToken", jwtToken);
            response.put("refreshToken", jwtRefreshToken);
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
