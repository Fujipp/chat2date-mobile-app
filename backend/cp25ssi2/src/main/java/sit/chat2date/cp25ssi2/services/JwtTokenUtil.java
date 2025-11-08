package sit.chat2date.cp25ssi2.services;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import io.jsonwebtoken.security.SignatureException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import javax.crypto.SecretKey;
import java.io.Serializable;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Component
public class JwtTokenUtil implements Serializable {

    @Autowired
    UserRepository userRepository;

    @Value("${jwt.secret}")
    private String secret_key;
    @Value("${jwt.max-token-interval-hour}")
    private int jwt_token_time;

    SignatureAlgorithm signatureAlgorithm = SignatureAlgorithm.HS256;
    SecretKey key = Keys.hmacShaKeyFor(secret_key.getBytes(StandardCharsets.UTF_8));

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
        Claims claims = Jwts.parser().setSigningKey(secret_key)
                .parseClaimsJws(token).getBody();
        return claims;
    }

    private Boolean isTokenExpired(String token) {
        final Date expiration = getExpirationDateFromToken(token);
        return expiration.before(new Date());
    }

    public String generateToken(Integer userId) {
        User userById = userRepository.findById(userId).orElse(null);
        String subject = null;
        Map<String, Object> claims = new HashMap<>();
        claims.put("iss", "https://cp25ssi2.sit.kmutt.ac.th/");
        claims.put("role", userById.getRole());
        claims.put("cid", userById.getCardId());
        if (userById.getEmail() != null) {
            claims.put("email", userById.getEmail());
            subject = userById.getEmail();
        } else {
            claims.put("phone", userById.getPhoneNumber());
            subject = userById.getPhoneNumber();
        }
        claims.put("name", userById.getFirstname() + " " + userById.getLastname());
        return doGenerateToken(claims, subject);
    }

    private String doGenerateToken(Map<String, Object> claims, String subject) {
        return Jwts.builder().setHeaderParam("typ", "JWT")
                .setClaims(claims).setSubject(subject)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + jwt_token_time))
                .signWith(key ,signatureAlgorithm).compact();
    }

    public Boolean validateToken(String token, String subject) {
        final String subjectToken = getSubjectFromToken(token);
        return (subjectToken.equals(subject) && !isTokenExpired(token));
    }

    public Boolean validateTokenExceptions(String token) {
        try {
            Jwts.parser()
                    .setSigningKey(key)
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
}
