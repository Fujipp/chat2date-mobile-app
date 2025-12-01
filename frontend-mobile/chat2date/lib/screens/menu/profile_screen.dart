import 'dart:convert';
import 'dart:io';
import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/common/image_upload_grid.dart';
import 'package:chat2date/components/common/loading_component.dart';
import 'package:chat2date/components/inputs/ds_label.dart';
import 'package:chat2date/components/inputs/ds_text_field/ds_text_field.dart';
import 'package:chat2date/components/inputs/ds_text_field/tag_autocomplete.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/layout/menu_bar.dart';
import 'package:chat2date/components/layout/responsive_container.dart';
import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/models/interest.dart';
import 'package:chat2date/models/lifestyle.dart';
import 'package:chat2date/models/tag.dart';
import 'package:chat2date/models/travelstyle.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/photo_verification_service.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  //ค่าที่อัพเดท
  String? nickname = "";
  List<int> user_has_interest = [];
  List<int> user_has_lifestyle = [];
  List<int> user_has_travelstyle = [];
  List<int> user_has_tag = [];
  List<String> photoUrls = [];
  //ค่าเก่า
  String? _oldNickname;
  List<int> _oldInterests = [];
  List<int> _oldLifeStyles = [];
  List<int> _oldTravelStyles = [];
  List<int> _oldTags = [];
  List<String> _oldPhotos = [];

  //ค่าคงที่
  double behaviorScore = 0;
  List<Travelstyle> _travelStyles = [];
  List<Lifestyle> _lifeStyles = [];
  List<Interest> _interests = [];
  List<Tag> _tags = [];
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    final userStore = ref.read(userStoreProvider);
    final userStoreMap = userStore as Map<String, dynamic>?;

    if (userStoreMap == null ||
        userStoreMap['profile'] == null ||
        userStoreMap['user'] == null) {
      return;
    }

    final prefs = userStore?['preferences'] as Map<String, dynamic>?;
    await _setDataFromStore(
      userStoreMap['profile'] as Map<String, dynamic>,
      userStoreMap['user'] as User,
      prefs: {
        'travelStyles': prefs?['travelStyles'],
        'lifeStyles': prefs?['lifeStyles'],
        'interests': prefs?['interests'],
        'tags': prefs?['tags'],
      },
    );
    return;
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
      _oldNickname = nickname;

      _oldInterests = List.from(user_has_interest);
      _oldLifeStyles = List.from(user_has_lifestyle);
      _oldTravelStyles = List.from(user_has_travelstyle);
      _oldTags = List.from(user_has_tag);
      _oldPhotos = List.from(photoUrls);
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
  List<String> _deletedImages = [];
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

    if (user == null || cardFaceBytes == null) {
      Toast.show(
        context,
        type: ToastType.error,
        title: 'ข้อผิดพลาด',
        message: 'ไม่พบข้อมูลผู้ใช้ หรือยังไม่ได้ถ่ายรูปบัตรประชาชน',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(photoVerificationServiceProvider);
      if (_selectedImages.isNotEmpty) {
        await service.verifyAndUpload(
          userId: user.userId,
          profileImages: _selectedImages,
          idCardBase64: cardFaceBytes,
        );
      }

      if (_deletedImages.isNotEmpty) {
        try {
          await service.removePhoto(
            userId: user.userId,
            imageUrls: _deletedImages,
          );
        } catch (e) {
          Toast.show(
            context,
            type: ToastType.warning,
            title: 'คำเตือน',
            message: 'ไม่สามารถลบรูป ไม่ให้เหลือใบหน้าได้',
          );
          return;
        }
      }

      if (mounted) {}
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

  bool _isListChanged(List oldList, List newList) {
    if (oldList.length != newList.length) return true;

    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i] != newList[i]) return true;
    }
    return false;
  }

  Future<void> _submitEdit() async {
    if (!mounted) return;

    final userStore = ref.read(userStoreProvider) as Map<String, dynamic>?;
    final userService = ref.read(userServiceProvider);
    final currentUser = userStore?['user'] as User;

    List<Future> tasks = [];

    try {
      if (nickname != _oldNickname) {
        final user = User(
          userId: currentUser.userId,
          nickname: _nicknameCtrl.text,
          version: currentUser.version,
        );
        tasks.add(userService.updateUser(user));
      }

      if (_isListChanged(_oldInterests, user_has_interest) ||
          _isListChanged(_oldLifeStyles, user_has_lifestyle) ||
          _isListChanged(_oldTravelStyles, user_has_travelstyle) ||
          _isListChanged(_oldTags, user_has_tag)) {
        final incrementedInterests = user_has_interest
            .map((id) => id + 1)
            .toList();
        final incrementedLifestyles = user_has_lifestyle
            .map((id) => id + 1)
            .toList();
        final incrementedTravelStyles = user_has_travelstyle
            .map((id) => id + 1)
            .toList();
        final incrementedTag = user_has_tag.map((id) => id + 1).toList();

        final preference = {
          "interests": incrementedInterests,
          "lifeStyles": incrementedLifestyles,
          "tags": incrementedTag,
          "travelStyles": incrementedTravelStyles,
        };

        tasks.add(userService.addPreferenceUser(preference));
      }

      if (_isListChanged(_oldPhotos, _selectedImages)) {
        tasks.add(_handleSubmit());
      }
      await Future.wait(tasks);

      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.success,
        title: 'สำเร็จ',
        message: 'บันทึกข้อมูลส่วนตัวสำเร็จ',
      );
       await ref.read(userServiceProvider).getProfile();
              _loadInitialData();

    } catch (e) {
      throw new Exception(e);
    }
  }

  bool get hasChanges {
    return (nickname != _oldNickname) ||
        _isListChanged(_oldInterests, user_has_interest) ||
        _isListChanged(_oldLifeStyles, user_has_lifestyle) ||
        _isListChanged(_oldTravelStyles, user_has_travelstyle) ||
        _isListChanged(_oldTags, user_has_tag) ||
        _isListChanged(_oldPhotos, _selectedImages.map((f) => f.path).toList());
  }

  // แทนที่ส่วน build method ทั้งหมด
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                child: ChatToDateHeaderWhite(
                  leftIconPath: 'assets/icons/icon_chat2date_full.svg',
                  rightIconPath: '',
                  iconColor: const Color(0xFF5ce1e6),
                  onBack: () {},
                  onSettings: () {},
                ),
              ),
              Expanded(
                child: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbColor: WidgetStateProperty.all(
                      const Color(0xFF5ce1e6).withOpacity(0.7),
                    ),
                    trackColor: WidgetStateProperty.all(Colors.grey.shade300),
                    trackBorderColor: WidgetStateProperty.all(
                      Colors.grey.shade400,
                    ),
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    thickness: 8,
                    radius: const Radius.circular(8),
                    interactive: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: ResponsiveContainer.form(
                        children: [
                          DsTextField(
                            label: 'ชื่อเล่น',
                            labelFontSize: 20,
                            controller: _nicknameCtrl,
                          ),

                          DsLabel(
                            label: 'แก้ไขรูปภาพที่แสดง',
                            labelFontSize: 20,
                          ),
                          ImageUploadGrid(
                            imageUser: photoUrls,
                            onImagesChanged: (images) {
                              setState(() {
                                _selectedImages = images
                                    .map((xFile) => File(xFile.path))
                                    .toList();
                              });
                            },
                            onImageRemoved: (index, removed) {
                              // รูปจาก server (String)
                              if (removed is String) {
                                setState(() {
                                  print(removed);
                                  _deletedImages.add(removed);
                                  photoUrls.remove(removed); // เอาออกจาก UI
                                });
                              }

                              // ถ้าเป็นรูปใหม่ (XFile) — จะเข้ามาเป็น File ตอน submit
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
                                    _lifeStyles
                                        .map((l) => l.lifestyle)
                                        .toList(),
                                  );
                                });
                                print('เลือกความสนใจ: $user_has_lifestyle');
                              }
                            },
                            labelFontSize: 20,
                          ),

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

                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              FocusScope.of(context).unfocus();
                            },
                            child: Column(
                              children: [
                                TagAutocomplete(
                                  key: ValueKey(user_has_tag.join(',')),
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
                                  DsLabel(
                                    label: 'เกณฑ์คะแนนความประพฤติ',
                                    labelFontSize: 16,
                                  ),
                                  const SizedBox(height: 12),
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
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        '• ',
                                        style: TextStyle(fontSize: 16),
                                      ),
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

                          // เพิ่มพื้นที่ว่างด้านล่างเพื่อไม่ให้ปุ่มบังเนื้อหา
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ปุ่ม Submit แบบลอย - อยู่ขวาล่างเสมอ
          Positioned(
            right: 20,
            bottom: 30,
            child: GestureDetector(
              onTap: _isLoading
                  ? null
                  : () async {
                      // Validation
                      if (_nicknameCtrl.text.isEmpty) {
                        Toast.show(
                          context,
                          type: ToastType.warning,
                          title: 'คำเตือน',
                          message: 'กรุณากรอกชื่อเล่น',
                        );
                        return;
                      }

                      if (user_has_travelstyle.length < 2 ||
                          user_has_travelstyle.length > 3) {
                        Toast.show(
                          context,
                          type: ToastType.warning,
                          title: 'คำเตือน',
                          message:
                              'กรุณาเลือกสไตล์การท่องเที่ยวอย่างน้อย 2–3 ข้อ',
                        );
                        return;
                      }

                      if (user_has_lifestyle.length < 3 ||
                          user_has_lifestyle.length > 5) {
                        Toast.show(
                          context,
                          type: ToastType.warning,
                          title: 'คำเตือน',
                          message: 'กรุณาเลือกไลฟ์สไตล์ 3–5 ข้อ',
                        );
                        return;
                      }

                      if (user_has_interest.length < 3 ||
                          user_has_interest.length > 5) {
                        Toast.show(
                          context,
                          type: ToastType.warning,
                          title: 'คำเตือน',
                          message: 'กรุณาเลือกความสนใจ 3–5 ข้อ',
                        );
                        return;
                      }

                      if (user_has_tag.length > 5) {
                        Toast.show(
                          context,
                          type: ToastType.warning,
                          title: 'คำเตือน',
                          message: 'สามารถเลือก Tag ได้สูงสุด 5 ข้อ',
                        );
                        return;
                      }

                      try {
                        await _submitEdit();
                      } catch (e) {
                        if (mounted) {
                          Toast.show(
                            context,
                            type: ToastType.error,
                            title: 'คำเตือน',
                            message: 'เกิดข้อผิดพลาด: $e',
                          );
                        }
                      }
                    },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: hasChanges
                      ? const LinearGradient(
                          colors: [
                            AppColors.btnPrimary,
                            AppColors.btnHoverPrimary,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : const LinearGradient(
                          colors: [AppColors.neutral400, AppColors.neutral500],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: hasChanges && !_isLoading
                      ? [
                          BoxShadow(
                            color: AppColors.btnPrimary.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) async {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0: // Home (Discovery)
              Navigator.pushReplacementNamed(context, '/discovery');
              break;

            case 1: // Chat
              Navigator.pushReplacementNamed(context, '/chat');
              break;

            case 2: // Profile
              await ref.read(userServiceProvider).getProfile();
              _loadInitialData();
              if (!mounted) return;
              break;

            case 3: // Setting
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }
}
