package sit.chat2date.cp25ssi2.services;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import io.jsonwebtoken.security.SignatureException;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.exceptions.RefreshTokenExpiredException;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import javax.crypto.SecretKey;
import java.io.Serializable;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;

@Component
public class JwtTokenUtil implements Serializable {

    @Autowired
    UserRepository userRepository;
    @Autowired
    private TokenBlacklistService tokenBlacklistService;

    @Value("${JWT_SECRET}")
    private String secret_key;
    @Value("${jwt.max-token-interval-hour}")
    private int jwt_token_time;

    @Value("${JWT_REFRESH_SECRET}")
    private String refresh_secret_key;
    @Value("${jwt.max-refresh-token-interval-hour}")
    private long jwt_refresh_token_time;

    private long jwt_token_time_millis;
    private long jwt_refresh_token_time_millis;

    SignatureAlgorithm signatureAlgorithm = SignatureAlgorithm.HS256;
    private SecretKey key;
    private SecretKey refreshKey;

    @PostConstruct
    public void init() {
        this.key = Keys.hmacShaKeyFor(secret_key.getBytes(StandardCharsets.UTF_8));
        this.refreshKey = Keys.hmacShaKeyFor(refresh_secret_key.getBytes(StandardCharsets.UTF_8));

        this.jwt_token_time_millis = jwt_token_time * 60L * 60L * 1000L; // 1 hr = 3600000
        this.jwt_refresh_token_time_millis = jwt_refresh_token_time * 60L * 60L * 1000L;
    }


    public String getSubjectFromToken(String token) {
        return getClaimFromToken(token, Claims::getSubject);
    }

    public Date getExpirationDateFromToken(String token) {
        return getClaimFromToken(token, Claims::getExpiration);
    }

    public <T> T getClaimFromToken(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = getAllClaimsFromToken(token);
        return claimsResolver.apply(claims);
    }

    public Claims getAllClaimsFromToken(String token) {
        return Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token).getBody();
    }

    private Boolean isTokenExpired(String token) {
        final Date expiration = getExpirationDateFromToken(token);
        return expiration.before(new Date());
    }

    public String generateToken(String identifier) {
        Optional<User> userById = Optional.empty();
        String sub;

        if (isEmail(identifier)) {
            userById = userRepository.findByEmail(identifier);
        } else if (identifier.matches("^[0-9]{10,}$")) {
            userById = userRepository.findByPhoneNumber(identifier);
        } else {
            userById = userRepository.findByUserId(identifier);
        }

        // ตรวจสอบว่ามี user จริง ๆ หรือไม่
        User user = userById.orElseThrow(() ->
                new NotFoundException("User not found for identifier: " + identifier)
        );

        if (user.getPhoneNumber() != null) {
            sub = user.getPhoneNumber();
        } else {
            sub = user.getEmail();
        }

        Map<String, Object> claims = new HashMap<>();
        claims.put("iss", "chat2date");
        claims.put("role", user.getRole());
        claims.put("cid", user.getCardId());

        if (userById.get().getPhoneNumber() != null) {
            claims.put("sub", user.getPhoneNumber());
        } else {
            claims.put("sub", user.getEmail());
        }

        claims.put("name", user.getFirstname() + " " + user.getLastname());

        return doGenerateToken(claims, sub);
    }

    private String doGenerateToken(Map<String, Object> claims, String subject) {
        return Jwts.builder().setHeaderParam("typ", "JWT")
                .setClaims(claims).setSubject(subject)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + jwt_token_time_millis))
                .signWith(key, signatureAlgorithm).compact();
    }

    public Boolean validateToken(String token, String subject) {
        if (tokenBlacklistService.isTokenBlacklisted(token)) {
            throw new IllegalArgumentException("Token has been revoked");
        }

        final String subjectToken = getSubjectFromToken(token);
        return (subjectToken.equals(subject) && !isTokenExpired(token));
    }

    public Boolean validateTokenExceptions(String token) {
        if (tokenBlacklistService.isTokenBlacklisted(token)) {
            throw new IllegalArgumentException("Token has been revoked");
        }

        try {
            Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
            return true;
        } catch (ExpiredJwtException e) {
            throw new IllegalArgumentException("Expired token");
        } catch (SignatureException e) {
            throw new IllegalArgumentException("Invalid token signature");
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid token");
        }
    }

    public boolean isEmail(String identifier) {
        if (identifier == null) return false;
        return identifier.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    }

    //refresh
    public String generateRefreshToken(String subject) {
        return Jwts.builder()
                .setSubject(subject)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + jwt_refresh_token_time_millis))
                .signWith(refreshKey,signatureAlgorithm)
                .compact();
    }

    public <T> T getClaimFromRefreshToken(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = Jwts.parserBuilder()
                .setSigningKey(refreshKey)
                .build()
                .parseClaimsJws(token)
                .getBody();
        return claimsResolver.apply(claims);
    }


    public String getSubjectFromRefreshToken(String token) {
        return getClaimFromRefreshToken(token, Claims::getSubject);
    }

    public Boolean isRefreshTokenExpired(String token) {
        final Date expiration = getClaimFromRefreshToken(token, Claims::getExpiration);
        return expiration.before(new Date());
    }

    public Boolean validateRefreshToken(String token) {
        if (tokenBlacklistService.isRefreshTokenBlacklisted(token)) {
            throw new IllegalArgumentException("Refresh token has been revoked");
        }

        try {
            Jwts.parserBuilder()
                    .setSigningKey(refreshKey)
                    .build()
                    .parseClaimsJws(token);

            if (isRefreshTokenExpired(token)) {
                throw new RefreshTokenExpiredException(
                        "Refresh token has expired. Please log in again."
                );
            }

            return true;

        } catch (ExpiredJwtException e) {
            throw new RefreshTokenExpiredException(
                    "Refresh token has expired. Please log in again."
            );
        } catch (SignatureException | io.jsonwebtoken.MalformedJwtException e) {
            throw new IllegalArgumentException("Invalid refresh token signature or format");
        } catch (Exception e) {
            throw new IllegalArgumentException("Invalid refresh token");
        }
    }

}
