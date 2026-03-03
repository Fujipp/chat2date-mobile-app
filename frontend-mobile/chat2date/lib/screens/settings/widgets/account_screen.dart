import 'package:chat2date/components/inputs/ds_edit_input.dart';
import 'package:chat2date/components/inputs/ds_text_field/ds_text_field.dart';
import 'package:flutter/material.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
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
          'Account',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DsTextField(
                label: 'หมายเลขโทรศัพท์',
                hintText: '+66 88-888-8888',
                enabled: false,
              ),

              const DsTextField(
                label: 'อีเมล',
                hintText: 'admin@kmutt.ac.th',
                enabled: false,
              ),

              const DsTextField(
                label: 'วันเกิด',
                hintText: '31 December 1999',
                enabled: false,
              ),

              const DsTextField(
                label: 'เพศ',
                hintText: 'MEN,WOMEN,LGBTQIA2S+',
                enabled: false,
              ),
              const SizedBox(height: 16),
              EditInputField(
                label: 'เบอร์ฉุกเฉินลำดับ 1',
                placeholder: '099-999-9999',
                initialValue: '099-999-9999',
                onSaved: (value) {},
              ),
              const SizedBox(height: 16),
              EditInputField(
                label: 'เบอร์ฉุกเฉินลำดับ 2',
                placeholder: 'เพิ่มเบอร์ที่นี่',
                onSaved: (value) {},
              ),
              const SizedBox(height: 16),
              EditInputField(
                label: 'เบอร์ฉุกเฉินลำดับ 3',
                placeholder: 'เพิ่มเบอร์ที่นี่',
                onSaved: (value) {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
