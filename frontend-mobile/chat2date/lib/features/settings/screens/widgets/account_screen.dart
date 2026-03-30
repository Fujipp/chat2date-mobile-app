import 'package:chat2date/components/common/app_raw_scrollbar.dart';
import 'package:chat2date/components/design_system/organisms/ds_app_secondary_header.dart';
import 'package:chat2date/components/inputs/ds_edit_input.dart';
import 'package:chat2date/components/inputs/ds_text_field/ds_text_field.dart';
import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/typography/body_text_styles.dart';
import 'package:chat2date/core/theme/tokens/typography/display_text_styles.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/emergency_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _phones = ['', '', ''];

  bool _isLoading = true;
  int _rebuildCounter = 0;

  @override
  void initState() {
    super.initState();
    _fetchEmergencyContacts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchEmergencyContacts() async {
    try {
      final service = ref.read(emergencyCallServiceProvider);
      final numbers = await service.getEmergencyCalls();

      setState(() {
        if (numbers.isNotEmpty) _phones[0] = _formatPhoneNumber(numbers[0]);
        if (numbers.length > 1) _phones[1] = _formatPhoneNumber(numbers[1]);
        if (numbers.length > 2) _phones[2] = _formatPhoneNumber(numbers[2]);
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.error,
        title: 'ผิดพลาด',
        message: 'ไม่สามารถดึงเบอร์โทรฉุกเฉินได้',
        durationSeconds: 3,
        showCountdown: false,
      );
    }
  }

  Future<void> _saveEmergencyContact(int index, String newValue) async {
    final tempPhones = List<String>.from(_phones);
    tempPhones[index] = newValue;

    final numbersToSend = tempPhones
        .map((phone) => phone.replaceAll('-', '').trim())
        .where((phone) => phone.isNotEmpty)
        .toList();

    if (numbersToSend.isEmpty) {
      Toast.show(
        context,
        type: ToastType.error,
        title: 'ผิดพลาด',
        message: 'กรุณากรอกเบอร์โทรฉุกเฉินอย่างน้อย 1 เบอร์',
        durationSeconds: 3,
        showCountdown: false,
      );
      setState(() => _rebuildCounter++);
      return;
    }

    _phones[index] = newValue;

    final filled = _phones
        .map((phone) => phone.replaceAll('-', '').trim())
        .where((phone) => phone.isNotEmpty)
        .toList();

    setState(() {
      for (int i = 0; i < 3; i++) {
        _phones[i] = i < filled.length ? _formatPhoneNumber(filled[i]) : '';
      }
      _rebuildCounter++;
    });

    try {
      final service = ref.read(emergencyCallServiceProvider);
      await service.updateEmergencyCalls(filled);
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.success,
        title: 'บันทึกสำเร็จ',
        message: 'เบอร์โทรฉุกเฉินได้รับการอัปเดตแล้ว',
        durationSeconds: 3,
        showCountdown: false,
      );
    } catch (_) {
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.error,
        title: 'ผิดพลาด',
        message: 'เกิดข้อผิดพลาดในการบันทึกเบอร์โทรฉุกเฉิน',
        durationSeconds: 3,
        showCountdown: false,
      );
    }
  }

  String _formatPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    if (cleanPhone.length == 10) {
      return '${cleanPhone.substring(0, 3)}-${cleanPhone.substring(3, 6)}-${cleanPhone.substring(6)}';
    }

    if (phone.startsWith('+66') && cleanPhone.length == 11) {
      return '+66 ${cleanPhone.substring(2, 4)}-${cleanPhone.substring(4, 7)}-${cleanPhone.substring(7)}';
    }

    return phone;
  }

  String _formatGender(Sex? sex) {
    switch (sex) {
      case Sex.MALE:
        return 'ชาย';
      case Sex.FEMALE:
        return 'หญิง';
      case null:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userStoreProvider);
    final user = userState['user'] as User?;

    final phoneNumber = _formatPhoneNumber(user?.phoneNumber ?? '');
    final email = user?.email ?? '';
    final birthDate = user?.birthday?.toIso8601String().split('T').first ?? '';
    final gender = _formatGender(user?.sex);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DsAppSecondaryHeader(
              variant: DsAppSecondaryHeaderVariant.baseText,
              title: 'บัญชี',
              onBackTap: () => Navigator.pop(context),
              center: Text(
                'บัญชี',
                style: AppDisplayTextStyles.h3.copyWith(
                  color: AppColors.textBlack,
                ),
              ),
              leading: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.brandSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              trailing: const SizedBox(width: 40, height: 40),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.brandSecondary,
                      ),
                    )
                  : AppRawScrollbar(
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 295),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ReadOnlyField(
                                  label: 'อีเมล',
                                  value: email,
                                  placeholder: 'support.chat2date@gmail.com',
                                ),
                                const SizedBox(height: 10),
                                _ReadOnlyField(
                                  label: 'หมายเลขโทรศัพท์',
                                  value: phoneNumber,
                                  placeholder: '+66 88-888-8888',
                                ),
                                const SizedBox(height: 10),
                                _ReadOnlyField(
                                  label: 'วันเกิด',
                                  value: birthDate,
                                  placeholder: '2000-10-10',
                                ),
                                const SizedBox(height: 10),
                                _ReadOnlyField(
                                  label: 'เพศ',
                                  value: gender,
                                  placeholder: 'ชาย',
                                ),
                                const SizedBox(height: 10),
                                EditInputField(
                                  key: ValueKey(
                                    'phone1_${_phones[0]}_$_rebuildCounter',
                                  ),
                                  label: 'เบอร์โทรฉุกเฉินลำดับที่ 1',
                                  placeholder: 'เพิ่มเบอร์โทรศัพท์',
                                  initialValue: _phones[0],
                                  keyboardType: TextInputType.phone,
                                  onSaved: (value) =>
                                      _saveEmergencyContact(0, value),
                                ),
                                const SizedBox(height: 10),
                                EditInputField(
                                  key: ValueKey(
                                    'phone2_${_phones[1]}_$_rebuildCounter',
                                  ),
                                  label: 'เบอร์โทรฉุกเฉินลำดับที่ 2',
                                  placeholder: 'เพิ่มเบอร์โทรศัพท์',
                                  initialValue: _phones[1],
                                  keyboardType: TextInputType.phone,
                                  onSaved: (value) =>
                                      _saveEmergencyContact(1, value),
                                ),
                                const SizedBox(height: 10),
                                EditInputField(
                                  key: ValueKey(
                                    'phone3_${_phones[2]}_$_rebuildCounter',
                                  ),
                                  label: 'เบอร์โทรฉุกเฉินลำดับที่ 3',
                                  placeholder: 'เพิ่มเบอร์โทรศัพท์',
                                  initialValue: _phones[2],
                                  keyboardType: TextInputType.phone,
                                  onSaved: (value) =>
                                      _saveEmergencyContact(2, value),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'หมายเหตุ : เบอร์โทรศัพท์ที่คุณกรอกจะเป็น เบอร์โทรฉุกเฉินแรก เมื่อกดปุ่ม SOS หากเว้นว่าง ระบบจะโทรไปยัง 191 อัตโนมัติ',
                                  style: AppBodyTextStyles.overline.copyWith(
                                    color: AppColors.error,
                                    height: 14 / 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.placeholder,
  });

  final String label;
  final String value;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return DsTextField(
      label: label,
      hintText: value.isNotEmpty ? value : placeholder,
      enabled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
