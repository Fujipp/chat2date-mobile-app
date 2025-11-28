package sit.chat2date.cp25ssi2.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import sit.chat2date.cp25ssi2.clients.CloudinaryClient;
import sit.chat2date.cp25ssi2.clients.FaceVerificationClient;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.entities.UserPhoto;
import sit.chat2date.cp25ssi2.enums.AccountStatus;
import sit.chat2date.cp25ssi2.repositories.UserPhotoRepository;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.util.*;
import java.util.concurrent.*;
import java.util.stream.Collectors;

@Service
public class IdentityService {

    @Autowired
    private FaceVerificationClient faceVerificationClient;

    @Autowired
    private CloudinaryClient cloudinaryService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserPhotoRepository userPhotoRepository;

    // Thread Pool สำหรับทำงานแบบ Parallel (ปรับขนาดตามเซิร์ฟเวอร์)
    private final ExecutorService executorService = Executors.newFixedThreadPool(10);

    public List<String> verifyAndUpload(String userId, List<MultipartFile> profileImages, String idCardBase64) {

        // 1. เตรียมรูปบัตรประชาชนครั้งเดียว
        if (idCardBase64.contains(",")) {
            idCardBase64 = idCardBase64.split(",")[1];
        }
        byte[] idCardBytes = Base64.getDecoder().decode(idCardBase64);

        // 2. ✨ Verify แบบ Parallel - หยุดทันทีที่เจอรูปแรกที่ Match
        boolean isVerified = verifyFacesParallel(profileImages, idCardBytes);

        if (!isVerified) {
            throw new IllegalArgumentException("ใบหน้าในรูปโปรไฟล์ไม่ตรงกับบัตรประชาชน");
        }

        // 3. ✨ Upload แบบ Parallel - อัปโหลดพร้อมกันทุกรูป
        List<String> uploadedUrls = uploadImagesParallel(profileImages);
        User user = userRepository.findUsersByUserId(userId);

        // 4. บันทึกลง Database
        user.setAccountStatus(AccountStatus.ACTIVE);
        saveUserPhotos(userId, uploadedUrls, idCardBase64);

        return uploadedUrls;
    }

    /**
     * Verify ใบหน้าแบบ Parallel - หยุดทันทีที่เจอรูปแรกที่ตรง
     */
    private boolean verifyFacesParallel(List<MultipartFile> profileImages, byte[] idCardBytes) {
        List<CompletableFuture<Boolean>> futures = profileImages.stream()
                .map(file -> CompletableFuture.supplyAsync(() -> {
                    try {
                        byte[] profileBytes = file.getBytes();
                        return faceVerificationClient.verify(idCardBytes, profileBytes);
                    } catch (Exception e) {
                        System.err.println("Error verifying image: " + file.getOriginalFilename());
                        return false;
                    }
                }, executorService))
                .collect(Collectors.toList());

        // ✨ รอจนกว่าจะมีรูปใดรูปหนึ่งที่ Match (หรือครบทุกรูป)
        try {
            CompletableFuture<Object> anyMatch = CompletableFuture.anyOf(
                    futures.stream()
                            .map(f -> f.thenApply(result -> result ? result : null))
                            .toArray(CompletableFuture[]::new)
            );

            // เช็กว่ามีรูปไหน Match ไหม
            for (CompletableFuture<Boolean> future : futures) {
                if (future.getNow(false)) {
                    // ✨ เจอแล้ว! ยกเลิกงานที่เหลือทันที
                    futures.forEach(f -> f.cancel(true));
                    return true;
                }
            }

            // รอให้ทุก future เสร็จ
            CompletableFuture.allOf(futures.toArray(new CompletableFuture[0])).join();

            // เช็กผลลัพธ์สุดท้าย
            return futures.stream().anyMatch(f -> {
                try {
                    return f.get();
                } catch (Exception e) {
                    return false;
                }
            });

        } catch (Exception e) {
            System.err.println("Error in parallel verification: " + e.getMessage());
            return false;
        }
    }

    /**
     * Upload รูปแบบ Parallel - อัปโหลดพร้อมกันทั้งหมด
     */
    private List<String> uploadImagesParallel(List<MultipartFile> profileImages) {
        List<CompletableFuture<String>> uploadFutures = profileImages.stream()
                .map(file -> CompletableFuture.supplyAsync(() -> {
                    try {
                        return cloudinaryService.upload(file);
                    } catch (Exception e) {
                        throw new RuntimeException("Upload failed for " + file.getOriginalFilename(), e);
                    }
                }, executorService))
                .collect(Collectors.toList());

        // รอให้ทุกรูปอัปโหลดเสร็จ
        try {
            CompletableFuture.allOf(uploadFutures.toArray(new CompletableFuture[0])).join();

            return uploadFutures.stream()
                    .map(future -> {
                        try {
                            return future.get();
                        } catch (Exception e) {
                            throw new RuntimeException("Failed to get upload result", e);
                        }
                    })
                    .collect(Collectors.toList());

        } catch (Exception e) {
            throw new RuntimeException("Upload process failed", e);
        }
    }

    /**
     * บันทึกข้อมูลรูปภาพลง Database
     */
    private void saveUserPhotos(String userId, List<String> uploadedUrls, String idCardBase64) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found: " + userId));

        UserPhoto userPhoto = userPhotoRepository.findByUser_UserId(userId);

        if (userPhoto == null) {
            userPhoto = new UserPhoto();
            userPhoto.setUser(user);
        }
        userPhoto.setBase64Card(idCardBase64);

        Map<String, Object> attributes = new HashMap<>();
        attributes.put("urls", uploadedUrls);

        userPhoto.setAttributes(attributes);
        userPhotoRepository.save(userPhoto);
    }

    public void deleteUserPhoto(String userId, String imageUrl) {
        // 1) หา UserPhoto ตาม userId
        UserPhoto userPhoto = userPhotoRepository.findByUser_UserId(userId);
        if (userPhoto == null) {
            throw new RuntimeException("User photo not found for userId: " + userId);
        }

        // 2) ดึง attributes (map) และ list ของ urls
        Map<String, Object> attributes = userPhoto.getAttributes();
        if (attributes == null || !attributes.containsKey("urls")) {
            throw new RuntimeException("No urls found for userId: " + userId);
        }

        @SuppressWarnings("unchecked")
        List<String> urls = (List<String>) attributes.get("urls");

        // 3) เช็กว่ามี url นี้ไหม
        if (!urls.contains(imageUrl)) {
            throw new RuntimeException("Image url not found in user photos");
        }

        // 4) ลบออกจาก list แล้ว save กลับ
        urls.remove(imageUrl);
        attributes.put("urls", urls);
        userPhoto.setAttributes(attributes);
        userPhotoRepository.save(userPhoto);

        // 5) แปลง URL → publicId แล้วสั่งลบที่ Cloudinary
        String publicId = extractPublicIdFromUrl(imageUrl);
        cloudinaryService.delete(publicId);
    }

    private String extractPublicIdFromUrl(String url) {
        // ตัด query string ถ้ามี
        String clean = url.split("\\?")[0];

        // ดึงส่วนหลัง /upload/
        int uploadIndex = clean.indexOf("/upload/");
        if (uploadIndex == -1) {
            throw new IllegalArgumentException("Invalid Cloudinary URL: " + url);
        }

        String afterUpload = clean.substring(uploadIndex + "/upload/".length());
        // afterUpload = v1763908238/chat2date_users/hq0aknxpkb87dawkjx9l.jpg

        // ตัดเวอร์ชัน (v1763908238/)
        String[] parts = afterUpload.split("/");
        int startIdx = 0;
        if (parts[0].startsWith("v") && parts[0].length() > 1) {
            startIdx = 1;
        }

        StringBuilder sb = new StringBuilder();
        for (int i = startIdx; i < parts.length; i++) {
            if (i > startIdx) sb.append("/");
            sb.append(parts[i]);
        }

        // ตัดนามสกุลไฟล์
        String withExt = sb.toString();
        int dotIndex = withExt.lastIndexOf('.');
        return (dotIndex == -1) ? withExt : withExt.substring(0, dotIndex);
    }


}