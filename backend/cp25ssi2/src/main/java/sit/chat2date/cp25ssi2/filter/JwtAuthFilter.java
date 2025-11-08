package sit.chat2date.cp25ssi2.filter;

import com.auth0.jwt.JWT;
import io.jsonwebtoken.io.IOException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.repositories.UserRepository;
import sit.chat2date.cp25ssi2.services.JwtTokenUtil;
import sit.chat2date.cp25ssi2.services.UserService;
import com.auth0.jwt.interfaces.DecodedJWT;

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

        if (requestTokenHeader == null && !requestTokenHeader.startsWith("Bearer ")) {
            return;
        } else {
            jwtToken = requestTokenHeader.substring(7);
            try {
                DecodedJWT jwt = JWT.decode(jwtToken);
                String issuer = jwt.getIssuer();
                String userCid = jwt.getClaim("cid").asString();
                User user = userRepository.findByCid(userCid);

                if (issuer.equals("https://cp25ssi2.sit.kmutt.ac.th/") && !request.getRequestURI().contains("/token/")) {
                    jwtTokenUtil.validateTokenExceptions(jwtToken);
                }
                try {
                    subject = jwt.getSubject();
                    if (jwtTokenUtil.validateToken(jwtToken, subject) && user != null) {
                        UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(user, subject);
                        SecurityContextHolder.getContext().setAuthentication(authenticationToken);
                    }
                } catch (Exception e) {

                }
            } catch(Exception e){

            }
            filterChain.doFilter(request, response);
        }
    }
}
