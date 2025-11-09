package sit.chat2date.cp25ssi2.filter;

import com.auth0.jwt.JWT;
import io.jsonwebtoken.io.IOException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.repositories.UserRepository;
import sit.chat2date.cp25ssi2.services.JwtTokenUtil;
import sit.chat2date.cp25ssi2.services.UserService;
import com.auth0.jwt.interfaces.DecodedJWT;

import java.util.List;

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

        if (request.getRequestURI().startsWith("/api/otp/")) {
            filterChain.doFilter(request, response);
            return;
        }
        if (requestTokenHeader != null && requestTokenHeader.startsWith("Bearer ")) {
            jwtToken = requestTokenHeader.substring(7);

            try {
                DecodedJWT jwt = JWT.decode(jwtToken);
                String issuer = jwt.getIssuer();
                String userPhone = jwt.getClaim("phone").asString();
                User user = userRepository.findByPhoneNumber(userPhone);

                if (issuer.equals("https://intproj23.sit.kmutt.ac.th/ssa2/")) {
                    jwtTokenUtil.validateTokenExceptions(jwtToken);
                }

                subject = jwt.getSubject();
                if (jwtTokenUtil.validateToken(jwtToken, subject) && user != null) {
                    UsernamePasswordAuthenticationToken authToken =
                            new UsernamePasswordAuthenticationToken(user, null, List.of(new SimpleGrantedAuthority("role" + user.getRole())));
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }
            } catch (Exception e) {
                // ไม่โยน exception → Spring Security จะ return 401
            }
        }

        filterChain.doFilter(request, response);
    }
}
