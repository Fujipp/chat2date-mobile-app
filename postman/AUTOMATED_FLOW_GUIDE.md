# Chat2Date - Automated Test Flow Guide 🚀

## วิธีใช้งาน (ง่ายมาก!)

### Step 1: Import Collection และ Environment

1. **Import Collection**:
   ```
   Postman → Import → Chat2Date_Automated_Flow.postman_collection.json
   ```

2. **Import Environment**:
   ```
   Postman → Import → Chat2Date_Local.postman_environment.json
   ```

3. **เลือก Environment**:
   - คลิก dropdown มุมขวาบน
   - เลือก `Chat2Date_Local`

### Step 2: ตั้งค่าตัวแปรเริ่มต้น

เปิด Environment `Chat2Date_Local` และตั้งค่า:

| Variable | Initial Value | ต้องตั้งหรือไม่ |
|----------|---------------|---------------|
| `baseURL` | `http://cp25ssi2.sit.kmutt.ac.th:8080/api/v1` | ✅ **จำเป็น** |
| `phoneNumber` | `0802249934` | ✅ **จำเป็น** |
| `otpCode` | `123456` | ⏳ **ตั้งทีหลัง** (หลังรับ SMS) |
| `latitude` | `13.7563` | 🔄 Auto (มี default) |
| `longitude` | `100.5018` | 🔄 Auto (มี default) |

### Step 3: Run Collection!

#### วิธีที่ 1: Run ทั้ง Collection (แนะนำ)

1. คลิกขวาที่ Collection `Chat2Date - Automated Test Flow`
2. เลือก **Run Collection**
3. ตั้งค่า Runner:
   ```
   ✅ Save responses
   ✅ Persist variables
   ⚙️ Delay: 500ms (ถ้าต้องการ)
   ```
4. คลิก **Run Chat2Date - Automated Test Flow**

#### วิธีที่ 2: Run แบบ Manual (ทีละ Request)

1. เปิดที่ `Setup & Authentication`
2. Run `1. Request OTP` → รอ SMS
3. ใส่ `otpCode` ใน Environment
4. Run `2. Verify OTP` → auto-save tokens
5. ที่เหลือ run ต่อเนื่องได้เลย (ไม่ต้องตั้งค่าอะไร)

---

## 🎯 Test Flow Breakdown

### Phase 1: Authentication (ต้องทำ Manual)
```
Request OTP → รับ SMS → ใส่ otpCode → Verify OTP
    ↓             ↓           ↓              ↓
  200 OK    "123456"    SET VARIABLE   auto-save tokens
```

### Phase 2-5: Automated! (ไม่ต้องทำอะไร)
```
Get Profile → Update Profile → Get Preferences → Set Preferences
     ↓              ↓                ↓                 ↓
Auto-save       Auto-increment   Test Success     Test Success
  version         version
```

### Phase 6: Location Tests (Automated)
```
Update Location → Test Empty Body → Test Invalid Lat → Test Invalid Lon
       ↓                 ↓                 ↓                  ↓
  200 Success       400 Error         400 Error         400 Error
```

### Phase 7: Error Handling (Automated)
```
Test 401 → Test 403 → Test 412
    ↓          ↓          ↓
No Token   Other User  Wrong Version
```

### Phase 8: Token Management (Automated)
```
Refresh Token → Logout
      ↓            ↓
Auto-save    Clear Session
```

---

## ⚙️ Auto-Saved Variables

Collection จะ **auto-save** ตัวแปรเหล่านี้:

| Variable | Saved From | Saved By |
|----------|------------|----------|
| `token` | Request OTP response | Test script |
| `accessToken` | Verify OTP response | Test script |
| `refreshToken` | Verify OTP response | Test script |
| `userId` | Verify OTP response | Test script |
| `id` | Verify OTP response | Test script |
| `userVersion` | Get Profile response | Test script |
| `nextVersion` | Auto-calculated | Pre-request script |
| `otherUserId` | Fake ID for testing | Pre-request script |

**ไม่ต้องตั้งเอง!** Scripts จะจัดการให้อัตโนมัติ 🎉

---

## 📝 Manual Setup (ทำแค่ครั้งเดียว)

### ตัวแปรที่ต้องตั้งเอง:

1. **baseURL** (จำเป็น):
   ```
   http://cp25ssi2.sit.kmutt.ac.th:8080/api/v1
   หรือ
   http://localhost:8080/api/v1
   ```

2. **phoneNumber** (จำเป็น):
   ```
   0802249934  (หรือเบอร์ของคุณ)
   ```

3. **otpCode** (ตั้งหลังรับ SMS):
   ```
   123456  (OTP จริงจาก SMS)
   ```

### Optional Variables:

```javascript
latitude: 13.7563      // Default: Bangkok
longitude: 100.5018    // Default: Bangkok
min_distance: 1        // Default: 1 km
max_distance: 10       // Default: 10 km
```

---

## 🔍 Test Scripts คืออะไร?

### 1. Pre-request Script (ก่อนส่ง request)
```javascript
// ตัวอย่าง: Auto-set default values
if (!pm.environment.get('phoneNumber')) {
    pm.environment.set('phoneNumber', '0802249934');
}
```

### 2. Test Script (หลังได้ response)
```javascript
// ตัวอย่าง: Auto-save token
if (pm.response.code === 200) {
    const jsonData = pm.response.json();
    pm.environment.set('accessToken', jsonData.accessToken);
}
```

### 3. Collection-level Script (ทุก request)
```javascript
// Global setup ที่ run ทุกครั้ง
console.log('🚀 Starting request:', pm.info.requestName);
```

---

## 🎯 Key Features

### ✅ Auto-Save Tokens
```javascript
// ไม่ต้องคัดลอก-วาง token เอง!
Verify OTP → Auto-save accessToken, refreshToken, userId
```

### ✅ Auto-Increment Version
```javascript
// ไม่ต้องคำนวณ version เอง!
Pre-request Script → Get current version → +1 → Use in body
```

### ✅ Smart Defaults
```javascript
// ไม่มีค่า? ใช้ default!
if (!pm.environment.get('latitude')) {
    pm.environment.set('latitude', '13.7563');
}
```

### ✅ Detailed Logging
```
Console output:
✅ Token saved: abc123...
⏳ Please check SMS for OTP
✅ Access Token saved
✅ User ID saved: 1234-5678-...
✅ Profile updated, new version: 2
```

---

## 🚦 Status Code Tests

ทุก request มี automated tests:

```javascript
pm.test('Status is 200', function() {
    pm.response.to.have.status(200);
});

pm.test('Response has required fields', function() {
    const jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('userId');
});
```

### Expected Status Codes:

| Request | Success | Error Cases |
|---------|---------|-------------|
| Request OTP | 200 | 429 (rate limit) |
| Verify OTP | 200 | 422 (wrong OTP) |
| Get Profile | 200 | 401, 403, 404 |
| Update Profile | 200 | 400, 401, 403, 412 |
| Preferences | 200 | 401 |
| Location Update | 200 | 400 (invalid coords) |
| Refresh Token | 200 | 401 |

---

## 🐛 Troubleshooting

### ❌ Problem: "otpCode not set"
```
⚠️ WARNING: otpCode not set. Please set it manually!
💡 TIP: Set otpCode variable from the SMS you received
```

**Solution**:
1. Run `1. Request OTP`
2. Check SMS for OTP code
3. Open Environment → Set `otpCode` = `123456`
4. Run `2. Verify OTP`

---

### ❌ Problem: "401 Unauthorized"
```
Status: 401
Error: "JWT expired" หรือ "Invalid token"
```

**Solution**:
1. Run `14. Refresh Token` (ใน Token Management folder)
2. หรือ Login ใหม่ (Run `1-2` ใหม่)

---

### ❌ Problem: "412 Precondition Failed"
```
Status: 412
Error: "Version mismatch"
```

**Solution**:
1. Run `3. Get Own Profile` ใหม่ → auto-save latest version
2. Run `4. Update Profile` อีกครั้ง

---

### ❌ Problem: "baseURL is not defined"
```
Error: getaddrinfo ENOTFOUND {{baseURL}}
```

**Solution**:
1. เปิด Environment `Chat2Date_Local`
2. ตั้ง `baseURL` = `http://cp25ssi2.sit.kmutt.ac.th:8080/api/v1`
3. Save Environment
4. Refresh Postman

---

## 📊 Test Results Interpretation

### ✅ All Green (Pass)
```
✅ Status is 200
✅ Profile has required fields
✅ Token saved
```
**→ Request สำเร็จ! ไปต่อได้**

### ⚠️ Some Orange (Warning)
```
⚠️ otpCode not set
```
**→ ต้องตั้งค่าเพิ่ม**

### ❌ Red (Fail)
```
❌ Status is 200 | AssertionError: expected 401 to equal 200
```
**→ มีปัญหา ดู error message**

---

## 🎓 Advanced: Collection Runner Settings

### Optimal Settings:
```
✅ Save responses        (เก็บ response ไว้ดู)
✅ Persist variables     (เก็บค่าตัวแปร)
⚙️ Delay: 500ms          (ถ้า API rate limit)
⚙️ Iterations: 1         (run ครั้งเดียว)
⚙️ Data file: (none)     (ไม่ใช้ CSV)
```

### Run Specific Folders:
```
Setup & Authentication     → Run ก่อน (ได้ tokens)
User Profile Tests         → Run ต่อ (ใช้ tokens)
Preferences Tests          → Run ต่อ
Location Tests             → Run ต่อ
Error Handling Tests       → Run ต่อ
Token Management           → Run ต่อ
Rate Limit Tests          → Run แยก (จะทำให้ rate limit)
```

---

## 🔄 Re-run Strategy

### First Run (Cold Start):
```
1. Set baseURL, phoneNumber
2. Run "Setup & Authentication" folder
3. Wait for SMS → Set otpCode
4. Continue with step 2
5. Run remaining folders
```

### Subsequent Runs (Warm):
```
1. Skip Setup if tokens still valid
2. Run "User Profile Tests" onwards
3. If 401 error → Run "Token Management → Refresh Token"
```

### Daily Testing:
```
Morning:   Run full collection (15 requests)
Bug Fix:   Run specific folder only
Afternoon: Run "Rate Limit Tests" separately
```

---

## 📱 Mobile App Integration

Collection นี้ test **Backend API** ส่วนเดียว

Frontend mobile tests (ไม่อยู่ใน Collection):
- C2D 8-2: Face detection UI
- C2D 13: Profile validation
- C2D 19: GPS permission
- C2D 20: GPS disabled
- C2D 29: Profile edit validation

**Note**: ใช้ Flutter integration tests สำหรับ UI tests

---

## 🎉 Summary

### ที่ต้องทำ Manual:
1. ✅ ตั้ง `baseURL`, `phoneNumber` (ครั้งเดียว)
2. ✅ Run Request OTP
3. ✅ ใส่ `otpCode` จาก SMS
4. ✅ Run Verify OTP

### ที่ Auto ให้:
1. 🔄 Save tokens (accessToken, refreshToken)
2. 🔄 Save user ID
3. 🔄 Save version numbers
4. 🔄 Increment versions
5. 🔄 Set default coordinates
6. 🔄 Validate responses
7. 🔄 Log progress

### จำนวน Tests:
- ✅ 17 requests
- ✅ 30+ automated tests
- ✅ 10+ auto-saved variables
- ✅ 100% API coverage (main flows)

---

## 🚀 Quick Start Checklist

```
□ Import Collection
□ Import Environment
□ Select Environment
□ Set baseURL
□ Set phoneNumber
□ Click Run Collection
□ Wait for "otpCode not set" message
□ Check SMS
□ Set otpCode in Environment
□ Continue run (or run step 2 manually)
□ Watch tests pass! 🎉
```

**Time to complete**: ~2 minutes (รวมรอ SMS)

---

## 💡 Pro Tips

1. **Use Console**: เปิด Console (Ctrl+Alt+C) เพื่อดู logs
   ```
   ✅ Token saved: abc123...
   ✅ User ID saved: 1234-5678-...
   ```

2. **Save Responses**: Enable "Save responses" ใน Runner
   - จะได้ดู response body ย้อนหลัง

3. **Environment Variables**: ใช้ `{{variable}}` ในทุกที่
   ```json
   {
     "userId": "{{id}}",
     "version": {{nextVersion}}
   }
   ```

4. **Test Scripts**: ตรวจสอบใน Tests tab
   ```javascript
   // See what's auto-saved
   console.log('Saved token:', pm.environment.get('accessToken'));
   ```

5. **Delay Between Requests**: ถ้า API มี rate limit
   ```
   Runner → Delay: 1000ms
   ```

---

**Ready to test?** Import และกด Run เลย! 🚀
