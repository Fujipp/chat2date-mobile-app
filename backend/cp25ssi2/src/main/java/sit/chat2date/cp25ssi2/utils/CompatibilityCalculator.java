package sit.chat2date.cp25ssi2.utils;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class CompatibilityCalculator {

    private static final double TRAVEL_WEIGHT = 0.40;
    private static final double LIFESTYLE_WEIGHT = 0.30;
    private static final double INTEREST_WEIGHT = 0.30;

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
        // 1. Travel Styles Score (2-3 อัน)
        double travelScore = calculateTravelScore(
                userTravelStyles,
                candidateTravelStyles,
                travelPref
        );

        // 2. Lifestyles Score (3-5 อัน)
        double lifestyleScore = calculateFlexibleScore(
                userLifestyles,
                candidateLifestyles,
                lifestylePref
        );

        // 3. Interests Score (3-5 อัน)
        double interestScore = calculateFlexibleScore(
                userInterests,
                candidateInterests,
                interestPref
        );

        // 4. Weighted Total
        double totalScore =
                (travelScore * TRAVEL_WEIGHT) +
                        (lifestyleScore * LIFESTYLE_WEIGHT) +
                        (interestScore * INTEREST_WEIGHT);

        return (int) Math.round(totalScore);
    }

    /**
     * คำนวณ Travel Styles Score (2-3 อัน)
     * SAME = ตรงทั้งหมด (2/2 หรือ 3/3) → 100 คะแนน
     * NEARLY = ตรงบางส่วน → 60-90 คะแนน
     * UNRELATED = ไม่ตรงเลย → 100 คะแนน
     */
    private double calculateTravelScore(
            List<String> userList,
            List<String> candidateList,
            String preference
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
                // ต้องตรงทั้งหมด (2/2 หรือ 3/3)
                if (matchCount == userTotal) {
                    return 100.0;
                }
                // ตรงบางส่วน
                else {
                    double matchRatio = (double) matchCount / userTotal;
                    return matchRatio * 60.0;  // ลงโทษหนักถ้าไม่ตรงทั้งหมด
                }

            case "NEARLY":
                // ตรงบางส่วน (ไม่ใช่ทั้งหมด และไม่ใช่ 0)
                if (matchCount > 0 && matchCount < userTotal) {
                    double matchRatio = (double) matchCount / userTotal;
                    // ยิ่งใกล้ 50-70% ยิ่งดี
                    if (matchRatio >= 0.4 && matchRatio <= 0.7) {
                        return 90.0 + (matchRatio * 10);
                    } else {
                        return 60.0 + (matchRatio * 30);
                    }
                }
                // ตรงทั้งหมด = เหมือนเกินไป (ควรเลือก SAME)
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

    /**
     * คำนวณ Lifestyles/Interests Score (3-5 อัน)
     * SAME = ตรงทั้งหมด → 85-100 คะแนน
     * NEARLY = ตรงบางส่วน → 60-98 คะแนน
     * UNRELATED = ไม่ตรงเลย → 100 คะแนน
     */
    private double calculateFlexibleScore(
            List<String> userList,
            List<String> candidateList,
            String preference
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
                if (matchCount == userTotal) {
                    // ถ้าเลือก 5/5 = 100 คะแนน
                    if (userTotal == 5) {
                        return 100.0;
                    }
                    // ถ้าเลือก 3/3 หรือ 4/4 = 85-90 คะแนน
                    else {
                        return 85.0;
                    }
                }
                // ตรงกันบางส่วน
                else {
                    double matchRatio = (double) matchCount / userTotal;
                    return matchRatio * 60.0;
                }

            case "NEARLY":
                // ตรงกันบางส่วน (ไม่ใช่ทั้งหมด และไม่ใช่ 0)
                if (matchCount > 0 && matchCount < userTotal) {
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