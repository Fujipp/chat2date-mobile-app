package sit.chat2date.cp25ssi2.services;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sit.chat2date.cp25ssi2.dto.ReportDetailResponse;
import sit.chat2date.cp25ssi2.entities.Report;
import sit.chat2date.cp25ssi2.entities.ReportEvidence;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.enums.AccountStatus;
import sit.chat2date.cp25ssi2.enums.ReportStatus;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.repositories.ReportEvidenceRepository;
import sit.chat2date.cp25ssi2.repositories.ReportRepository;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AdminReportService {

    private final ReportRepository reportRepository;
    private final ReportEvidenceRepository reportEvidenceRepository;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper;

    /**
     * Get all reports with optional status filter and pagination
     */
    public Page<Report> getAllReports(ReportStatus status, Pageable pageable) {
        if (status != null) {
            return reportRepository.findByStatus(status, pageable);
        }
        return reportRepository.findAll(pageable);
    }

    /**
     * Get detailed report information including evidence and user details
     */
    @Transactional(readOnly = true)
    public ReportDetailResponse getReportById(Integer reportId) {
        Report report = reportRepository.findById(reportId)
                .orElseThrow(() -> new NotFoundException("Report not found"));

        // Get reporter info
        User reporter = userRepository.findByUserId(report.getReporterId())
                .orElse(null);

        // Get target user info
        User targetUser = userRepository.findByUserId(report.getTargetUserId())
                .orElse(null);

        // Get evidence URLs
        List<String> evidenceUrls = new ArrayList<>();
        List<ReportEvidence> evidences = reportEvidenceRepository.findByReportId(reportId);
        for (ReportEvidence evidence : evidences) {
            try {
                if (evidence.getEvidenceUrl() != null) {
                    List<String> urls = objectMapper.readValue(
                            evidence.getEvidenceUrl(),
                            new TypeReference<List<String>>() {
                            }
                    );
                    evidenceUrls.addAll(urls);
                }
            } catch (Exception e) {
                // Log error but continue
                System.err.println("Failed to parse evidence URL: " + e.getMessage());
            }
        }

        return ReportDetailResponse.builder()
                .reportId(report.getReportId())
                .reporterId(report.getReporterId())
                .targetUserId(report.getTargetUserId())
                .reason(report.getReason())
                .anotherReason(report.getAnotherReason())
                .description(report.getDescription())
                .status(report.getStatus())
                .isNotified(report.getIsNotified())
                .createdAt(report.getCreatedAt())
                .evidenceUrls(evidenceUrls)
                .reporter(reporter != null ? mapUserToBasicInfo(reporter) : null)
                .targetUser(targetUser != null ? mapUserToBasicInfo(targetUser) : null)
                .build();
    }

    /**
     * Update report status
     */
    @Transactional
    public Report updateReportStatus(Integer reportId, ReportStatus newStatus, int decreasePoint) {
        Report report = reportRepository.findById(reportId)
                .orElseThrow(() -> new NotFoundException("Report not found"));

        report.setStatus(newStatus);

        if (newStatus == ReportStatus.RESOLVED) {
            Optional<User> user = userRepository.findByUserId(report.getTargetUserId());
            user.ifPresent(value -> value.setBehaviorScore(value.getBehaviorScore() - decreasePoint));
            if (user.get().getBehaviorScore() <= 50 && user.get().getBehaviorScore() >= 30) {

            } else if (user.get().getBehaviorScore() < 30) {
                user.get().setIsBlacklist(true);
                user.get().setDeletedAt(LocalDateTime.now());
                user.get().setAccountStatus(AccountStatus.SUSPENDED);
            }
            userRepository.save(user.get());
        }

        if (newStatus == ReportStatus.RESOLVED || newStatus == ReportStatus.DISMISSED) {
            report.setIsNotified(true);
        }

        return reportRepository.save(report);
    }

    /**
     * Helper method to map User entity to UserBasicInfo DTO
     */
    private ReportDetailResponse.UserBasicInfo mapUserToBasicInfo(User user) {
        // Calculate age from birthday
        Integer age = null;
        if (user.getBirthday() != null) {
            age = Period.between(user.getBirthday(), LocalDate.now()).getYears();
        }

        return ReportDetailResponse.UserBasicInfo.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .phoneNumber(user.getPhoneNumber())
                .firstname(user.getFirstname())
                .lastname(user.getLastname())
                .nickname(user.getNickname())
                .age(age)
                .sex(user.getSex() != null ? user.getSex().name() : null)
                .accountStatus(user.getAccountStatus() != null ? user.getAccountStatus().name() : null)
                .isBlacklist(user.getIsBlacklist())
                .behaviorScore(user.getBehaviorScore())
                .profilePhotoUrl(null) // Profile photo URL not available in User entity
                .build();
    }
}
