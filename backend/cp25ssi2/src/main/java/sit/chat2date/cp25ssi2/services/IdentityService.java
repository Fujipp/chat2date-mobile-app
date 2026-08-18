package sit.chat2date.cp25ssi2.services;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import sit.chat2date.cp25ssi2.clients.CloudinaryClient;
import sit.chat2date.cp25ssi2.clients.FaceVerificationClient;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.entities.UserPhoto;
import sit.chat2date.cp25ssi2.enums.AccountStatus;
import sit.chat2date.cp25ssi2.repositories.UserPhotoRepository;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class IdentityService {

    private final FaceVerificationClient faceVerificationClient;
    private final CloudinaryClient cloudinaryService;
    private final UserRepository userRepository;
    private final UserPhotoRepository userPhotoRepository;
    private final ExecutorService executorService = Executors.newFixedThreadPool(10);

    // Thread Pool สำหรับทำงานแบบ Parallel (ปรับขนาดตามเซิร์ฟเวอร์)
    public List<String> verifyAndUpload(String userId,
                                        List<MultipartFile> profileImages,
                                        String idCardBase64) {

        if (idCardBase64.contains(",")) {
            idCardBase64 = idCardBase64.split(",")[1];
        }
        byte[] idCardBytes = Base64.getDecoder().decode(idCardBase64);

        boolean hadVerifiedBefore = hasVerifiedPhotos(userId);
        boolean isVerified = verifyFacesParallel(profileImages, idCardBytes);

        // ถ้าไม่เคยผ่านมาก่อนเลย -> รอบนี้ต้องผ่าน
        if (!hadVerifiedBefore && !isVerified) {
            throw new IllegalArgumentException("ใบหน้าในรูปโปรไฟล์ไม่ตรงกับบัตรประชาชน");
        }

        // ถ้ารอบนี้มีรูปผ่าน → อัปเดต flag
        User user = userRepository.findUsersByUserId(userId);
        UserPhoto userPhoto = userPhotoRepository.findByUser_UserId(userId);

        if (isVerified) {
            if (userPhoto == null) {
                userPhoto = new UserPhoto();
                userPhoto.setUser(user);
                // ✅ สร้าง attributes ตั้งแต่ตอนนี้เลย
                userPhoto.setAttributes(new HashMap<>());
            }
            userPhoto.setIsVerified(true);
            user.setAccountStatus(AccountStatus.ACTIVE);
            userPhotoRepository.save(userPhoto);
        } else if (!hadVerifiedBefore) {
            throw new IllegalArgumentException("ใบหน้าในรูปโปรไฟล์ไม่ตรงกับบัตรประชาชน");
        }

        // อัปโหลดรูปใหม่
        List<String> uploadedUrls = uploadImagesParallel(profileImages);

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
            // Error in parallel verification
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

    private boolean hasVerifiedPhotos(String userId) {
        UserPhoto userPhoto = userPhotoRepository.findByUser_UserId(userId);
        return userPhoto != null && Boolean.TRUE.equals(userPhoto.getIsVerified());
    }



    /**
     * บันทึกข้อมูลรูปภาพลง Database
     */
    private void saveUserPhotos(String userId, List<String> uploadedUrls, String idCardBase64) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found: " + userId));

        UserPhoto userPhoto = userPhotoRepository.findByUser_UserId(userId);

        if (userPhoto == null) {
            // ✅ สร้างพร้อม attributes และ urls เลย
            userPhoto = new UserPhoto();
            userPhoto.setUser(user);
            userPhoto.setBase64Card(idCardBase64);

            Map<String, Object> attributes = new HashMap<>();
            attributes.put("urls", new ArrayList<>(uploadedUrls));
            userPhoto.setAttributes(attributes);
        } else {
            // อัพเดทข้อมูลเดิม
            if (idCardBase64 != null && !idCardBase64.isEmpty()) {
                userPhoto.setBase64Card(idCardBase64);
            }

            Map<String, Object> attributes = userPhoto.getAttributes();
            if (attributes == null) {
                attributes = new HashMap<>();
            }

            @SuppressWarnings("unchecked")
            List<String> urls = attributes.containsKey("urls") && attributes.get("urls") instanceof List
                    ? new ArrayList<>((List<String>) attributes.get("urls"))
                    : new ArrayList<>();

            // เพิ่ม URL ใหม่ (ป้องกันซ้ำ)
            uploadedUrls.stream()
                    .filter(url -> !urls.contains(url))
                    .forEach(urls::add);

            attributes.put("urls", urls);
            userPhoto.setAttributes(attributes);
        }

        // บันทึก
        userPhotoRepository.save(userPhoto);
    }

    public void deleteUserPhoto(String userId, List<String> imageUrl) throws IOException {
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
        List<String> urls = new ArrayList<>((List<String>) attributes.get("urls"));

        if (urls.isEmpty()) {
            throw new RuntimeException("No photos to delete.");
        }

        byte[] idCardBytes = downloadImageAsBytes(userPhoto.getBase64Card());

        int totalFaceCount = 0;
        Map<String, Boolean> isFaceMap = new HashMap<>();
        for (String url : urls) {
            byte[] profileBytes = downloadImageAsBytes(url);
            boolean match = faceVerificationClient.verify(idCardBytes, profileBytes);
            isFaceMap.put(url, match);
            if (match) totalFaceCount++;
        }

        List<String> publicIdsToDelete = new ArrayList<>();

        for (String imgUrl : imageUrl) {
            if (!urls.contains(imgUrl)) {
                throw new RuntimeException("Image url not found in user photos");
            }

            boolean isFace = isFaceMap.getOrDefault(imgUrl, false);

            if (isFace) {
                if (totalFaceCount <= 1) {
                    throw new RuntimeException("Cannot delete all face photos. At least one must remain.");
                }
                totalFaceCount--;
            }
            publicIdsToDelete.add(extractPublicIdFromUrl(imgUrl));
            urls.remove(imgUrl);

        }

        // 4) ลบออกจาก list แล้ว save กลับ
        attributes.put("urls", urls);
        userPhoto.setAttributes(attributes);
        userPhotoRepository.save(userPhoto);

        // ลบที่ Cloudinary
        for (String publicId : publicIdsToDelete) {
            cloudinaryService.delete(publicId);
        }
    }

    public byte[] downloadImageAsBytes(String imageSource) throws IOException {
        if (isBase64(imageSource)) {
            // ถ้าเป็น Base64
            if (imageSource.contains(",")) {
                // ลบ prefix เช่น "data:image/jpeg;base64,"
                imageSource = imageSource.split(",")[1];
            }
            return Base64.getDecoder().decode(imageSource);
        } else {
            // ถือว่าเป็น URL
            URL url = new URL(imageSource);
            try (InputStream in = url.openStream()) {
                return in.readAllBytes();
            }
        }
    }

    // ฟังก์ชันตรวจว่าเป็น Base64 ง่ายๆ
    private boolean isBase64(String str) {
        return str.startsWith("data:image/") ||
                (str.length() > 100 && str.matches("^[A-Za-z0-9+/=\\s]+$"));
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