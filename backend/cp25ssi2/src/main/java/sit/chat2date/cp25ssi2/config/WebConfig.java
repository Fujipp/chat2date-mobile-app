package sit.chat2date.cp25ssi2.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

  @Override
  public void addCorsMappings(CorsRegistry registry) {
    registry.addMapping("/**")
        .allowedOriginPatterns(
            "http://localhost:*",        // iOS Simulator / web
            "http://127.0.0.1:*",
            "http://10.0.2.2:*",         // Android Emulator -> host
            "http://192.168.*.*:*",      // อุปกรณ์ใน LAN
            "http://*.ngrok-free.app",   // ถ้าทดสอบผ่าน ngrok
            "http://cp25ssi2.sit.kmutt.ac.th",
            "https://cp25ssi2.sit.kmutt.ac.th"
        )
        .allowedMethods("GET","POST","PUT","DELETE","OPTIONS")
        .allowedHeaders("*")
        .exposedHeaders("*")
        .allowCredentials(false)        // ถ้าไม่ใช้ cookie/session ให้ false จะง่ายสุด
        .maxAge(3600);
  }
}
