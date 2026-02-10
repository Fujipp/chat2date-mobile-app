# Chat2Date Admin - Development Guide

Complete guide for developers working on the Chat2Date Admin Dashboard.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Environment Configuration](#environment-configuration)
- [Code Standards](#code-standards)
- [API Integration](#api-integration)
- [Testing](#testing)
- [Building and Deployment](#building-and-deployment)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## 🔧 Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js**: `^20.19.0` or `>=22.12.0`
- **npm**: `>=9.0.0` (comes with Node.js)
- **Git**: For version control
- **VS Code** (recommended): With Vue.js extensions

### Recommended VS Code Extensions

```json
{
  "recommendations": [
    "Vue.volar",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss"
  ]
}
```

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd repo_Capstone-Project-Chat-To-Date/frontend-web/chat2date-admin
```

### 2. Install Dependencies

```bash
npm install
```

This will install all required packages including:
- Vue.js 3
- Vue Router 4
- Pinia
- Vite
- ESLint & Prettier
- Vitest & Cypress

### 3. Set Up Environment Variables

Create a `.env.local` file in the root directory:

```env
# API Configuration
VITE_API_BASE_URL=http://cp25ssi2.sit.kmutt.ac.th/api

# Development Settings
VITE_DEV_MODE=true
```

### 4. Start Development Server

```bash
npm run dev
```

The application will be available at `http://localhost:5173`

## 📁 Project Structure

```
chat2date-admin/
├── public/                 # Static assets
├── src/
│   ├── assets/            # Images, styles, fonts
│   │   ├── base.css       # CSS reset and base styles
│   │   └── main.css       # Main stylesheet with theme
│   ├── components/        # Reusable Vue components
│   ├── router/            # Vue Router configuration
│   │   └── index.js       # Route definitions
│   ├── services/          # API services
│   │   └── api.js         # Centralized API calls
│   ├── stores/            # Pinia state management
│   ├── views/             # Page components
│   │   ├── ReportsView.vue    # Reports dashboard
│   │   ├── HomeView.vue       # User management
│   │   └── AboutView.vue      # About page
│   ├── App.vue            # Root component
│   └── main.js            # Application entry point
├── .env.example           # Environment variables template
├── .eslintrc.js           # ESLint configuration
├── .prettierrc.json       # Prettier configuration
├── cypress/               # E2E test files
├── vitest.config.js       # Unit test configuration
├── vite.config.js         # Vite build configuration
└── package.json           # Project dependencies
```

## 🔄 Development Workflow

### Daily Development

1. **Pull Latest Changes**
```bash
git pull origin main
```

2. **Create Feature Branch**
```bash
git checkout -b feature/your-feature-name
```

3. **Start Development Server**
```bash
npm run dev
```

4. **Make Changes and Test**
- Edit files in `src/`
- Changes hot-reload automatically
- Check console for errors

5. **Lint and Format Code**
```bash
npm run lint
npm run format
```

6. **Run Tests**
```bash
npm run test:unit
```

7. **Commit Changes**
```bash
git add .
git commit -m "feat: add new feature"
```

### Commit Message Convention

Follow conventional commits format:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting)
- `refactor:` Code refactoring
- `test:` Adding tests
- `chore:` Build process or auxiliary tool changes

Examples:
```
feat: add report filtering by date range
fix: correct pagination calculation
docs: update API integration guide
style: format code with prettier
refactor: extract API service to separate module
test: add unit tests for report component
chore: update dependencies
```

## ⚙️ Environment Configuration

### Environment Files

- `.env` - Default configuration (committed to repo)
- `.env.local` - Local overrides (not committed)
- `.env.production` - Production configuration

### Available Variables

```env
# API Configuration
VITE_API_BASE_URL=http://localhost:8080/api

# Feature Flags
VITE_ENABLE_ANALYTICS=false
VITE_ENABLE_DEBUG=true

# App Configuration
VITE_APP_TITLE=Chat2Date Admin
VITE_APP_VERSION=1.0.0
```

### Accessing Environment Variables

```javascript
// In your code
const apiUrl = import.meta.env.VITE_API_BASE_URL
const isDev = import.meta.env.DEV
const isProd = import.meta.env.PROD
```

## 📝 Code Standards

### Vue 3 Composition API

Always use `<script setup>` syntax:

```vue
<script setup>
import { ref, computed, onMounted } from 'vue'

const count = ref(0)
const doubled = computed(() => count.value * 2)

onMounted(() => {
  console.log('Component mounted')
})
</script>
```

### Component Naming

- Use PascalCase for component files: `ReportCard.vue`
- Use kebab-case in templates: `<report-card />`

### Props and Emits

```vue
<script setup>
const props = defineProps({
  reportId: {
    type: Number,
    required: true
  },
  status: {
    type: String,
    default: 'PENDING'
  }
})

const emit = defineEmits(['update', 'delete'])

const handleUpdate = () => {
  emit('update', props.reportId)
}
</script>
```

### CSS Styling

Use scoped styles and CSS variables:

```vue
<style scoped>
.card {
  background: var(--bg-white);
  border-radius: var(--radius-lg);
  padding: var(--spacing-md);
}

.card-title {
  color: var(--text-primary);
  font-size: 1.25rem;
}
</style>
```

### ESLint Rules

Project uses ESLint with Vue.js plugin. Key rules:

- No unused variables
- Consistent spacing and indentation
- Vue component naming conventions
- Proper import ordering

## 🔌 API Integration

### Using API Service

Always use the centralized API service in `src/services/api.js`:

```javascript
import api from '@/services/api'

// Fetch reports
const fetchReports = async () => {
  try {
    const data = await api.report.getAll({
      page: 0,
      size: 20,
      status: 'PENDING'
    })
    reports.value = data.content
  } catch (error) {
    console.error('Failed to fetch reports:', error)
  }
}

// Get report details
const getReportDetails = async (id) => {
  const report = await api.report.getById(id)
  return report
}

// Update report status
const updateStatus = async (id, status) => {
  await api.report.updateStatus(id, status)
}
```

### Error Handling

```javascript
const fetchData = async () => {
  loading.value = true
  error.value = null
  
  try {
    const data = await api.report.getAll()
    reports.value = data.content
  } catch (err) {
    error.value = err.message
    console.error('API Error:', err)
  } finally {
    loading.value = false
  }
}
```

### Adding New API Endpoints

Edit `src/services/api.js`:

```javascript
export const reportApi = {
  // ... existing methods
  
  getStatistics: async () => {
    const response = await fetch(`${ADMIN_API_URL}/reports/stats`, {
      method: 'GET',
      headers: getHeaders(),
    })
    return handleResponse(response)
  }
}
```

## 🧪 Testing

### Unit Tests (Vitest)

Run unit tests:

```bash
npm run test:unit
```

Example test file `src/components/__tests__/ReportCard.spec.js`:

```javascript
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import ReportCard from '../ReportCard.vue'

describe('ReportCard', () => {
  it('renders report information correctly', () => {
    const wrapper = mount(ReportCard, {
      props: {
        reportId: 1,
        status: 'PENDING'
      }
    })
    
    expect(wrapper.text()).toContain('#1')
    expect(wrapper.text()).toContain('PENDING')
  })
})
```

### E2E Tests (Cypress)

Run E2E tests:

```bash
# Development mode with GUI
npm run test:e2e:dev

# Production mode (headless)
npm run test:e2e
```

Example E2E test `cypress/e2e/reports.cy.js`:

```javascript
describe('Reports Dashboard', () => {
  it('loads and displays reports', () => {
    cy.visit('/')
    cy.contains('h1', 'Report Management')
    cy.get('table tbody tr').should('have.length.at.least', 1)
  })
  
  it('filters reports by status', () => {
    cy.visit('/')
    cy.get('#status-filter').select('PENDING')
    cy.get('.badge-pending').should('exist')
  })
})
```

## 🏗️ Building and Deployment

### Development Build

```bash
npm run dev
```

### Production Build

```bash
npm run build
```

Build output will be in `dist/` directory.

### Preview Production Build

```bash
npm run preview
```

### Docker Deployment

Build Docker image:

```bash
docker build -t chat2date-admin:latest .
```

Run container:

```bash
docker run -p 8080:80 chat2date-admin:latest
```

### Deployment Checklist

- [ ] Run tests: `npm run test:unit`
- [ ] Lint code: `npm run lint`
- [ ] Build for production: `npm run build`
- [ ] Test production build: `npm run preview`
- [ ] Update environment variables
- [ ] Configure CORS on backend
- [ ] Set up SSL/TLS certificates
- [ ] Configure CDN (if applicable)
- [ ] Set up monitoring and logging

## 🔍 Troubleshooting

### Common Issues

#### Port Already in Use

```bash
# Find process using port 5173
lsof -ti:5173

# Kill the process
kill -9 <PID>
```

#### Module Not Found

```bash
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

#### ESLint Errors

```bash
# Auto-fix linting issues
npm run lint

# Format code
npm run format
```

#### CORS Errors

Add CORS configuration to backend:

```java
@CrossOrigin(origins = "http://localhost:5173")
```

#### Build Errors

```bash
# Clear Vite cache
rm -rf node_modules/.vite

# Rebuild
npm run build
```

### Debug Mode

Enable Vue DevTools in browser:

1. Install Vue.js devtools extension
2. Open browser DevTools
3. Navigate to "Vue" tab

### Performance Profiling

```javascript
// Add performance marks
performance.mark('fetch-start')
await fetchReports()
performance.mark('fetch-end')
performance.measure('fetch-reports', 'fetch-start', 'fetch-end')
```

## ✅ Best Practices

### Code Organization

1. **Keep components small and focused**
   - One component should do one thing
   - Extract reusable logic to composables

2. **Use composables for shared logic**

```javascript
// src/composables/useReports.js
import { ref } from 'vue'
import api from '@/services/api'

export function useReports() {
  const reports = ref([])
  const loading = ref(false)
  
  const fetchReports = async (params) => {
    loading.value = true
    try {
      const data = await api.report.getAll(params)
      reports.value = data.content
    } finally {
      loading.value = false
    }
  }
  
  return { reports, loading, fetchReports }
}
```

3. **Use TypeScript JSDoc for better IntelliSense**

```javascript
/**
 * Fetch report details by ID
 * @param {number} reportId - The report ID
 * @returns {Promise<Object>} Report details
 */
async function getReportDetails(reportId) {
  // ...
}
```

### Performance Optimization

1. **Use computed properties for derived state**
2. **Implement virtual scrolling for large lists**
3. **Lazy load components**

```javascript
const ReportDetails = defineAsyncComponent(() =>
  import('./components/ReportDetails.vue')
)
```

4. **Debounce search inputs**

```javascript
import { debounce } from 'lodash-es'

const handleSearch = debounce((query) => {
  fetchReports({ search: query })
}, 300)
```

### Security

1. **Never commit sensitive data**
2. **Use environment variables for configuration**
3. **Sanitize user input**
4. **Implement proper authentication**
5. **Use HTTPS in production**

### Accessibility

1. **Use semantic HTML**
2. **Add ARIA labels**
3. **Ensure keyboard navigation**
4. **Maintain color contrast ratios**

```vue
<button
  aria-label="View report details"
  @click="viewReport"
>
  View
</button>
```

## 📚 Additional Resources

- [Vue.js Documentation](https://vuejs.org)
- [Vue Router Documentation](https://router.vuejs.org)
- [Pinia Documentation](https://pinia.vuejs.org)
- [Vite Documentation](https://vitejs.dev)
- [Vitest Documentation](https://vitest.dev)
- [Cypress Documentation](https://www.cypress.io)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📞 Support

For questions or issues:

- Create an issue in the repository
- Contact the development team
- Check existing documentation

---

**Happy Coding! 🚀**