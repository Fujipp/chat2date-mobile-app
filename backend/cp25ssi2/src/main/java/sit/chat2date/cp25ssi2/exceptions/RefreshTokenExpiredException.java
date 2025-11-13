package sit.chat2date.cp25ssi2.exceptions;

import io.jsonwebtoken.ExpiredJwtException;

public class RefreshTokenExpiredException extends RuntimeException {
    public RefreshTokenExpiredException(String message) {
        super(message);
    }
}
