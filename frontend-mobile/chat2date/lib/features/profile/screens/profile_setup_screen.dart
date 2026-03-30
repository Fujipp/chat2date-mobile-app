import 'package:chat2date/components/common/app_raw_scrollbar.dart';
import 'package:chat2date/components/design_system/index.dart';
import 'package:chat2date/core/formatters/thai_nickname_input_formatter.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/colors/app_gradients.dart';
import 'package:chat2date/core/theme/tokens/colors/input_colors.dart';
import 'package:chat2date/core/theme/tokens/colors/text_colors.dart';
import 'package:chat2date/models/interest.dart';
import 'package:chat2date/models/lifestyle.dart';
import 'package:chat2date/models/tag.dart';
import 'package:chat2date/models/travelstyle.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/preference_service.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:chat2date/features/profile/screens/selection_icon_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nicknameCtrl = TextEditingController();
  final _scrollController = ScrollController();
  final _nicknameFocusNode = FocusNode();

  List<Travelstyle> _travelStyles = [];
  List<Lifestyle> _lifeStyles = [];
  List<Interest> _interests = [];
  List<Tag> _tags = [];

  List<int> _selectedLifestyles = [];
  List<int> _selectedInterests = [];
  List<int> _selectedTags = [];
  final List<int> _selectedTravelStyles = [];

  bool _saving = false;

  String? get _nicknameErrorText {
    final nickname = _nicknameCtrl.text.trim();
    if (nickname.isEmpty) {
      return 'กรุณากรอกชื่อเล่น';
    }
    if (nickname.length > 20) {
      return 'ชื่อเล่นต้องไม่เกิน 20 ตัวอักษร';
    }
    return null;
  }

  bool get _canSubmit =>
      _nicknameCtrl.text.trim().isNotEmpty &&
      _selectedTravelStyles.length >= 2 &&
      _selectedTravelStyles.length <= 3 &&
      _selectedLifestyles.length >= 3 &&
      _selectedLifestyles.length <= 5 &&
      _selectedInterests.length >= 3 &&
      _selectedInterests.length <= 5 &&
      _selectedTags.length <= 5;

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
    _nicknameFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _clearFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Widget _buildSelectionSummaryField({
    required String label,
    required bool required,
    required List<String> selectedLabels,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 22 / 16,
                ),
            children: required
                ? const [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ]
                : null,
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
                  child: selectedLabels.isEmpty
                      ? Text(
                          'เลือก$label',
                          style: const TextStyle(
                            color: TextColors.supportText,
                            fontSize: 14,
                            height: 20 / 14,
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedLabels.map((rawLabel) {
                            final icon =
                                mapSelectionIcon(rawLabel);
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
                    Icons.arrow_circle_right_rounded,
                    size: 18,
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

  Future<void> _loadInitialData() async {
    try {
      await ref.read(preferenceServiceProvider).getPreference();
    } catch (_) {}

    final userStore = ref.read(userStoreProvider) as Map<String, dynamic>?;
    final prefs = userStore?['preferences'];
    if (prefs == null) return;

    if (!mounted) return;
    setState(() {
      _travelStyles = List<Travelstyle>.from(prefs['travelStyles'] ?? []);
      _lifeStyles = List<Lifestyle>.from(prefs['lifeStyles'] ?? []);
      _interests = List<Interest>.from(prefs['interests'] ?? []);
      _tags = List<Tag>.from(prefs['tags'] ?? []);
    });
  }

  Future<void> _pickLifestyles() async {
    _clearFocus();
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
      });
    }
    if (mounted) WidgetsBinding.instance.addPostFrameCallback((_) => _clearFocus());
  }

  Future<void> _pickInterests() async {
    _clearFocus();
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
      });
    }
    if (mounted) WidgetsBinding.instance.addPostFrameCallback((_) => _clearFocus());
  }

  Future<void> _pickTags() async {
    _clearFocus();
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
      });
    }
    if (mounted) WidgetsBinding.instance.addPostFrameCallback((_) => _clearFocus());
  }

  Future<void> _submit() async {
    if (_saving) return;

    if (_nicknameCtrl.text.trim().isEmpty) {
      _nicknameFocusNode.requestFocus();
      setState(() {});
      return;
    }

    if (_nicknameCtrl.text.trim().length > 20) {
      _nicknameFocusNode.requestFocus();
      setState(() {});
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

    setState(() => _saving = true);

    try {
      final userStore = ref.read(userStoreProvider) as Map<String, dynamic>?;
      final oldUser = userStore?['user'] as User?;

      if (oldUser == null || oldUser.version == null) {
        Toast.show(
          context,
          type: ToastType.error,
          title: 'ข้อผิดพลาด',
          message: 'ไม่พบข้อมูลผู้ใช้',
        );
        return;
      }

      final user = User(
        userId: oldUser.userId,
        nickname: _nicknameCtrl.text.trim(),
        version: oldUser.version,
      );

      final preference = {
        'interests': _selectedInterests.map((id) => id + 1).toList(),
        'lifeStyles': _selectedLifestyles.map((id) => id + 1).toList(),
        'tags': _selectedTags.map((id) => id + 1).toList(),
        'travelStyles': _selectedTravelStyles.map((id) => id + 1).toList(),
      };

      final userService = ref.read(userServiceProvider);
      await userService.updateUser(user);
      await userService.addPreferenceUser(preference);

      if (!mounted) return;
      Navigator.pushNamed(context, '/matchPreference');
    } catch (e) {
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.error,
        title: 'ข้อผิดพลาด',
        message: 'เกิดข้อผิดพลาด: ${e.toString()}',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildTravelStyleGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;
        final isAtMax = _selectedTravelStyles.length >= 3;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(_travelStyles.length, (index) {
            final item = _travelStyles[index];
            final selected = _selectedTravelStyles.contains(index);
            final disabled = !selected && isAtMax;

            return GestureDetector(
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
              child: Container(
                width: itemWidth,
                height: 32.6,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: selected ? AppGradients.themeApp2 : null,
                  color: selected
                      ? null
                      : disabled
                          ? InputColors.backgroundDisabled
                          : InputColors.background,
                  border: selected
                      ? null
                      : Border.all(color: InputColors.border, width: 1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: selected
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    if (selected) ...[
                      const Icon(
                        Icons.check,
                        size: 14,
                        color: TextColors.secondary,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Flexible(
                      child: Text(
                        item.travelstyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 20 / 14,
                          color: TextColors.secondary,
                        ).copyWith(
                          color: selected
                              ? TextColors.secondary
                              : disabled
                                  ? TextColors.disabled
                                  : TextColors.supportText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _clearFocus,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 375),
              child: Column(
                children: [
                  DsAppSecondaryHeader(
                    variant: DsAppSecondaryHeaderVariant.baseText,
                    title: 'ข้อมูลส่วนตัว',
                    leading: const SizedBox(width: 40, height: 40),
                    showBottomBorder: true,
                  ),
                  Expanded(
                    child: AppRawScrollbar(
                          controller: _scrollController,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(40, 10, 40, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DsTextField(
                                label: 'ชื่อเล่น',
                                required: true,
                                controller: _nicknameCtrl,
                                focusNode: _nicknameFocusNode,
                                labelFontSize: 16,
                                inputFontSize: 14,
                                maxLength: 20,
                                inputFormatters: const [
                                  ThaiNicknameInputFormatter(),
                                ],
                                state: _nicknameErrorText != null
                                    ? DsInputVisualState.error
                                    : null,
                                supportText: _nicknameErrorText,
                                showSupportText: _nicknameErrorText != null,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildSelectionSummaryField(
                                label: 'ไลฟ์สไตล์',
                                required: true,
                                selectedLabels: _selectedLifestyles
                                    .map((i) => _lifeStyles[i].lifestyle)
                                    .toList(),
                                onTap: _pickLifestyles,
                              ),
                              const SizedBox(height: 20),
                              _buildSelectionSummaryField(
                                label: 'สิ่งที่สนใจ',
                                required: true,
                                selectedLabels: _selectedInterests
                                    .map((i) => _interests[i].interest)
                                    .toList(),
                                onTap: _pickInterests,
                              ),
                              const SizedBox(height: 20),
                              _buildSelectionSummaryField(
                                label: 'Tags (ไม่บังคับ)',
                                required: false,
                                selectedLabels: _selectedTags
                                    .map((i) => _tags[i].tag)
                                    .toList(),
                                onTap: _pickTags,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'สไตล์การท่องเที่ยว',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: const Color(0xFF2F3036),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      height: 22 / 16,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    _selectedTravelStyles.length >= 2
                                        ? 'เลือกแล้ว ${_selectedTravelStyles.length}/3 รายการ'
                                        : 'เลือกเพิ่มอีก ${2 - _selectedTravelStyles.length} รายการ',
                                    style: TextStyle(
                                      color: _selectedTravelStyles.length >= 2
                                          ? TextColors.supportText
                                          : AppColors.brandSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildTravelStyleGrid(),
                              const SizedBox(height: 24),
                              Center(
                                child: DsButton(
                                  width: 231,
                                  label: 'ไปหน้าถัดไป',
                                  onPressed: (_canSubmit && !_saving) ? _submit : null,
                                  variant: DsButtonVariant.outlinePrimary,
                                  size: DsButtonSize.md,
                                ),
                              ),
                            ],
                          ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
