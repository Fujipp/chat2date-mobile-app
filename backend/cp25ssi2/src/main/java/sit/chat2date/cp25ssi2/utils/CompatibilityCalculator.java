package sit.chat2date.cp25ssi2.utils;

import java.util.List;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class CompatibilityCalculator {

    private static final double TRAVEL_WEIGHT = 0.40;
    private static final double LIFESTYLE_WEIGHT = 0.30;
    private static final double INTEREST_WEIGHT = 0.30;

    // จำนวนที่ User ต้องเลือก
    private static final int REQUIRED_TRAVEL_COUNT = 3;

    public int calculateCompatibilityWithPreference(
            List<String> userTravelStyles,
            List<String> candidateTravelStyles,
            String travelPref,

            List<String> userLifestyles,
            List<String> candidateLifestyles,
            String lifestylePref,

            List<String> userInterests,
            List<String> candidateInterests,
            String interestPref
    ) {
        // 1. Travel Styles Score (บังคับ 3 อัน)
        double travelScore = calculateTravelScore(
                userTravelStyles,
                candidateTravelStyles,
                travelPref
        );

        // 2. Lifestyles Score (1-5 อัน)
        double lifestyleScore = calculateFlexibleScore(
                userLifestyles,
                candidateLifestyles,
                lifestylePref,
                5  // max count
        );

        // 3. Interests Score (1-5 อัน)
        double interestScore = calculateFlexibleScore(
                userInterests,
                candidateInterests,
                interestPref,
                5  // max count
        );

        // 4. Weighted Total
        double totalScore =
                (travelScore * TRAVEL_WEIGHT) +
                        (lifestyleScore * LIFESTYLE_WEIGHT) +
                        (interestScore * INTEREST_WEIGHT);

        return (int) Math.round(totalScore);
    }

    /**
     * คำนวณ Travel Styles Score (บังคับ 3 อัน)
     */
    private double calculateTravelScore(
            List<String> userList,
            List<String> candidateList,
            String preference
    ) {
        if (userList.isEmpty() || candidateList.isEmpty()) {
            return 0.0;
        }

        // นับจำนวนที่ตรงกัน
        long matchCount = userList.stream()
                .filter(candidateList::contains)
                .count();

        switch (preference) {
            case "SAME":
                // ต้องตรงกันทั้ง 3 อัน
                if (matchCount == 3) {
                    return 100.0;
                }
                // ตรง 2 อัน
                else if (matchCount == 2) {
                    return 60.0;
                }
                // ตรง 1 อัน
                else if (matchCount == 1) {
                    return 30.0;
                }
                // ไม่ตรงเลย
                else {
                    return 0.0;
                }

            case "NEARLY":
                // ตรง 2 อัน = ดีที่สุด
                if (matchCount == 2) {
                    return 100.0;
                }
                // ตรง 1 อัน = ดี
                else if (matchCount == 1) {
                    return 80.0;
                }
                // ตรง 3 อัน = เหมือนเกินไป
                else if (matchCount == 3) {
                    return 50.0;
                }
                // ไม่ตรงเลย = ต่างเกินไป
                else {
                    return 20.0;
                }

            case "UNRELATED":
                // ไม่ตรงเลย = ดีที่สุด
                if (matchCount == 0) {
                    return 100.0;
                }
                // ตรง 1 อัน
                else if (matchCount == 1) {
                    return 40.0;
                }
                // ตรง 2 อัน
                else if (matchCount == 2) {
                    return 20.0;
                }
                // ตรง 3 อัน = แย่ที่สุด
                else {
                    return 0.0;
                }

            case "UNNECESSARY":
                // ไม่นับคะแนน
                return 50.0;

            default:
                return 0.0;
        }
    }

    /**
     * คำนวณ Lifestyles/Interests Score (flexible 1-5 อัน)
     */
    private double calculateFlexibleScore(
            List<String> userList,
            List<String> candidateList,
            String preference,
            int maxCount
    ) {
        if (userList.isEmpty() || candidateList.isEmpty()) {
            return 0.0;
        }

        int userTotal = userList.size();

        // นับจำนวนที่ตรงกัน
        long matchCount = userList.stream()
                .filter(candidateList::contains)
                .count();

        switch (preference) {
            case "SAME":
                // ต้องตรงกันทั้งหมด
                if (matchCount == userTotal && matchCount == maxCount) {
                    return 100.0;  // 5/5
                }
                // ตรงกันหมดแต่ไม่ถึง max
                else if (matchCount == userTotal) {
                    return 85.0;   // เช่น 3/3, 4/4
                }
                // ตรงกันบางส่วน
                else {
                    double matchRatio = (double) matchCount / userTotal;
                    return matchRatio * 60.0;  // ลงโทษหนัก
                }

            case "NEARLY":
                // ตรงกันบางส่วน (ไม่ใช่ทั้งหมด และไม่ใช่ 0)
                if (matchCount > 0 && matchCount < userTotal) {
                    // ตรง 2/5, 3/5, 4/5 = ดี
                    double matchRatio = (double) matchCount / userTotal;

                    // สูตร: ยิ่งใกล้ 50-80% ยิ่งดี
                    if (matchRatio >= 0.4 && matchRatio <= 0.8) {
                        return 90.0 + (matchRatio * 10);  // 90-98 คะแนน
                    }
                    // น้อยกว่า 40%
                    else if (matchRatio < 0.4) {
                        return 60.0 + (matchRatio * 50);  // 60-80 คะแนน
                    }
                    // มากกว่า 80%
                    else {
                        return 70.0;  // เหมือนมากเกินไป
                    }
                }
                // ตรงกันทั้งหมด = ไม่ดีเพราะควรเป็น SAME
                else if (matchCount == userTotal) {
                    return 50.0;
                }
                // ไม่ตรงเลย = ต่างเกินไป
                else {
                    return 20.0;
                }

            case "UNRELATED":
                // ไม่ตรงเลย = ดีที่สุด
                if (matchCount == 0) {
                    return 100.0;
                }
                // ยิ่งตรงมาก ยิ่งแย่
                else {
                    double matchRatio = (double) matchCount / userTotal;
                    return 100.0 - (matchRatio * 100);
                }

            case "UNNECESSARY":
                // ไม่นับคะแนน
                return 50.0;

            default:
                return 0.0;
        }
    }
}