import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/card/preference_card.dart';
import 'package:chat2date/components/inputs/ds_label.dart';
import 'package:chat2date/components/inputs/ds_text_field/ds_text_field.dart';
import 'package:chat2date/components/layout/responsive_container.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MatchPreferenceScreen extends StatefulWidget {
  const MatchPreferenceScreen({super.key});

  @override
  State<MatchPreferenceScreen> createState() => _MatchPreferenceScreenState();
}

class _MatchPreferenceScreenState extends State<MatchPreferenceScreen> {
  RangeValues selectedRange = const RangeValues(18, 100);
  bool _isGenderAgeSpecific = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ResponsiveContainer.form(
          gap: 20,
          children: [
            const SizedBox(height: 30),
            Center(
              child: DsLabel(label: 'ประเภทคู่เดตที่สนใจ', labelFontSize: 32),
            ),

            const SizedBox(height: 10),
            DsTextField(
              label: 'เพศที่สนใจ*',
              required: true,
              labelFontSize: 20,
              suffixIcon: Icons.keyboard_arrow_down_rounded,
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
                      '${selectedRange.start.round()} ปี',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${selectedRange.end.round()} ปี',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 8,
                    activeTrackColor: const Color(0xFF6B7280),
                    inactiveTrackColor: const Color(0xFFE0E0E0),
                    thumbColor: const Color(0xFF6B7280),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    overlayColor: const Color(0xFF6B7280).withOpacity(0.2),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16,
                    ),
                    trackShape: const RoundedRectSliderTrackShape(),
                  ),
                  child: RangeSlider(
                    values: selectedRange,
                    min: 18,
                    max: 100,
                    divisions: 82,
                    onChanged: (RangeValues values) {
                      setState(() {
                        selectedRange = values;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 0),
            PreferenceCard(
              title: 'สไตล์การท่องเที่ยว',
              backgroundColor: AppColors.lightBrandSecondary,
            ),
            PreferenceCard(
              title: 'ไลฟ์สไตล์',
              backgroundColor: AppColors.brandPrimary200,
            ),
            PreferenceCard(
              title: 'ความสนใจ',
              backgroundColor: AppColors.surfaceLight,
            ),

            InkWell(
              onTap: () {
                setState(() {
                  _isGenderAgeSpecific = !_isGenderAgeSpecific;
                });
              },

              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
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
              label: 'ถัดไป',
              onPressed: () {},
              variant: DsButtonVariant.primary,
              size: DsButtonSize.md,
            ),
          ],
        ),
      ),
    );
  }
}
