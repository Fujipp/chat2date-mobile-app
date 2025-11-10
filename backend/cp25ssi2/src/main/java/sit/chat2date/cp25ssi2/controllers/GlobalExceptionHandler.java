package sit.chat2date.cp25ssi2.controllers;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.context.request.WebRequest;
import sit.chat2date.cp25ssi2.exceptions.ErrorResponse;
import sit.chat2date.cp25ssi2.exceptions.PreconditionFailedException;

@RestController
public class GlobalExceptionHandler {
    @ExceptionHandler(PreconditionFailedException.class)
    @ResponseStatus(HttpStatus.PRECONDITION_FAILED)
    public ResponseEntity<ErrorResponse> handlePreconditionFailed(Exception e, WebRequest request) {
        ErrorResponse error = new ErrorResponse(HttpStatus.PRECONDITION_FAILED.value(), "Version data mismatch", request.getDescription(false));
        return ResponseEntity.status(HttpStatus.PRECONDITION_FAILED).body(error);
    }
}
