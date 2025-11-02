import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/inputs/ds_label.dart';
import 'package:chat2date/components/inputs/ds_text_field/ds_text_field.dart';
import 'package:chat2date/components/layout/responsive_container.dart';
import 'package:flutter/material.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nicknameCtrl = TextEditingController();
  final _lifeStyleCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ResponsiveContainer.form(
          children: [
            DsTextField(
              label: 'ชื่อเล่น',
              required: true,
              controller: _nicknameCtrl,
              
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: DsLabel(label: 'สไตล์การท่องเที่ยว', required: true),
            ),

            TagSelection(
              items: [
                'Style 1',
                'Style 2Style',
                'Style 3',
                'Style 4',
                'Style 5Style',
                'Style 6',
                'Style 7Style',
                'Style 8',
                'Style 9',
              ],
            ),

            DsTextField(
              label: 'ไลฟ์สไตล์',
              required: true,
              controller: _lifeStyleCtrl,
              suffixIcon: Icons.arrow_circle_right_rounded,
              onSuffixTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Go next')));
              },
            ),

            DsTextField(
              label: 'สิ่งที่สนใจ',
              required: true,
              controller: _lifeStyleCtrl,
              suffixIcon: Icons.arrow_circle_right_rounded,
              onSuffixTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Go next')));
              },
            ),

            DsTextField(
              label: 'tags(ไม่บังคับ)',
              required: true,
              controller: _lifeStyleCtrl,
              suffixIcon: Icons.add,
              onSuffixTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Go next')));
              },
            ),

            DsButton(
              label: 'ไปหน้าถัดไป',
              onPressed: () {},
              variant: DsButtonVariant.primary,
              size: DsButtonSize.sm,
            ),
          ],
        ),
      ),
    );
  }
}
