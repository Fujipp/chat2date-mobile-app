package sit.chat2date.cp25ssi2.services;

import com.auth0.jwt.JWT;
import com.auth0.jwt.interfaces.DecodedJWT;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sit.chat2date.cp25ssi2.dto.SwipeQuotaResponse;
import sit.chat2date.cp25ssi2.entities.SwipeQuota;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.repositories.SwipeQuotaRepository;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.sql.Timestamp;
import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;

@Service
@RequiredArgsConstructor
public class SwipeQuotaService {
    private final SwipeQuotaRepository swipeQuotaRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public SwipeQuotaResponse getQuotaStatus(String accessToken) {
        User user = extractToken(accessToken);
        SwipeQuota quota = swipeQuotaRepository.findByUserId(user.getUserId())
                .orElse(SwipeQuota.builder().userId(user.getUserId()).swipeCount(0).build());
        return convertToResponse(quota);
    }

    @Transactional
    public SwipeQuotaResponse processSwipe(String accessToken) {
        User user = extractToken(accessToken);

        SwipeQuota quota = swipeQuotaRepository.findByUserId(user.getUserId())
                .orElseGet(() -> swipeQuotaRepository.save(SwipeQuota.builder()
                        .userId(user.getUserId()).swipeCount(0)
                        .swipeDate(LocalDate.now(ZoneId.of("Asia/Bangkok")))
                        .build()));

        LocalDateTime nowTH = LocalDateTime.now(ZoneId.of("Asia/Bangkok"));
        LocalDate todayTH = nowTH.toLocalDate();

        if (quota.getRestrictUntil() != null) {
            if (quota.getRestrictUntil().plusHours(7).isAfter(nowTH)) {
                return convertToResponse(quota);
            }
            quota.setRestrictUntil(null);
        }

        if (quota.getSwipeDate() == null || !quota.getSwipeDate().isEqual(todayTH)) {
            quota.setSwipeCount(0);
            quota.setSwipeDate(todayTH);
        }

        if (quota.getSwipeCount() < 10) {
            quota.setSwipeCount(quota.getSwipeCount() + 1);
        }

        if (quota.getSwipeCount() >= 10) {
            quota.setRestrictUntil(todayTH.plusDays(1).atStartOfDay().minusHours(7));
        }

        return convertToResponse(quota);
    }

    private SwipeQuotaResponse convertToResponse(SwipeQuota quota) {
        ZoneId zoneTH = ZoneId.of("Asia/Bangkok");

        // ✅ 1. ตัดเศษนาโนวินาทีทิ้งให้เหลือแค่หน่วยวินาที (Precision Matching)
        LocalDateTime nowTH = LocalDateTime.now(zoneTH).withNano(0);
        LocalDate todayTH = nowTH.toLocalDate();

        boolean isRestricted = false;
        LocalDateTime unlockTimeTH = null;

        if (quota.getRestrictUntil() != null) {
            unlockTimeTH = quota.getRestrictUntil().plusHours(7).withNano(0);

            isRestricted = unlockTimeTH.isAfter(nowTH);
        }

        int current = (quota.getSwipeDate() != null && todayTH.isEqual(quota.getSwipeDate()))
                ? quota.getSwipeCount() : 0;

        return SwipeQuotaResponse.builder()
                .currentCount(current)
                .remainingCount(Math.max(0, 10 - current))
                .isRestricted(isRestricted)
                .unlockAt(unlockTimeTH)
                .build();
    }

    public User extractToken(String accessToken) {
        String token = accessToken.substring(7);
        DecodedJWT jwt = JWT.decode(token);
        String sub = jwt.getClaim("sub").asString();

        User user = (sub.length() == 10)
                ? userRepository.findByPhoneNumber(sub).orElseThrow()
                : userRepository.findByEmail(sub).orElseThrow();
        return user;
    }
}
