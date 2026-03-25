package sit.chat2date.cp25ssi2.clients;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.TimeUnit;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.server.ResponseStatusException;
import sit.chat2date.cp25ssi2.dto.UserDTO;
import sit.chat2date.cp25ssi2.enums.AccountStatus;
import sit.chat2date.cp25ssi2.exceptions.ForbiddenAccessException;
import sit.chat2date.cp25ssi2.exceptions.TooManyRequestException;
import sit.chat2date.cp25ssi2.exceptions.UnprocessableEntityException;
import sit.chat2date.cp25ssi2.services.AuthService;
import sit.chat2date.cp25ssi2.utils.UserFactory;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.repositories.UserRepository;
import sit.chat2date.cp25ssi2.services.JwtTokenUtil;

@Component
@RequiredArgsConstructor
public class ThSMSClient {

    private final JwtTokenUtil jwtTokenUtil;
    private final UserRepository userRepository;
    private final UserFactory userFactory;
    @Autowired
    private StringRedisTemplate redis;

    @Value("${thsms.apiToken}")
    String apiToken;
    @Autowired
    private RestTemplate restTemplate;

    private HttpHeaders headersJson() {
        HttpHeaders h = new HttpHeaders();
        h.setBearerAuth(apiToken);
        h.setContentType(MediaType.APPLICATION_JSON);
        return h;
    }

    /**
     * ส่ง OTP -> คืน token
     */
    public String send(String phone08, String refCode, String deviceId) {
        User user = userRepository.findUsersByPhoneNumber(phone08);
        boolean mock = false;

        if (user != null) {
            if (Boolean.TRUE.equals(user.getDeleteFlag())) {
                LocalDateTime deletedAt = user.getDeletedAt();
                LocalDateTime now = LocalDateTime.now();
                long daysRemaining = 30 - Duration.between(deletedAt, now).toDays();

                if (daysRemaining <= 0) {
                    throw new ResponseStatusException(
                            HttpStatus.GONE,
                            "ACCOUNT_PERMANENTLY_DELETED"
                    );
                }

                // ยังไม่เกิน 30 วัน - ส่งข้อมูลให้ frontend แสดง dialog
                Map<String, Object> errorDetails = new HashMap<>();
                errorDetails.put("error", "ACCOUNT_DELETED");
                errorDetails.put("isDeleted", true);
                errorDetails.put("deletedAt", deletedAt.toString());
                errorDetails.put("daysRemaining", daysRemaining);
                errorDetails.put("canRestore", true);
                errorDetails.put("userId", user.getUserId());

                throw new AuthService.AccountDeletedException(errorDetails);
            }

            if (user.getAccountStatus() == AccountStatus.SUSPENDED) {
                throw new ForbiddenAccessException("ACCOUNT_SUSPENDED");
            }
        }
        if (!mock) {
            String phone = normalizePhone(phone08);
            String lockKey = "otp:lock:" + phone + ":" + deviceId;
            if (redis.hasKey(lockKey)) {
                long waitSec = Optional.of(redis.getExpire(lockKey, TimeUnit.SECONDS)).orElse(60L);
                throw new TooManyRequestException("กรุณารออีก " + waitSec + " วินาที ก่อนขอ OTP ใหม่");
            }

            String otpCode = String.format("%06d", new Random().nextInt(1000000));
            redis.opsForValue().set("otp:value:" + phone, otpCode, 5, TimeUnit.MINUTES);

            redis.opsForValue().set(lockKey, "1", 60, TimeUnit.SECONDS);

            var url = "https://thsms.com/api/send-sms";
            Map<String, Object> payload = new HashMap<>();
            payload.put("sender", "Direct SMS");
            payload.put("msisdn", new String[]{phone});
            payload.put("message", "รหัส OTP ของคุณคือ " + otpCode + " (Ref: " + (refCode != null ? refCode : "Chat2Date") + ")");

            var req = new HttpEntity<>(payload, headersJson());
            ResponseEntity<Map> res = restTemplate.postForEntity(url, req, Map.class);

            // ตรวจสอบ response จาก THSMS
            if (res.getStatusCode() == HttpStatus.OK && res.getBody() != null) {
                Map<?, ?> body = res.getBody();
                if (Boolean.TRUE.equals(body.get("success"))) {
                    // คืนค่า phone กลับไปเพื่อให้ Frontend ใช้เรียกหน้า validate ต่อ
                    return phone;
                }

            }
            throw new UnprocessableEntityException("THSMS error: ", "Cannot send SMS");
        } else {
            return "d";
        }
    }

    /**
     * ตรวจ OTP -> true/false
     */
    public Map<String, Object> validate(String otpCode, String phoneNumber,
                                        boolean onLogin) {
        // URL ของ OTP validate API
        String phone = normalizePhone(phoneNumber);
        boolean mock = false;
        if (!mock) {
            String redisKey = "otp:value:" + phone;

            String savedOtp = redis.opsForValue().get(redisKey);
            boolean valid = savedOtp != null && savedOtp.equals(otpCode);

            if (valid) {
                redis.delete(redisKey); // ใช้แล้วลบทิ้งทันที
            } else {
                throw new UnprocessableEntityException("OTP_INVALID", "รหัส OTP ไม่ถูกต้องหรือหมดอายุ");
            }
        }
        Optional<User> userOptional = userRepository.findByPhoneNumber(phoneNumber);
        User user = new User();
        if (userOptional.isEmpty()) {
            user = userFactory.createPhoneUser(phoneNumber);
            user = userRepository.save(user);
        }

        String jwtToken = jwtTokenUtil.generateToken(phoneNumber);
        String jwtRefreshToken = jwtTokenUtil.generateRefreshToken(phoneNumber);
        UserDTO userDto;

        Map<String, Object> response = new LinkedHashMap<>();

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

        return response;
    }

    private String normalizePhone(String phone) {
        if (phone == null) return "";
        var p = phone.replaceAll("\\D", "");
        if (p.startsWith("66")) p = "0" + p.substring(2);
        return p;
    }
}
