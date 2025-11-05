import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/common/image_upload_grid.dart';
import 'package:chat2date/components/inputs/ds_label.dart';
import 'package:chat2date/components/layout/responsive_container.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';

class UserPictureScreen extends StatefulWidget {
  const UserPictureScreen({super.key});

  @override
  State<UserPictureScreen> createState() => _UserPictureScreenState();
}

class _UserPictureScreenState extends State<UserPictureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveContainer.form(
        gap: 20,
        children: [
          const SizedBox(height: 30),
          Center(child: DsLabel(label: 'เพิ่มรูปภาพของคุณ', labelFontSize: 32)),
          const SizedBox(height: 10),

          ImageUploadGrid(
            onImagesChanged: (images) {
              print('จำนวนรูปที่เลือก: ${images.length}');
            },
          ),

          const SizedBox(height: 20),
          Text(
            'เราจะทำการตรวจสอบรูปใบหน้าของคุณ กรุณาอัปโหลดรูปใบหน้าของคุณอย่างน้อย 1 รูป',
            style: TextStyle(color: AppColors.warning, fontSize: 16),
          ),

          const SizedBox(height: 10),

          DsButton(
            label: 'พร้อมแล้ว',
            onPressed: () {},
            variant: DsButtonVariant.primary,
            size: DsButtonSize.md,
          ),
        ],
      ),
    );
  }
}
