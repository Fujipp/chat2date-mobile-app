package sit.chat2date.cp25ssi2.filter;

import com.auth0.jwt.JWT;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.io.IOException;
import io.jsonwebtoken.security.SignatureException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.enums.Role;
import sit.chat2date.cp25ssi2.exceptions.ErrorResponse;
import sit.chat2date.cp25ssi2.repositories.UserRepository;
import sit.chat2date.cp25ssi2.services.JwtTokenUtil;
import com.auth0.jwt.interfaces.DecodedJWT;

import java.util.List;
import java.util.Optional;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtTokenUtil jwtTokenUtil;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException, java.io.IOException {
        final String requestTokenHeader = request.getHeader("Authorization");
        String subject = null;
        String jwtToken = null;
        Optional<User> user = null;
        String path = request.getRequestURI();

        // ✅ Skip JWT validation สำหรับ endpoint ที่ไม่ต้องการ authentication
        if (path.startsWith("/api/v1/auth") ||
                path.startsWith("/api/v1/preferences") ||
                path.equals("/api/v1/users/phone") ||
                path.matches("/api/v1/users/[^/]+/restore")) {
            filterChain.doFilter(request, response);
            return;
        }

        if (requestTokenHeader != null && requestTokenHeader.startsWith("Bearer ")) {
            jwtToken = requestTokenHeader.substring(7);

            // ✅ เช็คว่า token ไม่เป็น empty string
            if (jwtToken.isEmpty()) {
                sendErrorResponse(response, "Empty token", request, HttpStatus.UNAUTHORIZED);
                return;
            }

            try {
                DecodedJWT jwt = JWT.decode(jwtToken);
                String issuer = jwt.getIssuer();
                String sub = jwt.getClaim("sub").asString();
                if (sub.length() == 10) {
                    user = userRepository.findByPhoneNumber(sub);
                } else {
                    user = userRepository.findByEmail(sub);
                }

                if (issuer.equals("chat2date")) {
                    jwtTokenUtil.validateTokenExceptions(jwtToken);
                }

                subject = jwt.getSubject();

                if (jwtTokenUtil.validateToken(jwtToken, subject) && user != null) {
                    UsernamePasswordAuthenticationToken authToken =
                            new UsernamePasswordAuthenticationToken(user, null, List.of(new SimpleGrantedAuthority("ROLE_" + user.get().getRole())));
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }

                if (user.isPresent() && user.get().getRole() == Role.USER) {
                    AccessChecker checker = new AccessChecker(request, response, user.get());
                    if (!checker.checkUserAccess()) {
                        return; // ถ้า check ไม่ผ่าน
                    }
                }
            } catch (SignatureException | IllegalArgumentException | ExpiredJwtException e) {
                handleExceptionResponse(response, e, request);
                return;
            }
        } else {
            sendErrorResponse(response, "Unauthorized access to this resource", request, HttpStatus.UNAUTHORIZED);
            return;
        }

        filterChain.doFilter(request, response);
    }

    private void handleExceptionResponse(HttpServletResponse response, Exception e, HttpServletRequest request) throws IOException, java.io.IOException {
        String errorMessage;

        if (e instanceof SignatureException) {
            errorMessage = "Invalid credential please try again.";
        } else if (e instanceof IllegalArgumentException) {
            String originalMsg = e.getMessage();
            if (originalMsg != null && originalMsg.toLowerCase().contains("expired")) {
                errorMessage = "Your session has expired. Please log in again to continue.";
            } else if (originalMsg != null && originalMsg.toLowerCase().contains("invalid")) {
                errorMessage = "Invalid token format. Please log in again.";
            } else {
                errorMessage = "Token validation failed. Please log in again.";
            }
        } else if (e instanceof ExpiredJwtException) {
            errorMessage = "Your session has expired. Please log in again to continue.";
        } else {
            errorMessage = "Unauthorized access";
        }

        sendErrorResponse(response, errorMessage, request, HttpStatus.UNAUTHORIZED);
    }

    private void sendErrorResponse(HttpServletResponse response, String message, HttpServletRequest request, HttpStatus status) throws IOException, java.io.IOException {
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