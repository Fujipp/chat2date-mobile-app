package sit.chat2date.cp25ssi2.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.concurrent.TimeUnit;

@Service
public class TokenBlacklistService {

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    @Autowired
    @Lazy
    private JwtTokenUtil jwtTokenUtil;

    private static final String BLACKLIST_PREFIX = "blacklist:token:";

    public void blacklistToken(String token) {
        try {
            Date expirationDate = jwtTokenUtil.getExpirationDateFromToken(token);
            long ttl = expirationDate.getTime() - System.currentTimeMillis();

            if (ttl > 0) {
                String key = BLACKLIST_PREFIX + token;
                redisTemplate.opsForValue().set(key, "blacklisted", ttl, TimeUnit.MILLISECONDS);
            }
        } catch (Exception e) {
            throw new IllegalArgumentException("Failed to blacklist token: " + e.getMessage());
        }
    }


    public void blacklistRefreshToken(String refreshToken) {
        try {
            Date expirationDate = jwtTokenUtil.getClaimFromRefreshToken(refreshToken, claims -> claims.getExpiration());
            long ttl = expirationDate.getTime() - System.currentTimeMillis();
            System.out.println("Blacklist refresh token: " + refreshToken + " TTL: " + ttl);

            if (ttl > 0) {
                String key = BLACKLIST_PREFIX + "refresh:" + refreshToken;
                redisTemplate.opsForValue().set(key, "blacklisted", ttl, TimeUnit.MILLISECONDS);
            }
        } catch (Exception e) {
            throw new IllegalArgumentException("Failed to blacklist refresh token: " + e.getMessage());
        }
    }


    public boolean isTokenBlacklisted(String token) {
        String key = BLACKLIST_PREFIX + token;
        return Boolean.TRUE.equals(redisTemplate.hasKey(key));
    }

    public boolean isRefreshTokenBlacklisted(String refreshToken) {
        String key = BLACKLIST_PREFIX + "refresh:" + refreshToken;
        return Boolean.TRUE.equals(redisTemplate.hasKey(key));
    }

    public void removeTokenFromBlacklist(String token) {
        String key = BLACKLIST_PREFIX + token;
        redisTemplate.delete(key);
    }
}