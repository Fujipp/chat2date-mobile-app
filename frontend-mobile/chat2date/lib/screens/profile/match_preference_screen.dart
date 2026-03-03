import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/card/preference_card.dart';
import 'package:chat2date/components/common/custom_range_slider.dart';
import 'package:chat2date/components/inputs/ds_label.dart';
import 'package:chat2date/components/layout/responsive_container.dart';
import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchPreferenceScreen extends ConsumerStatefulWidget {
  const MatchPreferenceScreen({super.key});

  @override
  ConsumerState<MatchPreferenceScreen> createState() =>
      _MatchPreferenceScreenState();
}

class _MatchPreferenceScreenState extends ConsumerState<MatchPreferenceScreen> {
  RangeValues _selectedRange = const RangeValues(18, 100);
  bool _isGenderAgeSpecific = false;

  String? _travelStylePreference;
  String? _lifeStylePreference;
  String? _interestPreference;
  String? _selectedGenderPreference;

  @override
  void initState() {
    super.initState();

    final userStore = ref.read(userStoreProvider) as Map<String, dynamic>?;
    final profile = userStore?['profile'] as Map<String, dynamic>?;

    setState(() {
      _selectedGenderPreference = profile?['interestedGender'] ?? 'BOTH';
      _selectedRange = RangeValues(
        (profile?['interestedAgeMin'] as num?)?.toDouble() ?? 18,
        (profile?['interestedAgeMax'] as num?)?.toDouble() ?? 100,
      );

      _travelStylePreference = profile?['interestedTravelStyle'] ?? null;
      _lifeStylePreference = profile?['interestedLifeStyle'] ?? null;
      _interestPreference = profile?['interestedInterest'] ?? null;

      _isGenderAgeSpecific =
          (_interestPreference == "UNNECESSARY" &&
              _lifeStylePreference == "UNNECESSARY" &&
              _travelStylePreference == "UNNECESSARY")
          ? true
          : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    bool onUpdate = false;
    if (args is Map<String, dynamic>) {
      onUpdate = args['onUpdate'] as bool? ?? false;
    }

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: ResponsiveContainer.form(
              gap: 20,
              children: [
                SizedBox(height: onUpdate ? 10 : 30),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: onUpdate ? 52 : 0),
                    Expanded(
                      child: Center(
                        child: Text(
                          'ประเภทคู่เดตที่สนใจ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: onUpdate ? 52 : 0),
                  ],
                ),

                const SizedBox(height: 10),

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
                            style: TextStyle(fontSize: 20, color: Colors.red),
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

                  dropdownStyleData: const DropdownStyleData(
                    offset: Offset(0, 0),
                    direction: DropdownDirection.textDirection,
                  ),

                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('ผู้ชาย')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('ผู้หญิง')),
                    DropdownMenuItem(value: 'BOTH', child: Text('ได้ทั้งคู่')),
                  ],

                  onChanged: (value) {
                    setState(() {
                      _selectedGenderPreference = value;
                    });
                  },
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DsLabel(
                      label: 'ช่วงอายุที่สนใจ',
                      required: true,
                      labelFontSize: 20,
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedRange.start.round()} ปี',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${_selectedRange.end.round()} ปี',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    CustomRangeSlider(
                      values: _selectedRange,
                      min: 18,
                      max: 100,
                      onChanged: (RangeValues values) {
                        setState(() {
                          _selectedRange = values;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 0),
                PreferenceCard(
                  title: 'สไตล์การท่องเที่ยว',
                  backgroundColor: AppColors.lightBrandSecondary,
                  selectedValue: _isGenderAgeSpecific
                      ? 'UNNECESSARY'
                      : _travelStylePreference,
                  onChanged: _isGenderAgeSpecific
                      ? null
                      : (val) {
                          setState(() {
                            _travelStylePreference = val;
                          });
                        },
                  isDisabled: _isGenderAgeSpecific,
                ),
                PreferenceCard(
                  title: 'ไลฟ์สไตล์',
                  backgroundColor: AppColors.brandPrimary200,
                  selectedValue: _isGenderAgeSpecific
                      ? 'UNNECESSARY'
                      : _lifeStylePreference,
                  onChanged: _isGenderAgeSpecific
                      ? null
                      : (val) {
                          setState(() {
                            _lifeStylePreference = val;
                          });
                        },
                  isDisabled: _isGenderAgeSpecific,
                ),
                PreferenceCard(
                  title: 'สิ่งที่สนใจ',
                  backgroundColor: AppColors.surfaceLight,
                  selectedValue: _isGenderAgeSpecific
                      ? 'UNNECESSARY'
                      : _interestPreference,
                  onChanged: _isGenderAgeSpecific
                      ? null
                      : (val) {
                          setState(() {
                            _interestPreference = val;
                          });
                        },
                  isDisabled: _isGenderAgeSpecific,
                ),

                InkWell(
                  onTap: () {
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
                  },

                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _isGenderAgeSpecific
                                ? const Color(0xFF78CEFF)
                                : Colors.white,

                            border: Border.all(
                              width: 1,
                              color: _isGenderAgeSpecific
                                  ? const Color(0xFF78CEFF)
                                  : const Color(0xFFD1D5DB),
                            ),

                            borderRadius: BorderRadius.circular(2),
                          ),

                          child: _isGenderAgeSpecific
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18.0,
                                )
                              : null,
                        ),

                        const SizedBox(width: 12),

                        const Flexible(
                          child: Text(
                            'สนใจเฉพาะเพศและช่วงอายุ',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                DsButton(
                  label: onUpdate ? 'บันทึก' : 'ถัดไป',
                  onPressed: () async {
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
                    try {
                      final userStore =
                          ref.read(userStoreProvider) as Map<String, dynamic>?;

                      final Map<String, Object> preferenceMatch;

                      if (!onUpdate) {
                        preferenceMatch = {
                          "interestedGender": _selectedGenderPreference!,
                          "interestedAgeMax": _selectedRange.end,
                          "interestedAgeMin": _selectedRange.start,
                          "interestedTravelStyle": _travelStylePreference!,
                          "interestedLifeStyle": _lifeStylePreference!,
                          "interestedInterest": _interestPreference!,
                          "interestedDistanceMin": 0,
                          "interestedDistanceMax": 0,
                        };
                      } else {
                        preferenceMatch = {
                          "interestedGender": _selectedGenderPreference!,
                          "interestedAgeMax": _selectedRange.end,
                          "interestedAgeMin": _selectedRange.start,
                          "interestedTravelStyle": _travelStylePreference!,
                          "interestedLifeStyle": _lifeStylePreference!,
                          "interestedInterest": _interestPreference!,
                        };
                      }

                      final updatedUser = await ref
                          .read(userServiceProvider)
                          .addPreferenceMatchUser(preferenceMatch);
                      if (!onUpdate) {
                        Navigator.pushNamed(context, '/userPicture');
                      } else {
                        await ref.read(userServiceProvider).getProfile();
                        Navigator.pushNamed(context, '/settings');
                      }
                    } catch (e) {
                      throw Exception(e);
                    }
                  },
                  variant: DsButtonVariant.primary,
                  size: DsButtonSize.md,
                ),
              ],
            ),
          ),

          // ปุ่มย้อนกลับอยู่ซ้ายบน
          if (onUpdate)
            Positioned(
              top: 50,
              left: 16,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.brandSecondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
