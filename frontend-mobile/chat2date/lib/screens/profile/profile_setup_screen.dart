import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/inputs/ds_label.dart';
import 'package:chat2date/components/inputs/ds_text_field/ds_text_field.dart';
import 'package:chat2date/components/inputs/ds_text_field/tag_autocomplete.dart';
import 'package:chat2date/components/layout/responsive_container.dart';
import 'package:chat2date/models/interest.dart';
import 'package:chat2date/models/lifestyle.dart';
import 'package:chat2date/models/tag.dart';
import 'package:chat2date/models/travelstyle.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/preference_service.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nicknameCtrl = TextEditingController();
  final _lifestyleCtrl = TextEditingController();
  final _interestsCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  List<Travelstyle> _travelStyles = [];
  List<Lifestyle> _lifeStyles = [];
  List<Interest> _interests = [];
  List<Tag> _tags = [];

  List<int> _selectedLifestyles = [];
  List<int> _selectedInterests = [];
  List<int> _selectedTags = [];
  List<int> _selectedTravelStyles = [];
  List<int> get selectedTravelStyleIds =>
      _selectedTravelStyles.map((i) => _travelStyles[i].id!).toList();

  // ข้อมูลสำหรับแสดงใน TextField
  String _getSelectedText(List<int> selected, List<String> allItems) {
    if (selected.isEmpty) return '';
    return selected.map((i) => allItems[i]).join(', ');
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    final userStore = ref.read(userStoreProvider) as Map<String, dynamic>?;
    final prefs = userStore?['preferences'];
    setState(() {
      _travelStyles = prefs['travelStyles'];
      _lifeStyles = prefs['lifeStyles'];
      _interests = prefs['interests'];
      _tags = prefs['tags'];
    });
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
                  items: _travelStyles.map((t) => t.travelstyle).toList(),
                  initialSelected: _selectedTravelStyles,
                  onChanged: (newSelected) {
                    setState(() {
                      _selectedTravelStyles = newSelected;
                    });
                  },
                ),
              ],
            ),

            // 1. ไลฟ์สไตล์
            DsTextField(
              label: 'ไลฟ์สไตล์',
              required: true,
              controller: _lifestyleCtrl,
              suffixIcon: Icons.arrow_circle_right_rounded,
              readOnly: true,
              onSuffixTap: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/lifestylesSelection',
                  arguments: {
                    'items': _lifeStyles,
                    'selected': _selectedLifestyles,
                  },
                );

                if (result != null && result is List<int>) {
                  setState(() {
                    _selectedLifestyles = result;
                    // อัพเดทข้อความใน TextField (ถ้าต้องการแสดง)
                    _lifestyleCtrl.text = _getSelectedText(
                      result,
                      _lifeStyles.map((l) => l.lifestyle).toList(),
                    );
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
              readOnly: true,
              onSuffixTap: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/interestsSelection',
                  arguments: {
                    'items': _interests,
                    'selected': _selectedInterests,
                  },
                );

                if (result != null && result is List<int>) {
                  setState(() {
                    _selectedInterests = result;
                    _interestsCtrl.text = _getSelectedText(
                      result,
                      _interests.map((l) => l.interest).toList(),
                    );
                  });
                  print('เลือกความสนใจ: $_selectedInterests');
                }
              },
              labelFontSize: 20,
            ),

            // 3. Tags
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).unfocus(); // จะทำให้ทุก FocusNode หาย
              },
              child: Column(
                children: [
                  TagAutocomplete(
                    allTags: _tags.map((t) => t.tag).toList(),
                    selectedTags: _selectedTags
                        .map((i) => _tags[i].tag)
                        .toList(),
                    onChanged: (newList) {
                      setState(() {
                        _selectedTags = newList
                            .map((tag) => _tags.indexWhere((t) => t.tag == tag))
                            .toList();
                      });
                    },
                  ),
                ],
              ),
            ),

            DsButton(
              label: 'ไปหน้าถัดไป',
              onPressed: () async {
                // ตรวจสอบข้อมูลก่อนส่ง
                if (_nicknameCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กรุณากรอกชื่อเล่น')),
                  );
                  return;
                }

                if (_selectedTravelStyles.length < 2 ||
                    _selectedTravelStyles.length > 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('กรุณาเลือกสไตล์การท่องเที่ยว 2–3 ข้อ'),
                    ),
                  );
                  return;
                }

                if (_selectedLifestyles.length < 3 ||
                    _selectedLifestyles.length > 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('กรุณาเลือกไลฟ์สไตล์ 3–5 ข้อ'),
                    ),
                  );
                  return;
                }

                // ตรวจสอบ Interests
                if (_selectedInterests.length < 3 ||
                    _selectedInterests.length > 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กรุณาเลือกความสนใจ 3–5 ข้อ')),
                  );
                  return;
                }

                // ตรวจสอบ Tags สูงสุด 5 (ไม่บังคับเลือก)
                if (_selectedTags.length > 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('สามารถเลือก Tag สูงสุด 5 ข้อ'),
                    ),
                  );
                  return;
                }

                final incrementedInterests = _selectedInterests
                    .map((id) => id + 1)
                    .toList();
                final incrementedLifestyles = _selectedLifestyles
                    .map((id) => id + 1)
                    .toList();
                final incrementedTravelStyles = _selectedTravelStyles
                    .map((id) => id + 1)
                    .toList();
                final incrementedTag = _selectedTags
                    .map((id) => id + 1)
                    .toList();

                try {
                  final userStore =
                      ref.read(userStoreProvider) as Map<String, dynamic>?;

                  final oldUser = userStore?['user'] as User;

                  if (oldUser.userId == null || oldUser.version == null) return;

                  // สร้าง Map ของ user ที่ต้องการส่งไปอัปเดต
                  final user = User(
                    userId: oldUser.userId,
                    nickname: _nicknameCtrl.text,
                    version: oldUser.version,
                  );
                  final preference = {
                    "interests": incrementedInterests,
                    "lifeStyles": incrementedLifestyles,
                    "tags": incrementedTag,
                    "travelStyles": incrementedTravelStyles,
                  };
                  final userService = ref.read(userServiceProvider);

                  final update = await userService.updateUser(user);

                  final addPreference = await userService.addPreferenceUser(
                    preference,
                  );
                } catch (e) {
                  throw Exception(e);
                }

                // // ส่งข้อมูลไปหน้าถัดไป
                // print('===== ข้อมูล Profile =====');
                // print('ชื่อเล่น: ${_nicknameCtrl.text}');
                // print('ไลฟ์สไตล์: $_selectedLifestyles');
                // print('ความสนใจ: $_selectedInterests');
                // print('Tags: $_selectedTags');

                // // TODO: บันทึกข้อมูลหรือไปหน้าถัดไป
                Navigator.pushNamed(context, '/matchPreference');
              },
              variant: DsButtonVariant.primary,
              size: DsButtonSize.md,
            ),
          ],
        ),
      ),
    );
  }
}
