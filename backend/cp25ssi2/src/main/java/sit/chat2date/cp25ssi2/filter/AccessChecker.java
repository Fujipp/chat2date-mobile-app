package sit.chat2date.cp25ssi2.filter;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.exceptions.ErrorResponse;

import java.io.IOException;

public class AccessChecker {
    private final HttpServletRequest request;
    private final HttpServletResponse response;
    private final User currentUser;

    public AccessChecker(HttpServletRequest request, HttpServletResponse response, User currentUser) {
        this.request = request;
        this.response = response;
        this.currentUser = currentUser;
    }

    public boolean checkUserAccess() throws IOException {
        String path = request.getRequestURI();
        String method = request.getMethod();

        // ตรวจสอบ /api/v1/users
        if (method.matches("GET|PUT|DELETE") && path.startsWith("/api/v1/users")) {
            String targetId = path.substring(path.lastIndexOf("/") + 1);
            if (!targetId.equals(currentUser.getUserId())) {
                sendErrorResponse(response, "Forbidden: cannot access another user's data", request, HttpStatus.FORBIDDEN);
                return false;
            }
        }

        // ตรวจสอบ /api/v1/discovery
        if (method.matches("GET|POST") && path.startsWith("/api/v1/discovery")) {
            boolean isFeedbackPath = path.contains("/feedback");
            String requestParamId = request.getParameter("userId");

            if ((requestParamId != null && !requestParamId.equals(currentUser.getUserId()))) {
                sendErrorResponse(response, "Forbidden: cannot access another user's data", request, HttpStatus.FORBIDDEN);
                return false;
            }
        }

        return true; // ผ่านทุก check
    }

    private void sendErrorResponse(HttpServletResponse response, String message, HttpServletRequest request, HttpStatus status) throws io.jsonwebtoken.io.IOException, java.io.IOException {
        ErrorResponse errorResponse = new ErrorResponse(
                status.value(),
                message,
                request.getRequestURI()
        );
        response.setStatus(status.value());
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.getWriter().write(new ObjectMapper().writeValueAsString(errorResponse));
    }
}
