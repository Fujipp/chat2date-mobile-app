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
  final _lifestyleCtrl = TextEditingController();
  final _interestsCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  List<int> _selectedLifestyles = [];
  List<int> _selectedInterests = [];
  List<int> _selectedTags = [];

  // ข้อมูลสำหรับแสดงใน TextField
  String _getSelectedText(List<int> selected, List<String> allItems) {
    if (selected.isEmpty) return '';
    return selected.map((i) => allItems[i]).join(', ');
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _lifestyleCtrl.dispose();
    _interestsCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ResponsiveContainer.form(
          children: [
            const SizedBox(height: 10),
            DsTextField(
              label: 'ชื่อเล่น',
              required: true,
              controller: _nicknameCtrl,
              labelFontSize: 20,
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DsLabel(
                  label: 'สไตล์การท่องเที่ยว',
                  required: true,
                  labelFontSize: 20,
                ),
                const SizedBox(height: 0),
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
              ],
            ),

            // 1. ไลฟ์สไตล์
            DsTextField(
              label: 'ไลฟ์สไตล์',
              required: true,
              controller: _lifestyleCtrl,
              suffixIcon: Icons.arrow_circle_right_rounded,

              onSuffixTap: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/lifestylesSelection',
                );

                if (result != null && result is List<int>) {
                  setState(() {
                    _selectedLifestyles = result;
                    // อัพเดทข้อความใน TextField (ถ้าต้องการแสดง)
                    // _lifestyleCtrl.text = _getSelectedText(result, lifestyleItems);
                  });
                  print('เลือกไลฟ์สไตล์: $_selectedLifestyles');
                }
              },
              labelFontSize: 20,
            ),

            // 2. สิ่งที่สนใจ
            DsTextField(
              label: 'สิ่งที่สนใจ',
              required: true,
              controller: _interestsCtrl,
              suffixIcon: Icons.arrow_circle_right_rounded,

              onSuffixTap: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/interestsSelection',
                );

                if (result != null && result is List<int>) {
                  setState(() {
                    _selectedInterests = result;
                  });
                  print('เลือกความสนใจ: $_selectedInterests');
                }
              },
              labelFontSize: 20,
            ),

            // 3. Tags
            DsTextField(
              label: 'tags(ไม่บังคับ)',
              required: false,
              controller: _tagsCtrl,
              suffixIcon: Icons.add,
              hintText: 'เพิ่มแท็กที่นี่',

              onSuffixTap: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/tagsSelection',
                );

                if (result != null && result is List<int>) {
                  setState(() {
                    _selectedTags = result;
                  });
                  print('เลือก Tags: $_selectedTags');
                }
              },
              labelFontSize: 20,
            ),

            DsButton(
              label: 'ไปหน้าถัดไป',
              onPressed: () {
                // ตรวจสอบข้อมูลก่อนส่ง
                if (_nicknameCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กรุณากรอกชื่อเล่น')),
                  );
                  return;
                }

                if (_selectedLifestyles.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กรุณาเลือกไลฟ์สไตล์')),
                  );
                  return;
                }

                // ส่งข้อมูลไปหน้าถัดไป
                print('===== ข้อมูล Profile =====');
                print('ชื่อเล่น: ${_nicknameCtrl.text}');
                print('ไลฟ์สไตล์: $_selectedLifestyles');
                print('ความสนใจ: $_selectedInterests');
                print('Tags: $_selectedTags');

                // TODO: บันทึกข้อมูลหรือไปหน้าถัดไป
              },
              variant: DsButtonVariant.primary,
              size: DsButtonSize.sm,
            ),
          ],
        ),
      ),
    );
  }
}
