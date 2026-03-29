import 'dart:convert';
import 'dart:io';

import 'package:chat2date/components/common/image_upload_grid.dart';
import 'package:chat2date/components/design_system/index.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/colors/app_gradients.dart';
import 'package:chat2date/core/theme/tokens/colors/button_colors.dart';
import 'package:chat2date/core/theme/tokens/colors/input_colors.dart';
import 'package:chat2date/core/theme/tokens/colors/text_colors.dart';
import 'package:chat2date/features/discovery/screens/main_tabs.dart';
import 'package:chat2date/features/profile/screens/selection_icon_mapper.dart';
import 'package:chat2date/models/interest.dart';
import 'package:chat2date/models/lifestyle.dart';
import 'package:chat2date/models/tag.dart';
import 'package:chat2date/models/travelstyle.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/photo_verification_service.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool showBottomNav;

  const ProfileScreen({super.key, this.showBottomNav = true});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController _nicknameCtrl = TextEditingController();
  final TextEditingController _lifestyleCtrl = TextEditingController();
  final TextEditingController _interestsCtrl = TextEditingController();
  final TextEditingController _tagsCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Travelstyle> _travelStyles = [];
  List<Lifestyle> _lifeStyles = [];
  List<Interest> _interests = [];
  List<Tag> _tags = [];

  List<int> _selectedInterests = [];
  List<int> _selectedLifestyles = [];
  List<int> _selectedTravelStyles = [];
  List<int> _selectedTags = [];

  String? _selectedGenderPreference;
  String? _oldGenderPreference;
  String? _oldNickname;

  final List<int> _oldInterests = [];
  final List<int> _oldLifeStyles = [];
  final List<int> _oldTravelStyles = [];
  final List<int> _oldTags = [];

  List<String> _photoUrls = [];
  List<String> _oldPhotos = [];
  List<File> _selectedImages = [];
  List<String> _deletedImages = [];

  double _behaviorScore = 0;
  bool _isLoading = false;
  bool _isSavePressed = false;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _nicknameCtrl.addListener(_refresh);
    _loadInitialData();
  }

  @override
  void dispose() {
    _nicknameCtrl
      ..removeListener(_refresh)
      ..dispose();
    _lifestyleCtrl.dispose();
    _interestsCtrl.dispose();
    _tagsCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _loadInitialData() async {
    final userStore = ref.read(userStoreProvider) as Map<String, dynamic>?;
    final currentUser = userStore?['user'] as User?;
    final userService = ref.read(userServiceProvider);

    if (currentUser == null) return;

    try {
      await userService.getUser(currentUser.userId);
    } catch (_) {}

    try {
      await userService.getProfile();
    } catch (_) {}

    final freshStore = ref.read(userStoreProvider) as Map<String, dynamic>?;
    final profile = freshStore?['profile'] as Map<String, dynamic>?;
    final user = freshStore?['user'] as User?;
    final prefs = freshStore?['preferences'] as Map<String, dynamic>?;

    if (profile == null || user == null) return;

    final orderedUrls = await _loadSavedPhotoOrder(
      currentUser.userId,
      _extractPhotoUrls(profile['photos']),
    );
    final profileWithSavedOrder = Map<String, dynamic>.from(profile)
      ..['photos'] = jsonEncode({'urls': orderedUrls});

    _setDataFromStore(profileWithSavedOrder, user, prefs: prefs);
  }

  void _setDataFromStore(
    Map<String, dynamic> profile,
    User user, {
    Map<String, dynamic>? prefs,
  }) {
    final travelStyles = List<Travelstyle>.from(prefs?['travelStyles'] ?? []);
    final lifeStyles = List<Lifestyle>.from(prefs?['lifeStyles'] ?? []);
    final interests = List<Interest>.from(prefs?['interests'] ?? []);
    final tags = List<Tag>.from(prefs?['tags'] ?? []);

    final selectedInterests = _toZeroBasedList(profile['interests']);
    final selectedLifestyles = _toZeroBasedList(profile['lifeStyles']);
    final selectedTravelStyles = _toZeroBasedList(profile['travelStyles']);
    final selectedTags = _toZeroBasedList(profile['tags']);
    final selectedGender = profile['interestedGender'] as String? ?? 'BOTH';
    final photoUrls = _extractPhotoUrls(profile['photos']);

    setState(() {
      _travelStyles = travelStyles;
      _lifeStyles = lifeStyles;
      _interests = interests;
      _tags = tags;

      _selectedInterests = selectedInterests;
      _selectedLifestyles = selectedLifestyles;
      _selectedTravelStyles = selectedTravelStyles;
      _selectedTags = selectedTags;

      _selectedGenderPreference = selectedGender;
      _oldGenderPreference = selectedGender;

      _behaviorScore = ((user.behaviorScore ?? 0) / 100).clamp(0.0, 1.0);
      _nicknameCtrl.text = user.nickname ?? '';
      _lifestyleCtrl.text = selectedLifestyles
          .where((i) => i >= 0 && i < lifeStyles.length)
          .map((i) => displaySelectionLabel(lifeStyles[i].lifestyle))
          .join(', ');
      _interestsCtrl.text = selectedInterests
          .where((i) => i >= 0 && i < interests.length)
          .map((i) => displaySelectionLabel(interests[i].interest))
          .join(', ');
      _tagsCtrl.text = selectedTags
          .where((i) => i >= 0 && i < tags.length)
          .map((i) => displaySelectionLabel(tags[i].tag))
          .join(', ');
      _oldNickname = user.nickname ?? '';

      _photoUrls = photoUrls;
      _oldPhotos = List<String>.from(photoUrls);
      _oldInterests
        ..clear()
        ..addAll(selectedInterests);
      _oldLifeStyles
        ..clear()
        ..addAll(selectedLifestyles);
      _oldTravelStyles
        ..clear()
        ..addAll(selectedTravelStyles);
      _oldTags
        ..clear()
        ..addAll(selectedTags);
      _selectedImages = [];
      _deletedImages = [];
    });
  }

  List<int> _toZeroBasedList(dynamic value) {
    if (value is! List) return <int>[];
    return value
        .whereType<int>()
        .map((id) => id - 1)
        .where((id) => id >= 0)
        .toList();
  }

  List<String> _extractPhotoUrls(dynamic rawPhotos) {
    if (rawPhotos is! String || rawPhotos.isEmpty) return <String>[];

    try {
      final decoded = jsonDecode(rawPhotos) as Map<String, dynamic>;
      return (decoded['urls'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (_) {
      return <String>[];
    }
  }

  bool _isListChanged(List<int> oldList, List<int> newList) {
    if (oldList.length != newList.length) return true;
    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i] != newList[i]) return true;
    }
    return false;
  }

  bool _isStringListChanged(List<String> oldList, List<String> newList) {
    if (oldList.length != newList.length) return true;
    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i] != newList[i]) return true;
    }
    return false;
  }

  bool get _hasPendingChanges {
    return _nicknameCtrl.text.trim() != (_oldNickname ?? '') ||
        _selectedGenderPreference != _oldGenderPreference ||
        _isListChanged(_oldInterests, _selectedInterests) ||
        _isListChanged(_oldLifeStyles, _selectedLifestyles) ||
        _isListChanged(_oldTravelStyles, _selectedTravelStyles) ||
        _isListChanged(_oldTags, _selectedTags) ||
        _isStringListChanged(_oldPhotos, _photoUrls) ||
        _selectedImages.isNotEmpty ||
        _deletedImages.isNotEmpty;
  }

  String _photoOrderKey(String userId) => 'profilePhotoOrder:$userId';

  Future<List<String>> _loadSavedPhotoOrder(
    String userId,
    List<String> backendUrls,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_photoOrderKey(userId)) ?? const <String>[];
    if (saved.isEmpty) return backendUrls;

    final backendSet = backendUrls.toSet();
    final ordered = <String>[
      ...saved.where(backendSet.contains),
      ...backendUrls.where((url) => !saved.contains(url)),
    ];
    return ordered;
  }

  Future<void> _savePhotoOrder(String userId, List<String> urls) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_photoOrderKey(userId), urls);
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

  Future<void> _syncPhotosIfNeeded() async {
    final userState = ref.read(userStoreProvider);
    final user = userState['user'] as User?;
    final cardFaceBytes = userState['cardFaceBytes'] as String?;

    if (user == null || cardFaceBytes == null) {
      throw Exception('ไม่พบข้อมูลผู้ใช้ หรือยังไม่ได้ถ่ายรูปบัตรประชาชน');
    }

    final service = ref.read(photoVerificationServiceProvider);

    if (_selectedImages.isNotEmpty) {
      await service.verifyAndUpload(
        userId: user.userId,
        profileImages: _selectedImages,
        idCardBase64: cardFaceBytes,
      );
    }

    if (_deletedImages.isNotEmpty) {
      await service.removePhoto(
        userId: user.userId,
        imageUrls: _deletedImages,
      );
    }
  }

  Future<void> _submitEdit() async {
    if (_isLoading) return;

    if (_nicknameCtrl.text.trim().isEmpty) {
      Toast.show(
        context,
        type: ToastType.warning,
        title: 'ชื่อเล่นหายไป',
        message: 'กรุณากรอกชื่อเล่น',
      );
      return;
    }

    if (_selectedTravelStyles.length < 2 || _selectedTravelStyles.length > 3) {
      Toast.show(
        context,
        type: ToastType.warning,
        title: 'สไตล์การท่องเที่ยวไม่ถูกต้อง',
        message: 'กรุณาเลือกสไตล์การท่องเที่ยว 2–3 ข้อ',
      );
      return;
    }

    if (_selectedLifestyles.length < 3 || _selectedLifestyles.length > 5) {
      Toast.show(
        context,
        type: ToastType.warning,
        title: 'ไลฟ์สไตล์ไม่ถูกต้อง',
        message: 'กรุณาเลือกไลฟ์สไตล์ 3–5 ข้อ',
      );
      return;
    }

    if (_selectedInterests.length < 3 || _selectedInterests.length > 5) {
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

    setState(() => _isLoading = true);

    try {
      final userStore = ref.read(userStoreProvider) as Map<String, dynamic>?;
      final currentUser = userStore?['user'] as User?;
      final profile = userStore?['profile'] as Map<String, dynamic>? ?? {};
      final userService = ref.read(userServiceProvider);

      if (currentUser == null) {
        throw Exception('ไม่พบข้อมูลผู้ใช้');
      }

      final List<Future<void>> tasks = [];

      if (_nicknameCtrl.text.trim() != (_oldNickname ?? '')) {
        tasks.add(
          userService.updateUser(
            User(
              userId: currentUser.userId,
              nickname: _nicknameCtrl.text.trim(),
              version: currentUser.version,
            ),
          ),
        );
      }

      if (_selectedGenderPreference != null &&
          _selectedGenderPreference != _oldGenderPreference) {
        tasks.add(
          userService.addPreferenceMatchUser({
            'interestedGender': _selectedGenderPreference!,
            'interestedAgeMax': profile['interestedAgeMax'] ?? 100,
            'interestedAgeMin': profile['interestedAgeMin'] ?? 18,
            'interestedTravelStyle':
                profile['interestedTravelStyle'] ?? 'UNNECESSARY',
            'interestedLifeStyle':
                profile['interestedLifeStyle'] ?? 'UNNECESSARY',
            'interestedInterest':
                profile['interestedInterest'] ?? 'UNNECESSARY',
          }),
        );
      }

      if (_isListChanged(_oldInterests, _selectedInterests) ||
          _isListChanged(_oldLifeStyles, _selectedLifestyles) ||
          _isListChanged(_oldTravelStyles, _selectedTravelStyles) ||
          _isListChanged(_oldTags, _selectedTags)) {
        tasks.add(
          userService.addPreferenceUser({
            'interests': _selectedInterests.map((id) => id + 1).toList(),
            'lifeStyles': _selectedLifestyles.map((id) => id + 1).toList(),
            'travelStyles': _selectedTravelStyles.map((id) => id + 1).toList(),
            'tags': _selectedTags.map((id) => id + 1).toList(),
          }),
        );
      }

      if (_selectedImages.isNotEmpty || _deletedImages.isNotEmpty) {
        await _syncPhotosIfNeeded();
      }

      if (tasks.isNotEmpty) {
        await Future.wait(tasks);
      }

      if (_isStringListChanged(_oldPhotos, _photoUrls)) {
        await _savePhotoOrder(currentUser.userId, _photoUrls);
      }

      await userService.getProfile();
      await userService.getUser(currentUser.userId);
      await _loadInitialData();

      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.success,
        title: 'สำเร็จ',
        message: 'บันทึกข้อมูลส่วนตัวสำเร็จ',
      );
    } catch (e) {
      if (!mounted) return;
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
          message: 'เกิดข้อผิดพลาด: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickLifestyles() async {
    final result = await Navigator.pushNamed(
      context,
      '/lifestylesSelection',
      arguments: {
        'items': _lifeStyles,
        'selected': _selectedLifestyles,
      },
    );

    if (result is List<int>) {
      setState(() {
        _selectedLifestyles = result;
        _lifestyleCtrl.text = result
            .where((i) => i >= 0 && i < _lifeStyles.length)
            .map((i) => displaySelectionLabel(_lifeStyles[i].lifestyle))
            .join(', ');
      });
    }
  }

  Future<void> _pickInterests() async {
    final result = await Navigator.pushNamed(
      context,
      '/interestsSelection',
      arguments: {
        'items': _interests,
        'selected': _selectedInterests,
      },
    );

    if (result is List<int>) {
      setState(() {
        _selectedInterests = result;
        _interestsCtrl.text = result
            .where((i) => i >= 0 && i < _interests.length)
            .map((i) => displaySelectionLabel(_interests[i].interest))
            .join(', ');
      });
    }
  }

  Future<void> _pickTags() async {
    final result = await Navigator.pushNamed(
      context,
      '/tagsSelection',
      arguments: {
        'items': _tags,
        'selected': _selectedTags,
      },
    );

    if (result is List<int>) {
      setState(() {
        _selectedTags = result;
        _tagsCtrl.text = result
            .where((i) => i >= 0 && i < _tags.length)
            .map((i) => displaySelectionLabel(_tags[i].tag))
            .join(', ');
      });
    }
  }

  Widget _buildSelectionSummaryField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onTap,
  }) {
    final labels = controller.text.trim().isEmpty
        ? const <String>[]
        : controller.text
              .split(',')
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: TextColors.secondary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 22 / 16,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: InputColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: InputColors.border, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: labels.isEmpty
                      ? Text(
                          hintText,
                          style: const TextStyle(
                            color: TextColors.supportText,
                            fontSize: 14,
                            height: 20 / 14,
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: labels.map((rawLabel) {
                            final icon = mapSelectionIcon(rawLabel);
                            final text = displaySelectionLabel(rawLabel);
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: InputColors.backgroundDisabled,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: InputColors.border,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    icon,
                                    size: 14,
                                    color: TextColors.supportText,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    text,
                                    style: const TextStyle(
                                      color: TextColors.secondary,
                                      fontSize: 13,
                                      height: 18 / 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(width: 12),
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.add_circle_rounded,
                    size: 16,
                    color: AppColors.brandPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSaveAction() {
    if (!_hasPendingChanges) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isSavePressed = true),
      onTapUp: (_) => setState(() => _isSavePressed = false),
      onTapCancel: () => setState(() => _isSavePressed = false),
      onTap: _isLoading ? null : _submitEdit,
      child: AnimatedScale(
        scale: _isSavePressed ? 1.12 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: ButtonColors.accept,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ButtonColors.accept.withValues(alpha: 0.24),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: AppColors.textOnDark,
                    ),
                  )
                : const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.textOnDark,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTravelStyleGrid() {
    final labels = _travelStyles.map((item) => item.travelstyle).toList();
    final bool isAtMax = _selectedTravelStyles.length >= 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'สไตล์การท่องเที่ยว',
          style: TextStyle(
            color: TextColors.secondary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 22 / 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedTravelStyles.length >= 2
              ? 'เลือกแล้ว ${_selectedTravelStyles.length}/3 รายการ'
              : 'เลือกเพิ่มอีก ${2 - _selectedTravelStyles.length} รายการ',
          style: TextStyle(
            color: _selectedTravelStyles.length >= 2
                ? TextColors.secondary
                : TextColors.supportText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 18 / 13,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          itemCount: labels.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: 32.6,
          ),
          itemBuilder: (context, index) {
            final selected = _selectedTravelStyles.contains(index);
            final disabled = !selected && isAtMax;

            return InkWell(
              onTap: disabled
                  ? null
                  : () {
                      setState(() {
                        if (selected) {
                          _selectedTravelStyles.remove(index);
                        } else {
                          _selectedTravelStyles.add(index);
                        }
                      });
                    },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: BoxDecoration(
                  gradient: selected ? AppGradients.themeApp2 : null,
                  color: selected ? null : InputColors.background,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : disabled
                            ? InputColors.border
                            : InputColors.border,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (selected) ...[
                      const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: TextColors.secondary,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Flexible(
                      child: Text(
                        labels[index],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected
                              ? TextColors.secondary
                              : disabled
                                  ? TextColors.disabled
                                  : TextColors.supportText,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 20 / 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBehaviorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'คะแนนความประพฤติ',
          style: TextStyle(
            color: TextColors.secondary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 22 / 16,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: DsProgressRing(
            value: _behaviorScore,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'เกณฑ์คะแนนความประพฤติ:',
          style: TextStyle(
            color: TextColors.secondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'ถ้าคะแนน ≤ 50 : บัญชีจะถูกจำกัดฟีเจอร์ 3 วัน และปัดได้ไม่เกิน 10 ครั้ง/วัน',
          style: const TextStyle(
            color: TextColors.secondary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 18 / 12,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'ถ้าคะแนน < 30 : บัญชีจะถูกแบนถาวร และถูกใส่ใน Blacklist (ห้ามกลับมาใช้งาน)',
          style: const TextStyle(
            color: TextColors.secondary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 18 / 12,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'วิธีเพิ่มแต้มขึ้น',
          style: TextStyle(
            color: TextColors.secondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 18 / 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'อยู่ครบ 30 วันโดยไม่มีใครรายงาน ➜ เพิ่ม 15 คะแนนความประพฤติ',
          style: const TextStyle(
            color: TextColors.secondary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 18 / 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    final bottomPadding = widget.showBottomNav ? 92.0 : 32.0;

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      thickness: 4,
      radius: const Radius.circular(8),
      interactive: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(25, 12, 25, bottomPadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 310),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DsTextField(
                  label: 'ชื่อเล่น',
                  controller: _nicknameCtrl,
                  textColor: TextColors.secondary,
                ),
                const SizedBox(height: 20),
                DsDropdownField<String>(
                  label: 'ประเภทคู่เดตที่สนใจ',
                  value: _selectedGenderPreference,
                  hintText: 'เลือกประเภทคู่เดต',
                  items: const [
                    DsDropdownItem(value: 'MALE', label: 'เพศชาย'),
                    DsDropdownItem(value: 'FEMALE', label: 'เพศหญิง'),
                    DsDropdownItem(value: 'BOTH', label: 'ทั้งสองเพศ'),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedGenderPreference = value);
                  },
                ),
                const SizedBox(height: 20),
                _buildSelectionSummaryField(
                  label: 'ไลฟ์สไตล์',
                  controller: _lifestyleCtrl,
                  hintText: 'เลือกไลฟ์สไตล์',
                  onTap: _pickLifestyles,
                ),
                const SizedBox(height: 20),
                _buildSelectionSummaryField(
                  label: 'สิ่งที่สนใจ',
                  controller: _interestsCtrl,
                  hintText: 'เลือกสิ่งที่สนใจ',
                  onTap: _pickInterests,
                ),
                const SizedBox(height: 20),
                _buildSelectionSummaryField(
                  label: 'tags(ไม่บังคับ)',
                  controller: _tagsCtrl,
                  hintText: 'เลือก tags',
                  onTap: _pickTags,
                ),
                const SizedBox(height: 20),
                _buildTravelStyleGrid(),
                const SizedBox(height: 20),
                const Text(
                  'แก้ไขรูปภาพที่แสดง',
                  style: TextStyle(
                    color: TextColors.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 22 / 16,
                  ),
                ),
                const SizedBox(height: 12),
                ImageUploadGrid(
                  key: ValueKey(_photoUrls.join(',')),
                  imageUser: _photoUrls,
                  maxImages: 6,
                  itemWidth: 119,
                  itemHeight: 120,
                  spacing: 10,
                  runSpacing: 50,
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
                  onItemsChanged: (items) {
                    setState(() {
                      _photoUrls = items.whereType<String>().toList();
                      _selectedImages = items
                          .whereType<XFile>()
                          .map((file) => File(file.path))
                          .toList();
                    });
                  },
                  onImageRemoved: (index, removedItem) {
                    setState(() {
                      if (removedItem is String) {
                        _deletedImages.add(removedItem);
                        _photoUrls.remove(removedItem);
                      } else if (removedItem is XFile) {
                        _selectedImages.removeWhere(
                          (file) => file.path == removedItem.path,
                        );
                      }
                    });
                  },
                ),
                const SizedBox(height: 24),
                _buildBehaviorSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    if (!mounted) return;
    setState(() => _selectedIndex = index);
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MainTabs(initialIndex: index),
        transitionDuration: const Duration(milliseconds: 0),
        reverseTransitionDuration: const Duration(milliseconds: 0),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                DsAppHomeHeader(
                  action: _buildHeaderSaveAction(),
                  showBottomBorder: true,
                ),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.showBottomNav
          ? CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onTap: _handleBottomNavTap,
            )
          : null,
    );
  }
}
