package sit.chat2date.cp25ssi2.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import sit.chat2date.cp25ssi2.clients.FaceVerificationClient;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.entities.UserPhoto;
import sit.chat2date.cp25ssi2.repositories.UserPhotoRepository;
import sit.chat2date.cp25ssi2.repositories.UserRepository;


import java.util.*;

@Service
public class IdentityService {

    @Autowired
    private FaceVerificationClient faceVerificationClient;

     @Autowired
     private CloudinaryService cloudinaryService;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private UserPhotoRepository userPhotoRepository;

    public List<String> verifyAndUpload(String userId, List<MultipartFile> profileImages, String idCardBase64 ) {

        // 1. เตรียมรูปบัตรประชาชน (แปลงจาก Base64 เป็น byte[] แค่ครั้งเดียว)
        if (idCardBase64.contains(",")) {
            idCardBase64 = idCardBase64.split(",")[1];
        }
        byte[] idCardBytes = Base64.getDecoder().decode(idCardBase64);

        boolean isVerified = false;

        // 2. Loop เช็กทีละรูป (เอาไฟล์รูปโปรไฟล์มาชนกับรูปบัตร)
        for (MultipartFile file : profileImages) {
            try {
                byte[] profileBytes = file.getBytes();

                boolean isMatch = faceVerificationClient.verify(idCardBytes, profileBytes);

                if (isMatch) {
                    isVerified = true;
                    break;
                }

            } catch (Exception e) {
                System.err.println("Error checking image: " + file.getOriginalFilename());
                continue;
            }
        }

        // 3. สรุปผล ถ้าเช็กครบทุกรูปแล้วยังไม่เจอ
        if (!isVerified) {
            throw new IllegalArgumentException("ใบหน้าในรูปโปรไฟล์ไม่ตรงกับบัตรประชาชน");
        }

        // 4. ถ้าผ่านแล้ว ค่อยอัปโหลดขึ้น Cloudinary (ทำนอก Loop เหมือนเดิม)
        List<String> uploadedUrls = new ArrayList<>();

        for (MultipartFile file : profileImages) {
             try {
                 String url = cloudinaryService.upload(file);
                 uploadedUrls.add(url);
             } catch (Exception e) {
                 throw new RuntimeException("Upload failed", e);
             }
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found: " + userId));

        UserPhoto userPhoto = userPhotoRepository.findByUser_UserId(userId);

        if (userPhoto == null) {
            userPhoto = new UserPhoto();
            userPhoto.setUser(user);
        }

        Map<String, Object> attributes = new HashMap<>();
        attributes.put("urls", uploadedUrls);

        userPhoto.setAttributes(attributes);

        userPhotoRepository.save(userPhoto);

        return uploadedUrls;
    }
}