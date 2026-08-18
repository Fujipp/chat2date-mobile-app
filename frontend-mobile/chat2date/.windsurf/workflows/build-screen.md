---
description: How to build a new screen page inside a feature module
---

# Build New Screen

ใช้ workflow นี้เมื่อต้องการสร้างหน้าจอใหม่ภายใน feature ที่มีอยู่แล้ว

## User Preferences
- ตอบสั้นๆ เน้นแก้ไขไฟล์ ไม่ต้องอธิบายยาว
- ทุกหน้าจัดให้อยู่**ตรงกลาง** (Center) เสมอ
- ใช้ DS components จาก `design_system/` แทนของเดิมทั้งหมด
- user จะให้ Figma code export มา → แปลงเป็น Flutter ที่ใช้ DS components
- ตัด status bar / device frame ออกจาก Figma code เสมอ
- Button variants: **outlinePrimary** = ไม่มีพื้นหลัง (border pink), **primary** = มีพื้นหลัง (filled pink)

## Pre-requisites
- Feature folder ต้องมีอยู่แล้วใน `lib/features/<feature>/`
- ถ้ายังไม่มี ให้ใช้ `/refactor-feature` สร้างก่อน

## Steps

### 1. สร้างไฟล์ screen
สร้างไฟล์ใน `lib/features/<feature>/screens/<screen_name>.dart`

Template:
```dart
import 'package:chat2date/components/design_system/index.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // content here
            ],
          ),
        ),
      ),
    );
  }
}
```

ถ้าต้องการ state ภายใน ให้ใช้ `ConsumerStatefulWidget`:
```dart
class MyScreen extends ConsumerStatefulWidget {
  const MyScreen({super.key});
  @override
  ConsumerState<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }
}
```

### 2. เพิ่มใน barrel file
อัพเดท `lib/features/<feature>/screens/index.dart`:
```dart
export '<screen_name>.dart';
```

### 3. เพิ่ม route (ถ้าเป็นหน้าที่ navigate ได้)
อัพเดท `lib/app/router.dart`:
```dart
'/<route-name>': (context) => const MyScreen(),
```

ถ้า route ต้องรับ arguments:
```dart
'/<route-name>': (context) {
  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  return MyScreen(id: args?['id']);
},
```

### 4. Verify
// turbo
```bash
flutter analyze --no-fatal-infos --no-fatal-warnings
```

## Figma → Flutter Conversion Rules
1. ตัด device frame, status bar, border ออกเสมอ
2. แปลง hardcoded Container+Stack+Positioned ให้เป็น Scaffold+SafeArea+Center+Column
3. แปลง hardcoded button Container ให้ใช้ DsButton + variant ที่เหมาะสม
4. แปลง hardcoded text input ให้ใช้ DsTextField / DsOtpField
5. ใช้ SvgPicture.asset() สำหรับ SVG icons/logos
6. spacing ระหว่าง elements ใช้ SizedBox(height: N)
7. ทุก layout ต้อง Center อยู่กลางจอ

## DS Component Quick Reference
```dart
// ─── Buttons ───────────────────────────────
// Outline (ไม่มีพื้นหลัง)
DsButton(label: '...', variant: DsButtonVariant.outlinePrimary, size: DsButtonSize.md, onPressed: () {})

// Filled (มีพื้นหลัง pink)
DsButton(label: '...', variant: DsButtonVariant.primary, size: DsButtonSize.md, onPressed: () {})

// Filled green (accept)
DsButton(label: '...', variant: DsButtonVariant.secondary, size: DsButtonSize.md, onPressed: () {})

// Filled red (error/deny)
DsButton(label: '...', variant: DsButtonVariant.error, size: DsButtonSize.md, onPressed: () {})

// ─── Inputs ────────────────────────────────
DsTextField(label: '...', hintText: '...', controller: ctrl, onChanged: (v) {})
DsOtpField(label: '...', length: 6, onCompleted: (code) {})
DsSearchBar(hintText: '...', onChanged: (v) {})
DsDropdownField<String>(items: [...], label: '...', onChanged: (v) {})
EditInputField(label: '...', placeholder: '...', onSaved: (v) {})
DsTextAreaField(label: '...', hintText: '...')

// ─── Feedback ──────────────────────────────
Toast.show(context, type: ToastType.error, title: '...', message: '...');
DsActionModal.show(context, child: DsActionModal(title: '...', ...));
DsStatusModal.show(context, type: DsStatusModalType.success, title: '...', message: '...');

// ─── Controls ──────────────────────────────
DsSegmentedSwitcher(items: ['A', 'B'], selectedIndex: 0, onChanged: (i) {})
DsSlider(value: 50, onChanged: (v) {})
DsReactionButton(type: DsReactionButtonType.match, onTap: () {})
DsProgressRing(value: 0.75)
DsLevelProgressBar(level: 3, progress: 0.6)

// ─── Organisms ─────────────────────────────
DsAppHomeHeader(title: 'Chat To Date', onActionTap: () {})
DsAppSecondaryHeader(variant: DsAppSecondaryHeaderVariant.base, title: '...', onBackTap: () {})
DsChatCard(title: '...', subtitle: '...', onTap: () {})
DsChatThread(messages: [...])
DsBotChat(type: DsBotChatType.minigame, ...)
DsSpinWheelCard(items: [...])
DsCalendarScheduler(placeName: '...')
CustomBottomNavBar(selectedIndex: 0, onTap: (i) {})
```

### Navigation
```dart
Navigator.pushNamed(context, '/route');
Navigator.pushNamed(context, '/route', arguments: {'key': 'value'});
Navigator.pushReplacementNamed(context, '/route');
Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
```

### Access Riverpod state
```dart
final user = ref.read(userStoreProvider)['user'] as User?;
final accessToken = ref.read(userStoreProvider.notifier).accessToken;
final userState = ref.watch(userStoreProvider);
final authService = ref.read(authServiceProvider);
```

## Font Families
- **Inter** — default (English text)
- **IBMPlexSansThai** — Thai text (Regular 400, SemiBold 600, Bold 700)
- **Itim** — decorative (Regular 400)
