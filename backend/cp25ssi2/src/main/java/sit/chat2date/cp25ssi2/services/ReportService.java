package sit.chat2date.cp25ssi2.services;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import sit.chat2date.cp25ssi2.dto.ReportRequest;
import sit.chat2date.cp25ssi2.dto.ReportResponse;
import sit.chat2date.cp25ssi2.entities.Report;
import sit.chat2date.cp25ssi2.entities.ReportEvidence;
import sit.chat2date.cp25ssi2.enums.ReportStatus;
import sit.chat2date.cp25ssi2.exceptions.*;
import sit.chat2date.cp25ssi2.repositories.ReportEvidenceRepository;
import sit.chat2date.cp25ssi2.repositories.ReportRepository;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final ReportRepository reportRepository;
    private final ReportEvidenceRepository reportEvidenceRepository;
    private final UserRepository userRepository;
    private final Cloudinary cloudinary;
    private final ObjectMapper objectMapper;

    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
    private static final List<String> ALLOWED_CONTENT_TYPES = List.of(
            "image/jpeg", "image/png", "image/gif", "image/webp",
            "video/mp4", "video/quicktime");

    /**
     * Create a new report with optional evidence files
     */
    @Transactional
    public ReportResponse createReport(String userId, ReportRequest request, List<MultipartFile> evidenceFiles) {
        // Validate reporter
        if (!request.getUserId().equals(userId)) {
            throw new BadRequestException("User ID mismatch");
        }

        // Validate target user exists
        userRepository.findByUserId(request.getTargetUserId())
                .orElseThrow(() -> new NotFoundException("Target user not found"));

        // Check for existing report - 409 CONFLICT
        if (reportRepository.existsByReporterIdAndTargetUserId(userId, request.getTargetUserId())) {
            throw new ConflictException("You have already reported this user");
        }

        // Create report
        Report report = Report.builder()
                .reporterId(userId)
                .targetUserId(request.getTargetUserId())
                .reason(request.getReason())
                .anotherReason(request.getAnotherReason())
                .description(request.getDescription())
                .status(ReportStatus.PENDING)
                .isNotified(false)
                .build();

        report = reportRepository.save(report);

        // Handle evidence files
        if (evidenceFiles != null && !evidenceFiles.isEmpty()) {
            List<String> evidenceUrls = uploadEvidenceFiles(evidenceFiles);

            if (!evidenceUrls.isEmpty()) {
                try {
                    String evidenceJson = objectMapper.writeValueAsString(evidenceUrls);
                    ReportEvidence evidence = ReportEvidence.builder()
                            .reportId(report.getReportId())
                            .evidenceUrl(evidenceJson)
                            .build();
                    reportEvidenceRepository.save(evidence);
                } catch (Exception e) {
                    // Log error but don't fail the report
                    // Failed to save evidence
                }
            }
        }

        return ReportResponse.builder()
                .reportId(report.getReportId())
                .reporterId(report.getReporterId())
                .targetUserId(report.getTargetUserId())
                .reason(report.getReason())
                .status(report.getStatus())
                .createdAt(report.getCreatedAt())
                .build();
    }

    private List<String> uploadEvidenceFiles(List<MultipartFile> files) {
        List<String> urls = new ArrayList<>();

        for (MultipartFile file : files) {
            if (file.isEmpty())
                continue;

            // Validate file size - 413 PAYLOAD TOO LARGE
            if (file.getSize() > MAX_FILE_SIZE) {
                throw new PayloadTooLargeException("File size exceeds maximum limit of 10MB");
            }

            // Validate content type - 415 UNSUPPORTED MEDIA TYPE
            String contentType = file.getContentType();
            if (contentType == null || !ALLOWED_CONTENT_TYPES.contains(contentType)) {
                throw new UnsupportedMediaTypeException("Unsupported file type: " + contentType);
            }

            try {
                @SuppressWarnings("unchecked")
                Map<String, Object> uploadResult = cloudinary.uploader().upload(file.getBytes(),
                        ObjectUtils.asMap(
                                "folder", "reports/evidence",
                                "resource_type", "auto"));
                urls.add((String) uploadResult.get("secure_url"));
            } catch (IOException e) {
                throw new BadRequestException("Failed to upload file: " + e.getMessage());
            }
        }

        return urls;
    }
}
