# Chat2Date - Test Cases Mapping Guide

## Overview
This document maps the test cases from the requirements to the existing Postman collection structure.

---

## Environment Variables

### Required Variables (Chat2Date_Local environment)

| Variable | Description | Example Value | Used In |
|----------|-------------|---------------|---------|
| `baseURL` | Backend API base URL | `http://cp25ssi2.sit.kmutt.ac.th:8080/api/v1` | All requests |
| `phoneNumber` | Test phone number | `0802249934` | OTP Auth |
| `token` | Temporary token from request | Auto-set | OTP Auth |
| `otpCode` | OTP code from SMS | `123456` | OTP Verify |
| `accessToken` | JWT access token | Auto-set from login | Protected endpoints |
| `refreshToken` | JWT refresh token | Auto-set from login | Token refresh |
| `id` | User ID for operations | Auto-set or manual | CRUD operations |
| `identifier` | Email or phone for token request | `user@example.com` | Auth |
| `user_001_phone` | User 001 phone | `0802249934` | C2D 1-4, 30 |
| `user_002_email` | User 002 Gmail | `varittorn.siri@mail.kmutt.ac.th` | C2D 5-6, 31 |
| `user_003_email` | User 003 Gmail | `hutchlovenee2@gmail.com` | C2D 7-29 |
| `admin_001_phone` | Admin phone | `0626237630` | C2D 9 |
| `test_phone_new` | New phone for testing | `0626434165` | C2D 3-4 |
| `google_id_token` | Google OAuth token | From Google Sign-In | C2D 5-6, 31 |
| `fcm_token` | Firebase token | From mobile app | C2D 26-27 |
| `latitude` | GPS latitude | `13.7563` | C2D 18-22 |
| `longitude` | GPS longitude | `100.5018` | C2D 18-22 |
| `min_distance` | Min distance filter | `1` | C2D 23-25 |
| `max_distance` | Max distance filter | `10` | C2D 23-25 |

---

## Test Cases Mapping

### PBI 1: OTP Authentication (Folder: C2D1 - C2D4)

#### C2D 1: Register with OTP (Success) ✅
**Mapped to**: `Auth (Send OTP) (200)` + `Auth (Verify OTP) (200)`

**Step 1 - Request OTP**:
```
POST {{baseURL}}/auth/request-otp
Body: { "phoneNumber": "{{phoneNumber}}" }
```
**Variables**:
- Set `phoneNumber` = `0802249934` (user-001)
- Expected: 200, returns token

**Step 2 - Verify OTP**:
```
POST {{baseURL}}/auth/verify-otp
Body: { 
  "phoneNumber": "{{phoneNumber}}",
  "token": "{{token}}",
  "otpCode": "{{otpCode}}"
}
```
**Variables**:
- Set `otpCode` from SMS or backend log
- Expected: 200, returns `accessToken` and `refreshToken`

**Post-Test Script**:
```javascript
pm.test('Status 200', () => pm.response.to.have.status(200));
const jsonData = pm.response.json();
if (jsonData.accessToken) {
    pm.environment.set('accessToken', jsonData.accessToken);
}
if (jsonData.refreshToken) {
    pm.environment.set('refreshToken', jsonData.refreshToken);
}
```

---

#### C2D 2: Register with Existing Phone ⚠️
**Status**: Needs implementation
**Expected**: 200 or 409 (phone already registered)
**Action**: Add test script to check for "already registered" message

---

#### C2D 3: Incorrect OTP (Failed) ✅
**Mapped to**: `Auth (Verify OTP) (422)`

**Setup**:
- Use `phoneNumber` = `0626434165`
- Set `otpCode` = `000000` (wrong code)

**Expected**: 422 Unprocessable Entity

---

#### C2D 4: Too Many OTP Requests (Failed) ✅
**Mapped to**: `Auth (Send OTP) (429)`

**Setup**:
- Call `Auth (Send OTP)` repeatedly (>5 times within 15 minutes)

**Expected**: 429 Too Many Requests

---

#### C2D 30: Login with OTP (Success) ✅
**Mapped to**: Same as C2D 1
- Use existing registered phone
- Same steps as C2D 1

---

### PBI 2: Google Authentication

#### C2D 5: Register with Google (Success) ❌
**Status**: NOT in collection
**Needs**: Add request
```
POST {{baseURL}}/auth/google
Body: { "idToken": "{{google_id_token}}" }
Expected: 200
```

#### C2D 6: Empty idToken (Failed) ❌
**Status**: NOT in collection
**Needs**: Add request with empty idToken
```
POST {{baseURL}}/auth/google
Body: { "idToken": "" }
Expected: 400
```

#### C2D 31: Login with Google (Success) ❌
**Status**: NOT in collection
**Same as**: C2D 5 with existing user

---

### PBI 3: Face Verification

#### C2D 7-8: Face Verification ❌
**Status**: NOT in collection
**Needs**: Add requests
```
POST {{baseURL}}/kyc/ocr-thaiid
POST {{baseURL}}/kyc/verify-face
```

---

### PBI 4: Profile CRUD

#### C2D 9: Admin CRUD (Success) ✅
**Mapped to**: Folder `C2D9 Admin`

1. **GET All Users (200)** → `Users (All) (200)`
   - Set `accessToken` = admin token
   
2. **GET User by ID (200)** → `Users (By id) (200)`
   - Set `id` = target user ID
   
3. **POST Create User (201)** → `Users (Add) (201)`
   ```json
   {
     "firstname": "John",
     "lastname": "Doe",
     "nickname": "Johnny",
     "phoneNumber": "0832345644",
     "provider": "OTP",
     "cardId": "1234567890363",
     "birthday": "1990-01-01",
     "age": 33,
     "sex": "MALE",
     "version": 1,
     "role": "USER"
   }
   ```
   
4. **PUT Update User (200)** → `Users (Edit by id) (200)`
   - Update fields, increment `version`
   
5. **DELETE User (200)** → `Users (Delete) (200)`
   - Set `id` = user to delete

---

#### C2D 10: Regular User CRUD ⚠️
**Mapped to**: Folder `C2D10 - C2D11`
- Use regular user `accessToken`
- `Users (All) (403)` - should fail
- `Users (By id) (200)` - own ID should succeed
- `Users (By id) (403)` - other user ID should fail

---

#### C2D 11: Failed CRUD Operations ✅
**Mapped to**: Folder `C2D10 - C2D11`

**GET Tests**:
- `Users (By id) (401)` - No token
- `Users (By id) (403)` - Other user's ID
- `Users (By id) (404)` - Non-existent ID

**POST Tests**:
- `Users (Add) (400)` - Invalid data
- `Users (Add) (401)` - No token
- `Users (Add) (403)` - Regular user trying to create

**PUT Tests**:
- `Users (Edit by id) (400)` - Invalid data
- `Users (Edit by id) (401)` - No token
- `Users (Edit by id) (403)` - Edit other user
- `Users (Edit by id) (404)` - Non-existent ID
- `Users (Edit by id) (412)` - Version mismatch (optimistic locking)

**DELETE Tests**:
- `Users (Delete) (400)` - Invalid request
- `Users (Delete) (401)` - No token
- `Users (Delete) (403)` - Delete other user
- `Users (Delete) (404)` - Non-existent ID

---

#### C2D 12: Preferences (Success) ✅
**Mapped to**: Folder `C2D12`

1. **Get Preferences** → `Users (Preference) (200)`
   ```
   GET {{baseURL}}/users/preference
   ```

2. **Set Match Preferences** → `Users (Preference Match) (200)`
   ```json
   POST {{baseURL}}/users/preferenceMatch
   {
     "interestedGender": "BOTH",
     "interestedAgeMax": 60,
     "interestedAgeMin": 20,
     "interestedTravelStyle": "SAME",
     "interestedLifeStyle": "UNRELATED",
     "interestedInterest": "UNNECESSARY",
     "interestedDistanceMin": 0,
     "interestedDistanceMax": 100
   }
   ```

---

#### C2D 13-14: Profile Setup ⚠️
**Status**: Frontend validation tests
**Note**: These are primarily mobile app tests, not API tests

---

### PBI 5: Image Verification

#### C2D 15-17: Photo Upload ❌
**Status**: NOT in collection
**Needs**: Add requests
```
POST {{baseURL}}/users/{{id}}/photos/upload
POST {{baseURL}}/users/{{id}}/photos/delete
```

---

### PBI 6: Location & Matching

#### C2D 18-22: Location Update ❌
**Status**: NOT in collection (but exists in Chat2Date_Backend.postman_collection.json)
**Needs**: Copy from main collection:
```
POST {{baseURL}}/location/update
Body: {
  "latitude": {{latitude}},
  "longtitude": {{longitude}},
  "accuracy": 10.0
}
```

**Test Cases**:
- C2D 18: Success (200) with valid coords
- C2D 19: Permission denied (FE test)
- C2D 20: GPS off (FE test)
- C2D 21: Empty body (400)
- C2D 22: Invalid coords (400)

---

#### C2D 26-27: Match Notifications ❌
**Status**: NOT in collection
**Needs**: Add requests
```
POST {{baseURL}}/discovery/feedback?userId={{user_id}}
Body: { "targetUserId": "{{target_user_id}}", "action": "LIKE" }
```

---

### PBI 7: Discovery

#### C2D 23-25: Discovery Features ❌
**Status**: NOT in collection
**Needs**: Add requests
```
GET {{baseURL}}/discovery?userId={{user_id}}&minDistance={{min_distance}}&maxDistance={{max_distance}}
```

---

### PBI 8: Profile Management

#### C2D 28-29: Edit Profile ⚠️
**Mapped to**: Use existing CRUD endpoints
- Reuse `Users (Edit by id)` tests
- Add validation for constraints

---

## Token Management (Folder: Token)

### Refresh Token ✅
**Mapped to**: `Auth (Refresh Token)`
```
POST {{baseURL}}/auth/refresh-token
Body: { "refreshToken": "{{refreshToken}}" }
```

### Request Token ✅
**Mapped to**: `Auth (Request Token)`
```
POST {{baseURL}}/auth/request-token
Body: { "identifier": "{{identifier}}" }
```

### Logout ✅
**Mapped to**: `Auth (Logout)`
```
POST {{baseURL}}/auth/logout
Body: { "refreshToken": "{{refreshToken}}" }
```

---

## Missing Test Cases Summary

### High Priority (Need to Add)
1. ❌ **Google Auth** (C2D 5, 6, 31)
2. ❌ **Face Verification** (C2D 7, 8)
3. ❌ **Photo Upload** (C2D 15-17)
4. ❌ **Location Update** (C2D 18, 21-22) - Copy from main collection
5. ❌ **Discovery** (C2D 23-25)
6. ❌ **Match/Feedback** (C2D 26-27)

### Medium Priority (Partially Covered)
1. ⚠️ **OTP Already Registered** (C2D 2) - Add validation check
2. ⚠️ **Regular User Permissions** (C2D 10) - Organize existing tests
3. ⚠️ **Profile Setup Validation** (C2D 13-14) - FE tests

### Low Priority (Frontend Only)
1. 📱 **Face Detection UI** (C2D 8-2)
2. 📱 **GPS Permission** (C2D 19-20)
3. 📱 **Profile Validation** (C2D 13, 29)

---

## How to Use This Collection

### 1. Setup Environment
```
Postman → Environments → Import Chat2Date_Local.postman_environment.json
```

### 2. Set Base Variables
- `baseURL` = `http://cp25ssi2.sit.kmutt.ac.th:8080/api/v1`
- `phoneNumber` = Test phone number
- `id` = User ID for operations

### 3. Authentication Flow
**Step 1**: Run `C2D1 - C2D4 → Auth (Send OTP) (200)`
- Returns `token`, auto-saved to environment

**Step 2**: Get OTP from SMS or backend logs
- Set `otpCode` manually

**Step 3**: Run `C2D1 - C2D4 → Auth (Verify OTP) (200)`
- Returns `accessToken` and `refreshToken`
- Auto-saved to environment

### 4. Run Tests by Category
**Admin Tests**:
- Switch to admin account
- Run `C2D9 Admin` folder

**User Tests**:
- Switch to regular user account
- Run `C2D10 - C2D11` folder

**Preferences**:
- Run `C2D12` folder

### 5. Token Management
- Use `Token` folder for refresh/logout

---

## Test Execution Order

1. **Authentication** (C2D1 - C2D4)
   - Get tokens first
   
2. **Admin CRUD** (C2D9)
   - Requires admin token
   
3. **User CRUD & Errors** (C2D10 - C2D11)
   - Requires user token
   
4. **Preferences** (C2D12)
   - Requires authenticated user
   
5. **Token Management**
   - Test refresh/logout

---

## Notes

- Hard-coded URL: Some requests use `http://cp25ssi2.sit.kmutt.ac.th:8080/api/v1` instead of `{{baseURL}}`
  - **Fix**: Replace with `{{baseURL}}` variable
  
- Auth Bearer: Many requests have empty bearer token
  - **Fix**: Set to `{{accessToken}}`
  
- Missing Tests: Many PBIs don't have API tests yet
  - **Action**: Add missing endpoints from main collection

- Version Field: PUT requests must increment `version` for optimistic locking
  - **Important**: Always use latest version number

---

## Quick Reference

### Common Status Codes
- `200` OK - Success
- `201` Created - Resource created
- `400` Bad Request - Invalid data
- `401` Unauthorized - No token or invalid
- `403` Forbidden - No permission
- `404` Not Found - Resource doesn't exist
- `409` Conflict - Duplicate resource
- `412` Precondition Failed - Version mismatch
- `422` Unprocessable Entity - Invalid OTP
- `429` Too Many Requests - Rate limit exceeded

### Authentication Headers
```
Authorization: Bearer {{accessToken}}
Content-Type: application/json
```

### Test Script Template
```javascript
pm.test('Status code is [expected]', function () {
    pm.response.to.have.status([expected]);
});

pm.test('Response has required fields', function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('fieldName');
});

// Auto-save tokens
if (pm.response.code === 200) {
    var jsonData = pm.response.json();
    if (jsonData.accessToken) {
        pm.environment.set('accessToken', jsonData.accessToken);
    }
}
```
