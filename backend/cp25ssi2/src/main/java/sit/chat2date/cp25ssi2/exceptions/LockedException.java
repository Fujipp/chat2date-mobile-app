package sit.chat2date.cp25ssi2.exceptions;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.LOCKED)
public class LockedException extends RuntimeException {
    public LockedException(String message) {
        super(message);
    }
}
