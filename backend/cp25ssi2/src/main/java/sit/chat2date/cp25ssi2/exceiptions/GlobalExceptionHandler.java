package sit.chat2date.cp25ssi2.exceiptions;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class GlobalExceptionHandler {

    private ResponseEntity<ErrorResponse> build(HttpStatus status, String message, String instance) {
        ErrorResponse body = new ErrorResponse(status.value(), message, instance);
        body.setTitle(status.getReasonPhrase());
        return ResponseEntity.status(status).body(body);
    }

    @ExceptionHandler(BadRequestException.class)
    public ResponseEntity<ErrorResponse> handleBadRequest(BadRequestException ex, HttpServletRequest req) {
        return build(HttpStatus.BAD_REQUEST, ex.getMessage(), req.getRequestURI());
    }

    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(NotFoundException ex, HttpServletRequest req) {
        return build(HttpStatus.NOT_FOUND, ex.getMessage(), req.getRequestURI());
    }

    @ExceptionHandler(PreconditionFailedException.class)
    public ResponseEntity<ErrorResponse> handlePrecondition(PreconditionFailedException ex, HttpServletRequest req) {
        ErrorResponse body = new ErrorResponse(HttpStatus.PRECONDITION_FAILED.value(), ex.getMessage(), req.getRequestURI());
        body.setTitle(HttpStatus.PRECONDITION_FAILED.getReasonPhrase());
        body.addValidationError(ex.getField(), ex.getMessage());
        return ResponseEntity.status(HttpStatus.PRECONDITION_FAILED).body(body);
    }

    // validation จาก @Valid/@Min เป็นต้น
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex, HttpServletRequest req) {
        ErrorResponse body = new ErrorResponse(HttpStatus.BAD_REQUEST.value(), "Validation failed", req.getRequestURI());
        body.setTitle(HttpStatus.BAD_REQUEST.getReasonPhrase());
        ex.getBindingResult().getFieldErrors().forEach(err -> body.addValidationError(err.getField(), err.getDefaultMessage()));
        return ResponseEntity.badRequest().body(body);
    }

    @ExceptionHandler(ServiceException.class)
    public ResponseEntity<ErrorResponse> handleService(ServiceException ex, HttpServletRequest req) {
        return build(HttpStatus.INTERNAL_SERVER_ERROR, ex.getMessage(), req.getRequestURI());
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleOthers(Exception ex, HttpServletRequest req) {
        return build(HttpStatus.INTERNAL_SERVER_ERROR, "Unexpected error", req.getRequestURI());
    }
}
