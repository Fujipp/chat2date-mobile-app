import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/toasts/toast.dart';
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
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedSubject;
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  final List<String> _subjectOptions = [
    'ปัญหาด้านเทคนิค',
    'ข้อเสนอแนะ',
    'ฟีเจอร์ใหม่',
    'บัคหรือปัญหา',
    'อื่น ๆ',
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(userStoreProvider)['user'] as User?;
    if (user != null) {
      if (user.firstname != null && user.lastname != null) {
        _nameController.text = '${user.firstname} ${user.lastname}';
      }
      if (user.email != null && user.email!.isNotEmpty) {
        _emailController.text = user.email!;
      }
    }
  }

  bool get _hasEmail {
    final user =
        ref.read(userStoreProvider)['user'] as User?; // ← เพิ่ม as User?
    return user?.email != null && user!.email!.isNotEmpty;
  }

  bool get _hasName {
    final user =
        ref.read(userStoreProvider)['user'] as User?; // ← เพิ่ม as User?
    return user?.firstname != null && user?.lastname != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _selectedSubject == null ||
        _messageController.text.isEmpty) {
      Toast.show(
        context,
        type: ToastType.error,
        title: 'ข้อมูลไม่ครบถ้วน',
        message: 'กรุณากรอกข้อมูลให้ครบถ้วน',
      );
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
      await ref
          .read(contactServiceProvider)
          .sendContactMessage(
            contactName: _nameController.text.trim(),
            contactEmail: _emailController.text.trim(),
            subject: _selectedSubject!,
            message: _messageController.text.trim(),
          );

      if (mounted) {
        Toast.show(
          context,
          type: ToastType.success,
          title: 'ส่งข้อมูลสำเร็จ',
          message: 'ส่งข้อมูลติดต่อเรียบร้อย ทีมงานจะติดต่อกลับทางอีเมล',
        );
        _nameController.clear();
        _emailController.clear();
        setState(() => _selectedSubject = null);
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        Toast.show(
          context,
          type: ToastType.error,
          title: 'เกิดข้อผิดพลาด',
          message: 'เกิดข้อผิดพลาด: $e',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF98FB98),
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
        title: const Text(
          'Contact',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 22,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            const Text(
              'ชื่อ-นามสกุล',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              enabled: !_hasName,
              style: TextStyle(
                color: _hasName
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF0F172A),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: _fieldFillColor(_hasName), // ← สีเทาตอน disable
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                disabledBorder: OutlineInputBorder(
                  // ← เพิ่มตรงนี้
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF5ce1e6),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Email Field
            const Text(
              'อีเมล',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              enabled: !_hasEmail,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: _hasEmail
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF0F172A),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: !_hasEmail ? 'กรอกอีเมลของคุณ' : null,
                hintStyle: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: _fieldFillColor(_hasEmail),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF5ce1e6),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Subject Dropdown
            const Text(
              'หัวข้อ',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: ButtonTheme(
                  child: DropdownButton<String>(
                    value: _selectedSubject,
                    hint: const Text(
                      'เลือกหัวข้อที่ต้องการติดต่อ',
                      style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
                    ),
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(
                      16,
                    ), // ← มุมโค้ง dropdown list
                    dropdownColor: Colors.white, // ← สีพื้นหลัง dropdown
                    icon: const Padding(
                      padding: EdgeInsets.only(right: 12.0),
                      child: Icon(Icons.expand_more, color: Color(0xFF5ce1e6)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    items: _subjectOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() => _selectedSubject = newValue);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Message Field
            const Text(
              'อธิบาย',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 6,
              minLines: 4,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'โปรดระบุรายละเอียดเพิ่มเติม',
                hintStyle: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF5ce1e6),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Send Button
            SizedBox(
              width: double.infinity,
              child: DsButton(
                label: _isLoading ? 'กำลังส่ง...' : 'ส่ง',
                onPressed: _isLoading ? null : _submitForm,
                variant: DsButtonVariant.primary,
                size: DsButtonSize.md,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Color _fieldFillColor(bool disabled) =>
      disabled ? const Color(0xFFF1F5F9) : Colors.white;

  BorderSide _disabledBorderSide() =>
      const BorderSide(color: Color(0xFFE2E8F0));
}
