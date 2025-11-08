package sit.chat2date.cp25ssi2.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.config.Customizer;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import sit.chat2date.cp25ssi2.filter.JwtAuthFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtAuthFilter jwtAuthFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .authorizeHttpRequests(auth -> auth
                        //.requestMatchers("").permitAll()
                        //.anyRequest().authenticated()
                        .anyRequest().permitAll())
                //.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS));
                .httpBasic(Customizer.withDefaults());
        //http.addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        //ที่comment เป็นส่วนของ token

        return http.build();
    }


}
