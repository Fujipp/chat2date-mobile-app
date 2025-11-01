import 'package:flutter/material.dart';
import 'package:chat2date/components/inputs/index.dart';
import 'package:chat2date/theme/app_theme.dart';
import 'package:chat2date/components/calendar/index.dart';
import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/buttons/ds_icon_button.dart';

// Status Bar components
import 'package:chat2date/components/status_bar/score_row.dart';
import 'package:chat2date/components/status_bar/stacked_progress_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: buildLightTheme(),
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
            // === Inputs ===
            DsTextField(
              label: 'Full name',
              required: true,
              hintText: 'John Appleseed',
              controller: _nameCtrl,
              prefixIcon: Icons.person_rounded,
            ),
            const SizedBox(height: 12),

            DsTextField(
              label: 'Phone',
              hintText: '+66 88-888-8888',
              enabled: false,
              controller: _phoneCtrl,
              prefixIcon: Icons.phone_rounded,
            ),
            const SizedBox(height: 12),

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

            const DsOtpField(
              label: 'Verification code',
              required: true,
              supportText: 'We’ve sent a 6-digit code to your phone.',
            ),

            const SizedBox(height: 24),

            // === Calendar ===
            CalendarCard(
              initialMonth: DateTime(2026, 1, 1),
              initialTime: const TimeOfDay(hour: 12, minute: 0),
              accentColor: const Color(0xFFFF6B81),
              onClose: () => Navigator.of(context).maybePop(),
              onSave: (date, time) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Saved: $date (${time.format(context)})'),
                  ),
                );
              },
            ),

            // === Status Bars ===
            const SizedBox(height: 24),
            Text('Status Bars', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Container(
              width: 362,
              padding: const EdgeInsets.all(20),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFF9747FF)),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScoreRow(
                    heartAsset: 'assets/icons/icon_heart_status.svg',
                    segments: [
                      ProgressSegment(percent: 0.27, color: Color(0xFFFF8FB3)),
                      ProgressSegment(percent: 0.34, color: Color(0xFFFFD166)),
                    ],
                  ),
                  SizedBox(height: 12),
                  ScoreRow(
                    heartAsset: 'assets/icons/icon_heart_status.svg',
                    segments: [
                      ProgressSegment(percent: 0.35, color: Color(0xFFFF8FB3)),
                    ],
                  ),
                  SizedBox(height: 12),
                  ScoreRow(
                    leading: ScoreLeading.number,
                    numberText: '1',
                    segments: [
                      ProgressSegment(percent: 0.50, color: Color(0xFFFF8FB3)),
                    ],
                  ),
                  SizedBox(height: 12),
                  ScoreRow(
                    leading: ScoreLeading.number,
                    numberText: '2',
                    segments: [
                      ProgressSegment(percent: 0.74, color: Color(0xFFFF8FB3)),
                    ],
                  ),
                  SizedBox(height: 12),
                  ScoreRow(
                    leading: ScoreLeading.none,
                    segments: [
                      ProgressSegment(
                        percent: 0.60,
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFFC8A2E7),
                            Color(0xFF9FBBFF),
                            Color(0xFFA7EAF2),
                            Color(0xFFB7E4C7),
                            Color(0xFFFFF1A8),
                            Color(0xFFFFD1A6),
                            Color(0xFFFFB3B3),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // === Buttons ===
            const SizedBox(height: 24),
            Text('Buttons', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                DsButton(
                  label: 'Primary',
                  onPressed: () {},
                  variant: DsButtonVariant.primary,
                ),
                DsButton(
                  label: 'Primary (disabled)',
                  onPressed: null,
                  variant: DsButtonVariant.primary,
                ),
                DsButton(
                  label: 'Error',
                  onPressed: () {},
                  variant: DsButtonVariant.error,
                ),
                DsButton(
                  label: 'Error (disabled)',
                  onPressed: null,
                  variant: DsButtonVariant.error,
                ),
                DsButton(
                  label: 'Secondary',
                  onPressed: () {},
                  variant: DsButtonVariant.secondary,
                ),
                DsButton(
                  label: 'Secondary (disabled)',
                  onPressed: null,
                  variant: DsButtonVariant.secondary,
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              'Accent (Outline / Filled)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                DsButton(
                  label: 'Accent Outline',
                  onPressed: () {},
                  variant: DsButtonVariant.accentOutline,
                ),
                DsButton(
                  label: 'Accent Filled',
                  onPressed: () {},
                  variant: DsButtonVariant.accentFilled,
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              'Outline Primary',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                DsButton(
                  label: 'Outline (SM)',
                  onPressed: () {},
                  variant: DsButtonVariant.outlinePrimary,
                  size: DsButtonSize.sm,
                ),
                DsButton(
                  label: 'Outline (MD)',
                  onPressed: () {},
                  variant: DsButtonVariant.outlinePrimary,
                  size: DsButtonSize.md,
                ),
                DsButton(
                  label: 'Outline (LG)',
                  onPressed: () {},
                  variant: DsButtonVariant.outlinePrimary,
                  size: DsButtonSize.lg,
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              'With Icons + Full width',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DsButton(
                  label: 'Continue',
                  onPressed: () {},
                  variant: DsButtonVariant.primary,
                  leading: const Icon(Icons.play_arrow_rounded, size: 20),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: DsButton(
                    label: 'Next',
                    onPressed: () {},
                    variant: DsButtonVariant.accentFilled,
                    trailing: const Icon(Icons.arrow_forward_rounded, size: 20),
                  ),
                ),
              ],
            ),

            // === SVG Icon Buttons (Hover Glow) ===
            const SizedBox(height: 24),
            Text(
              'SVG Icon Buttons (Hover Glow)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),

            // กล่องเดโม 171x100: หัวใจ (filled) + กากบาท (outline)
            Container(
              width: 171,
              height: 100,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFF8A38F5)),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 20,
                    top: 20,
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: DsIconButton.filled(
                        svgAsset: 'assets/icons/icon_heart_status.svg',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Heart tapped')),
                          );
                        },
                        size: 60,
                        radius: 999,
                        baseBg: const Color(0xFFFF6B81),
                        baseIcon: Colors.white,
                        hoverBg: const Color(0x14FF6B81),
                        hoverIcon: Colors.white,
                        hoverGlow: const [
                          BoxShadow(blurRadius: 16, color: Color(0x33FF6B81)),
                        ],
                        pressedBg: const Color(0x1FFF6B81),
                        pressedIcon: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 91,
                    top: 20,
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: DsIconButton.outline(
                        svgAsset: 'assets/icons/close.svg',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Close tapped')),
                          );
                        },
                        size: 60,
                        radius: 999,
                        baseIcon: const Color(0xFF5CE1E6),
                        baseBorder: const Color(0xFF5CE1E6),
                        hoverBg: const Color(0x145CE1E6),
                        hoverIcon: const Color(0xFF5CE1E6),
                        hoverGlow: const [
                          BoxShadow(blurRadius: 16, color: Color(0x335CE1E6)),
                        ],
                        pressedBg: const Color(0x1F5CE1E6),
                        pressedIcon: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                DsIconButton.filled(
                  svgAsset: 'assets/icons/icon_heart_status.svg',
                  onPressed: () {},
                  size: 60,
                  radius: 999,
                  baseBg: const Color(0xFFFF6B81),
                  baseIcon: Colors.white,
                  hoverBg: const Color(0x14FF6B81),
                  hoverIcon: Colors.white,
                  hoverGlow: const [
                    BoxShadow(blurRadius: 16, color: Color(0x33FF6B81)),
                  ],
                  pressedBg: const Color(0x1FFF6B81),
                  pressedIcon: Colors.white,
                ),
                const SizedBox(width: 12),
                DsIconButton.outline(
                  svgAsset: 'assets/icons/close.svg',
                  onPressed: () {},
                  size: 60,
                  radius: 999,
                  baseIcon: const Color(0xFF5CE1E6),
                  baseBorder: const Color(0xFF5CE1E6),
                  hoverBg: const Color(0x145CE1E6),
                  hoverIcon: const Color(0xFF5CE1E6),
                  hoverGlow: const [
                    BoxShadow(blurRadius: 16, color: Color(0x335CE1E6)),
                  ],
                  pressedBg: const Color(0x1F5CE1E6),
                  pressedIcon: Colors.white,
                ),
              ],
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
