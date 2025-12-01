import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/inputs/ds_label.dart';
import 'package:chat2date/components/inputs/ds_text_field/ds_text_field.dart';
import 'package:chat2date/components/inputs/ds_text_field/tag_autocomplete.dart';
import 'package:chat2date/components/layout/responsive_container.dart';
import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/models/interest.dart';
import 'package:chat2date/models/lifestyle.dart';
import 'package:chat2date/models/tag.dart';
import 'package:chat2date/models/travelstyle.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
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
      _selectedTravelStyles.map((i) => _travelStyles[i].id).toList();

  // initial snapshot for change detection
  String? _initialNickname;
  List<int> _initialLifestyles = [];
  List<int> _initialInterests = [];
  List<int> _initialTags = [];
  List<int> _initialTravelStyles = [];

  bool _canSubmit = false;

  void _updateCanSubmit() {
    final changedNickname = (_nicknameCtrl.text != (_initialNickname ?? ''));
    final changedLifestyle = !_listEquals(
      _selectedLifestyles,
      _initialLifestyles,
    );
    final changedInterests = !_listEquals(
      _selectedInterests,
      _initialInterests,
    );
    final changedTags = !_listEquals(_selectedTags, _initialTags);
    final changedTravel = !_listEquals(
      _selectedTravelStyles,
      _initialTravelStyles,
    );
    setState(() {
      _canSubmit =
          changedNickname ||
          changedLifestyle ||
          changedInterests ||
          changedTags ||
          changedTravel;
    });
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // ข้อมูลสำหรับแสดงใน TextField
  String _getSelectedText(List<int> selected, List<String> allItems) {
    if (selected.isEmpty) return '';
    return selected.map((i) => allItems[i]).join(', ');
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _nicknameCtrl.addListener(_updateCanSubmit);
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

    // Fetch latest user to prefill nickname
    final user = userStore?['user'] as User?;
    if (user != null) {
      try {
        await ref.read(userServiceProvider).getUser(user.userId);
        final refreshed =
            (ref.read(userStoreProvider) as Map<String, dynamic>?)?['user']
                as User?;
        final nickname = refreshed?.nickname ?? user.nickname ?? '';
        setState(() {
          _initialNickname = nickname;
          _nicknameCtrl.text = nickname;
        });
      } catch (_) {
        final nickname = user.nickname ?? '';
        setState(() {
          _initialNickname = nickname;
          _nicknameCtrl.text = nickname;
        });
      }
    }

    // initialize initial selections from prefs if present (empty by default)
    _initialLifestyles = List.from(_selectedLifestyles);
    _initialInterests = List.from(_selectedInterests);
    _initialTags = List.from(_selectedTags);
    _initialTravelStyles = List.from(_selectedTravelStyles);
    _updateCanSubmit();
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
                      _updateCanSubmit();
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
                    _updateCanSubmit();
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
                    _updateCanSubmit();
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
                        _updateCanSubmit();
                      });
                    },
                  ),
                ],
              ),
            ),

            DsButton(
              label: 'ไปหน้าถัดไป',
              onPressed: _canSubmit
                  ? () async {
                      // ตรวจสอบข้อมูลก่อนส่ง
                      if (_nicknameCtrl.text.isEmpty) {
                        Toast.show(
                          context,
                          type: ToastType.warning,
                          title: 'ชื่อเล่นหายไป',
                          message: 'กรุณากรอกชื่อเล่น',
                        );
                        return;
                      }

                      if (_selectedTravelStyles.length < 2 ||
                          _selectedTravelStyles.length > 3) {
                        Toast.show(
                          context,
                          type: ToastType.warning,
                          title: 'สไตล์การท่องเที่ยวไม่ถูกต้อง',
                          message: 'กรุณาเลือกสไตล์การท่องเที่ยว 2–3 ข้อ',
                        );
                        return;
                      }

                      if (_selectedLifestyles.length < 3 ||
                          _selectedLifestyles.length > 5) {
                        Toast.show(
                          context,
                          type: ToastType.warning,
                          title: 'ไลฟ์สไตล์ไม่ถูกต้อง',
                          message: 'กรุณาเลือกไลฟ์สไตล์ 3–5 ข้อ',
                        );
                        return;
                      }

                      if (_selectedInterests.length < 3 ||
                          _selectedInterests.length > 5) {
                        Toast.show(
                          context,
                          type: ToastType.warning,
                          title: 'สิ่งที่สนใจไม่ถูกต้อง',
                          message: 'กรุณาเลือกสิ่งที่สนใจ 3–5 ข้อ',
                        );
                        return;
                      }

                      if (_selectedTags.length > 5) {
                        Toast.show(
                          context,
                          type: ToastType.warning,
                          title: 'จำนวน Tag เกิน',
                          message: 'สามารถเลือก Tag สูงสุด 5 ข้อ',
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

                      print('===== เริ่มบันทึกข้อมูล =====');

                      try {
                        final userStore =
                            ref.read(userStoreProvider)
                                as Map<String, dynamic>?;

                        if (userStore == null) {
                          if (mounted) {
                            Toast.show(
                              context,
                              type: ToastType.error,
                              title: 'ข้อผิดพลาด',
                              message: 'ไม่พบข้อมูลผู้ใช้',
                            );
                          }
                          return;
                        }

                        final oldUser = userStore['user'] as User?;

                        if (oldUser == null) {
                          if (mounted) {
                            Toast.show(
                              context,
                              type: ToastType.error,
                              title: 'ข้อผิดพลาด',
                              message: 'ไม่พบข้อมูลผู้ใช้',
                            );
                          }
                          return;
                        }

                        if (oldUser.version == null) {
                          if (mounted) {
                            Toast.show(
                              context,
                              type: ToastType.error,
                              title: 'ข้อผิดพลาด',
                              message: 'ไม่พบข้อมูลผู้ใช้',
                            );
                          }
                          return;
                        }

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

                        print('🔄 Calling updateUser...');
                        final update = await userService.updateUser(user);
                        print('✅ updateUser result: $update');

                        print('🔄 Calling addPreferenceUser...');
                        final addPreference = await userService
                            .addPreferenceUser(preference);
                        print('✅ addPreferenceUser result: $addPreference');

                        // 🔄 Refresh user to fetch latest nickname and reset change tracking
                        try {
                          final refreshedUser = await userService.getUser(user.userId);
                          final latestUser = (ref.read(userStoreProvider) as Map<String, dynamic>?)?['user'] as User?;
                          final latestNickname = latestUser?.nickname ?? refreshedUser?.nickname ?? _nicknameCtrl.text;
                          setState(() {
                            _initialNickname = latestNickname;
                            _nicknameCtrl.text = latestNickname;
                            // After successful save, treat current selections as initial to disable button
                            _initialLifestyles = List.from(_selectedLifestyles);
                            _initialInterests = List.from(_selectedInterests);
                            _initialTags = List.from(_selectedTags);
                            _initialTravelStyles = List.from(_selectedTravelStyles);
                            _updateCanSubmit();
                          });
                        } catch (_) {
                          // If refresh fails, still proceed but keep current nickname
                          setState(() {
                            _initialNickname = _nicknameCtrl.text;
                            _initialLifestyles = List.from(_selectedLifestyles);
                            _initialInterests = List.from(_selectedInterests);
                            _initialTags = List.from(_selectedTags);
                            _initialTravelStyles = List.from(_selectedTravelStyles);
                            _updateCanSubmit();
                          });
                        }

                        print('🎉 บันทึกสำเร็จ กำลัง Navigate...');

                        // ✅ Navigate หลังจาก API สำเร็จ
                        if (mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            '/matchPreference',
                          );
                          print('✅ Navigate สำเร็จ');
                        }
                      } catch (e, stackTrace) {
                        print('❌ ===== ERROR =====');
                        print('Error: $e');
                        print('StackTrace: $stackTrace');

                        if (mounted) {
                          Toast.show(
                            context,
                            type: ToastType.error,
                            title: 'ข้อผิดพลาด',
                            message: 'เกิดข้อผิดพลาด: ${e.toString()}',
                          );
                        }
                        // ⚠️ ไม่ throw exception ออกไป
                      }
                    }
                  : null,
              variant: DsButtonVariant.primary,
              size: DsButtonSize.md,
            ),
          ],
        ),
      ),
    );
  }
}
