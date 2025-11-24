import 'dart:convert';
import 'dart:io';

import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/common/image_upload_grid.dart';
import 'package:chat2date/components/common/loading_component.dart';
import 'package:chat2date/components/inputs/ds_label.dart';
import 'package:chat2date/components/inputs/ds_text_field/ds_text_field.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/layout/menu_bar.dart';
import 'package:chat2date/components/layout/responsive_container.dart';
import 'package:chat2date/models/dto/preference_dto.dart';
import 'package:chat2date/models/interest.dart';
import 'package:chat2date/models/lifestyle.dart';
import 'package:chat2date/models/tag.dart';
import 'package:chat2date/models/travelstyle.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/photo_verification_service.dart';
import 'package:chat2date/services/preference_service.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:chat2date/components/inputs/ds_text_field/tag_autocomplete.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nicknameCtrl = TextEditingController();
  final _lifestyleCtrl = TextEditingController();
  final _interestsCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? nickname = "";
  String? _selectedGenderPreference = null;
  double behaviorScore = 0;
  List<int> user_has_interest = [];
  List<int> user_has_lifestyle = [];
  List<int> user_has_travelstyle = [];
  List<int> user_has_tag = [];
  List<Travelstyle> _travelStyles = [];
  List<Lifestyle> _lifeStyles = [];
  List<Interest> _interests = [];
  List<Tag> _tags = [];
  List<String> photoUrls = [];
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    final userStore = ref.read(userStoreProvider) as Map<String, dynamic>?;

    if (userStore?['profile'] != null && userStore?['user'] != null) {
      final prefs = userStore?['preferences']; 
      await _setDataFromStore(
        userStore?['profile'],
        userStore?['user'],
        prefs: prefs,
      );
      return;
    }
    final prefs = await PreferenceService.getPreference();
    final user = userStore?['user'] as User;
    final userId = user.userId;
    final userService = ref.read(userServiceProvider);
    final userProfile = await userService.getProfile(userId);

    ref.read(userStoreProvider.notifier).setProfile(userProfile);
    ref.read(userStoreProvider.notifier).setPreferences({
      'travelStyles': prefs.travelStyles,
      'lifeStyles': prefs.lifeStyles,
      'interests': prefs.interests,
      'tags': prefs.tags,
    });

    await _setDataFromStore(
      userProfile,
      user,
      prefs: {
        'travelStyles': prefs.travelStyles,
        'lifeStyles': prefs.lifeStyles,
        'interests': prefs.interests,
        'tags': prefs.tags,
      },
    );
  }

  Future<void> _setDataFromStore(
    Map<String, dynamic> userProfile,
    User user, {
    Map<String, dynamic>? prefs,
  }) async {
    setState(() {
      _travelStyles = prefs?['travelStyles'] ?? [];
      _lifeStyles = prefs?['lifeStyles'] ?? [];
      _interests = prefs?['interests'] ?? [];
      _tags = prefs?['tags'] ?? [];

      user_has_interest = (userProfile['interests'] as List)
          .map((e) => (e as int) - 1)
          .toList();

      user_has_lifestyle = (userProfile['lifeStyles'] as List)
          .map((e) => (e as int) - 1)
          .toList();

      user_has_tag = (userProfile['tags'] as List)
          .map((e) => (e as int) - 1)
          .toList();

      user_has_travelstyle = (userProfile['travelStyles'] as List)
          .map((e) => (e as int) - 1)
          .toList();

      _selectedGenderPreference = userProfile['interestedGender'];
      nickname = user.nickname;
      behaviorScore = (user.behaviorScore!) / 100;

      _nicknameCtrl.text = nickname.toString();

      _lifestyleCtrl.text = _getSelectedText(
        user_has_lifestyle,
        _lifeStyles.map((l) => l.lifestyle).toList(),
      );

      _interestsCtrl.text = _getSelectedText(
        user_has_interest,
        _interests.map((l) => l.interest).toList(),
      );

      _tagsCtrl.text = _getSelectedText(
        user_has_tag,
        _tags.map((t) => t.tag).toList(),
      );

      final photoPath = userProfile['photos'];
      final photoMap = jsonDecode(photoPath) as Map<String, dynamic>;
      photoUrls = (photoMap['urls'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();

      print(photoUrls);
    });
  }

  String _getSelectedText(List<int> selected, List<String> allItems) {
    if (selected.isEmpty) return '';
    return selected.map((i) => allItems[i]).join(', ');
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ป้องกัน memory leak
    super.dispose();
  }

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

      // if (mounted) {
      //   Navigator.pushReplacementNamed(context, '/discovery');
      // }
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
      body: Column(
        children: [
          SafeArea(
            child: ChatToDateHeaderWhite(
              leftIconPath: 'assets/images/logo_chat2date_text.png',
              rightIconPath: 'assets/icons/icon_menu.svg',
              iconColor: const Color(0xFF5ce1e6),
              onBack: () {},
              onSettings: () {},
            ),
          ),
          Expanded(
            child: ScrollbarTheme(
              // <--- 1. เพิ่ม ScrollbarTheme เพื่อกำหนดสี
              data: ScrollbarThemeData(
                // ---- นี่คือส่วนที่เพิ่มสีครับ ----
                // สีของแท่ง Scrollbar (thumb)
                thumbColor: WidgetStateProperty.all(
                  const Color(0xFF5ce1e6).withOpacity(
                    0.7,
                  ), // สีฟ้าอมเขียว (สีเดียวกับไอคอน) แบบโปร่งแสง
                ),
                // สีของราง (track)
                trackColor: WidgetStateProperty.all(Colors.grey.shade300),
                // สีขอบของราง (ถ้าต้องการ)
                trackBorderColor: WidgetStateProperty.all(Colors.grey.shade400),
              ),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 8,
                radius: const Radius.circular(8),
                interactive:
                    true, // <--- 2. เพิ่มตัวนี้เพื่อให้ Scrollbar เลื่อนได้!
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: ResponsiveContainer.form(
                    children: [
                      DsTextField(
                        label: 'ชื่อเล่น',
                        labelFontSize: 20,
                        controller: TextEditingController(text: nickname),
                      ),

                      // DsTextField(
                      //   label: 'เพศที่สนใจ',
                      //   labelFontSize: 20,
                      //   suffixIcon: Icons.keyboard_arrow_down_rounded,
                      // ),
                      DropdownButtonFormField2<String>(
                        value: _selectedGenderPreference,
                        decoration: InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'เพศที่สนใจ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.red, // สีแดงของ *
                                  ),
                                ),
                              ],
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.inputBorderHover,
                              width: 1.5,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),

                        isExpanded: true,

                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                        ),

                        // 👇👇 เพิ่มส่วนนี้เพื่อให้เมนูอยู่ล่างเสมอ
                        dropdownStyleData: const DropdownStyleData(
                          offset: Offset(0, 0), // เมนูเริ่มล่างช่อง
                          direction: DropdownDirection
                              .textDirection, // บังคับอยู่ด้านล่าง
                        ),

                        items: const [
                          DropdownMenuItem(
                            value: 'MALE',
                            child: Text('ผู้ชาย'),
                          ),
                          DropdownMenuItem(
                            value: 'FEMALE',
                            child: Text('ผู้หญิง'),
                          ),
                          DropdownMenuItem(
                            value: 'BOTH',
                            child: Text('ได้ทั้งคู่'),
                          ),
                        ],

                        onChanged: (value) {
                          setState(() {
                            _selectedGenderPreference = value;
                          });
                        },
                      ),

                      DsLabel(label: 'แก้ไขรูปภาพที่แสดง', labelFontSize: 20),
                      ImageUploadGrid(
                        key: ValueKey(photoUrls.join(',')),
                        imageUser: photoUrls,
                        onImagesChanged: (images) {
                          print('จำนวนรูปที่เลือก: ${images.length}');
                        },
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DsLabel(
                            label: 'สไตล์การท่องเที่ยว',
                            labelFontSize: 20,
                          ),
                          const SizedBox(height: 0),
                          TagSelection(
                            key: ValueKey(user_has_travelstyle.join(',')),
                            items: _travelStyles
                                .map((t) => t.travelstyle)
                                .toList(),
                            initialSelected: user_has_travelstyle,
                            onChanged: (newSelected) {
                              setState(() {
                                user_has_travelstyle = newSelected;
                              });
                            },
                          ),
                        ],
                      ),

                      // ไลฟ์สไตล์
                      DsTextField(
                        label: 'ไลฟ์สไตล์',
                        controller: _lifestyleCtrl,
                        required: true,
                        readOnly: true,
                        suffixIcon: Icons.arrow_circle_right_rounded,
                        onSuffixTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/lifestylesSelection',
                            arguments: {
                              'items': _lifeStyles,
                              'selected': user_has_lifestyle,
                            },
                          );
                          if (result != null && result is List<int>) {
                            setState(() {
                              user_has_lifestyle = result;
                              _lifestyleCtrl.text = _getSelectedText(
                                result,
                                _lifeStyles.map((l) => l.lifestyle).toList(),
                              );
                            });
                            print('เลือกความสนใจ: $user_has_lifestyle');
                          }
                        },
                        labelFontSize: 20,
                      ),

                      // สิ่งที่สนใจ
                      DsTextField(
                        label: 'สิ่งที่สนใจ',
                        controller: _interestsCtrl,
                        required: true,
                        readOnly: true,
                        suffixIcon: Icons.arrow_circle_right_rounded,
                        onSuffixTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/interestsSelection',
                            arguments: {
                              'items': _interests,
                              'selected': user_has_interest,
                            },
                          );
                          if (result != null && result is List<int>) {
                            setState(() {
                              user_has_interest = result;
                              _interestsCtrl.text = _getSelectedText(
                                result,
                                _interests.map((l) => l.interest).toList(),
                              );
                            });
                            print('เลือกความสนใจ: $user_has_interest');
                          }
                        },
                        labelFontSize: 20,
                      ),

                      // Tags
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          FocusScope.of(
                            context,
                          ).unfocus(); // จะทำให้ทุก FocusNode หาย
                        },
                        child: Column(
                          children: [
                            TagAutocomplete(
                              key: ValueKey(
                                user_has_tag.join(','),
                              ), // บังคับ rebuild
                              allTags: _tags.map((t) => t.tag).toList(),
                              selectedTags: user_has_tag
                                  .map((i) => _tags[i].tag)
                                  .toList(),
                              onChanged: (newList) {
                                setState(() {
                                  user_has_tag = newList
                                      .map(
                                        (tag) => _tags.indexWhere(
                                          (t) => t.tag == tag,
                                        ),
                                      )
                                      .toList();
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      DsLabel(label: 'คะแนนความประพฤติ', labelFontSize: 20),
                      CircularLoading(percent: behaviorScore),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // หัวข้ออยู่ใน card เลย
                              DsLabel(
                                label: 'เกณฑ์คะแนนความประพฤติ',
                                labelFontSize: 16,
                              ),

                              const SizedBox(height: 12),

                              // เงื่อนไขเป็นบรรทัดย่อย (ใช้ Text.rich เพื่อเน้นตัวหนา)
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'ถ้าคะแนน ≤ 50 : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          'บัญชีจะถูกจำกัดฟีเจอร์ 3 วัน และปัดได้ไม่เกิน 10 ครั้ง/วัน',
                                    ),
                                  ],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'ถ้าคะแนน < 30 : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          'บัญชีจะถูกแบนถาวร และถูกใส่ใน Blacklist (ห้ามกลับมาใช้งาน)',
                                    ),
                                  ],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              const Divider(),

                              const SizedBox(height: 12),

                              const Text(
                                'วิธีได้คะแนนเพิ่ม',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // รายการวิธีได้คะแนน (แสดงเป็นบูลเล็ตหรือ arrow)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('• ', style: TextStyle(fontSize: 16)),
                                  Expanded(
                                    child: Text(
                                      'อยู่ครบ 30 วันโดยไม่มีใครรายงาน ➜ เพิ่ม 15 คะแนนความประพฤติ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      DsButton(
                        label: 'บันทึกข้อมูล',
                        onPressed: () async {
                          // ตรวจสอบข้อมูลก่อนส่ง
                          if (_nicknameCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('กรุณากรอกชื่อเล่น'),
                              ),
                            );
                            return;
                          }

                          if (user_has_travelstyle.length < 2 ||
                              user_has_travelstyle.length > 3) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'กรุณาเลือกสไตล์การท่องเที่ยว 2–3 ข้อ',
                                ),
                              ),
                            );
                            return;
                          }

                          if (user_has_lifestyle.length < 3 ||
                              user_has_lifestyle.length > 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('กรุณาเลือกไลฟ์สไตล์ 3–5 ข้อ'),
                              ),
                            );
                            return;
                          }

                          // ตรวจสอบ Interests
                          if (user_has_interest.length < 3 ||
                              user_has_interest.length > 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('กรุณาเลือกความสนใจ 3–5 ข้อ'),
                              ),
                            );
                            return;
                          }

                          // ตรวจสอบ Tags สูงสุด 5 (ไม่บังคับเลือก)
                          if (user_has_tag.length > 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('สามารถเลือก Tag สูงสุด 5 ข้อ'),
                              ),
                            );
                            return;
                          }

                          final incrementedInterests = user_has_interest
                              .map((id) => id + 1)
                              .toList();
                          final incrementedLifestyles = user_has_lifestyle
                              .map((id) => id + 1)
                              .toList();
                          final incrementedTravelStyles = user_has_travelstyle
                              .map((id) => id + 1)
                              .toList();
                          final incrementedTag = user_has_tag
                              .map((id) => id + 1)
                              .toList();

                          try {
                            final userStore =
                                ref.read(userStoreProvider)
                                    as Map<String, dynamic>?;

                            final oldUser = userStore?['user'] as User;

                            if (oldUser.userId == null ||
                                oldUser.version == null)
                              return;

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

                            final addPreference = await userService
                                .addPreferenceUser(preference);
                          } catch (e) {
                            throw Exception(e);
                          }
                          final Map<String, Object> preferenceMatch = {
                            "interestedGender": _selectedGenderPreference!,
                          };

                          final updatedUser = ref
                              .read(userServiceProvider)
                              .addPreferenceMatchUser(preferenceMatch);
                              _handleSubmit();
                          // // ส่งข้อมูลไปหน้าถัดไป
                          // print('===== ข้อมูล Profile =====');
                          // print('ชื่อเล่น: ${_nicknameCtrl.text}');
                          // print('ไลฟ์สไตล์: $_selectedLifestyles');
                          // print('ความสนใจ: $_selectedInterests');
                          // print('Tags: $_selectedTags');

                          // // TODO: บันทึกข้อมูลหรือไปหน้าถัดไป
                        },
                        variant: DsButtonVariant.primary,
                        size: DsButtonSize.md,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // อัปเดต selectedIndex
          });

          // ตรวจสอบ index
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/discovery');
          }
        },
      ),
    );
  }
}
