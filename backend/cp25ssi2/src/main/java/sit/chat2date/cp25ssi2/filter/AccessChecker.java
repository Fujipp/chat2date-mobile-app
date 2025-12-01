package sit.chat2date.cp25ssi2.filter;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.exceptions.ErrorResponse;

import java.io.IOException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

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
        if (Boolean.TRUE.equals(currentUser.getDeleteFlag())) {
            LocalDateTime deletedAt = currentUser.getDeletedAt();
            LocalDateTime now = LocalDateTime.now();
            long daysRemaining = 30 - Duration.between(deletedAt, now).toDays();

            // ถ้าเกิน 30 วัน -> บัญชีหมดอายุ
            if (daysRemaining <= 0) {
                sendErrorResponse(
                        response,
                        "Account has been permanently deleted",
                        request,
                        HttpStatus.GONE // 410 Gone
                );
                return false;
            }

            // ถ้ายังไม่เกิน 30 วัน -> ส่งข้อมูลให้ frontend แสดง dialog กู้คืน
            Map<String, Object> deletionInfo = new HashMap<>();
            deletionInfo.put("error", "ACCOUNT_DELETED");
            deletionInfo.put("message", "Your account has been deleted");
            deletionInfo.put("isDeleted", true);
            deletionInfo.put("deletedAt", deletedAt.toString());
            deletionInfo.put("daysRemaining", daysRemaining);
            deletionInfo.put("canRestore", true);
            deletionInfo.put("userId", currentUser.getUserId());

            response.setStatus(HttpStatus.FORBIDDEN.value()); // 403
            response.setCharacterEncoding("UTF-8");
            response.setContentType("application/json");
            response.getWriter().write(new ObjectMapper().writeValueAsString(deletionInfo));
            return false;
        }

        String path = request.getRequestURI();
        String method = request.getMethod();

        // ตรวจสอบ /api/v1/users
        if (method.matches("GET|PUT|DELETE") && path.startsWith("/api/v1/users")) {
            java.util.regex.Matcher m = java.util.regex.Pattern.compile("/api/v1/users/([^/]+)").matcher(path);
            if (m.find()) {
                String targetId = m.group(1);
                if (!targetId.equals(currentUser.getUserId())) {
                    sendErrorResponse(
                            response,
                            "Forbidden: cannot access another user's data",
                            request,
                            HttpStatus.FORBIDDEN
                    );
                    return false;
                }
            }
        }

        // ตรวจสอบ /api/v1/discovery
        if (method.matches("GET|POST") && path.startsWith("/api/v1/discovery")) {
            String requestParamId = request.getParameter("userId");

            if ((requestParamId != null && !requestParamId.equals(currentUser.getUserId()))) {
                sendErrorResponse(response, "Forbidden: cannot access another user's data", request, HttpStatus.FORBIDDEN);
                return false;
            }
        }

        return true; // ผ่านทุก check
    }

    private void sendErrorResponse(HttpServletResponse response, String message, HttpServletRequest request, HttpStatus status) throws IOException {
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