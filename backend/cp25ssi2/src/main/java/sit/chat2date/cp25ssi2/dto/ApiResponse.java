package sit.chat2date.cp25ssi2.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Generic wrapper for all API success responses.
 * Provides a consistent JSON structure across the entire application.
 *
 * <pre>
 * Success with data:  { "status": 200, "message": "OK", "data": { ... } }
 * Success no data:    { "status": 201, "message": "Created" }
 * </pre>
 *
 * @param <T> the type of the response payload
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {

    private int status;
    private String message;
    private T data;

    /** Create a 200 OK response with data. */
    public static <T> ApiResponse<T> ok(T data) {
        return ApiResponse.<T>builder()
                .status(200)
                .message("OK")
                .data(data)
                .build();
    }

    /** Create a 200 OK response with a custom message and data. */
    public static <T> ApiResponse<T> ok(String message, T data) {
        return ApiResponse.<T>builder()
                .status(200)
                .message(message)
                .data(data)
                .build();
    }

    /** Create a 200 OK response with only a message (no data). */
    public static <T> ApiResponse<T> ok(String message) {
        return ApiResponse.<T>builder()
                .status(200)
                .message(message)
                .build();
    }

    /** Create a 201 Created response with data. */
    public static <T> ApiResponse<T> created(T data) {
        return ApiResponse.<T>builder()
                .status(201)
                .message("Created")
                .data(data)
                .build();
    }

    /** Create a 201 Created response with a custom message and data. */
    public static <T> ApiResponse<T> created(String message, T data) {
        return ApiResponse.<T>builder()
                .status(201)
                .message(message)
                .data(data)
                .build();
    }

    /** Create a 201 Created response with only a message (no data). */
    public static <T> ApiResponse<T> created(String message) {
        return ApiResponse.<T>builder()
                .status(201)
                .message(message)
                .build();
    }
}
