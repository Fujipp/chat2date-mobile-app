import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:chat2date/components/common/app_raw_scrollbar.dart';
import 'package:chat2date/components/common/image_upload_grid.dart';
import 'package:chat2date/components/design_system/index.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/typography/body_text_styles.dart';
import 'package:chat2date/core/theme/tokens/typography/display_text_styles.dart';
import 'package:chat2date/models/report_reason.dart';
import 'package:chat2date/models/report_request.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/report_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserReportScreen extends ConsumerStatefulWidget {
  const UserReportScreen({
    super.key,
    this.targetUserId,
    this.avatarUrl,
    this.userName,
    this.roomId,
    this.reportItems,
  });

  final String? targetUserId;
  final String? avatarUrl;
  final String? userName;
  final String? roomId;
  final List<ReportReason>? reportItems;

  @override
  ConsumerState<UserReportScreen> createState() => _UserReportScreenState();
}

class _UserReportScreenState extends ConsumerState<UserReportScreen> {
  late final List<ReportReason> _reportItems;
  final TextEditingController _otherReasonController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _otherReasonFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  final int _otherReasonCharLimit = 50;
  bool _isSubmitting = false;
  bool _showSuccessModal = false;
  List<String> _selectedReasons = [];
  List<String> _otherReasons = [];
  List<File> _selectedImages = [];

  bool get _canSubmit =>
      !_isSubmitting &&
      (_selectedReasons.isNotEmpty || _otherReasons.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _reportItems =
        widget.reportItems ??
        [
          ReportReason(id: 1, report: 'สแปม'),
          ReportReason(id: 2, report: 'โปรไฟล์ปลอม'),
          ReportReason(id: 3, report: 'พฤติกรรมไม่เหมาะสม'),
          ReportReason(id: 4, report: 'ภาษาที่ไม่เหมาะสม'),
          ReportReason(id: 5, report: 'อื่น ๆ'),
        ];
    _otherReasonController.addListener(_refresh);
  }

  @override
  void dispose() {
    _otherReasonController
      ..removeListener(_refresh)
      ..dispose();
    _descriptionController.dispose();
    _otherReasonFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _navigateBackToChat() {
    Navigator.pushReplacementNamed(
      context,
      '/chat',
      arguments: {
        'roomId': widget.roomId,
        'targetUserId': widget.targetUserId,
        'userName': widget.userName,
        'avatarUrl': widget.avatarUrl,
      },
    );
  }

  void _closeSuccessModalAndReturn() {
    if (!mounted) return;
    setState(() => _showSuccessModal = false);
    _navigateBackToChat();
  }

  void _toggleReason(String reason) {
    setState(() {
      if (_selectedReasons.contains(reason)) {
        _selectedReasons = _selectedReasons.where((item) => item != reason).toList();
      } else {
        _selectedReasons = [..._selectedReasons, reason];
      }
    });
  }

  void _addOtherReason() {
    final reason = _otherReasonController.text.trim();
    if (reason.isEmpty || _otherReasons.contains(reason)) {
      return;
    }

    setState(() {
      _otherReasons = [..._otherReasons, reason];
      _otherReasonController.clear();
    });
    _otherReasonFocusNode.requestFocus();
  }

  void _removeOtherReason(String reason) {
    setState(() {
      _otherReasons = _otherReasons.where((item) => item != reason).toList();
    });
  }

  void _showError(String message) {
    DsStatusModal.show(
      context,
      type: DsStatusModalType.warning,
      title: 'เกิดข้อผิดพลาด',
      message: message,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _submitReport() async {
    if (widget.targetUserId == null) {
      _showError('ไม่พบข้อมูลผู้ใช้ที่ต้องการรายงาน');
      return;
    }

    if (_selectedReasons.isEmpty && _otherReasons.isEmpty) {
      _showError('กรุณาเลือกเหตุผลในการรายงาน');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userStore = ref.read(userStoreProvider);
      final currentUser = userStore['user'] as User?;

      if (currentUser == null) {
        _showError('กรุณาเข้าสู่ระบบก่อนรายงาน');
        setState(() => _isSubmitting = false);
        return;
      }

      final allReasons = [..._selectedReasons, ..._otherReasons];
      final primaryReason = allReasons.first;
      final anotherReason =
          allReasons.length > 1 ? allReasons.skip(1).join(', ') : null;

      final request = ReportRequest(
        userId: currentUser.userId,
        targetUserId: widget.targetUserId!,
        reason: primaryReason,
        anotherReason: anotherReason,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      final reportService = ref.read(reportServiceProvider);
      await reportService.createReport(
        request,
        evidenceFiles: _selectedImages.isEmpty ? null : _selectedImages,
      );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _showSuccessModal = true;
      });

      unawaited(
        Future<void>.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;
          _closeSuccessModalAndReturn();
        }),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      DsAppSecondaryHeader(
                        variant: DsAppSecondaryHeaderVariant.baseText,
                        title: 'รายงาน',
                        onBackTap: _navigateBackToChat,
                        showBottomBorder: true,
                        bottomBorderSpacing: 0,
                      ),
                      Expanded(
                        child: AppRawScrollbar(
                          controller: _scrollController,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 310),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    _buildProfilePreview(),
                                    const SizedBox(height: 18),
                                    _buildReasonSection(),
                                    const SizedBox(height: 16),
                                    _buildOtherReasonSection(),
                                    const SizedBox(height: 16),
                                    DsTextAreaField(
                                      label: 'คำอธิบายเพิ่มเติม',
                                      hintText: 'ใส่คำอธิบาย',
                                      controller: _descriptionController,
                                      focusNode: _descriptionFocusNode,
                                      minLines: 4,
                                      maxLines: 4,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildEvidenceSection(),
                                    const SizedBox(height: 20),
                                    Center(
                                      child: DsButton(
                                        label: _isSubmitting
                                            ? 'กำลังส่ง...'
                                            : 'บันทึก',
                                        onPressed: _canSubmit
                                            ? _submitReport
                                            : null,
                                        variant: DsButtonVariant.primary,
                                        size: DsButtonSize.md,
                                        width: 231,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_showSuccessModal) ...[
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: ColoredBox(
                      color: AppColors.overlay.withValues(alpha: 0.18),
                    ),
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: Container(
                    width: 310,
                    height: 190,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ขอบคุณสำหรับการรายงาน',
                          textAlign: TextAlign.center,
                          style: AppDisplayTextStyles.subtitleBold.copyWith(
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'ระบบได้ส่งเรื่องของคุณไปยังผู้ดูแลระบบเรียบร้อยแล้ว\nและจะดำเนินการบล็อกบัญชีที่ถูกรายงานโดยทันที',
                          textAlign: TextAlign.center,
                          style: AppBodyTextStyles.bodySmall.copyWith(
                            color: AppColors.textSupport,
                            fontSize: 13,
                            height: 18 / 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DsButton(
                          label: 'ปิด',
                          onPressed: _closeSuccessModalAndReturn,
                          variant: DsButtonVariant.primary,
                          size: DsButtonSize.md,
                          width: 231,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePreview() {
    final avatarUrl = widget.avatarUrl;

    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF2F4F7),
              image: avatarUrl != null && avatarUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(avatarUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: avatarUrl == null || avatarUrl.isEmpty
                ? const Icon(
                    Icons.account_circle_rounded,
                    size: 100,
                    color: AppColors.surface,
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            widget.userName?.trim().isNotEmpty == true ? widget.userName! : 'Name',
            style: AppBodyTextStyles.body.copyWith(color: AppColors.textBlack),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เหตุผลที่ต้องการรายงาน',
          style: AppDisplayTextStyles.subtitleBold.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 8) / 2;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reportItems
                  .map(
                    (item) => SizedBox(
                      width: itemWidth,
                      child: _ReportReasonChip(
                        label: item.report,
                        selected: _selectedReasons.contains(item.report),
                        onTap: () => _toggleReason(item.report),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOtherReasonSection() {
    final canAdd = _otherReasonController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_otherReasons.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _otherReasons
                .map(
                  (reason) => _OtherReasonChip(
                    label: reason,
                    onRemove: () => _removeOtherReason(reason),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
        DsTextField(
          label: 'เหตุผลอื่น ๆ',
          hintText: 'ระบุเหตุผล',
          controller: _otherReasonController,
          focusNode: _otherReasonFocusNode,
          maxLength: _otherReasonCharLimit,
          suffix: GestureDetector(
            onTap: canAdd ? _addOtherReason : null,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.add,
                size: 22,
                color: canAdd ? AppColors.brandPrimary : AppColors.textDisabled,
              ),
            ),
          ),
          supportText: _otherReasons.isNotEmpty
              ? 'เพิ่มเหตุผลอื่นได้อีก หากต้องการระบุเพิ่มเติม'
              : null,
          showSupportText: _otherReasons.isNotEmpty,
        ),
      ],
    );
  }

  Widget _buildEvidenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'แนบหลักฐาน',
          style: AppDisplayTextStyles.subtitleBold.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ImageUploadGrid(
          isHorizontal: true,
          maxImages: 3,
          itemHeight: 70,
          itemWidth: 70,
          spacing: 16,
          addTileColor: AppColors.divider,
          addIconColor: AppColors.surface,
          tileRadius: 10,
          onImagesChanged: (images) {
            setState(() {
              _selectedImages = images.map((xFile) => File(xFile.path)).toList();
            });
          },
        ),
      ],
    );
  }
}

class _ReportReasonChip extends StatelessWidget {
  const _ReportReasonChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? AppColors.textBlack : AppColors.textSupport;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 33,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.brandSecondary : AppColors.background,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.brandSecondary : AppColors.textSupport,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 16, color: AppColors.textBlack),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppBodyTextStyles.body.copyWith(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherReasonChip extends StatelessWidget {
  const _OtherReasonChip({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.brandPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppBodyTextStyles.bodySmall.copyWith(
                color: AppColors.brandPrimary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: AppColors.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
