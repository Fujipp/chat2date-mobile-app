package sit.chat2date.cp25ssi2.exceptions;

import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@Getter
@ResponseStatus(HttpStatus.UNPROCESSABLE_ENTITY)
public class UnprocessableEntityException extends RuntimeException {
    private final String field;
    private final String message;

    public UnprocessableEntityException(String field, String message) {
        super();
        this.field = field;
        this.message = message;
    }
}
