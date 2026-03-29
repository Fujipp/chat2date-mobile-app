import 'dart:io';

import 'package:chat2date/components/design_system/buttons/ds_button.dart';
import 'package:chat2date/components/design_system/feedback/ds_action_modal.dart';
import 'package:chat2date/components/design_system/feedback/ds_toast.dart';
import 'package:chat2date/components/design_system/organisms/ds_app_secondary_header.dart';
import 'package:chat2date/components/common/image_upload_grid.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/colors/text_colors.dart';
import 'package:chat2date/core/theme/tokens/typography/display_text_styles.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/photo_verification_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPictureScreen extends ConsumerStatefulWidget {
  const UserPictureScreen({super.key});

  @override
  ConsumerState<UserPictureScreen> createState() => _UserPictureScreenState();
}

class _UserPictureScreenState extends ConsumerState<UserPictureScreen> {
  List<File> _selectedImages = [];
  bool _isLoading = false;
  Key _imageGridKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _selectedImages = [];
    _imageGridKey = UniqueKey();
  }

  void _showFaceVerificationDialog() {
    DsActionModal.show(
      context,
      barrierDismissible: false,
      child: DsActionModal(
        title: 'ไม่พบใบหน้าที่ชัดเจน',
        description:
            'เราตรวจไม่พบใบหน้าที่ชัดเจนในรูปภาพของคุณ หรือใบหน้าไม่ตรงกับรูปบัตรประชาชน',
        minHeight: 360,
        topVisual: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            size: 36,
            color: AppColors.warning,
          ),
        ),
        content: DsModalInfoBox(
          heading: 'คำแนะนำ',
          headingColor: Colors.blue[700]!,
          lines: const [
            'ถ่ายรูปในที่ที่มีแสงสว่างเพียงพอ',
            'ใบหน้าหันตรงกล้องและเห็นชัดเจน',
            'อัปโหลดรูปที่เห็นหน้าตรงอย่างน้อย 1 รูป',
            'หลีกเลี่ยงแว่นตาหรือหมวกที่บังหน้า',
          ],
        ),
        actions: SizedBox(
          width: double.infinity,
          child: DsButton(
            label: 'เลือกรูปใหม่',
            onPressed: () => Navigator.of(context).pop(),
            variant: DsButtonVariant.primary,
            size: DsButtonSize.md,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final userState = ref.read(userStoreProvider);
    final user = userState['user'] as User?;
    final cardFaceBytes = userState['cardFaceBytes'] as String?;

    if (_selectedImages.isEmpty) {
      Toast.show(
        context,
        type: ToastType.warning,
        title: 'รูปภาพไม่พอ',
        message: 'กรุณาเลือกรูปภาพอย่างน้อย 1 รูป',
      );
      return;
    }

    if (user == null || cardFaceBytes == null) {
      Toast.show(
        context,
        type: ToastType.error,
        title: 'ข้อมูลไม่ครบ',
        message: 'ไม่พบข้อมูลผู้ใช้ หรือยังไม่ได้ถ่ายรูปบัตรประชาชน',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(photoVerificationServiceProvider);

      await service.verifyAndUpload(
        userId: user.userId,
        profileImages: _selectedImages,
        idCardBase64: cardFaceBytes,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/discovery');
      }
    } catch (e) {
      if (mounted) {
        // ตรวจสอบว่า error เป็นเรื่องใบหน้าไม่ตรงหรือไม่
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('face') ||
            errorMessage.contains('ใบหน้า') ||
            errorMessage.contains('upload failed')) {
          _showFaceVerificationDialog();
        } else {
          Toast.show(
            context,
            type: ToastType.error,
            title: 'ผิดพลาด',
            message: 'เกิดข้อผิดพลาด: ${e.toString()}',
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildBody(double availableHeight) {
    final bool canSubmit = _selectedImages.isNotEmpty && !_isLoading;
    final int selectedCount = _selectedImages.length;
    final bool isCompact = availableHeight < 700;
    final double topPadding = isCompact ? 12 : 20;
    final double gridBottomSpacing = isCompact ? 24 : 36;
    final double buttonTopSpacing = isCompact ? 18 : 24;

    return Padding(
      padding: EdgeInsets.fromLTRB(25, topPadding, 25, isCompact ? 24 : 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              ImageUploadGrid(
                key: _imageGridKey,
                maxImages: 6,
                itemWidth: 119,
                itemHeight: 120,
                spacing: 72,
                runSpacing: isCompact ? 28 : 44,
                addTileColor: AppColors.divider,
                addIconColor: AppColors.surface,
                tileRadius: 10,
                allowEditing: !_isLoading,
                onImagesChanged: (images) {
                  setState(() {
                    _selectedImages = images
                        .map((xFile) => File(xFile.path))
                        .toList();
                  });
                },
              ),
              const SizedBox(height: 12),
              Text(
                'เลือกแล้ว $selectedCount/6 รูป',
                style: const TextStyle(
                  color: TextColors.supportText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 18 / 13,
                ),
              ),
              SizedBox(height: gridBottomSpacing),
              SizedBox(
                width: 310,
                child: Text(
                  'เลือกได้สูงสุด 6 รูป และอย่างน้อย 1 รูปต้องเห็นหน้าชัดเจนเพื่อให้ระบบตรวจสอบได้',
                  textAlign: TextAlign.center,
                  style: AppDisplayTextStyles.subtitle.copyWith(
                    color: TextColors.supportText,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: buttonTopSpacing),
            child: DsButton(
              label: _isLoading ? 'กำลังตรวจสอบ...' : 'ยืนยัน',
              onPressed: canSubmit ? _handleSubmit : null,
              variant: DsButtonVariant.outlinePrimary,
              size: DsButtonSize.md,
              width: 231,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            DsAppSecondaryHeader(
              variant: DsAppSecondaryHeaderVariant.baseText,
              title: 'เพิ่มรูปภาพของคุณ',
              onBackTap: _isLoading ? null : () => Navigator.maybePop(context),
              showBottomBorder: true,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) =>
                    _buildBody(constraints.maxHeight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
