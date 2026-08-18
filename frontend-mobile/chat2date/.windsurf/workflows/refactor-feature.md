---
description: How to refactor a feature module into the features/ folder structure
---

# Refactor Feature Module

ใช้ workflow นี้เมื่อต้องการเพิ่ม feature ใหม่ หรือย้ายโค้ดเข้าสู่ `features/` folder

## Architecture Overview

```
lib/
├── app/                          ← App bootstrap, routing
│   ├── app.dart                  ← MyApp (ConsumerWidget)
│   └── router.dart               ← centralised route map, initialRoute = '/login'
├── core/                         ← Shared across all features
│   ├── config/                   ← backend_base.dart
│   ├── theme/                    ← app_theme, app_colors, tokens/
│   ├── utils/                    ← date_utils, location_permission, backend_datetime_parser
│   └── widgets/                  ← global_match_listener, global_user_listener
├── features/<name>/              ← One folder per feature
│   ├── screens/                  ← UI pages
│   ├── services/                 ← API / socket services
│   ├── controllers/              ← Business logic
│   ├── models/                   ← Feature-specific models (optional)
│   └── index.dart                ← Barrel file
├── components/                   ← Shared UI components
│   ├── design_system/            ← DS components (source of truth)
│   │   ├── index.dart            ← master barrel — import เดียวได้ทุก DS component
│   │   ├── buttons/              ← DsButton, DsButtonSchemes
│   │   ├── controls/             ← ProgressBar, Slider, Switcher, etc.
│   │   ├── feedback/             ← DsActionModal, DsStatusModal, DsToast
│   │   ├── inputs/               ← TextField, OtpField, SearchBar, etc.
│   │   ├── navigation/           ← DsBottomNavBar
│   │   └── organisms/            ← Headers, ChatCard, ChatThread, GpsAlert, etc.
│   ├── buttons/                  ← re-export wrappers → design_system/
│   ├── inputs/                   ← ds_label, ds_input_state + re-exports
│   ├── toasts/                   ← re-export → design_system/feedback/
│   ├── layout/                   ← header, menu_bar, responsive_container
│   ├── card/                     ← card_chat, generic_card, preference_card
│   ├── chat/                     ← bot_message, chat_text, content_switcher
│   ├── calendar/                 ← calendar_card, day_cell, modal
│   ├── common/                   ← loading, modal, style, image_upload
│   ├── dialogs/                  ← restore_account_dialog
│   ├── modal/                    ← feature_guide, relationship_mission
│   ├── page/                     ← unlock_date_modal
│   └── status_bar/               ← gps_alert, score_row
├── models/                       ← Global/shared models
├── services/                     ← Global/shared services
├── stores/                       ← Global Riverpod state (user_store, game_store)
└── main.dart                     ← Bootstrap only
```

## Steps to add/refactor a feature

### 1. Create feature folder
// turbo
```bash
mkdir -p lib/features/<name>/screens lib/features/<name>/services lib/features/<name>/controllers
```

### 2. Create screen files
สร้างไฟล์ screen ใน `lib/features/<name>/screens/`
- ใช้ `ConsumerWidget` หรือ `ConsumerStatefulWidget` (Riverpod)
- Import DS components จาก `package:chat2date/components/design_system/index.dart`
- Import theme จาก `package:chat2date/core/theme/...`
- Import config จาก `package:chat2date/core/config/...`

### 3. Create service files (if needed)
สร้างไฟล์ service ใน `lib/features/<name>/services/`
- ใช้ `@riverpod` annotation สำหรับ auto-generated provider
- Import config จาก `package:chat2date/core/config/backend_base.dart`

### 4. Create barrel file
สร้าง `lib/features/<name>/index.dart`:
```dart
export 'screens/screen_a.dart';
export 'services/my_service.dart';
```

### 5. Register routes in router.dart
เพิ่ม routes ใหม่ใน `lib/app/router.dart`:
```dart
// ─── <Feature Name> ──────────────────────────
'/<route>': (context) => const MyScreen(),
```

### 6. Verify
// turbo
```bash
flutter analyze --no-fatal-infos --no-fatal-warnings
```
ต้อง exit code 0 และไม่มี error ใหม่

## Import Conventions
```dart
// ✅ DS Components (ใช้ master barrel)
import 'package:chat2date/components/design_system/index.dart';

// ✅ Theme / Colors
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/app_theme.dart';

// ✅ Config
import 'package:chat2date/core/config/backend_base.dart';

// ✅ Cross-feature import
import 'package:chat2date/features/auth/controllers/auth_controller.dart';

// ✅ Shared models / stores
import 'package:chat2date/models/user.dart';
import 'package:chat2date/stores/user_store.dart';

// ❌ NEVER use relative imports across features
// ❌ import '../../auth/screens/home_login_page.dart';
```

## Naming Conventions
- **Feature folder**: lowercase, singular → `auth`, `chat`, `game`, `profile`
- **Screen files**: `snake_case_screen.dart` or `snake_case_page.dart`
- **Service files**: `snake_case_service.dart`
- **Controller files**: `snake_case_controller.dart`
- **Barrel files**: always `index.dart`
- **Route names**: lowercase, kebab-case → `/login`, `/kyc-id-ocr`, `/chat-list`

## Key Routes (Auth Flow)
```
/login          → HomeLoginPage (หน้าแรก)
/policy         → PolicyPage (ข้อตกลง)
/phone          → PhonePage (กรอกเบอร์โทร)
/otp            → OtpPage (กรอก OTP)
/kyc-id-ocr     → IdOcrScreen (สแกนบัตร)
/face-scan      → FaceVerifyScreen (ยืนยันใบหน้า)
/kyc-loading    → KycLoadingScreen
/kyc-result-*   → ผลลัพธ์ KYC
/main           → MainTabs (หน้าหลักหลัง login สำเร็จ)
```

## Current Feature Status
| Feature     | Status     | Location                    |
|-------------|------------|-----------------------------|
| auth        | migrated   | `features/auth/`            |
| chat        | migrated   | `features/chat/`            |
| discovery   | migrated   | `features/discovery/`       |
| game        | migrated   | `features/game/`            |
| match       | migrated   | `features/match/`           |
| menu        | migrated   | `features/menu/`            |
| profile     | migrated   | `features/profile/`         |
| report      | migrated   | `features/report/`          |
| settings    | migrated   | `features/settings/`        |
