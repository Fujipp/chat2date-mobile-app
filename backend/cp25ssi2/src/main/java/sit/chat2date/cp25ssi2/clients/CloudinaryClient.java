    package sit.chat2date.cp25ssi2.clients;

    import com.cloudinary.Cloudinary;
    import com.cloudinary.utils.ObjectUtils;
    import jakarta.annotation.PostConstruct;
    import org.springframework.beans.factory.annotation.Value;
    import org.springframework.stereotype.Service;
    import org.springframework.web.multipart.MultipartFile;

    import java.io.IOException;
    import java.util.HashMap;
    import java.util.Map;

    @Service
    public class CloudinaryClient {

        @Value("${cloudinary.cloud-name}")
        private String cloudName;

        @Value("${cloudinary.api-key}")
        private String apiKey;

        @Value("${cloudinary.api-secret}")
        private String apiSecret;

        private Cloudinary cloudinary;

        @PostConstruct
        public void init() {
            Map<String, String> config = new HashMap<>();
            config.put("cloud_name", cloudName);
            config.put("api_key", apiKey);
            config.put("api_secret", apiSecret);
            this.cloudinary = new Cloudinary(config);
        }

        public String upload(MultipartFile file) {
            try {
                Map uploadResult = cloudinary.uploader().upload(file.getBytes(),
                        ObjectUtils.asMap("folder", "chat2date_users"));

                return (String) uploadResult.get("secure_url");

            } catch (IOException e) {
                throw new RuntimeException("Cloudinary upload failed: " + e.getMessage());
            }
        }

        public void delete(String publicId) {
            try {
                cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
            } catch (Exception e) {
                throw new RuntimeException("Failed to delete image from Cloudinary: " + publicId, e);
            }
        }
    }