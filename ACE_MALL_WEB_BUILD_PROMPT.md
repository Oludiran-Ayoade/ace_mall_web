# Ace Mall Staff Management System - Complete Web Version Build Prompt

## 📋 PROJECT OVERVIEW

Build a complete **Next.js 14+ web application** that is a 100% replica of the existing Flutter mobile app for **Ace Mall Staff Management System**. This is an enterprise-grade HR and workforce management platform for Ace Mall with 13 branches across Nigeria.

### Tech Stack for Web Version
- **Frontend**: Next.js 14+ (App Router), React 18, TypeScript
- **Styling**: TailwindCSS, shadcn/ui components
- **Icons**: Lucide React
- **State Management**: React Context + React Query (TanStack Query)
- **Forms**: React Hook Form + Zod validation
- **Authentication**: JWT tokens stored in httpOnly cookies/localStorage
- **API**: Connect to existing Go backend at `https://ace-supermarket-backend.onrender.com/api/v1`

### Design System
- **Primary Color**: Green (#4CAF50)
- **Dark Green**: #2E7D32
- **Font**: Inter (Google Fonts)
- **Border Radius**: 12px for cards/buttons
- **Shadows**: Modern box-shadows for depth

---

## 🏗️ PHASE 1: PROJECT SETUP & AUTHENTICATION

### Step 1.1: Initialize Next.js Project
```bash
npx create-next-app@latest ace_mall_web --typescript --tailwind --eslint --app --src-dir
cd ace_mall_web
npm install @tanstack/react-query lucide-react react-hook-form zod @hookform/resolvers
npx shadcn-ui@latest init
```

### Step 1.2: Install shadcn/ui Components
```bash
npx shadcn-ui@latest add button card input label select tabs avatar badge dropdown-menu dialog toast sheet table calendar popover command
```

### Step 1.3: Create Project Structure
```
src/
├── app/
│   ├── (auth)/
│   │   ├── signin/page.tsx
│   │   └── forgot-password/page.tsx
│   ├── (dashboard)/
│   │   ├── layout.tsx (with sidebar)
│   │   ├── dashboard/page.tsx
│   │   ├── staff/page.tsx
│   │   ├── staff/[id]/page.tsx
│   │   ├── staff/add/page.tsx
│   │   ├── branches/page.tsx
│   │   ├── departments/page.tsx
│   │   ├── rosters/page.tsx
│   │   ├── rosters/create/page.tsx
│   │   ├── rosters/history/page.tsx
│   │   ├── reviews/page.tsx
│   │   ├── reviews/my-reviews/page.tsx
│   │   ├── promotions/page.tsx
│   │   ├── terminated-staff/page.tsx
│   │   ├── notifications/page.tsx
│   │   ├── reports/page.tsx
│   │   ├── profile/page.tsx
│   │   ├── settings/page.tsx
│   │   └── messaging/page.tsx
│   ├── layout.tsx
│   └── page.tsx (redirect to signin)
├── components/
│   ├── ui/ (shadcn components)
│   ├── layout/
│   │   ├── Sidebar.tsx
│   │   ├── Header.tsx
│   │   └── MobileNav.tsx
│   ├── dashboard/
│   │   ├── StatsCard.tsx
│   │   ├── ActionCard.tsx
│   │   └── WelcomeHeader.tsx
│   ├── staff/
│   │   ├── StaffCard.tsx
│   │   ├── StaffForm.tsx
│   │   ├── StaffTable.tsx
│   │   └── DocumentUploader.tsx
│   ├── roster/
│   │   ├── RosterGrid.tsx
│   │   ├── ShiftCard.tsx
│   │   └── StaffSelector.tsx
│   └── shared/
│       ├── LoadingSpinner.tsx
│       ├── EmptyState.tsx
│       └── ConfirmDialog.tsx
├── contexts/
│   ├── AuthContext.tsx
│   └── NotificationContext.tsx
├── hooks/
│   ├── useAuth.ts
│   ├── useStaff.ts
│   ├── useRoster.ts
│   └── useNotifications.ts
├── lib/
│   ├── api.ts (API client)
│   ├── auth.ts (auth utilities)
│   ├── utils.ts
│   └── constants.ts
├── types/
│   ├── user.ts
│   ├── roster.ts
│   ├── review.ts
│   └── index.ts
└── styles/
    └── globals.css
```

### Step 1.4: Create API Client (`src/lib/api.ts`)
Create a comprehensive API client that mirrors all endpoints:

**Authentication Endpoints:**
- `POST /auth/login` - User login
- `POST /auth/forgot-password` - Send OTP
- `POST /auth/verify-reset-otp` - Verify OTP
- `POST /auth/reset-password` - Reset password
- `POST /auth/change-password` - Change password (authenticated)
- `PUT /auth/update-email` - Update email (authenticated)
- `GET /auth/me` - Get current user

**Data Endpoints:**
- `GET /data/branches` - Get all branches
- `GET /data/departments` - Get all departments
- `GET /data/departments/:id/sub-departments` - Get sub-departments
- `GET /data/roles` - Get all roles
- `GET /data/roles/category/:category` - Get roles by category

### Step 1.5: Create Auth Context (`src/contexts/AuthContext.tsx`)
Handle:
- Login/logout
- Token management
- User state
- Role-based routing

### Step 1.6: Create Sign In Page
Replicate the Flutter signin page:
- Shopping cart icon with green circle background
- "Ace Mall" title with "Welcome back!" subtitle
- Email input with email icon
- Password input with visibility toggle
- Green "Sign In" button with loading state
- "Forgot Password?" link
- Role-based redirect after login

**Role-based Dashboard Routing:**
```typescript
const getDashboardRoute = (roleName: string): string => {
  if (roleName.includes('CEO') || roleName.includes('Chairman') || roleName.includes('Group Head')) {
    return '/dashboard/ceo';
  } else if (roleName.includes('COO')) {
    return '/dashboard/coo';
  } else if (roleName.includes('HR') || roleName.includes('Human Resource')) {
    return '/dashboard/hr';
  } else if (roleName.includes('Auditor')) {
    return '/dashboard/auditor';
  } else if (roleName.includes('Branch Manager')) {
    return '/dashboard/branch-manager';
  } else if (roleName.includes('Floor Manager')) {
    return '/dashboard/floor-manager';
  } else {
    return '/dashboard/staff';
  }
};
```

### Step 1.7: Create Forgot Password Flow
- Email input page
- OTP verification page (6-digit)
- New password page
- Success redirect to signin

---

## 🏗️ PHASE 2: DASHBOARD LAYOUTS & NAVIGATION

### Step 2.1: Create Sidebar Component
Role-based sidebar with sections:

**CEO/Chairman/HR Menu:**
- Dashboard
- Staff Management (submenu: All Staff, Add Staff, Bulk Upload)
- Branches
- Departments
- Rosters (submenu: View Rosters, Roster History)
- Reviews & Ratings
- Promotions
- Terminated Staff
- Reports & Analytics
- Messaging
- Settings

**Branch Manager Menu:**
- Dashboard
- Branch Staff
- Departments
- View Rosters
- Staff Performance
- Reports

**Floor Manager Menu:**
- Dashboard
- My Team
- Roster Management
- Shift Times
- Team Reviews
- My Reviews

**General Staff Menu:**
- Dashboard
- My Profile
- My Schedule
- My Reviews
- Notifications

### Step 2.2: Create Header Component
- User avatar with dropdown (Profile, Settings, Logout)
- Notification bell with badge
- Breadcrumbs
- Mobile menu toggle

### Step 2.3: Create Dashboard Pages

**CEO Dashboard** features:
- Welcome header with user name
- Stats cards: Total Staff, Active Branches (13), Total Departments (6)
- Action cards grid (2x2):
  - Staff Oversight → /staff
  - View Rosters → /rosters
  - Reports & Analytics → /reports
  - Admin Messaging → /messaging
- Quick filters for branches

**HR Dashboard** features:
- Staff statistics
- Action cards:
  - Add New Staff
  - Staff List
  - Promotions
  - Terminated Staff
  - Departments Management
  - Bulk Upload

**Branch Manager Dashboard** features:
- Branch-specific stats
- Staff by department breakdown
- Action cards:
  - Branch Staff
  - View Rosters
  - Staff Performance
  - Branch Reports

**Floor Manager Dashboard** features:
- Team stats
- Action cards:
  - Roster Management
  - My Team
  - Team Reviews
  - Shift Times

**General Staff Dashboard** features:
- Personal info display
- Upcoming shifts
- Recent reviews
- Notifications
- Action cards:
  - My Schedule
  - My Reviews
  - My Profile

---

## 🏗️ PHASE 3: STAFF MANAGEMENT

### Step 3.1: Staff List Page (`/staff`)
**Features:**
- Search bar (name, email, employee ID)
- Filter tabs: By Branch, By Department, Senior Staff
- Staff cards with:
  - Profile picture (with fallback avatar)
  - Full name, role, department
  - Branch, email
  - Salary (for authorized users)
  - Quick actions (View, Edit, Terminate)
- Click to view detailed profile

**API Endpoints:**
- `GET /hr/staff` - Get all staff (HR/CEO)
- `GET /branch/staff` - Get branch staff (Branch Manager)
- `GET /roster/my-team` - Get team (Floor Manager)

### Step 3.2: Staff Detail Page (`/staff/[id]`)
**Sections:**
1. **Header**: Profile picture, name, role, status badge
2. **Basic Info**: Email, phone, gender, DOB, address, state of origin
3. **Work Info**: Employee ID, department, branch, date joined, salary
4. **Education**: Course, grade, institution
5. **Documents**: (with view/download for authorized users)
   - Passport photo
   - National ID
   - Birth Certificate
   - WAEC/NECO Certificate
   - Degree Certificate
   - NYSC Certificate
   - State of Origin Certificate
6. **Next of Kin**: Full details
7. **Guarantors** (2): Info + documents (Passport, National ID, Work ID)
8. **Work Experience**: Previous employment history
9. **Promotion History**: Role changes with dates
10. **Performance Reviews**: Rating history with comments

**Permission Levels:**
- `full_access`: Can view/edit everything (HR, own profile)
- `limited_access`: Can view basic + work info (Managers)
- `basic_access`: Can view only basic info (Others)

**API Endpoints:**
- `GET /staff/:id` - Get staff profile
- `PUT /staff/:id` - Update staff profile
- `GET /promotions/history/:id` - Get promotion history
- `GET /reviews/staff/:id` - Get staff reviews

### Step 3.3: Add Staff Page (`/staff/add`)
**Multi-step form:**

**Step 1: Basic Information**
- Full Name*, Email*, Phone*
- Gender, Marital Status
- Date of Birth, State of Origin
- Home Address

**Step 2: Work Information**
- Role* (dropdown from API)
- Department (dropdown from API)
- Branch (dropdown from API)
- Employee ID
- Salary

**Step 3: Education**
- Course of Study
- Grade
- Institution

**Step 4: Documents Upload**
- Profile Photo (Cloudinary upload)
- Passport, National ID, Birth Certificate
- WAEC, NECO, JAMB Result
- Degree Certificate, NYSC Certificate
- State of Origin Certificate

**Step 5: Next of Kin**
- Full Name, Relationship
- Phone, Email
- Home Address, Work Address

**Step 6: Guarantors (x2)**
- Full Name, Phone
- Occupation, Relationship
- Home Address, Email
- Document uploads (Passport, National ID, Work ID)

**Step 7: Work Experience** (repeatable)
- Company Name, Position
- Start Date, End Date

**API Endpoints:**
- `POST /hr/staff` - Create staff (HR)
- `POST /floor-manager/create-staff` - Create staff (Floor Manager)
- Cloudinary upload for documents

### Step 3.4: Bulk Upload Page
- CSV template download
- CSV file upload
- Preview table before import
- Import progress with results

**API Endpoint:**
- `POST /hr/staff/bulk-upload` - Bulk upload staff

---

## 🏗️ PHASE 4: ROSTER MANAGEMENT

### Step 4.1: View Rosters Page (`/rosters`)
**Features:**
- Filter by Branch (for CEO/HR)
- Filter by Department
- Week selector (previous/current/next)
- Roster grid showing:
  - Days of week as columns
  - Staff as rows
  - Shift times in cells
  - Color-coded by shift type (morning/afternoon/evening/night)
- Click staff name → View profile

**API Endpoints:**
- `GET /roster/by-branch-department` - Get rosters for HR/CEO
- `GET /roster/week` - Get roster for week

### Step 4.2: Create/Edit Roster Page (`/rosters/create`)
**For Floor Managers only:**
- Week date picker
- Staff selector (from team)
- Drag-drop shift assignment
- Shift types:
  - Morning (configurable times)
  - Afternoon (configurable times)
  - Evening (configurable times)
  - Night (configurable times)
- Day-of-week grid
- Save/Publish roster

**API Endpoints:**
- `POST /roster` - Create roster
- `GET /roster/my-team` - Get team members
- `GET /shifts/templates` - Get shift templates
- `PUT /shifts/templates/:id` - Update shift template

### Step 4.3: Roster History Page (`/rosters/history`)
**Features:**
- Year filter (dropdown)
- Month filter
- Branch filter (for CEO/HR)
- Department filter
- List of past rosters with:
  - Week dates
  - Floor manager name
  - Assignment count
  - Attendance rate
- Click to view roster details

**API Endpoint:**
- `GET /roster/by-branch-department?history=true` - Get roster history

### Step 4.4: Shift Times Page (`/rosters/shifts`)
**For Floor Managers:**
- 4 shift cards (Morning, Afternoon, Evening, Night)
- Color-coded cards
- Time pickers for start/end
- Save button per shift

**API Endpoints:**
- `GET /shifts/templates` - Get templates
- `PUT /shifts/templates/:id` - Update template

### Step 4.5: My Schedule Page (`/schedule`)
**For General Staff:**
- Week view with assigned shifts
- Shift details: Day, time, department
- Manager who assigned

**API Endpoint:**
- `GET /roster/my-assignments` - Get personal schedule

---

## 🏗️ PHASE 5: REVIEWS & RATINGS

### Step 5.1: Create Review Dialog/Page
**For Floor Managers:**
- Staff selector (from team)
- 5-star rating for:
  - Attendance
  - Punctuality
  - Performance
- Remarks text area
- Submit button

**API Endpoint:**
- `POST /reviews` - Create review

### Step 5.2: View Ratings Page (`/reviews`)
**For Branch Managers/HR/CEO:**
- Branch filter
- Department filter
- Period filter (week/month/year)
- Table showing:
  - Staff name, role
  - Average rating
  - Review count
  - Latest comment
  - View details link

**API Endpoint:**
- `GET /reviews/by-department` - Get ratings by department

### Step 5.3: My Reviews Page (`/reviews/my-reviews`)
**For All Staff:**
- List of received reviews
- Grouped by week/month
- Show:
  - Date, reviewer name
  - Ratings breakdown
  - Comments
  - Average rating

**API Endpoint:**
- `GET /reviews/my-reviews` - Get own reviews

### Step 5.4: All Staff Reviews Page (`/reviews/all`)
**For HR/CEO:**
- All reviews across organization
- Filters: Branch, Department, Staff, Date range
- Sortable table

**API Endpoint:**
- `GET /hr/reviews` - Get all reviews

---

## 🏗️ PHASE 6: PROMOTIONS & TERMINATIONS

### Step 6.1: Promotions Page (`/promotions`)
**Features:**
- Search staff to promote
- Promotion form:
  - Current role display
  - New role selector (optional)
  - Current salary display
  - New salary input
  - New branch (optional - for transfer)
  - New department (optional)
  - Promotion reason
- Promotion history table

**API Endpoints:**
- `POST /promotions` - Promote staff
- `GET /promotions/history/:id` - Get history

### Step 6.2: Terminated Staff Page (`/terminated-staff`)
**Features:**
- Filters: Termination type, Branch, Department
- Table showing:
  - Name, role, department, branch
  - Termination type (terminated/resigned/retired/contract ended)
  - Termination date
  - Terminated by
  - Reason
- Restore option

**API Endpoints:**
- `GET /staff/departed` - Get terminated staff
- `POST /staff/:id/terminate` - Terminate staff
- `POST /staff/:id/restore` - Restore staff

### Step 6.3: Terminate Staff Dialog
- Termination type selector
- Reason (required)
- Last working day
- Clearance notes
- Confirm button

---

## 🏗️ PHASE 7: NOTIFICATIONS & MESSAGING

### Step 7.1: Notifications Page (`/notifications`)
**Features:**
- List of all notifications
- Type icons (roster, review, promotion, general)
- Read/unread status
- Mark as read on click
- Mark all as read button
- Delete notification
- Relative timestamps

**API Endpoints:**
- `GET /notifications` - Get notifications
- `PUT /notifications/:id/read` - Mark as read
- `PUT /notifications/mark-all-read` - Mark all read
- `DELETE /notifications/:id` - Delete notification
- `GET /notifications/unread-count` - Get count

### Step 7.2: Messaging Page (`/messaging`)
**For Admin (CEO/HR):**
- Target selector: All Staff, Branch, Department
- Title input
- Message content (rich text)
- Send button
- Sent messages history

**API Endpoints:**
- `POST /messages/send` - Send message
- `GET /messages/sent` - Get sent messages

---

## 🏗️ PHASE 8: REPORTS & ANALYTICS

### Step 8.1: Reports Dashboard (`/reports`)
**Sections:**

**Staff Statistics:**
- Total staff by category (pie chart)
- Staff by branch (bar chart)
- Staff by department (bar chart)
- New hires vs terminations trend

**Roster Analytics:**
- Attendance rates by department
- Shift distribution
- Overtime tracking

**Performance Analytics:**
- Average ratings by department
- Top performers list
- Improvement needed list

**Export Options:**
- Export as PDF
- Export as CSV
- Date range selector

---

## 🏗️ PHASE 9: PROFILE & SETTINGS

### Step 9.1: Profile Page (`/profile`)
**Features:**
- Profile picture with upload
- Personal info (editable for own profile)
- Work info (read-only except for HR)
- Work experience (add/edit/delete)
- Qualifications
- Documents (view/upload based on permissions)

**API Endpoints:**
- `GET /profile` - Get own profile
- `PUT /profile/picture` - Update picture
- `PUT /staff/:id/work-experience` - Update experience

### Step 9.2: Settings Page (`/settings`)
**Sections:**
- Change Password
- Change Email
- Notification Preferences
- Theme (light/dark)
- Language (future)

**API Endpoints:**
- `POST /auth/change-password`
- `PUT /auth/update-email`

---

## 🏗️ PHASE 10: BRANCHES & DEPARTMENTS

### Step 10.1: Branches Page (`/branches`)
**Features:**
- List of 13 branches
- Staff count per branch
- Branch manager info
- Click to view branch staff

**API Endpoint:**
- `GET /data/branches`

### Step 10.2: Departments Page (`/departments`)
**Features:**
- 6 main departments
- Sub-departments for Fun & Arcade:
  - Cinema
  - Photo Studio
  - Saloon
  - Arcade and Kiddies Park
  - Casino
- Staff count per department
- Department managers

---

## 📊 DATABASE SCHEMA REFERENCE

### Core Tables:
```sql
-- branches: id, name, location, is_active
-- departments: id, name, description, is_active
-- sub_departments: id, department_id, name
-- roles: id, name, category (senior_admin/admin/general), department_id
-- users: id, email, password_hash, full_name, role_id, department_id, branch_id, ...
-- next_of_kin: id, user_id, full_name, relationship, phone, email, addresses
-- guarantors: id, user_id, guarantor_number, full_name, phone, occupation, ...
-- guarantor_documents: id, guarantor_id, document_type, file_path
-- work_experience: id, user_id, company_name, position, start_date, end_date
-- rosters: id, floor_manager_id, department_id, branch_id, week_start_date, week_end_date
-- roster_assignments: id, roster_id, staff_id, day_of_week, shift_type, start_time, end_time
-- weekly_reviews: id, staff_id, reviewer_id, rating, comments, week_start_date
-- notifications: id, user_id, type, title, message, is_read
-- terminated_staff: id, user_id, full_name, termination_type, reason, terminated_by
-- promotion_history: id, user_id, previous_role_id, new_role_id, previous_salary, new_salary
```

### Role Categories:
- **senior_admin**: CEO, COO, HR, Chairman, Auditors, Group Heads
- **admin**: Branch Managers, Operations Managers, Floor Managers
- **general**: Cashiers, Cooks, Security, Cleaners, etc.

---

## 🎨 UI/UX REQUIREMENTS

### Design Patterns:
1. **Cards with shadows** for grouping content
2. **Green gradient headers** for dashboards
3. **Role-based color coding**:
   - Senior Admin: Purple badges
   - Admin: Blue badges
   - General: Green badges
4. **Responsive design**: Mobile-first approach
5. **Loading states**: Skeleton loaders, bouncing dots
6. **Empty states**: Illustrations with helpful messages
7. **Toast notifications** for success/error feedback
8. **Confirmation dialogs** for destructive actions

### Component Styling:
```css
/* Primary Button */
.btn-primary {
  background: #4CAF50;
  color: white;
  border-radius: 12px;
  padding: 12px 24px;
}

/* Card */
.card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  padding: 24px;
}

/* Input */
.input {
  border: 1px solid #E0E0E0;
  border-radius: 12px;
  padding: 16px;
}
```

---

## 🔐 AUTHENTICATION & AUTHORIZATION

### JWT Token Flow:
1. User logs in with email/password
2. Backend returns JWT token + user data
3. Store token in localStorage/cookie
4. Include `Authorization: Bearer <token>` in all API requests
5. Redirect to signin if 401 received

### Role-Based Access:
```typescript
const ROLE_PERMISSIONS = {
  'senior_admin': ['all'],
  'admin': ['branch_staff', 'rosters', 'reviews', 'create_general_staff'],
  'general': ['own_profile', 'own_schedule', 'own_reviews']
};
```

### Protected Routes:
- All `/dashboard/*` routes require authentication
- Check role before rendering certain components
- API handles final authorization

---

## 📁 FILE UPLOAD (CLOUDINARY)

### Configuration:
```typescript
const CLOUDINARY_CONFIG = {
  cloud_name: 'desk7uuna',
  upload_preset: 'flutter_uploads',
  folders: {
    profile: 'ace_mall_staff/profiles',
    documents: 'ace_mall_staff/documents',
    guarantors: 'ace_mall_staff/guarantors'
  }
};
```

### Upload Flow:
1. User selects file
2. Upload directly to Cloudinary
3. Receive secure_url
4. Save URL to backend

---

## ✅ TESTING CHECKLIST

### Authentication:
- [ ] Login with valid credentials
- [ ] Login with invalid credentials
- [ ] Forgot password flow
- [ ] Password reset
- [ ] Role-based dashboard redirect
- [ ] Logout

### Staff Management:
- [ ] View all staff (HR)
- [ ] View branch staff (Branch Manager)
- [ ] View team (Floor Manager)
- [ ] Search staff
- [ ] Filter by branch/department
- [ ] View staff profile
- [ ] Edit staff profile (permissions)
- [ ] Add new staff
- [ ] Bulk upload staff
- [ ] Upload documents

### Roster Management:
- [ ] View rosters (all roles)
- [ ] Create roster (Floor Manager)
- [ ] Edit roster
- [ ] View roster history
- [ ] Configure shift times
- [ ] View personal schedule (General Staff)

### Reviews:
- [ ] Create review (Floor Manager)
- [ ] View team reviews
- [ ] View own reviews
- [ ] View all reviews (HR/CEO)
- [ ] View ratings by department

### Promotions & Terminations:
- [ ] Promote staff
- [ ] View promotion history
- [ ] Terminate staff
- [ ] Restore staff
- [ ] View terminated staff

### Notifications:
- [ ] View notifications
- [ ] Mark as read
- [ ] Delete notification
- [ ] Unread count badge

---

## 🚀 DEPLOYMENT

### Netlify Deployment:
1. Connect GitHub repo
2. Build command: `npm run build`
3. Publish directory: `.next`
4. Environment variables:
   - `NEXT_PUBLIC_API_URL=https://ace-supermarket-backend.onrender.com/api/v1`
   - `NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME=desk7uuna`

---

## 📌 IMPORTANT NOTES

1. **The backend already exists** - Do NOT modify Go backend, only consume APIs
2. **Use existing API structure** - All endpoints documented above are working
3. **Match Flutter UI/UX** - The web version should feel familiar to mobile users
4. **Role-based everything** - Always check user role before showing features
5. **Handle loading/error states** - Every API call needs proper handling
6. **Responsive design** - Must work on desktop, tablet, and mobile browsers
7. **Test with real data** - Backend has populated data for testing

---

## 🔗 API BASE URL

**Production**: `https://ace-supermarket-backend.onrender.com/api/v1`
**Local Development**: `http://localhost:8080/api/v1`

---

## 📞 TEST CREDENTIALS

| Role | Email | Password |
|------|-------|----------|
| CEO | john@acemarket.com | password |
| HR | masterhr@acesupermarket.com | password |
| Cashier | cashier1.akobo@acesupermarket.com | (email prefix) |

---

**END OF COMPREHENSIVE BUILD PROMPT**

This document contains everything needed to build the complete web version of the Ace Mall Staff Management System with 100% feature parity to the Flutter mobile app.
