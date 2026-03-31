package sit.chat2date.cp25ssi2.exceptions;

import com.fasterxml.jackson.databind.exc.InvalidFormatException;
import io.jsonwebtoken.ExpiredJwtException;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.server.ResponseStatusException;
import sit.chat2date.cp25ssi2.services.AuthService;

import java.security.SignatureException;

/**
 * Global exception handler for the entire application.
 * All handlers return a consistent {@link ErrorResponse} JSON body.
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    // ────────────────────────────────────────────────────────────────────────
    // Helper
    // ────────────────────────────────────────────────────────────────────────

    private ResponseEntity<ErrorResponse> build(HttpStatus status, String message, String instance) {
        ErrorResponse body = new ErrorResponse(status.value(), message, instance);
        body.setTitle(status.getReasonPhrase());
        return ResponseEntity.status(status).body(body);
    }

    // ────────────────────────────────────────────────────────────────────────
    // 400 Bad Request
    // ────────────────────────────────────────────────────────────────────────

    @ExceptionHandler(BadRequestException.class)
    public ResponseEntity<ErrorResponse> handleBadRequest(BadRequestException ex, HttpServletRequest req) {
        return build(HttpStatus.BAD_REQUEST, ex.getMessage(), req.getRequestURI());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex, HttpServletRequest req) {
        ErrorResponse body = new ErrorResponse(HttpStatus.BAD_REQUEST.value(), "Validation failed", req.getRequestURI());
        body.setTitle(HttpStatus.BAD_REQUEST.getReasonPhrase());
        ex.getBindingResult().getFieldErrors()
                .forEach(err -> body.addValidationError(err.getField(), err.getDefaultMessage()));
        return ResponseEntity.badRequest().body(body);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ErrorResponse> handleMalformedJson(HttpMessageNotReadableException ex, HttpServletRequest req) {
        String message = "Malformed JSON request or invalid value";
        if (ex.getCause() instanceof InvalidFormatException cause && cause.getTargetType().isEnum()) {
            message = "Invalid enum value '" + cause.getValue() + "' for field '" + cause.getPath().get(0).getFieldName() + "'";
        }
        return build(HttpStatus.BAD_REQUEST, message, req.getRequestURI());
    }

    // ────────────────────────────────────────────────────────────────────────
    // 401 Unauthorized
    // ────────────────────────────────────────────────────────────────────────

    @ExceptionHandler(UnauthorizedAccessException.class)
    public ResponseEntity<ErrorResponse> handleUnauthorized(UnauthorizedAccessException ex, HttpServletRequest req) {
        return build(HttpStatus.UNAUTHORIZED, ex.getMessage(), req.getRequestURI());
    }

    @ExceptionHandler(RefreshTokenExpiredException.class)
    public ResponseEntity<ErrorResponse> handleRefreshExpired(RefreshTokenExpiredException ex, HttpServletRequest req) {
        return build(HttpStatus.UNAUTHORIZED, ex.getMessage(), req.getRequestURI());
    }

    @ExceptionHandler(ExpiredJwtException.class)
    public ResponseEntity<ErrorResponse> handleExpiredJwt(ExpiredJwtException ex, HttpServletRequest req) {
        return build(HttpStatus.UNAUTHORIZED, "Access token has expired", req.getRequestURI());
    }

    @ExceptionHandler(SignatureException.class)
    public ResponseEntity<ErrorResponse> handleSignatureException(SignatureException ex, HttpServletRequest req) {
        return build(HttpStatus.UNAUTHORIZED, "Invalid token signature", req.getRequestURI());
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErrorResponse> handleIllegalArgument(IllegalArgumentException ex, HttpServletRequest req) {
        return build(HttpStatus.UNAUTHORIZED, ex.getMessage(), req.getRequestURI());
    }

    // ────────────────────────────────────────────────────────────────────────
    // 403 Forbidden
    // ────────────────────────────────────────────────────────────────────────

    @ExceptionHandler(ForbiddenAccessException.class)
    public ResponseEntity<ErrorResponse> handleForbidden(ForbiddenAccessException ex, HttpServletRequest req) {
        return build(HttpStatus.FORBIDDEN, ex.getMessage(), req.getRequestURI());
    }

    @ExceptionHandler(AuthService.AccountDeletedException.class)
    public ResponseEntity<ErrorResponse> handleAccountDeleted(AuthService.AccountDeletedException ex, HttpServletRequest req) {
        return build(HttpStatus.FORBIDDEN, ex.getMessage(), req.getRequestURI());
    }

    // ────────────────────────────────────────────────────────────────────────
    // 404 Not Found
    // ────────────────────────────────────────────────────────────────────────

    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(NotFoundException ex, HttpServletRequest req) {
        return build(HttpStatus.NOT_FOUND, ex.getMessage(), req.getRequestURI());
    }

    // ────────────────────────────────────────────────────────────────────────
    // 409 Conflict
    // ────────────────────────────────────────────────────────────────────────

    @ExceptionHandler(ConflictException.class)
    public ResponseEntity<ErrorResponse> handleConflict(ConflictException ex, HttpServletRequest req) {
        return build(HttpStatus.CONFLICT, ex.getMessage(), req.getRequestURI());
    }

    // ────────────────────────────────────────────────────────────────────────
    // 412 Precondition Failed
    // ────────────────────────────────────────────────────────────────────────

    @ExceptionHandler(PreconditionFailedException.class)
    public ResponseEntity<ErrorResponse> handlePreconditionFailed(PreconditionFailedException ex, HttpServletRequest req) {
        return build(HttpStatus.PRECONDITION_FAILED, "Version data mismatch", req.getRequestURI());
    }

    // ────────────────────────────────────────────────────────────────────────
    // 413 Payload Too Large
    // ────────────────────────────────────────────────────────────────────────

    @ExceptionHandler(PayloadTooLargeException.class)
    public ResponseEntity<ErrorResponse> handlePayloadTooLarge(PayloadTooLargeException ex, HttpServletRequest req) {
        return build(HttpStatus.PAYLOAD_TOO_LARGE, ex.getMessage(), req.getRequestURI());
    }

    // ────────────────────────────────────────────────────────────────────────
    // 415 Unsupported Media Type
    // ────────────────────────────────────────────────────────────────────────

    @ExceptionHandler(UnsupportedMediaTypeException.class)
    public ResponseEntity<ErrorResponse> handleUnsupportedMediaType(UnsupportedMediaTypeException ex, HttpServletRequest req) {
        return build(HttpStatus.UNSUPPORTED_MEDIA_TYPE, ex.getMessage(), req.getRequestURI());
    }

    // ────────────────────────────────────────────────────────────────────────
    // 422 Unprocessable Entity
    // ────────────────────────────────────────────────────────────────────────

    @ExceptionHandler(UnprocessableEntityException.class)
    public ResponseEntity<ErrorResponse> handleUnprocessableEntity(UnprocessableEntityException ex, HttpServletRequest req) {
        return build(HttpStatus.UNPROCESSABLE_ENTITY, ex.getMessage(), req.getRequestURI());
    }

    // ────────────────────────────────────────────────────────────────────────
    // 423 Locked
    // ────────────────────────────────────────────────────────────────────────

    @ExceptionHandler(LockedException.class)
    public ResponseEntity<ErrorResponse> handleLocked(LockedException ex, HttpServletRequest req) {
        return build(HttpStatus.LOCKED, ex.getMessage(), req.getRequestURI());
    }

    // ────────────────────────────────────────────────────────────────────────
    // 429 Too Many Requests
    // ────────────────────────────────────────────────────────────────────────

    @ExceptionHandler(TooManyRequestException.class)
    public ResponseEntity<ErrorResponse> handleTooManyRequests(TooManyRequestException ex, HttpServletRequest req) {
        return build(HttpStatus.TOO_MANY_REQUESTS, ex.getMessage(), req.getRequestURI());
    }

    // ────────────────────────────────────────────────────────────────────────
    // Spring ResponseStatusException (catch-all for @ResponseStatus)
    // ────────────────────────────────────────────────────────────────────────

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<ErrorResponse> handleResponseStatusException(ResponseStatusException ex, HttpServletRequest req) {
        HttpStatus status = HttpStatus.valueOf(ex.getStatusCode().value());
        return build(status, ex.getReason(), req.getRequestURI());
    }

    // ────────────────────────────────────────────────────────────────────────
    // 500 Internal Server Error (fallbacks)
    // ────────────────────────────────────────────────────────────────────────

    @ExceptionHandler(ServiceException.class)
    public ResponseEntity<ErrorResponse> handleServiceException(ServiceException ex, HttpServletRequest req) {
        return build(HttpStatus.INTERNAL_SERVER_ERROR, ex.getMessage(), req.getRequestURI());
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleUnexpected(Exception ex, HttpServletRequest req) {
        return build(HttpStatus.INTERNAL_SERVER_ERROR, "Unexpected error: " + ex.getMessage(), req.getRequestURI());
    }
}
