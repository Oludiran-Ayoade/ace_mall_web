# COMPREHENSIVE PROMPT: Make Web App 100% Identical to Flutter App

## ✅ BRANCH COUNT CONFIRMED
**Total Branches**: **13 branches** (this is correct)
**Branches in schema.sql**:
1. Ace Mall, Oluyole (Oluyole, Ibadan)
2. Ace Mall, Bodija (Bodija, Ibadan)
3. Ace Mall, Akobo (Akobo, Ibadan)
4. Ace Mall, Oyo (Oyo Town)
5. Ace Mall, Ogbomosho (Ogbomosho)
6. Ace Mall, Ilorin (Ilorin, Kwara)
7. Ace Mall, Iseyin (Iseyin)
8. Ace Mall, Saki (Saki)
9. Ace Mall, Ife (Ile-Ife)
10. Ace Mall, Osogbo (Osogbo)
11. Ace Mall, Abeokuta (Abeokuta)
12. Ace Mall, Ijebu (Ijebu-Ode)
13. Ace Mall, Sagamu (Sagamu)

**VERIFICATION REQUIRED**: 
- Ensure backend API returns all 13 branches correctly
- Verify web app displays all 13 branches
- Confirm branch data is consistent across app and web

---

## 📱 FLUTTER APP ANALYSIS (Complete Feature List)

### **Pages in Flutter App (49 total)**:

#### 1. **Authentication & Onboarding**
- `intro_page.dart` - Animated splash screen
- `signin_page.dart` - Login with email/password
- `signup_page.dart` - Registration form
- `forgot_password_page.dart` - Password recovery
- `staff_type_selection_page.dart` - Admin vs General staff
- `role_selection_page.dart` - Role picker
- `branch_selection_page.dart` - Branch picker
- `department_selection_page.dart` - Department picker

#### 2. **Dashboard Pages (Role-Based)**
- `ceo_dashboard_page.dart` - CEO dashboard
- `coo_dashboard_page.dart` - COO dashboard with branch reports
- `hr_dashboard_page.dart` - HR dashboard
- `auditor_dashboard_page.dart` - Auditor dashboard
- `branch_manager_dashboard_page.dart` - Branch manager dashboard
- `floor_manager_dashboard_page.dart` - Floor manager dashboard
- `operations_manager_dashboard_page.dart` - Operations manager dashboard
- `compliance_officer_dashboard_page.dart` - Compliance dashboard
- `facility_manager_dashboard_page.dart` - Facility manager dashboard
- `general_staff_dashboard_page.dart` - General staff dashboard

#### 3. **Staff Management**
- `staff_list_page.dart` - All staff with 3 tabs:
  - By Branch (expandable with department grouping)
  - By Department (expandable with branch grouping)
  - Senior Staff
- `staff_detail_page.dart` - Individual staff profile
- `staff_profile_creation_page.dart` - Multi-step staff creation with document uploads
- `add_general_staff_page.dart` - Floor manager staff creation
- `floor_manager_add_staff_page.dart` - Floor manager specific creation
- `view_profile_page.dart` - Staff profile viewer
- `staff_performance_page.dart` - Performance tracking

#### 4. **Staff Actions**
- `staff_promotion_page.dart` - Promotion/transfer/salary increase (3 types)
- `terminated_staff_page.dart` - Departed staff archive with type filters
- `departed_staff_detail_page.dart` - Detailed termination info

#### 5. **Branch & Department Management**
- `branch_staff_list_page.dart` - Staff in specific branch
- `branch_departments_page.dart` - Departments within branch
- `branch_reports_page.dart` - Branch-specific reports
- `branch_staff_performance_page.dart` - Branch staff performance
- `departments_management_page.dart` - Department management
- `coo_branch_report_page.dart` - COO branch reports

#### 6. **Roster & Schedule Management**
- `roster_management_page.dart` - Create/edit rosters
- `view_rosters_page.dart` - View current rosters
- `roster_history_page.dart` - Past rosters with filters
- `my_schedule_page.dart` - Personal schedule view
- `shift_times_page.dart` - Shift timing configuration

#### 7. **Reviews & Performance**
- `floor_manager_team_page.dart` - Floor manager team view
- `floor_manager_team_reviews_page.dart` - Team reviews
- `my_reviews_page.dart` - Personal reviews
- `weekly_review_page.dart` - Weekly review submission

#### 8. **Messaging & Communication**
- `admin_messaging_page.dart` - Send announcements (all staff, by branch, by department)
- `notifications_page.dart` - Notification center

#### 9. **Reports & Analytics**
- `reports_analytics_page.dart` - Comprehensive reports

#### 10. **Profile & Settings**
- `profile_page.dart` - User profile management
- `settings_page.dart` - Account settings
- `change_password_page.dart` - Password change
- `change_email_page.dart` - Email change

#### 11. **Document Management**
- `full_screen_document_page.dart` - Document viewer

---

## 🌐 WEB APP ANALYSIS (Current Implementation)

### **Pages in Web App (17 total)**:
1. `/dashboard` - Main dashboard
2. `/dashboard/staff` - Staff list
3. `/dashboard/staff/[id]` - Staff profile
4. `/dashboard/staff/add` - Add staff (INCOMPLETE)
5. `/dashboard/branches` - Branches (✅ FIXED)
6. `/dashboard/departments` - Departments (✅ FIXED)
7. `/dashboard/promotions` - Promotions (NEEDS REBUILD)
8. `/dashboard/terminated-staff` - Terminated staff (✅ FIXED)
9. `/dashboard/reports` - Reports (✅ FIXED)
10. `/dashboard/messaging` - Messaging (✅ FIXED)
11. `/dashboard/reviews` - Reviews
12. `/dashboard/my-reviews` - Personal reviews
13. `/dashboard/rosters` - Rosters
14. `/dashboard/schedule` - Schedule
15. `/dashboard/notifications` - Notifications
16. `/dashboard/profile` - Profile
17. `/dashboard/settings` - Settings

---

## 🔴 CRITICAL MISSING FEATURES IN WEB APP

### 1. **Role-Based Dashboards**
**Flutter**: 10 different dashboards for different roles
**Web**: 1 generic dashboard for all roles

**REQUIRED**: Implement role-specific dashboards:
- CEO Dashboard with company-wide oversight
- COO Dashboard with branch reports
- HR Dashboard with staff management tools
- Branch Manager Dashboard with branch-specific tools
- Floor Manager Dashboard with team management
- General Staff Dashboard with personal info only

### 2. **Staff Creation Form - INCOMPLETE**
**Flutter**: 9-step multi-step form with document uploads
**Web**: Basic form without document uploads

**Steps Required**:
1. **Basic Information**: Name, email, phone, employee ID, DOB, gender, marital status, address, state of origin, date joined
2. **Education**: Course, grade, institution, exam scores
3. **Work Experience**: Multiple entries (company, roles, start date, end date)
4. **Ace Mall Roles History**: Previous promotions/roles within company
5. **Salary**: Current salary input
6. **Next of Kin**: Full name, relationship, email, phone, home address, work address
7. **Guarantor 1**: 
   - Full details: name, phone, occupation, relationship, sex, age, address, email, DOB, grade level
   - **3 Document Uploads**: Passport, National ID, Work ID
8. **Guarantor 2**: 
   - Same as Guarantor 1
   - **3 Document Uploads**: Passport, National ID, Work ID
9. **Staff Documents** (8 uploads):
   - Birth Certificate
   - Passport Photo
   - Valid ID
   - NYSC Certificate
   - Degree Certificate
   - WAEC Certificate
   - State of Origin Certificate
   - First Leaving Certificate

**Document Upload Requirements**:
- Support PDF, JPG, JPEG, PNG formats
- File size limit (e.g., 5MB per file)
- Upload progress indicator
- Preview uploaded files
- Ability to remove/replace files
- Integration with cloud storage (Cloudinary or S3)

### 3. **Staff Promotion/Transfer System - INCOMPLETE**
**Flutter**: 3-type promotion system with multi-step wizard
**Web**: Basic promotion form only

**3 Promotion Types Required**:

#### Type 1: **Promotion (New Role + Salary)**
- Select staff
- Choose new role (higher level)
- Enter new salary
- Enter promotion reason
- Show before/after comparison
- Confirmation dialog

#### Type 2: **Salary Increase Only**
- Select staff
- Keep same role
- Enter new salary (must be higher)
- Enter reason
- Show current vs new salary
- Confirmation dialog

#### Type 3: **Transfer & Promotion**
- Select staff
- Choose new branch
- Choose new department (optional)
- Choose new role (optional)
- Enter new salary
- Enter transfer/promotion reason
- Show all changes (branch, dept, role, salary)
- Confirmation dialog

**Multi-Step Wizard Required**:
1. **Select Staff**: Searchable list with filters
2. **Choose Promotion Type**: 3 cards to select type
3. **Enter Details**: Based on selected type
4. **Review & Confirm**: Summary with before/after comparison
5. **Success Message**: Confirmation and history update

### 4. **Staff Transfer Feature - MISSING ENTIRELY**
**Flutter**: Dedicated transfer page
**Web**: Does not exist

**Required Features**:
- Select staff from searchable list
- Select new branch (dropdown)
- Select new department (optional dropdown)
- Transfer reason (text area)
- Effective date (date picker)
- Before/After comparison display:
  - Current Branch → New Branch
  - Current Department → New Department
- Transfer history tracking
- Confirmation dialog
- Success notification

**Backend Endpoint Needed**:
```
POST /api/v1/hr/staff/:id/transfer
Body: {
  new_branch_id: string,
  new_department_id?: string,
  reason: string,
  effective_date?: string
}
Response: {
  message: string,
  transfer_record: TransferHistory
}
```

### 5. **Roster Pages - NEED VERIFICATION**
**Flutter**: 
- `roster_management_page.dart` - Create/edit rosters
- `view_rosters_page.dart` - Current week rosters
- `roster_history_page.dart` - Past rosters with year/month filters

**Web**: Basic roster pages exist but need verification they match Flutter:
- Proper role-based access (Floor Manager create, Branch Manager view, CEO view all)
- Shift templates
- Staff assignment with drag-drop or selection
- Weekly schedule view (Monday-Sunday grid)
- Save and publish functionality
- History with filters (year, month, branch, department)
- Attendance tracking integration

### 6. **Branch Reports (COO Feature) - MISSING**
**Flutter**: `coo_branch_report_page.dart`
**Web**: Does not exist

**Required Features**:
- Select branch from dropdown
- Date range filter
- Report sections:
  - Staff count and distribution
  - Department performance
  - Attendance statistics
  - Sales/performance metrics (if available)
  - Active rosters
  - Recent promotions
  - Recent terminations
- Export report functionality
- Print report functionality

### 7. **Floor Manager Team Management - MISSING**
**Flutter**: 
- `floor_manager_team_page.dart` - View team members
- `floor_manager_team_reviews_page.dart` - Submit reviews

**Web**: Does not exist

**Required Features**:
- View all staff under floor manager
- Filter by department/sub-department
- Staff cards showing:
  - Photo, name, role
  - Current schedule
  - Performance rating
  - Recent reviews
- Quick actions:
  - View full profile
  - Submit review
  - Create roster
- Review submission:
  - 5-star rating
  - Comment/feedback text
  - Submit button
  - Review history view

### 8. **Weekly Review System - INCOMPLETE**
**Flutter**: Full review submission and history
**Web**: Review viewing only

**Required Features**:
- Submit review for team member:
  - Select staff member
  - 5-star rating scale
  - Performance categories (punctuality, quality, teamwork, etc.)
  - Comment section
  - Submit button
- View review history:
  - Filter by date range
  - Filter by staff member
  - Average rating display
  - Individual review cards
- Review statistics:
  - Average rating
  - Total reviews
  - Rating distribution chart

### 9. **Document Management & Viewing - MISSING**
**Flutter**: `full_screen_document_page.dart`
**Web**: Does not exist

**Required Features**:
- View uploaded documents (staff, guarantors)
- Full-screen document viewer
- Support for PDF, images
- Zoom in/out
- Download document
- Document verification status
- Document upload date
- Uploaded by information

### 10. **Shift Times Configuration - MISSING**
**Flutter**: `shift_times_page.dart`
**Web**: Does not exist

**Required Features** (HR/Admin only):
- Define shift templates:
  - Shift name (Morning, Afternoon, Night, etc.)
  - Start time
  - End time
  - Break duration
  - Total hours
- Active/Inactive status
- Edit existing shifts
- Delete unused shifts
- Assign shifts to departments

---

## 🎨 UI/UX CONSISTENCY REQUIREMENTS

### **Design System**
- **Primary Color**: #4CAF50 (Green) - MUST be consistent
- **Font**: Google Fonts Inter - MUST be used
- **Corner Radius**: 12px for cards, 8px for buttons
- **Shadows**: Consistent elevation (sm, md, lg)
- **Spacing**: 16px base unit
- **Animations**: Smooth transitions (300ms ease-in-out)

### **Component Consistency**

#### 1. **Expandable Cards** (Branches, Departments, Rosters)
Flutter pattern:
```
Card Header:
  - Icon (left, colored background circle)
  - Title (bold, 18px)
  - Subtitle (gray, 14px)
  - Badge (staff count, colored)
  - Chevron (right, up/down based on state)

Expanded Content:
  - Divider line
  - Grouped sections with colored headers
  - Staff tiles with avatar, name, role, action icon
  - Click anywhere on tile to navigate
```

Web must match this EXACTLY.

#### 2. **Staff Tiles/Cards**
Flutter pattern:
```
Avatar Circle (left):
  - Initials or photo
  - Colored background
  - 40px diameter

Content (middle):
  - Name (bold, 15px)
  - Role (gray, 13px)
  - Additional info (gray, 12px)

Action Icon (right):
  - Chevron right or custom action icon
  - Gray color
```

#### 3. **Filter Sections**
Flutter pattern:
```
Search Bar:
  - Full width
  - Rounded (12px)
  - Icon left
  - Clear button right
  - Green focus ring

Dropdowns/Selects:
  - Labeled above
  - Rounded (12px)
  - White background
  - Gray border
  - Green focus ring
  - Full width on mobile

Tab Bar:
  - Background color for inactive
  - Primary color for active
  - Underline indicator
  - Smooth transition
```

#### 4. **Action Buttons**
Flutter pattern:
```
Primary Button:
  - Green background (#4CAF50)
  - White text
  - Rounded (12px)
  - Padding: 16px vertical
  - Full width on mobile
  - Icon + text option
  - Loading state (spinner)

Secondary Button:
  - White background
  - Green border
  - Green text
  - Same dimensions as primary

Danger Button:
  - Red background
  - White text
  - Used for delete/terminate actions
```

---

## 📡 API REQUIREMENTS & BACKEND INTEGRATION

### **Existing APIs (Verify All Working)**
```
✅ Authentication:
  POST /api/v1/auth/signin
  POST /api/v1/auth/signup
  POST /api/v1/auth/verify-email
  POST /api/v1/auth/forgot-password
  POST /api/v1/auth/reset-password

✅ User/Staff:
  GET  /api/v1/staff (with filters: branch, department, role)
  GET  /api/v1/staff/:id
  POST /api/v1/hr/staff (create staff)
  PUT  /api/v1/staff/:id (update staff)
  DELETE /api/v1/hr/staff/:id (soft delete)

✅ Profile:
  GET  /api/v1/profile
  PUT  /api/v1/profile/personal
  PUT  /api/v1/profile/password
  POST /api/v1/profile/photo

✅ Branches:
  GET  /api/v1/branches (MUST return 13 branches)
  GET  /api/v1/branches/:id
  GET  /api/v1/branches/:id/staff

✅ Departments:
  GET  /api/v1/departments
  GET  /api/v1/departments/:id
  GET  /api/v1/departments/:id/staff
  POST /api/v1/departments (HR only)

✅ Roles:
  GET  /api/v1/roles
  GET  /api/v1/roles/by-category/:category

✅ Rosters:
  GET  /api/v1/rosters/current
  GET  /api/v1/rosters/history
  POST /api/v1/rosters (create)
  PUT  /api/v1/rosters/:id (update)
  GET  /api/v1/rosters/:id/staff

✅ Reviews:
  GET  /api/v1/reviews (all)
  GET  /api/v1/reviews/staff/:id
  POST /api/v1/reviews (submit)
  GET  /api/v1/reviews/my-reviews

✅ Promotions:
  GET  /api/v1/promotions
  GET  /api/v1/promotions/staff/:id
  POST /api/v1/promotions (promote)

✅ Terminated Staff:
  GET  /api/v1/hr/terminated-staff
  POST /api/v1/hr/staff/:id/terminate
```

### **Missing APIs (Must Implement)**
```
❌ Staff Transfer:
  POST /api/v1/hr/staff/:id/transfer
  Body: {
    new_branch_id: string,
    new_department_id?: string,
    reason: string,
    effective_date?: string
  }
  Response: { message: string, transfer_record: TransferHistory }

  GET /api/v1/transfers/staff/:id (transfer history)
  GET /api/v1/transfers (all transfers, admin only)

❌ Document Uploads:
  POST /api/v1/upload/document
  Body: multipart/form-data {
    file: File,
    document_type: string,
    user_id?: string,
    category: 'staff' | 'guarantor1' | 'guarantor2'
  }
  Response: { url: string, document_id: string }

  GET /api/v1/documents/staff/:id (all docs for staff)
  DELETE /api/v1/documents/:id (remove document)

❌ Admin Messaging:
  POST /api/v1/messages/send
  Body: {
    title: string,
    content: string,
    target_type: 'all' | 'branch' | 'department' | 'role',
    target_branch_id?: string,
    target_department_id?: string,
    target_role_id?: string
  }
  Response: { message: string, message_id: string, recipients_count: number }

  GET /api/v1/messages/sent (sent message history)
  GET /api/v1/messages/received (user's inbox)
  PUT /api/v1/messages/:id/read (mark as read)

❌ Shift Times:
  GET  /api/v1/shift-templates
  POST /api/v1/shift-templates (create)
  PUT  /api/v1/shift-templates/:id (update)
  DELETE /api/v1/shift-templates/:id

❌ Branch Reports (COO):
  GET /api/v1/reports/branch/:id?start_date&end_date
  Response: {
    branch: Branch,
    staff_count: number,
    department_stats: Array,
    attendance_stats: Object,
    rosters_count: number,
    promotions_count: number,
    terminations_count: number
  }

❌ Dashboard Stats (Role-Based):
  GET /api/v1/dashboard/stats
  Response: { role-specific stats based on user role }
```

---

## 📝 IMPLEMENTATION CHECKLIST

### **Phase 1: Branch Verification & Web App Fixes**
- [ ] Verify backend returns all 13 branches correctly via API
- [ ] Verify web app displays all 13 branches
- [ ] Test branch filtering and selection in web app
- [ ] Ensure branch data consistency between API and UI

### **Phase 2: Role-Based Dashboards**
- [ ] Create CEO dashboard page
- [ ] Create COO dashboard page with branch reports
- [ ] Create HR dashboard page
- [ ] Create Branch Manager dashboard page
- [ ] Create Floor Manager dashboard page
- [ ] Create Operations Manager dashboard page
- [ ] Create Auditor dashboard page
- [ ] Create Compliance Officer dashboard page
- [ ] Create Facility Manager dashboard page
- [ ] Create General Staff dashboard page
- [ ] Implement dashboard routing based on user role
- [ ] Test each dashboard with appropriate role login

### **Phase 3: Complete Staff Creation Form**
- [ ] Create multi-step wizard component
- [ ] Implement Step 1: Basic Information
- [ ] Implement Step 2: Education
- [ ] Implement Step 3: Work Experience (multiple entries)
- [ ] Implement Step 4: Ace Mall Roles History
- [ ] Implement Step 5: Salary
- [ ] Implement Step 6: Next of Kin
- [ ] Implement Step 7: Guarantor 1 with document uploads
- [ ] Implement Step 8: Guarantor 2 with document uploads
- [ ] Implement Step 9: Staff Documents (8 uploads)
- [ ] Implement file upload component with:
  - File picker
  - Progress indicator
  - Preview
  - Remove/replace functionality
  - Format validation (PDF, JPG, JPEG, PNG)
  - Size limit validation (5MB)
- [ ] Integrate with Cloudinary or S3 for file storage
- [ ] Implement backend document upload endpoint
- [ ] Save staff data with document URLs
- [ ] Test complete flow from start to finish

### **Phase 4: Promotion/Transfer System**
- [ ] Create promotion page with 3-type selection
- [ ] Implement Type 1: Promotion (new role + salary)
  - Staff selection with search
  - Role dropdown (higher roles only)
  - Salary input
  - Reason textarea
  - Before/after comparison
  - Confirmation dialog
- [ ] Implement Type 2: Salary Increase Only
  - Staff selection
  - New salary input (validation: must be higher)
  - Reason textarea
  - Comparison display
  - Confirmation dialog
- [ ] Implement Type 3: Transfer & Promotion
  - Staff selection
  - Branch dropdown
  - Department dropdown
  - Role dropdown (optional)
  - New salary input
  - Reason textarea
  - Complete before/after comparison
  - Confirmation dialog
- [ ] Create multi-step wizard for each type
- [ ] Implement promotion history view with filters
- [ ] Test all 3 promotion types
- [ ] Verify promotion records saved correctly

### **Phase 5: Staff Transfer Feature**
- [ ] Create `/dashboard/staff/transfer` page
- [ ] Implement staff selection (searchable list)
- [ ] Implement branch selector
- [ ] Implement department selector
- [ ] Implement reason input
- [ ] Implement effective date picker
- [ ] Create before/after comparison display
- [ ] Create confirmation dialog
- [ ] Implement backend transfer endpoint
- [ ] Create transfer history view
- [ ] Test complete transfer flow
- [ ] Verify staff updated in new branch/department

### **Phase 6: Roster System Verification & Enhancement**
- [ ] Verify role-based access (Floor Manager, Branch Manager, CEO)
- [ ] Verify roster creation page matches Flutter
- [ ] Verify current roster view matches Flutter
- [ ] Verify roster history with filters matches Flutter
- [ ] Implement shift templates if missing
- [ ] Implement staff assignment interface
- [ ] Verify weekly schedule grid (Monday-Sunday)
- [ ] Test save and publish functionality
- [ ] Test filters (year, month, branch, department)
- [ ] Verify attendance integration

### **Phase 7: Floor Manager Features**
- [ ] Create Floor Manager Team page
  - List all team members
  - Department/sub-department filter
  - Staff cards with photo, name, role, schedule
  - Quick actions (view profile, submit review)
- [ ] Create Team Reviews page
  - Review submission form
  - 5-star rating
  - Performance categories
  - Comment section
  - Review history
- [ ] Implement review submission backend
- [ ] Test review flow from start to finish

### **Phase 8: COO Branch Reports**
- [ ] Create COO Branch Report page
- [ ] Implement branch selector
- [ ] Implement date range filter
- [ ] Create report sections:
  - Staff statistics
  - Department performance
  - Attendance metrics
  - Active rosters
  - Recent promotions
  - Recent terminations
- [ ] Implement export functionality (PDF/Excel)
- [ ] Implement print functionality
- [ ] Implement backend report endpoint
- [ ] Test report generation

### **Phase 9: Document Management**
- [ ] Create document viewer page
- [ ] Implement full-screen view
- [ ] Support PDF rendering
- [ ] Support image viewing
- [ ] Implement zoom controls
- [ ] Implement download button
- [ ] Show document metadata (upload date, uploader)
- [ ] Show verification status
- [ ] Test with various document types

### **Phase 10: Shift Times Configuration**
- [ ] Create Shift Times page (HR/Admin only)
- [ ] Implement shift template form:
  - Shift name input
  - Start time picker
  - End time picker
  - Break duration
  - Total hours calculation
- [ ] Implement shift list view
- [ ] Implement edit functionality
- [ ] Implement delete with confirmation
- [ ] Implement active/inactive toggle
- [ ] Implement backend shift template endpoints
- [ ] Test shift creation and usage in rosters

### **Phase 11: Admin Messaging Enhancement**
- [ ] Enhance messaging page with all target types:
  - All Staff
  - By Branch
  - By Department
  - By Role
- [ ] Implement message history view
- [ ] Implement inbox for received messages
- [ ] Implement mark as read functionality
- [ ] Implement backend messaging endpoints
- [ ] Test message delivery
- [ ] Verify notifications created

### **Phase 12: UI/UX Polish**
- [ ] Apply consistent green (#4CAF50) color scheme throughout
- [ ] Replace all fonts with Google Fonts Inter
- [ ] Standardize all card corner radius to 12px
- [ ] Standardize button corner radius to 8px
- [ ] Implement consistent shadows (elevation)
- [ ] Standardize spacing (16px base unit)
- [ ] Add smooth transitions (300ms ease-in-out)
- [ ] Ensure all expandable cards match Flutter pattern
- [ ] Ensure all staff tiles match Flutter pattern
- [ ] Ensure all buttons match Flutter pattern
- [ ] Test responsive design on mobile, tablet, desktop

### **Phase 13: Testing & Quality Assurance**
- [ ] Test all pages with different role logins:
  - CEO
  - COO
  - HR
  - Branch Manager
  - Floor Manager
  - Operations Manager
  - Auditor
  - Compliance Officer
  - Facility Manager
  - General Staff
- [ ] Verify role-based access control works correctly
- [ ] Test all CRUD operations:
  - Create staff with documents
  - View staff profile
  - Update staff info
  - Promote staff (all 3 types)
  - Transfer staff
  - Terminate staff
- [ ] Test all filters and search functionality
- [ ] Test pagination where applicable
- [ ] Test document upload/download/view
- [ ] Test roster creation and viewing
- [ ] Test review submission
- [ ] Test messaging system
- [ ] Test reports generation
- [ ] Verify all API integrations work
- [ ] Check error handling and loading states
- [ ] Test on different browsers (Chrome, Firefox, Safari)
- [ ] Test on different devices (mobile, tablet, desktop)

### **Phase 14: Performance & Optimization**
- [ ] Optimize API calls (reduce unnecessary requests)
- [ ] Implement caching where appropriate
- [ ] Optimize image loading
- [ ] Optimize document loading
- [ ] Minimize bundle size
- [ ] Implement lazy loading for routes
- [ ] Optimize database queries on backend
- [ ] Add loading skeletons
- [ ] Test page load times
- [ ] Test with slow network conditions

### **Phase 15: Documentation**
- [ ] Update API documentation with all endpoints
- [ ] Create user guide for each role
- [ ] Document all features and how to use them
- [ ] Create admin setup guide
- [ ] Document deployment process
- [ ] Create troubleshooting guide
- [ ] Update README with complete setup instructions

---

## 🚀 DEPLOYMENT CHECKLIST

### **Pre-Deployment**
- [ ] All 15 phases completed
- [ ] All tests passing
- [ ] No console errors
- [ ] No TypeScript errors
- [ ] All APIs returning expected data
- [ ] Database has 13 branches (verified)
- [ ] All document uploads working
- [ ] All role-based features working
- [ ] Performance optimized
- [ ] Security review completed

### **Environment Setup**
- [ ] Production database configured
- [ ] Cloud storage configured (Cloudinary/S3)
- [ ] Email service configured
- [ ] JWT secret keys set
- [ ] CORS configured correctly
- [ ] Rate limiting configured
- [ ] SSL certificates installed
- [ ] Domain configured
- [ ] CDN configured (optional)

### **Post-Deployment**
- [ ] Smoke tests on production
- [ ] Test critical user flows
- [ ] Monitor error logs
- [ ] Monitor performance metrics
- [ ] Backup database
- [ ] Create rollback plan
- [ ] Train users on new features
- [ ] Gather user feedback

---

## 🔐 SECURITY REQUIREMENTS

- [ ] JWT tokens with proper expiration
- [ ] Password hashing with bcrypt
- [ ] Role-based access control (RBAC)
- [ ] Input validation on all forms
- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] CSRF protection
- [ ] Secure file upload (virus scanning)
- [ ] File type validation
- [ ] File size limits enforced
- [ ] Secure document URLs (signed/expiring)
- [ ] HTTPS everywhere
- [ ] Secure cookies
- [ ] Rate limiting on APIs
- [ ] Audit logging for sensitive actions

---

## 📊 SUCCESS CRITERIA

The web app will be considered **100% identical** to the Flutter app when:

1. ✅ All 49 Flutter app pages have web equivalents
2. ✅ All features work identically in both platforms
3. ✅ UI/UX matches exactly (colors, fonts, spacing, animations)
4. ✅ All role-based dashboards implemented
5. ✅ Complete staff creation with document uploads
6. ✅ 3-type promotion system working
7. ✅ Staff transfer feature working
8. ✅ Roster system fully functional
9. ✅ Floor manager features complete
10. ✅ COO branch reports working
11. ✅ Document management working
12. ✅ Shift times configuration working
13. ✅ Admin messaging fully functional
14. ✅ All 13 branches displayed correctly
15. ✅ All APIs integrated and working
16. ✅ No dummy data anywhere
17. ✅ All tests passing
18. ✅ Performance acceptable (<3s page load)
19. ✅ Mobile responsive
20. ✅ Cross-browser compatible
21. ✅ Security requirements met
22. ✅ Documentation complete
23. ✅ Successfully deployed to production

---

## 🎯 PRIORITY ORDER

### **HIGH PRIORITY (Must Complete First)**
1. Fix branch count to 14
2. Implement role-based dashboards
3. Complete staff creation form with document uploads
4. Implement 3-type promotion system
5. Add staff transfer feature

### **MEDIUM PRIORITY (Complete Next)**
6. Verify and enhance roster system
7. Implement floor manager features
8. Add COO branch reports
9. Implement document viewer
10. Add shift times configuration

### **LOW PRIORITY (Polish & Enhancement)**
11. Enhance admin messaging
12. UI/UX polish
13. Performance optimization
14. Documentation
15. Deployment preparation

---

## 📞 SUPPORT & RESOURCES

- **Backend API Docs**: `/backend/README.md`
- **Database Schema**: `/backend/database/schema.sql`
- **Flutter App**: `/ace_mall_app/`
- **Web App**: `/ace_mall_web/`
- **Design System**: Based on Material Design 3 + Ace branding
- **Color Palette**: Primary #4CAF50, variations for each department
- **Font**: Google Fonts Inter (400, 500, 600, 700)

---

**THIS PROMPT PROVIDES EVERYTHING NEEDED TO MAKE THE WEB APP 100% IDENTICAL TO THE FLUTTER APP. FOLLOW IT SYSTEMATICALLY, ONE PHASE AT A TIME, TESTING THOROUGHLY AT EACH STEP.**
