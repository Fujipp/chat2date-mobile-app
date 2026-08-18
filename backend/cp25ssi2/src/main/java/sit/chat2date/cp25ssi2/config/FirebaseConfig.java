package sit.chat2date.cp25ssi2.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

@Configuration
public class FirebaseConfig {

    @Value("${firebase.config.path:}")   // <- อ่านจาก application.properties
    private String firebaseConfigPath;

    @Bean
    public FirebaseApp firebaseApp() throws IOException {
        if (!FirebaseApp.getApps().isEmpty()) {
            return FirebaseApp.getInstance();
        }

        GoogleCredentials credentials;

        if (firebaseConfigPath != null && !firebaseConfigPath.isBlank()) {
            // ✅ โหลดจาก path ที่ตั้งใน ENV / properties
            try (FileInputStream serviceAccount = new FileInputStream(firebaseConfigPath)) {
                credentials = GoogleCredentials.fromStream(serviceAccount);
            }
        } else {
            // ✅ fallback: โหลดไฟล์จาก resources/firebase/service-account.json
            ClassPathResource resource =
                    new ClassPathResource("firebase/service-account.json");
            try (InputStream serviceAccount = resource.getInputStream()) {
                credentials = GoogleCredentials.fromStream(serviceAccount);
            }
        }

        FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(credentials)
                .build();

        return FirebaseApp.initializeApp(options);
    }
}
