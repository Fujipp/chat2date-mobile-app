# Chat2Date Complete Test Cases Documentation

## Overview
This document provides comprehensive test cases for the Chat2Date application, covering all PBIs (Product Backlog Items) from authentication to profile management.

---

## Environment Variables Setup

### Required Variables in `Chat2Date_Local` Environment

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `base_url` | Backend API base URL | `http://localhost:8080/api/v1` |
| `access_token` | JWT access token from login | Set by auth tests |
| `refresh_token` | JWT refresh token | Set by auth tests |
| `google_id_token` | Google OAuth ID token | Get from Google Sign-In |
| `phone` | Current test phone number | Use `user_001_phone` etc. |
| `user_id` | Current logged-in user ID | Set by auth tests |
| `target_user_id` | Target user for like/match | Set manually |
| `fcm_token` | Firebase Cloud Messaging token | From mobile app |
| `thaiid_front_base64` | Thai ID card image (base64) | From OCR test |
| `selfie_base64` | Selfie image (base64) | From face verify |
| `id_face_base64` | Cropped face from ID (base64) | From OCR result |
| `other_user_id` | Different user ID for forbidden tests | Set manually |
| `forbidden_token` | Token of different user | Set manually |
| `invalid_token` | Invalid/expired token | `invalid_jwt_token_123` |
| `user_001_phone` | User 001 phone | `0802249934` |
| `user_002_email` | User 002 Gmail | `varittorn.siri@mail.kmutt.ac.th` |
| `user_003_email` | User 003 Gmail | `hutchlovenee2@gmail.com` |
| `admin_001_phone` | Admin phone | `0626237630` |
| `test_phone_new` | New phone for testing | `0626434165` |
| `otp_code` | OTP code from SMS | Get from backend logs |
| `admin_access_token` | Admin user token | Set by admin login |
| `user_a_token` | User A token for match test | Set by login |
| `user_b_token` | User B token for match test | Set by login |
| `user_a_id` | User A ID | Set by login |
| `user_b_id` | User B ID | Set by login |
| `profile_photo_base64` | Profile photo with face | Upload test |
| `non_face_photo_base64` | Photo without face | Upload test |
| `latitude` | GPS latitude | `13.7563` |
| `longitude` | GPS longitude | `100.5018` |
| `min_distance` | Min distance filter (km) | `1` |
| `max_distance` | Max distance filter (km) | `10` |

---

## PBI 1: Register/Login with OTP

### C2D 1: Register Phone and OTP (Normal)
**Test ID**: C2D-1  
**Scenario**: Normal registration with phone and OTP  
**User**: user-001 (0802249934)

**Steps**:
1. POST `/auth/request-otp`
   ```json
   {
     "phoneNumber": "{{user_001_phone}}"
   }
   ```
2. Get OTP from backend logs or SMS
3. POST `/auth/verify-otp`
   ```json
   {
     "phoneNumber": "{{user_001_phone}}",
     "otp": "{{otp_code}}"
   }
   ```

**Expected**:
- Step 1: BE responds `200`, FE shows OTP input page
- Step 3: BE responds `200`, returns `accessToken`, FE redirects to ID card scan

**Postman Test Script**:
```javascript
pm.test('Status code is 200', () => pm.response.to.have.status(200));
pm.test('Response has accessToken', () => {
    const jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('accessToken');
    pm.environment.set('access_token', jsonData.accessToken);
});
```

---

### C2D 2: Register with Already Registered Phone (Failed)
**Test ID**: C2D-2  
**Scenario**: Attempt to register with existing phone  
**User**: user-001 (0802249934)

**Steps**:
1. POST `/auth/request-otp` with registered phone

**Expected**:
- BE responds `200` (or `409` if implemented)
- FE shows message "Phone already registered" and stays on login page

---

### C2D 3: Register with Incorrect OTP (Failed)
**Test ID**: C2D-3  
**Scenario**: Enter wrong OTP code  
**User**: test_phone_new (0626434165)

**Steps**:
1. POST `/auth/request-otp` with new phone
2. POST `/auth/verify-otp` with wrong OTP
   ```json
   {
     "phoneNumber": "{{test_phone_new}}",
     "otp": "000000"
   }
   ```

**Expected**:
- BE responds `422` Unprocessable Entity
- FE shows toast error "Incorrect OTP"

---

### C2D 4: Request OTP Too Many Times (Failed)
**Test ID**: C2D-4  
**Scenario**: Rate limiting for OTP requests  
**User**: test_phone_new (0626434165)

**Steps**:
1. POST `/auth/request-otp` multiple times rapidly (>5 times)

**Expected**:
- BE responds `429` Too Many Requests
- FE shows "Too many attempts, please try again later"

---

### C2D 30: Login with Phone and OTP (Normal)
**Test ID**: C2D-30  
**Scenario**: Existing user logs in with phone  
**User**: user-001 (0802249934)

**Steps**:
1. POST `/auth/request-otp` with registered phone
2. POST `/auth/verify-otp` with correct OTP

**Expected**:
- BE responds `200`, returns tokens
- FE redirects to Discovery screen

---

## PBI 2: Register/Login with Google

### C2D 5: Register with Google (Normal)
**Test ID**: C2D-5  
**Scenario**: First-time Google sign-in  
**User**: user-002 (varittorn.siri@mail.kmutt.ac.th)

**Steps**:
1. Click "Sign in with Google" on login page
2. POST `/auth/google`
   ```json
   {
     "idToken": "{{google_id_token}}"
   }
   ```

**Expected**:
- BE responds `200`, returns `accessToken` and user data
- FE redirects to ID card scan page

**Note**: Get `google_id_token` from actual Google OAuth flow

---

### C2D 6: Empty idToken (Failed)
**Test ID**: C2D-6  
**Scenario**: Send empty idToken  

**Steps**:
1. POST `/auth/google`
   ```json
   {
     "idToken": ""
   }
   ```

**Expected**:
- BE responds `400` Bad Request

---

### C2D 31: Login with Existing Google Account (Normal)
**Test ID**: C2D-31  
**Scenario**: Returning user logs in with Google  
**User**: user-002 (varittorn.siri@mail.kmutt.ac.th)

**Steps**:
1. POST `/auth/google` with existing account's idToken

**Expected**:
- BE responds `200`
- FE redirects to Discovery page

---

## PBI 3: Face Verification

### C2D 7: Successful Face Scan (Normal)
**Test ID**: C2D-7  
**Scenario**: Complete all poses successfully  
**User**: user-003 (hutchlovenee2@gmail.com)

**Steps**:
1. Open face scan screen
2. Perform center/smile/blink/look poses
3. POST `/kyc/verify-face`
   ```json
   {
     "selfieBytes": "{{selfie_base64}}",
     "idFaceBase64": "{{id_face_base64}}"
   }
   ```

**Expected**:
- FE shows success message
- BE responds `200` with `matched: true`

---

### C2D 8-1: Face Mismatch (Failed)
**Test ID**: C2D-8-1  
**Scenario**: Selfie doesn't match ID card face  

**Steps**:
1. Upload selfie of different person
2. POST `/kyc/verify-face` with mismatched faces

**Expected**:
- FE shows "face mismatch" error
- BE responds `400` or `422`
- App doesn't crash

---

### C2D 8-2: No Face Detected (Failed)
**Test ID**: C2D-8-2  
**Scenario**: No face in camera frame  

**Steps**:
1. Open face scan
2. Keep face out of frame

**Expected**:
- FE shows "face not found" message
- No BE call made
- App doesn't crash

---

## PBI 4: Basic Profile User

### C2D 9: Admin CRUD Operations (Normal)
**Test ID**: C2D-9  
**Scenario**: Admin can perform all CRUD operations  
**User**: admin-001 (0626237630)

**Steps**:
1. GET `/users/{id}` - Get specific user
2. POST `/users` - Create new user
3. PUT `/users/{id}` - Update user
4. DELETE `/users/{id}` - Delete user
5. GET `/users` - Get all users

**Expected**:
- GET: `200`
- POST: `201`
- PUT: `200`
- DELETE: `200`
- GET ALL: `200`

---

### C2D 10: Regular User CRUD Operations (Normal)
**Test ID**: C2D-10  
**Scenario**: Regular user can access own data only  
**User**: user-003 (hutchlovenee2@gmail.com)

**Steps**:
1. GET `/users/{own_id}` - Get own profile
2. PUT `/users/{own_id}` - Update own profile
3. GET `/users` - Attempt to get all users

**Expected**:
- GET own: `200`
- PUT own: `200`
- GET ALL: `403` Forbidden

---

### C2D 11: Failed CRUD Operations (Failed)
**Test ID**: C2D-11  
**Scenario**: Test various error scenarios  

**Test Cases**:
- GET `/users/{id}` without token → `401`
- GET `/users/{other_id}` → `403`
- GET `/users/nonexistent` → `404`
- POST `/users` with invalid data → `400`
- PUT `/users/{id}` with wrong version → `412` (optimistic locking)

---

### C2D 12: Preference Operations (Normal)
**Test ID**: C2D-12  
**Scenario**: Get and set user preferences  

**Steps**:
1. GET `/users/preference`
2. POST `/users/preferenceMatch`
   ```json
   {
     "interestedGender": "FEMALE",
     "minAge": 22,
     "maxAge": 30,
     "interestedInterests": [1, 2, 3],
     "interestedLifeStyles": [1, 2, 3],
     "interestedTravelStyles": [1, 2]
   }
   ```

**Expected**:
- GET: `200` with preferences data
- POST: `200` success

---

### C2D 13: Profile Setup Validation (Failed)
**Test ID**: C2D-13  
**Scenario**: Frontend validation for required fields  

**Validation Rules**:
- Nickname: Required
- Travel style: Must select 2-3
- Lifestyle: Must select 3-5
- Interests: Must select 3-5
- Tags: Optional, max 5

**Expected**:
- FE shows validation errors
- FE stays on current page until valid

---

### C2D 14: Complete Profile Setup (Normal)
**Test ID**: C2D-14  
**Scenario**: Successfully complete profile setup  
**User**: user-003

**Steps**:
1. Scan ID card page → edit user data
2. Profile setup page:
   - Enter nickname
   - Select 2-3 travel styles
   - Select 3-5 lifestyles
   - Select 3-5 interests
   - Optional: add tags
3. Preference match page:
   - Select preferred gender
   - Set age range
   - Select interested interests, lifestyles, travel styles
4. Submit

**Expected**:
- FE redirects: ID scan → Profile setup → Preference → User photo
- BE responds `200` at each step

---

## PBI 5: User Image Verification

### C2D 15: No Photo Uploaded (Failed)
**Test ID**: C2D-15  
**Scenario**: Attempt to submit without photos  

**Steps**:
1. Navigate to user photo page
2. Click submit without uploading

**Expected**:
- FE shows "Please upload at least 1 photo"
- No BE API call

---

### C2D 16: Upload Photo Without Face (Failed)
**Test ID**: C2D-16  
**Scenario**: Upload photo that doesn't contain a face  

**Steps**:
1. Navigate to user photo page
2. Upload landscape/object photo
3. Submit

**Expected**:
- FE shows modal with face detection error and suggestions
- BE responds `400` with error message

---

### C2D 17: Upload Face Photo Successfully (Normal)
**Test ID**: C2D-17  
**Scenario**: Upload valid face photo  

**Steps**:
1. Navigate to user photo page
2. POST `/users/{id}/photos/upload`
   ```json
   {
     "photos": ["{{profile_photo_base64}}"]
   }
   ```

**Expected**:
- BE responds `200`
- FE redirects to Discovery page

---

## PBI 6: Update Location GPS

### C2D 18: Update Location Success (Normal)
**Test ID**: C2D-18  
**Scenario**: Successfully update GPS location  

**Steps**:
1. Grant location permission
2. Turn on GPS
3. POST `/location/update`
   ```json
   {
     "latitude": {{latitude}},
     "longtitude": {{longitude}},
     "accuracy": 10.0
   }
   ```

**Expected**:
- BE responds `200` with `status: "ok"`
- FE shows success
- Location saved in database

---

### C2D 19: Location Permission Denied (Normal)
**Test ID**: C2D-19  
**Scenario**: User denies location permission  

**Steps**:
1. Deny location permission
2. Attempt to tap update

**Expected**:
- FE redirects to /home (as implemented)
- No BE call
- App doesn't crash

---

### C2D 20: GPS Turned Off (Normal)
**Test ID**: C2D-20  
**Scenario**: GPS is disabled but permission granted  

**Steps**:
1. Turn off GPS
2. Grant permission
3. Attempt update

**Expected**:
- FE prompts "Enable GPS"
- BE call may proceed with (0,0) or last known location
- App handles gracefully

---

### C2D 21: Missing Coordinates (Failed)
**Test ID**: C2D-21  
**Scenario**: Empty body sent to location update  

**Request**:
```json
POST /location/update
Headers: Authorization: Bearer {{access_token}}
Body: {}
```

**Expected**:
- BE responds `400` Bad Request
- Error message: "Missing coordinates"

---

### C2D 22: Out-of-Range Coordinates (Failed)
**Test ID**: C2D-22  
**Scenario**: Invalid latitude/longitude values  

**Test Cases**:
1. Latitude > 90
   ```json
   { "latitude": 91.0, "longtitude": 100.0, "accuracy": 10.0 }
   ```
2. Latitude < -90
   ```json
   { "latitude": -91.0, "longtitude": 100.0, "accuracy": 10.0 }
   ```
3. Longitude > 180
   ```json
   { "latitude": 13.7563, "longtitude": 181.0, "accuracy": 10.0 }
   ```
4. Longitude < -180
   ```json
   { "latitude": 13.7563, "longtitude": -181.0, "accuracy": 10.0 }
   ```

**Expected**:
- BE responds `400` Bad Request
- Error message: "Invalid latitude/longitude"

---

## PBI 7: Discover User

### C2D 23: Access Discovery Successfully (Normal)
**Test ID**: C2D-23  
**Scenario**: View discovery page with candidates  
**User**: user-001 (0802249934)

**Steps**:
1. Successfully sign in
2. GET `/discovery?userId={{user_id}}&minDistance=1&maxDistance=100`

**Expected**:
- FE displays candidate profiles with:
  - Name, age, photos, bio
  - Like/dislike action buttons
- BE responds `200` with candidate array

---

### C2D 24: No Candidates Available (Normal)
**Test ID**: C2D-24  
**Scenario**: Empty candidate list  

**Steps**:
1. Sign in
2. GET `/discovery?userId={{user_id}}&minDistance=1&maxDistance=100`

**Expected**:
- BE responds `200` with empty array
- FE shows empty state: "ไม่มีคนที่เหมาะสมในขณะนี้"
- FE suggests adjusting preferences

---

### C2D 25: Filter Candidates by Distance (Normal)
**Test ID**: C2D-25  
**Scenario**: Apply distance filter  
**User**: test_phone_new (0626434165)

**Steps**:
1. Sign in
2. Open filters
3. Set distance: 10km
4. GET `/discovery?userId={{user_id}}&minDistance=1&maxDistance=10`

**Expected**:
- BE responds `200` with filtered candidates
- FE shows only candidates within 10km

---

## PBI 6 (Continued): Matching Notification

### C2D 26: Match Success Sends Push (Normal)
**Test ID**: C2D-26  
**Scenario**: Both users like each other, push sent  
**Users**: userA, userB (both with FCM tokens registered)

**Steps**:
1. User A likes User B:
   ```json
   POST /discovery/feedback?userId={{user_a_id}}
   {
     "targetUserId": "{{user_b_id}}",
     "action": "LIKE"
   }
   ```
2. User B likes User A:
   ```json
   POST /discovery/feedback?userId={{user_b_id}}
   {
     "targetUserId": "{{user_a_id}}",
     "action": "LIKE"
   }
   ```

**Expected**:
- BE responds `201` or `200` for both
- Both devices receive FCM push notification
- Match created in database

---

### C2D 27: Notification on Background (Normal)
**Test ID**: C2D-27  
**Scenario**: User not actively using app receives notification  

**Steps**:
1. User closes app or switches to background
2. Trigger match event

**Expected**:
- BE responds `200`
- Notification appears on device
- Tapping notification opens app to match screen

---

## PBI 8: Profile Management

### C2D 28: Edit User Data Successfully (Normal)
**Test ID**: C2D-28  
**Scenario**: Edit various profile fields  

**Steps**:
1. Navigate to Profile from menu bar
2. Edit fields:
   - Nickname
   - Photos (add/delete)
   - Travel style
   - Lifestyle
   - Interests
   - Tags
3. Navigate to Settings → Edit match preferences
4. Submit changes

**Expected**:
- FE edits successfully
- BE responds `200` for each update
- Changes persisted

---

### C2D 29: Edit User Data Failed (Failed)
**Test ID**: C2D-29  
**Scenario**: Validation errors prevent save  

**Test Cases**:
1. Nickname empty
2. Delete all face pictures
3. Travel style < 2 selected
4. Lifestyle < 3 selected
5. Interests < 3 selected

**Expected**:
- FE shows validation errors
- For deleting all faces: BE responds `400`
- Changes not saved until valid

---

## Postman Collection Structure

```
Chat2Date Backend/
├── PBI 1: OTP Auth/
│   ├── C2D 1: Register OTP (Success)
│   ├── C2D 2: Register Existing Phone (Failed)
│   ├── C2D 3: Incorrect OTP (Failed)
│   ├── C2D 4: Too Many OTP Requests (Failed)
│   └── C2D 30: Login OTP (Success)
├── PBI 2: Google Auth/
│   ├── C2D 5: Register Google (Success)
│   ├── C2D 6: Empty idToken (Failed)
│   └── C2D 31: Login Google (Success)
├── PBI 3: Face Verification/
│   ├── C2D 7: Face Scan Success
│   ├── C2D 8-1: Face Mismatch
│   └── C2D 8-2: No Face Detected
├── PBI 4: Profile CRUD/
│   ├── C2D 9: Admin CRUD (Success)
│   ├── C2D 10: User CRUD (Partial)
│   ├── C2D 11: CRUD Errors
│   ├── C2D 12: Preferences (Success)
│   ├── C2D 13: Validation (Failed)
│   └── C2D 14: Complete Profile (Success)
├── PBI 5: Image Verification/
│   ├── C2D 15: No Photo (Failed)
│   ├── C2D 16: No Face (Failed)
│   └── C2D 17: Upload Success
├── PBI 6: Location & Matching/
│   ├── C2D 18: Update Location (Success)
│   ├── C2D 19: Permission Denied
│   ├── C2D 20: GPS Off
│   ├── C2D 21: Empty Body (Failed)
│   ├── C2D 22: Invalid Coords (Failed)
│   ├── C2D 26: Match Push (Success)
│   └── C2D 27: Background Notification
├── PBI 7: Discovery/
│   ├── C2D 23: Discovery Success
│   ├── C2D 24: No Candidates
│   └── C2D 25: Filter Distance
└── PBI 8: Profile Management/
    ├── C2D 28: Edit Success
    └── C2D 29: Edit Failed
```

---

## Running Tests

### Prerequisites
1. Start backend server
2. Import Postman collection
3. Set environment variables
4. Obtain real tokens from login

### Run Order
1. **Auth Tests First**: Get tokens
   - C2D 1, 5, 30, 31
2. **KYC Tests**: Get face data
   - C2D 7, 8
3. **Profile Tests**: Complete profile
   - C2D 9-14
4. **Photo Tests**: Upload images
   - C2D 15-17
5. **Location Tests**: Update GPS
   - C2D 18-22
6. **Discovery Tests**: View candidates
   - C2D 23-25
7. **Match Tests**: Create matches
   - C2D 26-27
8. **Management Tests**: Edit profile
   - C2D 28-29

### Manual Steps Required
- Get Google `idToken` from actual OAuth flow
- Get OTP from SMS or backend logs
- Upload actual photos for image tests
- Enable/disable GPS on test device
- Register FCM tokens for push notification tests

---

## Notes

- All timestamps in ISO 8601 format
- All IDs are UUIDs or integers
- Base64 images should include data URI prefix if required
- Phone numbers in E.164 format
- Optimistic locking uses version field
- Rate limiting applies to OTP requests (5 per 15 minutes)
- GPS accuracy in meters
- Distance filters in kilometers
- Age range: 18-100
