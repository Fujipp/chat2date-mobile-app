import 'package:flutter/material.dart';
import 'package:chat2date/components/buttons/ds_button.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  static const String routeName = '/contact';

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบครัน')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: API call to send contact form
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ส่งข้อมูลติดต่อเรียบร้อย')),
        );

        // Reset form
        _nameController.clear();
        _emailController.clear();
        _selectedSubject = null;
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
              keyboardType: TextInputType.text,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Placeholder',
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
                  borderSide: const BorderSide(
                    color: Color(0xFFE2E8F0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFE2E8F0),
                  ),
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
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Placeholder',
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
                  borderSide: const BorderSide(
                    color: Color(0xFFE2E8F0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFE2E8F0),
                  ),
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
              'เรื่อง',
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
              ),
              child: DropdownButton<String>(
                value: _selectedSubject,
                hint: const Text(
                  'Placeholder',
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 14,
                  ),
                ),
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Icon(
                    Icons.expand_more,
                    color: Color(0xFF5ce1e6),
                  ),
                ),
                items: _subjectOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSubject = newValue;
                  });
                },
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
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Placeholder',
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
                  borderSide: const BorderSide(
                    color: Color(0xFFE2E8F0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFE2E8F0),
                  ),
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
}
