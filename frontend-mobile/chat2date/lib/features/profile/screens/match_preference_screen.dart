import 'package:chat2date/components/common/app_raw_scrollbar.dart';
import 'package:chat2date/components/design_system/index.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/colors/app_gradients.dart';
import 'package:chat2date/core/theme/tokens/colors/text_colors.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchPreferenceScreen extends ConsumerStatefulWidget {
  const MatchPreferenceScreen({super.key});

  @override
  ConsumerState<MatchPreferenceScreen> createState() =>
      _MatchPreferenceScreenState();
}

class _MatchPreferenceScreenState extends ConsumerState<MatchPreferenceScreen> {
  final ScrollController _scrollController = ScrollController();

  RangeValues _selectedRange = const RangeValues(18, 100);
  late RangeValues _initialRange;
  bool _isGenderAgeSpecific = false;
  late bool _initialIsGenderAgeSpecific;

  String? _travelStylePreference;
  String? _lifeStylePreference;
  String? _interestPreference;
  String? _selectedGenderPreference;
  String? _initialTravelStylePreference;
  String? _initialLifeStylePreference;
  String? _initialInterestPreference;
  String? _initialGenderPreference;

  @override
  void initState() {
    super.initState();

    final userStore = ref.read(userStoreProvider) as Map<String, dynamic>?;
    final profile = userStore?['profile'] as Map<String, dynamic>?;

    _selectedGenderPreference = profile?['interestedGender'] ?? 'BOTH';
    final ageMin = (profile?['interestedAgeMin'] as num?)?.toDouble() ?? 18;
    final ageMax = (profile?['interestedAgeMax'] as num?)?.toDouble() ?? 100;
    _selectedRange = RangeValues(ageMin, ageMax);
    _travelStylePreference = profile?['interestedTravelStyle'];
    _lifeStylePreference = profile?['interestedLifeStyle'];
    _interestPreference = profile?['interestedInterest'];

    _isGenderAgeSpecific =
        _interestPreference == 'UNNECESSARY' &&
        _lifeStylePreference == 'UNNECESSARY' &&
        _travelStylePreference == 'UNNECESSARY';

    _initialGenderPreference = _selectedGenderPreference;
    _initialRange = _selectedRange;
    _initialTravelStylePreference = _travelStylePreference;
    _initialLifeStylePreference = _lifeStylePreference;
    _initialInterestPreference = _interestPreference;
    _initialIsGenderAgeSpecific = _isGenderAgeSpecific;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _selectedGenderPreference != null &&
      _travelStylePreference != null &&
      _lifeStylePreference != null &&
      _interestPreference != null;

  bool get _hasChanges =>
      _selectedGenderPreference != _initialGenderPreference ||
      _selectedRange.start != _initialRange.start ||
      _selectedRange.end != _initialRange.end ||
      _travelStylePreference != _initialTravelStylePreference ||
      _lifeStylePreference != _initialLifeStylePreference ||
      _interestPreference != _initialInterestPreference ||
      _isGenderAgeSpecific != _initialIsGenderAgeSpecific;

  void _toggleGenderAgeSpecific() {
    setState(() {
      _isGenderAgeSpecific = !_isGenderAgeSpecific;
      if (_isGenderAgeSpecific) {
        _travelStylePreference = 'UNNECESSARY';
        _lifeStylePreference = 'UNNECESSARY';
        _interestPreference = 'UNNECESSARY';
      } else {
        _travelStylePreference = null;
        _lifeStylePreference = null;
        _interestPreference = null;
      }
    });
  }

  void _handleScopeChange(String scope, String value) {
    setState(() {
      if (scope == 'travel') {
        _travelStylePreference = value;
      } else if (scope == 'lifestyle') {
        _lifeStylePreference = value;
      } else if (scope == 'interest') {
        _interestPreference = value;
      }

      if (value != 'UNNECESSARY') {
        _isGenderAgeSpecific = false;
      }
    });
  }

  Future<void> _submit(bool onUpdate) async {
    if (_selectedGenderPreference == null) {
      Toast.show(
        context,
        type: ToastType.warning,
        title: 'ข้อมูลไม่ครบ',
        message: 'กรุณาเลือกเพศที่สนใจ',
      );
      return;
    }
    if (_travelStylePreference == null) {
      Toast.show(
        context,
        type: ToastType.warning,
        title: 'ข้อมูลไม่ครบ',
        message: 'กรุณาเลือกสไตล์การท่องเที่ยว',
      );
      return;
    }
    if (_lifeStylePreference == null) {
      Toast.show(
        context,
        type: ToastType.warning,
        title: 'ข้อมูลไม่ครบ',
        message: 'กรุณาเลือกไลฟ์สไตล์',
      );
      return;
    }
    if (_interestPreference == null) {
      Toast.show(
        context,
        type: ToastType.warning,
        title: 'ข้อมูลไม่ครบ',
        message: 'กรุณาเลือกสิ่งที่สนใจ',
      );
      return;
    }

    final Map<String, Object> preferenceMatch;
    if (!onUpdate) {
      preferenceMatch = {
        'interestedGender': _selectedGenderPreference!,
        'interestedAgeMax': _selectedRange.end,
        'interestedAgeMin': _selectedRange.start,
        'interestedTravelStyle': _travelStylePreference!,
        'interestedLifeStyle': _lifeStylePreference!,
        'interestedInterest': _interestPreference!,
        'interestedDistanceMin': 0,
        'interestedDistanceMax': 0,
      };
    } else {
      preferenceMatch = {
        'interestedGender': _selectedGenderPreference!,
        'interestedAgeMax': _selectedRange.end,
        'interestedAgeMin': _selectedRange.start,
        'interestedTravelStyle': _travelStylePreference!,
        'interestedLifeStyle': _lifeStylePreference!,
        'interestedInterest': _interestPreference!,
      };
    }

    await ref.read(userServiceProvider).addPreferenceMatchUser(preferenceMatch);

    if (!mounted) return;
    if (!onUpdate) {
      Navigator.pushNamed(context, '/userPicture');
    } else {
      await ref.read(userServiceProvider).getProfile();
      if (!mounted) return;
      Navigator.pushNamed(context, '/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    bool onUpdate = false;
    if (args is Map<String, dynamic>) {
      onUpdate = args['onUpdate'] as bool? ?? false;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 375),
            child: Column(
              children: [
                DsAppSecondaryHeader(
                  variant: DsAppSecondaryHeaderVariant.baseText,
                  title: 'ประเภทคู่เดตที่สนใจ',
                  center: const Text(
                    'ประเภทคู่เดตที่สนใจ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TextColors.secondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      height: 24 / 18,
                    ),
                  ),
                  onBackTap: () => Navigator.pop(context),
                  showBottomBorder: true,
                ),
                Expanded(
                  child: AppRawScrollbar(
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(25, 10, 25, 32),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildGenderDropdown(),
                            const SizedBox(height: 20),
                            _MatchPreferenceRangeField(
                              values: _selectedRange,
                              onChanged: (values) {
                                setState(() => _selectedRange = values);
                              },
                            ),
                            const SizedBox(height: 20),
                            _ScopePreferenceCard(
                              title: 'สไตล์การท่องเที่ยว',
                              value: _travelStylePreference,
                              onChanged: (value) =>
                                  _handleScopeChange('travel', value),
                            ),
                            const SizedBox(height: 12),
                            _ScopePreferenceCard(
                              title: 'ไลฟ์สไตล์',
                              value: _lifeStylePreference,
                              onChanged: (value) =>
                                  _handleScopeChange('lifestyle', value),
                            ),
                            const SizedBox(height: 12),
                            _ScopePreferenceCard(
                              title: 'ความสนใจ',
                              value: _interestPreference,
                              onChanged: (value) =>
                                  _handleScopeChange('interest', value),
                            ),
                            const SizedBox(height: 18),
                            _GenderAgeSpecificToggle(
                              value: _isGenderAgeSpecific,
                              onTap: _toggleGenderAgeSpecific,
                            ),
                            const SizedBox(height: 28),
                            DsButton(
                              width: 231,
                              label: onUpdate ? 'บันทึก' : 'ไปหน้าถัดไป',
                              onPressed: (onUpdate
                                      ? (_canSubmit && _hasChanges)
                                      : _canSubmit)
                                  ? () => _submit(onUpdate)
                                  : null,
                              variant: DsButtonVariant.outlinePrimary,
                              size: DsButtonSize.md,
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
    );
  }

  Widget _buildGenderDropdown() {
    return DsDropdownField<String>(
      label: 'เพศที่สนใจ',
      required: true,
      value: _selectedGenderPreference,
      hintText: 'กรุณาเลือกเพศ',
      items: const [
        DsDropdownItem(value: 'MALE', label: 'ผู้ชาย'),
        DsDropdownItem(value: 'FEMALE', label: 'ผู้หญิง'),
        DsDropdownItem(value: 'BOTH', label: 'ได้ทั้งคู่'),
      ],
      onChanged: (value) {
        setState(() => _selectedGenderPreference = value);
      },
    );
  }
}

class _MatchPreferenceRangeField extends StatelessWidget {
  const _MatchPreferenceRangeField({
    required this.values,
    required this.onChanged,
  });

  final RangeValues values;
  final ValueChanged<RangeValues> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ช่วงอายุที่สนใจ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: TextColors.secondary,
            height: 22 / 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              values.start.round().toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: TextColors.secondary,
                height: 22 / 16,
              ),
            ),
            Text(
              values.end.round().toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: TextColors.secondary,
                height: 22 / 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            activeTrackColor: const Color(0xFF2D2D2D),
            inactiveTrackColor: const Color(0xFFE0E0E0),
            rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
            overlayShape: SliderComponentShape.noOverlay,
            rangeThumbShape: const _ScopeRangeThumbShape(),
          ),
          child: RangeSlider(
            values: values,
            min: 18,
            max: 100,
            divisions: 82,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _ScopePreferenceCard extends StatelessWidget {
  const _ScopePreferenceCard({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? value;
  final ValueChanged<String>? onChanged;

  static const _options = <_ScopeOption>[
    _ScopeOption(label: 'เหมือนกัน', value: 'SAME'),
    _ScopeOption(label: 'คล้ายกัน', value: 'NEARLY'),
    _ScopeOption(label: 'ไม่จำเป็น', value: 'UNNECESSARY'),
    _ScopeOption(label: 'ไม่เกี่ยวข้องกัน', value: 'UNRELATED'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        gradient: AppGradients.themeApp2,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: title,
              style: const TextStyle(
                color: TextColors.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 22 / 16,
              ),
              children: const [
                TextSpan(
                  text: '*',
                  style: TextStyle(color: AppColors.error),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            itemCount: _options.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              mainAxisExtent: 22,
            ),
            itemBuilder: (context, index) {
              final option = _options[index];
              return _ScopeOptionTile(
                label: option.label,
                selected: value == option.value,
                onTap: onChanged == null ? null : () => onChanged!(option.value),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ScopeOption {
  const _ScopeOption({required this.label, required this.value});

  final String label;
  final String value;
}

class _ScopeOptionTile extends StatelessWidget {
  const _ScopeOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF2D2D2D) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? const Color(0xFF2D2D2D) : const Color(0xFFD8DEE6),
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: onTap == null ? TextColors.disabled : TextColors.secondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 20 / 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderAgeSpecificToggle extends StatelessWidget {
  const _GenderAgeSpecificToggle({
    required this.value,
    required this.onTap,
  });

  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 23,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF2D2D2D),
              ),
            ),
            child: value
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2D2D2D),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Text(
              'สนใจเฉพาะเพศและช่วงอายุ',
              style: TextStyle(
                color: TextColors.secondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 20 / 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScopeRangeThumbShape extends RangeSliderThumbShape {
  const _ScopeRangeThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size.square(16);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    required SliderThemeData sliderTheme,
    TextDirection textDirection = TextDirection.ltr,
    Thumb thumb = Thumb.start,
    bool isPressed = false,
  }) {
    final canvas = context.canvas;
    final paint = Paint()..color = const Color(0xFF2D2D2D);
    canvas.drawCircle(center, 8, paint);
  }
}
