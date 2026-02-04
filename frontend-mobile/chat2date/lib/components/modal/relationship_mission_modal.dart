import 'dart:ui';
import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat2date/theme/app_colors.dart';

class RelationshipMissionModal extends StatelessWidget {
  final int streakDays;
  final int dailyMessages;
  final bool isFirstMessageBonus;

  const RelationshipMissionModal({
    super.key,
    required this.streakDays,
    required this.dailyMessages,
    this.isFirstMessageBonus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildConnectionStatusBanner(),
                      const SizedBox(height: 16),
                      _buildMissionCard(
                        svgPath: "assets/icons/HEART_STATUS_BAR.svg",
                        iconColor: AppColors.brandAccentStrong,
                        title: 'ก้าวแรกแห่งความสัมพันธ์ (ครั้งเดียว)',
                        description:
                            'เริ่มต้นบทสนทนาครั้งแรก แต้มความสัมพันธ์ +5 คะแนน',
                        progressText: isFirstMessageBonus ? 'สำเร็จ' : '0/1',
                        isCompleted: isFirstMessageBonus,
                      ),
                      const SizedBox(height: 12),
                      _buildMissionCard(
                        svgPath: "assets/icons/icon_chat.svg",
                        iconColor: AppColors.brandPrimary,
                        title: 'บทสนทนาที่ไหลลื่น (รายวัน)',
                        description:
                            'ส่งข้อความครบ 30 ข้อความวันนี้ แต้มความสัมพันธ์ +8 คะแนน',
                        progressValue: (dailyMessages / 30).clamp(0.0, 1.0),
                        progressText: '$dailyMessages/30',
                        isCompleted: dailyMessages >= 30,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: AppColors.divider, height: 1),
                      ),
                      _buildStreakMission(3, 'แต้มความสัมพันธ์ +7 คะแนน'),
                      const SizedBox(height: 12),
                      _buildStreakMission(7, 'แต้มความสัมพันธ์ +10 คะแนน'),
                      const SizedBox(height: 12),
                      _buildStreakMission(10, 'แต้มความสัมพันธ์ +20 คะแนน'),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: AppColors.divider, height: 1),
                      ),
                      _buildPenaltySection(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildCloseButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatusBanner() {
    if (streakDays >= 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.brandSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.brandSecondary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/icon_check.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.brandSecondary700,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'สถานะ: กำลังคุยกันอย่างต่อเนื่อง',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.successText,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final int missedDays = streakDays.abs();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.badgeErrorBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/icon_warning.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.error,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'เงียบหายไป $missedDays วันแล้ว',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.error,
                  ),
                ),
                Text(
                  missedDays >= 25
                      ? 'ระวัง: ความสัมพันธ์ใกล้จะสิ้นสุดลง'
                      : 'รีบทักไปคุยเพื่อรักษาแต้มความสัมพันธ์นะ',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/icons/icon_warning.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(AppColors.error, BlendMode.srcIn),
            ),
            SizedBox(width: 8),
            Text(
              'บทลงโทษเมื่อขาดการติดต่อ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildPenaltyRow(
          'ไม่คุยต่อเนื่อง 3 วัน',
          'หัก 5 คะแนน',
          streakDays <= -3,
        ),
        const SizedBox(height: 8),
        _buildPenaltyRow(
          'ไม่คุยต่อเนื่อง 7 วัน',
          'หัก 10 คะแนน',
          streakDays <= -7,
        ),
        const SizedBox(height: 8),
        _buildPenaltyRow(
          'ไม่คุยต่อเนื่อง 10 วัน',
          'หัก 25 คะแนน',
          streakDays <= -10,
        ),
        const SizedBox(height: 8),
        _buildPenaltyRow(
          'ไม่คุยต่อเนื่อง 30 วัน',
          'Unmatch อัตโนมัติ',
          streakDays <= -30,
          isCritical: true,
        ),
      ],
    );
  }

  Widget _buildPenaltyRow(
    String title,
    String penalty,
    bool isActive, {
    bool isCritical = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AppColors.badgeErrorBg : AppColors.neutral50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? AppColors.error.withOpacity(0.4)
              : AppColors.neutral200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.error : AppColors.textSecondary,
            ),
          ),
          Text(
            penalty,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: (isCritical || isActive)
                  ? AppColors.error
                  : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakMission(int targetDays, String milestoneTitle) {
    final int displayDays = streakDays < 0 ? 0 : streakDays;
    final bool isAchieved = streakDays >= targetDays;
    final double progress = (displayDays / targetDays).clamp(0.0, 1.0);

    return _buildMissionCard(
      svgPath: "assets/icons/icon_one-sided.svg",
      iconColor: AppColors.warning,
      title: 'คุยต่อเนื่อง $targetDays วัน',
      description: milestoneTitle,
      progressValue: isAchieved ? null : progress,
      progressText: isAchieved ? 'สำเร็จแล้ว' : '$displayDays/$targetDays วัน',
      isCompleted: isAchieved,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'หลอดความสัมพันธ์',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: SvgPicture.asset(
                "assets/icons/icon_close.svg",
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.textMuted, // แนะนำให้ใช้สีเทา Muted ตาม UI ปกติ
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
        const Text(
          'ภารกิจจะช่วยเพิ่มแต้มความสัมพันธ์ และปลดล็อกฟีเจอร์นัดเดทเมื่อครบ 100 คะแนน',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildMissionCard({
    required String svgPath,
    required Color iconColor,
    required String title,
    required String description,
    required String progressText,
    double? progressValue,
    bool isCompleted = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? iconColor.withOpacity(0.05) : AppColors.neutral50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCompleted
              ? iconColor.withOpacity(0.5)
              : AppColors.neutral200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                svgPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isCompleted)
                SvgPicture.asset(
                  'assets/icons/icon_check.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.brandSecondary700,
                    BlendMode.srcIn,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (progressValue != null && !isCompleted)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: iconColor.withOpacity(0.1),
                      color: iconColor,
                      minHeight: 6,
                    ),
                  ),
                ),
              if (progressValue != null && !isCompleted)
                const SizedBox(width: 12),
              Text(
                progressText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isCompleted
                      ? AppColors.successText
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return DsButton(
      label: "รับทราบ!",
      onPressed: () => Navigator.pop(context),
      size: DsButtonSize.lg,
    );
  }
}
