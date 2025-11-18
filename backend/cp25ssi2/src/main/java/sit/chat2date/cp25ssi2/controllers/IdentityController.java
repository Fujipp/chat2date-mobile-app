package sit.chat2date.cp25ssi2.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import sit.chat2date.cp25ssi2.services.IdentityService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/identity")
@Validated
public class IdentityController {

        @Autowired
        private IdentityService identityService;

        @PostMapping("/verify-face")
        public ResponseEntity<?> verifyFace(
                @RequestParam("profile_images") List<MultipartFile> profileImages,
                @RequestParam("id_card_base64") String idCardBase64,
                @RequestParam("userId") String userId
        ) {
            try {
                if (profileImages == null || profileImages.isEmpty()) {
                    return ResponseEntity.badRequest().body(Map.of("message", "Profile images are required"));
                }
                if (profileImages.size() > 6) {
                    return ResponseEntity.badRequest().body(Map.of("message", "Maximum 6 images allowed"));
                }
                System.out.println(idCardBase64);

                List<String> uploadedUrls = identityService.verifyAndUpload(userId, profileImages, idCardBase64);

                return ResponseEntity.ok(Map.of(
                        "status", "verified",
                        "image_urls", uploadedUrls
                ));

            } catch (IllegalArgumentException e) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", e.getMessage()));
            } catch (Exception e) {
                e.printStackTrace();
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("message", "Internal Server Error"));
            }
        }
    }
