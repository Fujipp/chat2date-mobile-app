# Location Update API - Test Cases

## Overview
Test cases for validating the `/location/update` endpoint with various scenarios including empty body and out-of-range coordinates.

---

## Prerequisites

### Environment Variables Required
Make sure these variables are set in your Postman environment (`Chat2Date_Local`):

| Variable | Description | Example |
|----------|-------------|---------|
| `base_url` | Backend API base URL | `http://localhost:8080/api/v1` or `https://cp25ssi2.sit.kmutt.ac.th:8080/api/v1` |
| `access_token` | Valid JWT access token | Get from login endpoint |

---

## Test Cases

### ✅ Success Case

#### **Location Update - Success (200)**
- **Method**: POST
- **Endpoint**: `{{base_url}}/location/update`
- **Headers**:
  - `Authorization`: Bearer {{access_token}}
  - `Content-Type`: application/json
- **Body**:
```json
{
  "latitude": 13.7563,
  "longtitude": 100.5018,
  "accuracy": 10.0
}
```
- **Expected Response**:
  - Status: `200 OK`
  - Body:
```json
{
  "status": "ok"
}
```

---

### ❌ C2D 21: Empty Body Test Case

#### **C2D 21: Location Update - Empty Body (400)**
- **Test ID**: C2D 21
- **Scenario**: Missing coordinates
- **Method**: POST
- **Endpoint**: `{{base_url}}/location/update`
- **Headers**:
  - `Authorization`: Bearer {{access_token}}
  - `Content-Type`: application/json
- **Body**:
```json
{}
```
- **Expected Response**:
  - Status: `400 Bad Request`
  - Body contains error message about missing coordinates
  - Example:
```json
{
  "error": "Missing coordinates: latitude and longitude are required"
}
```

---

### ❌ C2D 22: Out-of-Range Coordinates Test Cases

#### **Test 1: Out-of-Range Latitude (Positive)**
- **Test ID**: C2D 22-1
- **Scenario**: Latitude > 90
- **Method**: POST
- **Endpoint**: `{{base_url}}/location/update`
- **Headers**:
  - `Authorization`: Bearer {{access_token}}
  - `Content-Type`: application/json
- **Body**:
```json
{
  "latitude": 91.0,
  "longtitude": 100.0,
  "accuracy": 10.0
}
```
- **Expected Response**:
  - Status: `400 Bad Request`
  - Body:
```json
{
  "error": "Invalid latitude: must be between -90 and 90 degrees"
}
```

---

#### **Test 2: Out-of-Range Latitude (Negative)**
- **Test ID**: C2D 22-2
- **Scenario**: Latitude < -90
- **Method**: POST
- **Endpoint**: `{{base_url}}/location/update`
- **Headers**:
  - `Authorization`: Bearer {{access_token}}
  - `Content-Type`: application/json
- **Body**:
```json
{
  "latitude": -91.0,
  "longtitude": 100.0,
  "accuracy": 10.0
}
```
- **Expected Response**:
  - Status: `400 Bad Request`
  - Body:
```json
{
  "error": "Invalid latitude: must be between -90 and 90 degrees"
}
```

---

#### **Test 3: Out-of-Range Longitude (Positive)**
- **Test ID**: C2D 22-3
- **Scenario**: Longitude > 180
- **Method**: POST
- **Endpoint**: `{{base_url}}/location/update`
- **Headers**:
  - `Authorization`: Bearer {{access_token}}
  - `Content-Type`: application/json
- **Body**:
```json
{
  "latitude": 13.7563,
  "longtitude": 181.0,
  "accuracy": 10.0
}
```
- **Expected Response**:
  - Status: `400 Bad Request`
  - Body:
```json
{
  "error": "Invalid longitude: must be between -180 and 180 degrees"
}
```

---

#### **Test 4: Out-of-Range Longitude (Negative)**
- **Test ID**: C2D 22-4
- **Scenario**: Longitude < -180
- **Method**: POST
- **Endpoint**: `{{base_url}}/location/update`
- **Headers**:
  - `Authorization`: Bearer {{access_token}}
  - `Content-Type`: application/json
- **Body**:
```json
{
  "latitude": 13.7563,
  "longtitude": -181.0,
  "accuracy": 10.0
}
```
- **Expected Response**:
  - Status: `400 Bad Request`
  - Body:
```json
{
  "error": "Invalid longitude: must be between -180 and 180 degrees"
}
```

---

## Coordinate Validation Rules

### Latitude
- **Valid Range**: `-90.0` to `90.0` degrees
- **Examples**:
  - ✅ Valid: `0`, `13.7563`, `90`, `-90`, `45.5`
  - ❌ Invalid: `91`, `-91`, `100`, `-100`

### Longitude
- **Valid Range**: `-180.0` to `180.0` degrees
- **Examples**:
  - ✅ Valid: `0`, `100.5018`, `180`, `-180`, `45.5`
  - ❌ Invalid: `181`, `-181`, `200`, `-200`

### Edge Cases
| Latitude | Longitude | Valid? | Note |
|----------|-----------|--------|------|
| 90.0 | 180.0 | ✅ | Maximum valid values |
| -90.0 | -180.0 | ✅ | Minimum valid values |
| 90.1 | 100.0 | ❌ | Latitude exceeds max |
| 13.0 | 180.1 | ❌ | Longitude exceeds max |
| -90.1 | 100.0 | ❌ | Latitude below min |
| 13.0 | -180.1 | ❌ | Longitude below min |
| 0.0 | 0.0 | ❌ | Empty coordinates (treated as missing) |

---

## How to Run Tests in Postman

### Option 1: Run Individual Test
1. Open Postman
2. Import the collection: `Chat2Date_Backend.postman_collection.json`
3. Set the environment: `Chat2Date_Local`
4. Make sure `access_token` is set (login first)
5. Select the test case (e.g., "C2D 21: Location Update - Empty Body")
6. Click **Send**
7. Check the **Test Results** tab

### Option 2: Run All Location Tests
1. In Postman Collections panel
2. Right-click on the collection
3. Select **Run collection**
4. Filter for tests starting with "C2D 2" or "Location"
5. Click **Run Chat2Date Backend**
6. View results summary

### Option 3: Using Postman CLI (newman)
```bash
# Install newman if not already installed
npm install -g newman

# Run all tests
newman run Chat2Date_Backend.postman_collection.json \
  -e Chat2Date_Local.postman_environment.json

# Run with HTML report
newman run Chat2Date_Backend.postman_collection.json \
  -e Chat2Date_Local.postman_environment.json \
  --reporters cli,html \
  --reporter-html-export location-test-report.html
```

---

## Getting Access Token

Before running these tests, you need a valid `access_token`. Use one of these endpoints:

### Via Google Sign-In
```
POST {{base_url}}/auth/google
Body: { "token": "{{google_id_token}}" }
```

### Via OTP
1. Request OTP:
```
POST {{base_url}}/auth/otp/request
Body: { "phoneNumber": "0812345678" }
```

2. Validate OTP:
```
POST {{base_url}}/auth/otp/validate
Body: { 
  "phoneNumber": "0812345678",
  "otp": "123456"
}
```

The response will include `accessToken` - copy this to your environment variable.

---

## Backend Validation Implementation

The validation is implemented in `UserLocationService.java`:

```java
// Validate coordinates
if (req == null || req.getLatitude() == 0.0 && req.getLongtitude() == 0.0) {
    throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST,
        "Missing coordinates: latitude and longitude are required"
    );
}

// Validate latitude range: -90 to 90
if (req.getLatitude() < -90.0 || req.getLatitude() > 90.0) {
    throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST,
        "Invalid latitude: must be between -90 and 90 degrees"
    );
}

// Validate longitude range: -180 to 180
if (req.getLongtitude() < -180.0 || req.getLongtitude() > 180.0) {
    throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST,
        "Invalid longitude: must be between -180 and 180 degrees"
    );
}
```

---

## Test Summary

| Test Case | Status | Expected Code | Description |
|-----------|--------|---------------|-------------|
| Location Update - Success | ✅ | 200 | Valid coordinates update successfully |
| C2D 21 - Empty Body | ❌ | 400 | Missing coordinates validation |
| C2D 22-1 - Latitude > 90 | ❌ | 400 | Upper bound latitude validation |
| C2D 22-2 - Latitude < -90 | ❌ | 400 | Lower bound latitude validation |
| C2D 22-3 - Longitude > 180 | ❌ | 400 | Upper bound longitude validation |
| C2D 22-4 - Longitude < -180 | ❌ | 400 | Lower bound longitude validation |

---

## Troubleshooting

### Issue: 401 Unauthorized
- **Cause**: Missing or expired access token
- **Solution**: Login again and update `access_token` in environment

### Issue: 500 Internal Server Error
- **Cause**: Backend service might be down or database connection issue
- **Solution**: Check backend logs and ensure database is running

### Issue: Test passes but shouldn't
- **Cause**: Backend validation might not be deployed yet
- **Solution**: 
  1. Rebuild backend: `mvn clean install`
  2. Restart Spring Boot application
  3. Verify `UserLocationService.java` contains validation code

---

## Additional Resources

- **Backend Controller**: `LocationController.java`
- **Service Logic**: `UserLocationService.java`
- **DTO Model**: `UpdateLocationRequest.java`
- **Postman Collection**: `Chat2Date_Backend.postman_collection.json`
- **Environment File**: `Chat2Date_Local.postman_environment.json`
