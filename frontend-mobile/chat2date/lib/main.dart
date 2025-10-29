import 'package:flutter/material.dart';
import 'package:chat2date/components/inputs/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        // ใช้ seed ง่าย ๆ ไปก่อนไม่ชนกับระบบสีของ Dev
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7987AC)),
        // ถ้าอยากให้พื้นหลังสว่างขึ้น ให้ปรับค่านี้
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  // Controllers สำหรับตัวอย่างฟิลด์
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nextCtrl = TextEditingController();
  final _addCtrl = TextEditingController();
  final _selectCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _nextCtrl.dispose();
    _addCtrl.dispose();
    _selectCtrl.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() => _counter++);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === ตัวอย่างการใช้ Component Input ที่เราสร้าง ===

            // 1) Text + required
            DsTextField(
              label: 'Full name',
              required: true,
              hintText: 'John Appleseed',
              controller: _nameCtrl,
              prefixIcon: Icons.person_rounded,
            ),
            const SizedBox(height: 12),

            // 2) Disabled + hint (เช่นเบอร์โทร)
            DsTextField(
              label: 'Phone',
              hintText: '+66 88-888-8888',
              enabled: false,
              controller: _phoneCtrl,
              prefixIcon: Icons.phone_rounded,
            ),
            const SizedBox(height: 12),

            // 3) With suffix icon (arrow / add / chevron)
            DsTextField(
              label: 'Next step',
              required: true,
              controller: _nextCtrl,
              suffixIcon: Icons.arrow_forward_rounded,
              onSuffixTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Go next')));
              },
            ),
            const SizedBox(height: 12),

            DsTextField(
              label: 'Add item',
              required: true,
              controller: _addCtrl,
              suffixIcon: Icons.add_rounded,
            ),
            const SizedBox(height: 12),

            DsTextField(
              label: 'Select option',
              required: true,
              controller: _selectCtrl,
              suffixIcon: Icons.keyboard_arrow_down_rounded,
            ),
            const SizedBox(height: 16),

            // 4) OTP 6 ช่อง + support text (ตัวอย่าง)
            const DsOtpField(
              label: 'Verification code',
              required: true,
              supportText: 'We’ve sent a 6-digit code to your phone.',
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
