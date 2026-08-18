# Chat2Date Admin API Documentation

Complete API reference for Chat2Date Admin Dashboard backend endpoints.

## Base URL

```
http://cp25ssi2.sit.kmutt.ac.th/api
```

## Authentication

All admin endpoints require authentication with `ADMIN` role.

### Headers

```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

### Role Requirements

- All `/admin/*` endpoints require `ROLE_ADMIN`
- Regular `/api/*` endpoints may require `ROLE_USER` or `ROLE_ADMIN`

---

## 📊 Report Endpoints

### Get All Reports

Retrieve paginated list of reports with optional filtering and sorting.

**Endpoint:** `GET /api/admin/reports`

**Authorization:** Required (ADMIN)

#### Query Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| page | integer | No | 0 | Page number (0-based) |
| size | integer | No | 20 | Items per page |
| status | string | No | - | Filter by status: PENDING, RESOLVED, DISMISSED, REJECTED |
| sortBy | string | No | createdAt | Field to sort by: reportId, createdAt, status |
| sortDirection | string | No | DESC | Sort direction: ASC or DESC |

#### Example Request

```bash
curl -X GET \
  'http://cp25ssi2.sit.kmutt.ac.th/api/admin/reports?page=0&size=20&status=PENDING&sortBy=createdAt&sortDirection=DESC' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
```

#### Example Response (200 OK)

```json
{
  "content": [
    {
      "reportId": 1,
      "reporterId": "user123",
      "targetUserId": "user456",
      "reason": "Harassment",
      "anotherReason": null,
      "description": "User sent inappropriate messages repeatedly",
      "status": "PENDING",
      "isNotified": false,
      "createdAt": "2024-01-15T10:30:00"
    },
    {
      "reportId": 2,
      "reporterId": "user789",
      "targetUserId": "user101",
      "reason": "Spam",
      "anotherReason": "Bot behavior",
      "description": "Account appears to be automated",
      "status": "PENDING",
      "isNotified": false,
      "createdAt": "2024-01-15T09:15:00"
    }
  ],
  "pageable": {
    "sort": {
      "sorted": true,
      "unsorted": false,
      "empty": false
    },
    "pageNumber": 0,
    "pageSize": 20,
    "offset": 0,
    "paged": true,
    "unpaged": false
  },
  "totalPages": 5,
  "totalElements": 95,
  "last": false,
  "number": 0,
  "size": 20,
  "numberOfElements": 20,
  "first": true,
  "empty": false
}
```

#### Error Responses

**401 Unauthorized**
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 401,
  "error": "Unauthorized",
  "message": "Full authentication is required to access this resource"
}
```

**403 Forbidden**
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 403,
  "error": "Forbidden",
  "message": "Access is denied - ADMIN role required"
}
```

---

### Get Report Details

Retrieve detailed information about a specific report including user profiles and evidence.

**Endpoint:** `GET /api/admin/reports/{id}`

**Authorization:** Required (ADMIN)

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | integer | Yes | Report ID |

#### Example Request

```bash
curl -X GET \
  'http://cp25ssi2.sit.kmutt.ac.th/api/admin/reports/1' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
```

#### Example Response (200 OK)

```json
{
  "reportId": 1,
  "reporterId": "user123",
  "targetUserId": "user456",
  "reason": "Harassment",
  "anotherReason": null,
  "description": "User sent inappropriate messages repeatedly",
  "status": "PENDING",
  "isNotified": false,
  "createdAt": "2024-01-15T10:30:00",
  "evidenceUrls": [
    "https://res.cloudinary.com/chat2date/image/upload/v1234567890/reports/evidence/img1.jpg",
    "https://res.cloudinary.com/chat2date/image/upload/v1234567890/reports/evidence/img2.jpg"
  ],
  "reporter": {
    "userId": "user123",
    "email": "reporter@example.com",
    "phoneNumber": "+66812345678",
    "firstname": "John",
    "lastname": "Doe",
    "nickname": "Johnny",
    "age": 25,
    "sex": "Male",
    "accountStatus": "ACTIVE",
    "isBlacklist": false,
    "behaviorScore": 85,
    "profilePhotoUrl": "https://res.cloudinary.com/chat2date/image/upload/v1234567890/profiles/user123.jpg"
  },
  "targetUser": {
    "userId": "user456",
    "email": "target@example.com",
    "phoneNumber": "+66887654321",
    "firstname": "Jane",
    "lastname": "Smith",
    "nickname": "Janey",
    "age": 28,
    "sex": "Female",
    "accountStatus": "ACTIVE",
    "isBlacklist": false,
    "behaviorScore": 45,
    "profilePhotoUrl": "https://res.cloudinary.com/chat2date/image/upload/v1234567890/profiles/user456.jpg"
  }
}
```

#### Error Responses

**404 Not Found**
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 404,
  "error": "Not Found",
  "message": "Report not found"
}
```

---

### Update Report Status

Update the status of a report (resolve, dismiss, reject, or reopen).

**Endpoint:** `PUT /api/admin/reports/{id}/status`

**Authorization:** Required (ADMIN)

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | integer | Yes | Report ID |

#### Request Body

```json
{
  "status": "RESOLVED"
}
```

**Available Status Values:**
- `PENDING` - Report is awaiting review
- `RESOLVED` - Report has been addressed and closed
- `DISMISSED` - Report was reviewed but no action taken
- `REJECTED` - Report was invalid or false

#### Example Request

```bash
curl -X PUT \
  'http://cp25ssi2.sit.kmutt.ac.th/api/admin/reports/1/status' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'Content-Type: application/json' \
  -d '{
    "status": "RESOLVED"
  }'
```

#### Example Response (200 OK)

```json
{
  "reportId": 1,
  "reporterId": "user123",
  "targetUserId": "user456",
  "reason": "Harassment",
  "anotherReason": null,
  "description": "User sent inappropriate messages repeatedly",
  "status": "RESOLVED",
  "isNotified": true,
  "createdAt": "2024-01-15T10:30:00"
}
```

#### Error Responses

**400 Bad Request**
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 400,
  "error": "Bad Request",
  "message": "Invalid status value"
}
```

**404 Not Found**
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 404,
  "error": "Not Found",
  "message": "Report not found"
}
```

---

## 🔐 Authentication Endpoints

### Request Refresh Token

Request a new refresh token for admin operations.

**Endpoint:** `POST /api/admin/request-refresh`

**Authorization:** Required (ADMIN)

#### Request Body

```json
{
  "identifier": "admin@example.com"
}
```

#### Example Request

```bash
curl -X POST \
  'http://cp25ssi2.sit.kmutt.ac.th/api/admin/request-refresh' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'Content-Type: application/json' \
  -d '{
    "identifier": "admin@example.com"
  }'
```

#### Example Response (200 OK)

```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbkBleGFtcGxlLmNvbSIsImlhdCI6MTYzOTU4MjQwMCwiZXhwIjoxNjM5NjY4ODAwfQ.abc123..."
}
```

---

## 👥 User Endpoints

### Get All Users

Retrieve list of all users in the system.

**Endpoint:** `GET /api/users`

**Authorization:** Required (ADMIN)

#### Example Request

```bash
curl -X GET \
  'http://cp25ssi2.sit.kmutt.ac.th/api/users' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
```

#### Example Response (200 OK)

```json
[
  {
    "userId": "user123",
    "email": "user@example.com",
    "phoneNumber": "+66812345678",
    "isVerify": true,
    "provider": "GOOGLE",
    "firstname": "John",
    "lastname": "Doe",
    "nickname": "Johnny",
    "cardId": "1234567890123",
    "birthday": "1999-01-15",
    "age": 25,
    "sex": "Male",
    "faceVerify": true,
    "behaviorScore": 85,
    "isBlacklist": false,
    "accountStatus": "ACTIVE",
    "version": 1,
    "role": "USER"
  }
]
```

---

## 📝 Data Models

### Report

```typescript
{
  reportId: number;           // Unique report identifier
  reporterId: string;         // User ID of the reporter
  targetUserId: string;       // User ID of the reported user
  reason: string;             // Main reason for report
  anotherReason?: string;     // Additional reason (optional)
  description?: string;       // Detailed description (optional)
  status: ReportStatus;       // Current status
  isNotified: boolean;        // Whether users have been notified
  createdAt: string;          // ISO 8601 datetime
}
```

### ReportStatus (Enum)

```typescript
enum ReportStatus {
  PENDING = "PENDING",       // Awaiting review
  RESOLVED = "RESOLVED",     // Successfully resolved
  DISMISSED = "DISMISSED",   // No action required
  REJECTED = "REJECTED"      // Invalid/false report
}
```

### UserBasicInfo

```typescript
{
  userId: string;
  email: string;
  phoneNumber: string;
  firstname: string;
  lastname: string;
  nickname: string;
  age: number;
  sex: string;
  accountStatus: string;
  isBlacklist: boolean;
  behaviorScore: number;
  profilePhotoUrl?: string;
}
```

### Page Response

```typescript
{
  content: T[];              // Array of items
  pageable: {
    sort: {
      sorted: boolean;
      unsorted: boolean;
      empty: boolean;
    };
    pageNumber: number;
    pageSize: number;
    offset: number;
    paged: boolean;
    unpaged: boolean;
  };
  totalPages: number;        // Total number of pages
  totalElements: number;     // Total number of items
  last: boolean;             // Is last page
  number: number;            // Current page number
  size: number;              // Page size
  numberOfElements: number;  // Items in current page
  first: boolean;            // Is first page
  empty: boolean;            // Is empty result
}
```

---

## 🚨 Error Codes

| Status Code | Description |
|-------------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Authentication required |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource doesn't exist |
| 409 | Conflict - Duplicate report |
| 413 | Payload Too Large - File size exceeds limit |
| 415 | Unsupported Media Type - Invalid file type |
| 500 | Internal Server Error |

---

## 📋 Common Use Cases

### 1. View Pending Reports

```bash
# Get first page of pending reports
curl -X GET \
  'http://cp25ssi2.sit.kmutt.ac.th/api/admin/reports?status=PENDING&page=0&size=20' \
  -H 'Authorization: Bearer TOKEN'
```

### 2. Review Report Details

```bash
# Get full report details
curl -X GET \
  'http://cp25ssi2.sit.kmutt.ac.th/api/admin/reports/1' \
  -H 'Authorization: Bearer TOKEN'
```

### 3. Resolve a Report

```bash
# Mark report as resolved
curl -X PUT \
  'http://cp25ssi2.sit.kmutt.ac.th/api/admin/reports/1/status' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{"status": "RESOLVED"}'
```

### 4. Dismiss Invalid Report

```bash
# Dismiss report
curl -X PUT \
  'http://cp25ssi2.sit.kmutt.ac.th/api/admin/reports/1/status' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{"status": "DISMISSED"}'
```

---

## 🔧 Testing

### Using Postman

1. Import the API collection
2. Set environment variable: `BASE_URL = http://cp25ssi2.sit.kmutt.ac.th/api`
3. Set authorization token in collection variables
4. Run requests

### Using cURL

Save token to variable:
```bash
export TOKEN="your_jwt_token_here"

# Use in requests
curl -H "Authorization: Bearer $TOKEN" \
  http://cp25ssi2.sit.kmutt.ac.th/api/admin/reports
```

---

## 📚 Additional Resources

- **Swagger UI**: `http://cp25ssi2.sit.kmutt.ac.th/api/swagger-ui.html`
- **Backend Repository**: `backend/cp25ssi2/`
- **Frontend Repository**: `frontend-web/chat2date-admin/`

---

## 🆘 Support

For API issues or questions:
- Check Swagger documentation
- Review error messages in response
- Contact backend development team
- Create issue in project repository

---

**Last Updated:** January 2025  
**API Version:** 1.0.0