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
import sit.chat2date.cp25ssi2.exceptions.ErrorResponse;
import sit.chat2date.cp25ssi2.exceptions.UnauthorizedAccessException;
import sit.chat2date.cp25ssi2.repositories.UserRepository;
import sit.chat2date.cp25ssi2.services.JwtTokenUtil;
import sit.chat2date.cp25ssi2.services.UserService;
import com.auth0.jwt.interfaces.DecodedJWT;

import java.util.List;
import java.util.Optional;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    @Autowired
    private UserService userService;

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

        if (request.getRequestURI().startsWith("/auth")) {
            filterChain.doFilter(request, response);
            return;
        }
        if (requestTokenHeader != null && requestTokenHeader.startsWith("Bearer ")) {
            jwtToken = requestTokenHeader.substring(7);

            try {
                DecodedJWT jwt = JWT.decode(jwtToken);
                String issuer = jwt.getIssuer();
                String sub = jwt.getClaim("sub").asString();
                if (sub.length() == 10) {
                    user = userRepository.findByPhoneNumber(sub);
                } else {
                    user = userRepository.findByEmail(sub);
                }

                if (issuer.equals("https://intproj23.sit.kmutt.ac.th/ssa2/")) {
                    jwtTokenUtil.validateTokenExceptions(jwtToken);
                }

                subject = jwt.getSubject();
                if (jwtTokenUtil.validateToken(jwtToken, subject) && user != null) {
                    UsernamePasswordAuthenticationToken authToken =
                            new UsernamePasswordAuthenticationToken(user, null, List.of(new SimpleGrantedAuthority("ROLE_" + user.get().getRole())));
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }
            } catch (SignatureException | IllegalArgumentException | ExpiredJwtException e) {
                if (request.getMethod().matches("POST|PUT|DELETE|PATCH")) {
                    String errorMessage;
                    if (e instanceof SignatureException ) {
                        errorMessage = "Invalid credential please try again.";
                    } else if (e instanceof IllegalArgumentException) {
                        errorMessage = "Invalid token format. Please ensure the token is correctly formatted and try again.";
                    } else {
                        errorMessage = "Your session has expired. Please log in again to continue.";
                    }
                    sendErrorResponse(response, errorMessage, request, HttpStatus.UNAUTHORIZED);
                    return;
                }
                return;
            }
        } else {
            sendErrorResponse(response, "Unauthorized access to this resource", request, HttpStatus.UNAUTHORIZED);
            return;
        }

        filterChain.doFilter(request, response);
    }

    private void sendErrorResponse(HttpServletResponse response, String message, HttpServletRequest request, HttpStatus status) throws IOException, java.io.IOException {
        ErrorResponse errorResponse = new ErrorResponse(
                status.value(),
                message,
                request.getRequestURI()
        );
        response.setStatus(status.value());
        response.setContentType("application/json");
        response.getWriter().write(new ObjectMapper().writeValueAsString(errorResponse));
    }
}
