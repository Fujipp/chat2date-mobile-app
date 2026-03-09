package sit.chat2date.cp25ssi2.services;

import com.auth0.jwt.JWT;
import com.auth0.jwt.interfaces.DecodedJWT;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import sit.chat2date.cp25ssi2.dto.UpdateLocationRequest;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.entities.UserLocation;
import sit.chat2date.cp25ssi2.repositories.UserLocationRepository;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserLocationService {

    private final UserRepository userRepository;
    private final UserLocationRepository userLocationRepository;

    public String updateCurrentUserLocation(String accessToken, UpdateLocationRequest req) {
        // 1) Validate coordinates
        if (req == null || req.getLatitude() == 0.0 && req.getLongtitude() == 0.0) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Missing coordinates: latitude and longitude are required"
            );
        }

        // Validate latitude range: -90 to 90
        if (req.getLatitude() < -90.0 || req.getLatitude() > 90.0) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Invalid latitude: must be between -90 and 90 degrees"
            );
        }

        // Validate longitude range: -180 to 180
        if (req.getLongtitude() < -180.0 || req.getLongtitude() > 180.0) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Invalid longitude: must be between -180 and 180 degrees"
            );
        }

        // 2) เช็ค header
        if (accessToken == null || !accessToken.startsWith("Bearer ")) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Missing or invalid Authorization header"
            );
        }

        try {
            // 3) ดึง sub จาก JWT
            String token = accessToken.substring(7);
            DecodedJWT jwt = JWT.decode(token);
            String sub = jwt.getClaim("sub").asString();

            if (sub == null || sub.isBlank()) {
                throw new ResponseStatusException(
                        HttpStatus.UNAUTHORIZED,
                        "Invalid token: subject is empty"
                );
            }

            // 4) หา user ตาม sub (เหมือนที่ใช้ใน UserService)
            Optional<User> userOpt;
            if (sub.length() == 10) {
                userOpt = userRepository.findByPhoneNumber(sub);
            } else {
                userOpt = userRepository.findByEmail(sub);
            }

            User user = userOpt.orElseThrow(() ->
                    new ResponseStatusException(
                            HttpStatus.UNAUTHORIZED,
                            "User not found for token"
                    )
            );

            // 5) หา/สร้าง location ของ user
            UserLocation location = userLocationRepository.findByUser_UserId(user.getUserId());
            if (location == null) {
                location = new UserLocation();
                location.setUser(user);
            }

            location.setLatitude(BigDecimal.valueOf(req.getLatitude()));
            location.setLongtitude(BigDecimal.valueOf(req.getLongtitude()));
            location.setAccuracy(BigDecimal.valueOf(req.getAccuracy()));
            location.setTimestamp(Instant.now());

            userLocationRepository.save(location);

            return "https://www.google.com/maps/search/?api=1&query=" + req.getLatitude() + "," + req.getLongtitude();

        } catch (ResponseStatusException e) {
            // ส่งต่อให้ GlobalExceptionHandler จัดการ (จะได้ status ตามที่ set ไว้)
            throw e;
        } catch (Exception e) {
            // log error จริงใน console
            e.printStackTrace();
            // ส่ง error แบบสวย ๆ กลับไป
            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Failed to update location: " + e.getMessage()
            );
        }
    }
}
