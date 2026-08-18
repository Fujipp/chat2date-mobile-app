# Chat2Date Admin - Quick Start Guide

Get up and running with the Chat2Date Admin Dashboard in 5 minutes! 🚀

## 📋 What You'll Need

Before starting, make sure you have:

- ✅ Node.js v20.19.0 or higher ([Download here](https://nodejs.org))
- ✅ Admin access credentials
- ✅ Web browser (Chrome, Firefox, Safari, or Edge)
- ✅ Internet connection

## 🚀 Installation (First Time Only)

### Step 1: Get the Code

```bash
cd repo_Capstone-Project-Chat-To-Date/frontend-web/chat2date-admin
```

### Step 2: Install Dependencies

```bash
npm install
```

This will take 2-3 minutes. ☕

### Step 3: Start the Application

```bash
npm run dev
```

You should see:

```
VITE v7.1.7  ready in XXX ms

➜  Local:   http://localhost:5173/
➜  Network: use --host to expose
```

### Step 4: Open in Browser

Open your browser and go to:

```
http://localhost:5173
```

**🎉 Done! You should now see the admin dashboard.**

---

## 📊 Your First Tasks

### Task 1: View Reports Dashboard

1. The homepage shows all user reports
2. You'll see:
   - **Total Reports** - All reports in the system
   - **Pending** - Reports awaiting review (yellow badge)
   - **Resolved** - Reports that have been handled (green badge)

### Task 2: Filter Reports

Try filtering to see only pending reports:

1. Find the **"Filter by Status"** dropdown
2. Select **"Pending"**
3. Click **"🔄 Refresh"**

Now you only see reports that need your attention!

### Task 3: Review a Report

Let's review your first report:

1. Click the **"👁️ View"** button on any report
2. A detailed modal will open showing:
   - Reporter information (who reported)
   - Target user information (who was reported)
   - Reason and description
   - Evidence photos/videos (if any)

### Task 4: Take Action on a Report

You have 4 options:

| Button | When to Use |
|--------|-------------|
| ✓ **Mark as Resolved** | You've addressed the issue (e.g., warned the user, took action) |
| ✕ **Dismiss** | Report doesn't require action (e.g., misunderstanding) |
| 🚫 **Reject** | Report is invalid or false |
| ↻ **Back to Pending** | Need to review again later |

**Example Flow:**

1. Review the report details
2. Check the evidence
3. Decide on action
4. Click the appropriate button
5. Confirmation message appears
6. Report list automatically refreshes

---

## 🎯 Common Admin Tasks

### Reviewing Harassment Reports

1. Filter by status: **"Pending"**
2. Look for reason: **"Harassment"**
3. Review evidence carefully
4. Check target user's behavior score
5. Take appropriate action

### Checking Report Statistics

The top of the dashboard shows:
- **Total**: All reports ever filed
- **Pending**: Reports awaiting your review
- **Resolved**: Reports you've completed

### Sorting Reports

Change how reports are ordered:

1. **Sort by**: Choose "Date Created", "Report ID", or "Status"
2. **Order**: Choose "Ascending" or "Descending"
3. Click **"🔄 Refresh"**

### Pagination

Navigate through reports:
- Use **"← Previous"** and **"Next →"** buttons
- See page count: "Page 1 of 5"

---

## 💡 Pro Tips

### ⚡ Keyboard Shortcuts

- Press `Esc` to close the report detail modal
- Click outside the modal to close it
- Use browser's Find (Ctrl+F / Cmd+F) to search on page

### 🔍 Quick Filters

Most used filters:
```
Status: PENDING + Sort by: Date Created + Order: DESC
```
This shows newest pending reports first!

### 📱 Mobile Access

The dashboard works on mobile devices:
- Responsive design adapts to screen size
- All features available on phone/tablet
- Best viewed in landscape mode

### 🔄 Auto-Refresh

After updating a report status:
- List automatically refreshes in 1 second
- No need to manually reload page

---

## 🆘 Troubleshooting

### Problem: Can't see any reports

**Solution:**
```bash
# Check if backend is running
curl http://cp25ssi2.sit.kmutt.ac.th/api/admin/reports
```

If you get an error, the backend might be down. Contact tech support.

### Problem: Port 5173 already in use

**Solution:**
```bash
# Kill the existing process
npx kill-port 5173

# Or use a different port
npm run dev -- --port 3000
```

### Problem: Page won't load

**Solution:**
1. Hard refresh: `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)
2. Clear browser cache
3. Check browser console for errors (F12)

### Problem: Changes not appearing

**Solution:**
```bash
# Stop the server (Ctrl+C)
# Clear cache and restart
rm -rf node_modules/.vite
npm run dev
```

---

## 📚 Where to Learn More

| Document | What's Inside |
|----------|---------------|
| `README.md` | Full feature list and installation guide |
| `DEVELOPMENT.md` | Developer documentation and code standards |
| `API_DOCUMENTATION.md` | Complete API reference |

### Quick Links

- **Reports Dashboard**: `http://localhost:5173/`
- **User Management**: `http://localhost:5173/users`
- **About Page**: `http://localhost:5173/about`
- **API Docs**: `http://cp25ssi2.sit.kmutt.ac.th/api/swagger-ui.html`

---

## 🎓 Training Scenarios

### Scenario 1: Handle a Spam Report

1. Filter: `Status = PENDING`
2. Find a report with `Reason = Spam`
3. Click "👁️ View"
4. Review evidence
5. Check target user's behavior score
6. If confirmed spam: Click "✓ Mark as Resolved"

### Scenario 2: Dismiss False Report

1. Open any pending report
2. Review details - realize it's a misunderstanding
3. Click "✕ Dismiss"
4. Report is marked as dismissed

### Scenario 3: Review Multiple Reports

1. Set: `Size = 20` (shows 20 reports per page)
2. Review first 5 reports
3. Take action on each
4. Use pagination to go to next page

---

## ⚙️ Production Deployment

### Building for Production

```bash
# Create optimized build
npm run build

# Preview production build
npm run preview
```

### Environment Variables

Create `.env.production`:

```env
VITE_API_BASE_URL=https://your-production-api.com/api
```

### Deploy to Server

```bash
# Build
npm run build

# Copy dist/ folder to your web server
# Example: nginx, Apache, or any static hosting
```

---

## 🚦 Daily Workflow

### Morning Routine

1. Start the dashboard: `npm run dev`
2. Open: `http://localhost:5173`
3. Check **Pending** reports count
4. Sort by newest first
5. Review and action on new reports

### During the Day

- Check dashboard every 2-3 hours
- Prioritize harassment and safety reports
- Keep "Pending" count low
- Document any patterns you notice

### End of Day

- Review all actions taken
- Check if any reports need follow-up
- Close browser tab
- Stop server: `Ctrl+C` in terminal

---

## 📞 Getting Help

### In the App

- Click "About" page for system information
- Check console (F12) for error messages

### Contact Support

- **Technical Issues**: Contact development team
- **Backend Problems**: Check with backend developers
- **Feature Requests**: Create issue in repository

### Emergency Contacts

- Backend API down? → Contact infrastructure team
- Critical security issue? → Escalate immediately

---

## ✅ Checklist for Admins

Before you start each session:

- [ ] Backend API is accessible
- [ ] Browser is updated to latest version
- [ ] You have admin credentials ready
- [ ] You know the escalation process

During your session:

- [ ] Review all pending reports
- [ ] Take appropriate action on each
- [ ] Document any unusual patterns
- [ ] Keep response time under 24 hours

---

## 🎯 Success Metrics

Good admin performance:

- ✅ **Response Time**: Review reports within 24 hours
- ✅ **Accuracy**: Make correct decisions on report validity
- ✅ **Thoroughness**: Review all evidence before deciding
- ✅ **Consistency**: Apply rules fairly to all users

---

## 🔐 Security Best Practices

1. **Never share** your admin credentials
2. **Always log out** when done
3. **Don't screenshot** user personal information
4. **Report** any security concerns immediately
5. **Use HTTPS** in production

---

## 🎉 You're Ready!

You now know how to:

- ✅ Start the admin dashboard
- ✅ View and filter reports
- ✅ Review report details
- ✅ Take action on reports
- ✅ Handle common issues
- ✅ Find help when needed

**Happy moderating! Keep Chat2Date safe for everyone.** 💙

---

**Need help?** Check `README.md` or contact the development team.

**Last Updated:** January 2025