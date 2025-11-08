package sit.chat2date.cp25ssi2.exceiptions;

import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@Getter
@ResponseStatus(HttpStatus.PRECONDITION_FAILED)
public class PreconditionFailedException extends RuntimeException {
    private final String field;
    private final String message;

    public PreconditionFailedException(String field, String message) {
        super();
        this.field = field;
        this.message = message;
    }
}
