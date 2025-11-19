import 'dart:io';

import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/common/image_upload_grid.dart';
import 'package:chat2date/components/inputs/ds_label.dart';
import 'package:chat2date/components/layout/responsive_container.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/photo_verification_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:chat2date/theme/app_colors.dart';
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

  // แสดง Dialog แจ้งเตือนเมื่อใบหน้าไม่ตรงกับบัตร
  void _showFaceVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ไอคอนเตือน
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 36,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: 20),

              // หัวข้อ
              const Text(
                'ไม่พบใบหน้าที่ชัดเจน',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // รายละเอียด
              Text(
                'เราตรวจไม่พบใบหน้าที่ชัดเจนในรูปภาพของคุณ หรือใบหน้าไม่ตรงกับรูปบัตรประชาชน',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // คำแนะนำ
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 20,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'คำแนะนำ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('ถ่ายรูปในที่ที่มีแสงสว่างเพียงพอ'),
                    _buildTip('ใบหน้าหันตรงกล้องและเห็นชัดเจน'),
                    _buildTip('อัปโหลดรูปที่เห็นหน้าตรงอย่างน้อย 1 รูป'),
                    _buildTip('หลีกเลี่ยงแว่นตาหรือหมวกที่บังหน้า'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // ปุ่มลองใหม่
            SizedBox(
              width: double.infinity,
              child: DsButton(
                label: 'เลือกรูปใหม่',
                onPressed: () {
                  Navigator.of(context).pop();
                },
                variant: DsButtonVariant.primary,
                size: DsButtonSize.md,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.blue[700],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final userState = ref.read(userStoreProvider);
    final user = userState['user'] as User?;
    final cardFaceBytes = userState['cardFaceBytes'] as String?;

    // Validation
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกรูปภาพอย่างน้อย 1 รูป')),
      );
      return;
    }

    if (user == null || cardFaceBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่พบข้อมูลผู้ใช้ หรือยังไม่ได้ถ่ายรูปบัตรประชาชน'),
        ),
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
          // แสดง Dialog แทน SnackBar
          _showFaceVerificationDialog();
        } else {
          // Error อื่นๆ แสดง SnackBar ปกติ
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveContainer.form(
        gap: 20,
        children: [
          const SizedBox(height: 30),
          Center(child: DsLabel(label: 'เพิ่มรูปภาพของคุณ', labelFontSize: 32)),

          ImageUploadGrid(
            onImagesChanged: (images) {
              setState(() {
                _selectedImages = images
                    .map((xFile) => File(xFile.path))
                    .toList();
              });
              print('จำนวนรูปที่เลือก: ${images.length}');
            },
          ),

          Center(
            child: Text(
              'เราจะทำการตรวจสอบรูปใบหน้าของคุณ กรุณาอัปโหลดรูปใบหน้าของคุณอย่างน้อย 1 รูป',
              style: TextStyle(color: AppColors.error, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),

          DsButton(
            label: _isLoading ? 'กำลังตรวจสอบ...' : 'พร้อมแล้ว',
            onPressed: _isLoading ? null : _handleSubmit,
            variant: DsButtonVariant.primary,
            size: DsButtonSize.md,
          ),
        ],
      ),
    );
  }
}
