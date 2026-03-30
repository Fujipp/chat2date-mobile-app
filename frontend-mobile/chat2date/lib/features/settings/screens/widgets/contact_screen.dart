import 'package:chat2date/components/common/app_raw_scrollbar.dart';
import 'package:chat2date/components/design_system/buttons/ds_button.dart';
import 'package:chat2date/components/design_system/inputs/ds_dropdown_field.dart';
import 'package:chat2date/components/design_system/inputs/ds_text_area_field.dart';
import 'package:chat2date/components/design_system/inputs/ds_text_field.dart';
import 'package:chat2date/components/design_system/inputs/ds_text_field_props.dart';
import 'package:chat2date/components/design_system/organisms/ds_app_secondary_header.dart';
import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/typography/display_text_styles.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/contact_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  static const String routeName = '/contact';

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String? _selectedSubject;
  bool _isLoading = false;

  final List<String> _subjectOptions = [
    'ปัญหาด้านเทคนิค',
    'ข้อเสนอแนะ',
    'ฟีเจอร์ใหม่',
    'บัคหรือปัญหา',
    'ขอข้อมูล/หลักฐานเหตุฉุกเฉิน (SOS)',
    'อื่น ๆ',
  ];

  @override
  void initState() {
    super.initState();
    _prefillUserInfo();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _prefillUserInfo() {
    final user = ref.read(userStoreProvider)['user'] as User?;
    if (user == null) return;

    final firstname = user.firstname?.trim() ?? '';
    final lastname = user.lastname?.trim() ?? '';
    final fullName = [firstname, lastname].where((part) => part.isNotEmpty).join(
      ' ',
    );
    if (fullName.isNotEmpty) {
      _nameController.text = fullName;
    }
    if ((user.email ?? '').trim().isNotEmpty) {
      _emailController.text = user.email!.trim();
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool get _hasEmail {
    final user = ref.read(userStoreProvider)['user'] as User?;
    return (user?.email ?? '').trim().isNotEmpty;
  }

  bool get _hasName {
    final user = ref.read(userStoreProvider)['user'] as User?;
    final firstname = user?.firstname?.trim() ?? '';
    final lastname = user?.lastname?.trim() ?? '';
    return firstname.isNotEmpty || lastname.isNotEmpty;
  }

  String get _messageHintText {
    if (_selectedSubject == 'ขอข้อมูล/หลักฐานเหตุฉุกเฉิน (SOS)') {
      return 'โปรดระบุวันที่เกิดเหตุ หรือรายละเอียดสั้นๆ เพื่อให้ทีมงานตรวจสอบได้เร็วขึ้น';
    }
    return 'โปรดระบุรายละเอียดเพิ่มเติม';
  }

  bool get _canSubmit {
    return _selectedSubject != null && _messageController.text.trim().isNotEmpty;
  }

  void _resetFormAfterSuccess() {
    if (_hasName) {
      _prefillUserInfo();
    } else {
      _nameController.clear();
    }

    if (_hasEmail) {
      _prefillUserInfo();
    } else {
      _emailController.clear();
    }

    setState(() => _selectedSubject = null);
    _messageController.clear();
  }

  Future<void> _submitForm() async {
    if (!_canSubmit) {
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      Toast.show(
        context,
        type: ToastType.error,
        title: 'อีเมลไม่ถูกต้อง',
        message: 'รูปแบบอีเมลไม่ถูกต้อง',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(contactServiceProvider).sendContactMessage(
            contactName: _nameController.text.trim(),
            contactEmail: _emailController.text.trim(),
            subject: _selectedSubject!,
            message: _messageController.text.trim(),
          );

      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.success,
        title: 'ส่งข้อมูลสำเร็จ',
        message: 'ส่งข้อมูลติดต่อเรียบร้อย ทีมงานจะติดต่อกลับทางอีเมล',
      );
      _resetFormAfterSuccess();
    } catch (e) {
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.error,
        title: 'เกิดข้อผิดพลาด',
        message: 'เกิดข้อผิดพลาด: $e',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DsAppSecondaryHeader(
              variant: DsAppSecondaryHeaderVariant.baseText,
              title: 'ติดต่อ',
              onBackTap: () => Navigator.pop(context),
              center: Text(
                'ติดต่อ',
                style: AppDisplayTextStyles.h3.copyWith(
                  color: AppColors.textBlack,
                ),
              ),
              trailing: const SizedBox(width: 40, height: 40),
            ),
            Expanded(
              child: AppRawScrollbar(
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
                          DsTextField(
                            label: 'ชื่อ-นามสกุล',
                            controller: _nameController,
                            enabled: !_hasName,
                            hintText: 'กรอกชื่อ-นามสกุลของคุณ',
                            state: _hasName
                                ? DsInputVisualState.inactive
                                : null,
                          ),
                          const SizedBox(height: 10),
                          DsTextField(
                            label: 'อีเมล',
                            controller: _emailController,
                            enabled: !_hasEmail,
                            keyboardType: TextInputType.emailAddress,
                            hintText: 'กรอกอีเมลของคุณ',
                            state: _hasEmail
                                ? DsInputVisualState.inactive
                                : null,
                          ),
                          const SizedBox(height: 10),
                          DsDropdownField<String>(
                            label: 'หัวข้อ',
                            value: _selectedSubject,
                            hintText: 'เลือกหัวข้อที่ต้องการติดต่อ',
                            items: _subjectOptions
                                .map(
                                  (value) => DsDropdownItem<String>(
                                    value: value,
                                    label: value,
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedSubject = value);
                            },
                          ),
                          const SizedBox(height: 10),
                          DsTextAreaField(
                            label: 'อธิบาย',
                            controller: _messageController,
                            hintText: _messageHintText,
                            minLines: 4,
                            maxLines: 4,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: SizedBox(
                              width: 231,
                              child: DsButton(
                                label: _isLoading ? 'กำลังส่ง...' : 'ส่ง',
                                onPressed: (_isLoading || !_canSubmit)
                                    ? null
                                    : _submitForm,
                                variant: DsButtonVariant.primary,
                                size: DsButtonSize.md,
                              ),
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
