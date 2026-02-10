# Chat2Date Admin Dashboard

Admin dashboard for managing user reports and moderation for the Chat2Date dating application.

## 🎯 Overview

This is the administrative web interface for Chat2Date, built with Vue.js 3. It provides administrators with tools to manage user reports, review evidence, and take appropriate actions on reported content.

## ✨ Features

### Report Management
- **View All Reports** - Browse and filter all user reports with pagination
- **Filter & Sort** - Filter by status (Pending, Resolved, Dismissed, Rejected) and sort by date or ID
- **Detailed View** - View comprehensive report details including:
  - Reporter information (profile, contact, behavior score)
  - Target user information
  - Report reason and description
  - Evidence files (images/videos)
  - Report status and timestamps

### Report Actions
- **Mark as Resolved** - Close reports that have been addressed
- **Dismiss** - Dismiss reports that don't require action
- **Reject** - Reject invalid or false reports
- **Back to Pending** - Reopen resolved reports for review

### Dashboard Features
- **Statistics Summary** - Quick overview of total, pending, and resolved reports
- **Responsive Design** - Mobile-friendly interface
- **Real-time Updates** - Automatic refresh after status changes
- **User Information** - View detailed profiles of both reporter and target users

## 🛠️ Tech Stack

- **Vue.js 3** - Progressive JavaScript framework
- **Vue Router 4** - Official router for Vue.js
- **Pinia** - State management
- **Vite** - Next-generation frontend tooling
- **CSS3** - Custom styling with CSS variables

## 🎨 Design System

The dashboard follows the Chat2Date brand guidelines with:
- **Primary Color**: `#78CEFF` (Brand Blue)
- **Secondary Color**: `#98FB98` (Light Green)
- **Accent Color**: `#5CE1E6` (Turquoise)
- **Status Colors**:
  - Success: `#9FE2BF`
  - Warning: `#FFD166`
  - Error: `#FF6B6B`
  - Info: `#A7E0FF`

## 📋 Prerequisites

- Node.js `^20.19.0` or `>=22.12.0`
- npm or yarn package manager
- Access to Chat2Date backend API

## 🚀 Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd repo_Capstone-Project-Chat-To-Date/frontend-web/chat2date-admin
```

2. **Install dependencies**
```bash
npm install
```

3. **Configure API endpoint**

Edit the API base URL in `src/views/ReportsView.vue`:
```javascript
const API_BASE_URL = 'http://cp25ssi2.sit.kmutt.ac.th/api/admin'
```

4. **Run development server**
```bash
npm run dev
```

The application will be available at `http://localhost:5173`

## 📦 Build for Production

```bash
npm run build
```

Build output will be in the `dist/` directory.

## 🐳 Docker Deployment

Build and run with Docker:

```bash
# Build image
docker build -t chat2date-admin .

# Run container
docker run -p 8080:80 chat2date-admin
```

## 🔌 API Endpoints

The admin dashboard connects to the following backend endpoints:

### Get All Reports
```
GET /api/admin/reports?page=0&size=20&status=PENDING&sortBy=createdAt&sortDirection=DESC
```

**Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 20)
- `status` (optional): Filter by status (PENDING, RESOLVED, DISMISSED, REJECTED)
- `sortBy` (optional): Sort field (default: createdAt)
- `sortDirection` (optional): Sort direction (ASC, DESC)

**Response:**
```json
{
  "content": [...],
  "totalPages": 5,
  "totalElements": 95
}
```

### Get Report Details
```
GET /api/admin/reports/{id}
```

**Response:**
```json
{
  "reportId": 1,
  "reporterId": "user123",
  "targetUserId": "user456",
  "reason": "Harassment",
  "description": "...",
  "status": "PENDING",
  "evidenceUrls": ["https://..."],
  "reporter": {...},
  "targetUser": {...},
  "createdAt": "2024-01-15T10:30:00"
}
```

### Update Report Status
```
PUT /api/admin/reports/{id}/status
```

**Request Body:**
```json
{
  "status": "RESOLVED"
}
```

**Response:**
```json
{
  "reportId": 1,
  "status": "RESOLVED",
  ...
}
```

## 🔐 Authentication

⚠️ **Note**: This dashboard currently does not implement authentication. In production, you should:

1. Add login/authentication system
2. Implement JWT token management
3. Protect routes with auth guards
4. Add role-based access control (ADMIN role required)

Example authentication setup:
```javascript
// In your API calls
headers: {
  'Content-Type': 'application/json',
  'Authorization': `Bearer ${token}`
}
```

## 📱 Views

### Reports View (`/`)
Main dashboard for managing reports with:
- Statistics cards
- Filter and sort controls
- Reports table with pagination
- Detailed report modal

### Users View (`/users`)
User management interface (redirects to original user list)

### About View (`/about`)
Information about the application

## 🎯 Usage

### Viewing Reports

1. Open the dashboard at `http://localhost:5173`
2. Reports are displayed in a paginated table
3. Use filters to narrow down results by status
4. Sort by date, ID, or status

### Managing a Report

1. Click "👁️ View" on any report
2. Review all report details including:
   - Reporter and target user information
   - Report reason and description
   - Evidence files (click to view full size)
3. Choose an action:
   - **✓ Mark as Resolved** - Report has been handled
   - **✕ Dismiss** - Report doesn't require action
   - **🚫 Reject** - Report is invalid
   - **↻ Back to Pending** - Reopen for review

### Filtering and Sorting

- **Status Filter**: Show only reports with specific status
- **Sort By**: Order by creation date, report ID, or status
- **Order**: Ascending or descending
- **Refresh**: Reload data from server

## 🧪 Development

### Project Structure
```
src/
├── assets/           # Static assets and global styles
│   ├── base.css     # Base CSS variables
│   └── main.css     # Main stylesheet with theme
├── components/       # Reusable Vue components
├── router/          # Vue Router configuration
│   └── index.js
├── stores/          # Pinia stores
├── views/           # Page components
│   ├── ReportsView.vue  # Main reports dashboard
│   ├── HomeView.vue     # Users list
│   └── AboutView.vue    # About page
├── App.vue          # Root component with navigation
└── main.js          # Application entry point
```

### Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Lint and fix files
- `npm run format` - Format code with Prettier
- `npm run test:unit` - Run unit tests
- `npm run test:e2e` - Run E2E tests with Cypress

### Adding New Features

1. Create new component in `src/components/` or view in `src/views/`
2. Add route in `src/router/index.js` if needed
3. Use existing CSS variables from `main.css` for consistent styling
4. Follow Vue 3 Composition API patterns

### Code Style

This project uses:
- **ESLint** for code linting
- **Prettier** for code formatting
- **Vue 3 Composition API** (`<script setup>`)

## 🎨 Customization

### Changing Theme Colors

Edit CSS variables in `src/assets/main.css`:

```css
:root {
  --brand-primary: #78ceff;
  --brand-secondary: #98fb98;
  --btn-primary: #5ce1e6;
  /* ... */
}
```

### Modifying API Endpoint

Update the API base URL in `src/views/ReportsView.vue`:

```javascript
const API_BASE_URL = 'https://your-api-domain.com/api/admin'
```

### Adding New Report Status

1. Add status to backend enum
2. Add badge style in `main.css`:
```css
.badge-newstatus {
  background-color: #your-color;
  color: var(--text-primary);
}
```

## 🐛 Troubleshooting

### CORS Issues

If you encounter CORS errors, ensure your backend allows requests from your frontend domain:

```java
@CrossOrigin(origins = "http://localhost:5173")
```

### API Connection Failed

1. Verify backend is running
2. Check API endpoint URL is correct
3. Ensure you have admin authentication (if implemented)
4. Check browser console for detailed error messages

### Reports Not Loading

1. Check browser console for errors
2. Verify API returns data in expected format
3. Check pagination parameters are valid
4. Ensure backend API endpoints are accessible

## 📝 License

This project is part of the Chat2Date capstone project.

## 👥 Team

CP25SSI2 - Chat2Date Team

## 🔗 Related Projects

- **Backend API**: `backend/cp25ssi2/`
- **Mobile App**: `frontend-mobile/chat2date/`

## 📞 Support

For issues or questions, please contact the development team or create an issue in the project repository.

---

**Last Updated**: January 2025