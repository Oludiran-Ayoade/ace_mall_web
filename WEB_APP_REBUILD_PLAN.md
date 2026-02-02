# Web App Complete Rebuild Plan
## Matching Flutter App 100%

### CRITICAL FIXES NEEDED:

## 1. STAFF LIST PAGE - By Branch Tab
**Flutter App Structure:**
- Expandable cards for each branch
- Shows branch name, location, and staff count
- When expanded, shows staff grouped by DEPARTMENTS within that branch
- Each department section has color-coded header
- Staff tiles show avatar, name, role, department
- Clicking staff opens profile

**Current Web Issue:**
- Not matching this structure

**Action:**
- Rebuild `/dashboard/staff` page with exact Flutter structure
- ExpansionTile-style cards for branches
- Department grouping within each branch
- Proper staff tiles with all info

---

## 2. STAFF CREATION FORM
**Flutter App Structure:**
- Multi-step form (Stepper component)
- Steps:
  1. Basic Information (name, email, phone, employee ID, DOB, gender, marital status, address, state of origin, date joined)
  2. Education (course, grade, institution, exam scores)
  3. Work Experience (multiple entries: company, roles, start date, end date)
  4. Ace Mall Roles History (promotion history: role, branch, start date, end date)
  5. Salary
  6. Next of Kin (full details)
  7. Guarantor 1 (full details + 3 document uploads: passport, national ID, work ID)
  8. Guarantor 2 (full details + 3 document uploads: passport, national ID, work ID)
  9. Staff Documents (7 uploads: birth cert, passport, valid ID, NYSC, degree, WAEC, state of origin cert, first leaving cert)

**Document Upload Fields:**
- Staff: birth certificate, passport, valid ID, NYSC cert, degree cert, WAEC cert, state of origin cert, first leaving cert
- Guarantor 1: passport, national ID, work ID
- Guarantor 2: passport, national ID, work ID

**Current Web Issue:**
- Simple form without document uploads
- Missing guarantor sections
- No work experience tracking

**Action:**
- Complete rebuild of `/dashboard/staff/add` page
- Implement file upload with Cloudinary or similar
- Multi-step form with all sections
- Document preview and management

---

## 3. STAFF TRANSFER FEATURE
**Flutter App Has:**
- Separate transfer page/dialog
- Select staff → Select new branch → Select new department → Reason
- Shows current location vs new location
- Transfer history tracking

**Current Web:**
- Missing entirely

**Action:**
- Create `/dashboard/staff/transfer` page
- Transfer form with confirmation dialog
- Transfer history view
- API integration with backend `/hr/staff/:id/transfer`

---

## 4. PROMOTIONS PAGE
**Flutter App Structure:**
- Three main options:
  1. Promotion (new role + salary increase)
  2. Salary Increase Only (same role, higher salary)
  3. Transfer & Promotion (new branch + new role + salary)
- Multi-step selection:
  - Step 1: Select staff (searchable list)
  - Step 2: Select promotion type
  - Step 3: Choose new role (if promoting) OR select branch (if transferring)
  - Step 4: Enter new salary
  - Step 5: Enter reason
  - Confirmation dialog showing before/after comparison
- Promotion history list with filters
- Color-coded cards by type

**Current Web:**
- Basic promotion form, missing transfer option
- No salary increase only option
- Not matching app structure

**Action:**
- Complete rebuild of `/dashboard/promotions` page
- Three promotion types
- Multi-step wizard
- Before/after comparison
- History with proper filters

---

## 5. STAFF TERMINATION
**Flutter App Structure:**
- Filter dropdown: All Types, Terminated, Resigned, Retired, Contract Ended
- Search bar
- Grouped by DEPARTMENT (collapsible sections)
- Each staff card shows:
  - Color-coded badge by termination type
  - Staff info (name, role, employee ID)
  - Termination date
  - Termination type with icon
  - Department
- Click to view full termination details

**Current Web:**
- Flat list without grouping
- Missing type filters
- Not matching app UI

**Action:**
- Rebuild `/dashboard/terminated-staff` page
- Department grouping with collapsible sections
- Type filters dropdown
- Color-coded badges
- Match Flutter design exactly

---

## 6. BRANCHES PAGE
**Flutter App Structure:**
- List of expandable branch cards
- Each card shows:
  - Branch icon
  - Branch name and location
  - Staff count badge
  - Expand icon
- When expanded:
  - Shows departments within that branch as colored sections
  - Each department section shows staff list
  - Staff tiles with avatar, name, role
  - Click staff to view profile

**Current Web:**
- Simple grid of branch cards that link away
- No expansion
- No in-page department grouping

**Action:**
- Complete rebuild of `/dashboard/branches` page
- Expandable cards (Accordion component)
- Department sections within each branch
- Staff tiles with click-to-profile
- Match Flutter's exact structure

---

## 7. DEPARTMENTS PAGE
**Flutter App Structure:**
- List of expandable department cards
- Each card shows:
  - Department icon (color-coded)
  - Department name
  - Staff count across all branches
  - Branch count badge
- When expanded:
  - Shows branches with staff in that department
  - Each branch section shows staff list
  - Staff tiles with avatar, name, role, branch

**Current Web:**
- Similar issue to branches
- Not showing nested structure

**Action:**
- Rebuild `/dashboard/departments` page
- Expandable department cards
- Branch sections within each department
- Staff tiles grouped properly

---

## 8. ROSTER PAGES
**Flutter App Has:**
- **View Rosters**: Current week rosters by branch/department
- **Roster History**: Past rosters with year/month filters
- Filter controls at top
- Roster cards showing:
  - Week date range
  - Branch and department
  - Floor manager name
  - Staff count
  - Shift breakdown
  - Attendance stats (if completed)

**Current Web:**
- Basic roster pages but may not match exact structure

**Action:**
- Review and match `/dashboard/rosters` and `/dashboard/rosters/history`
- Ensure filters work properly
- Match card design
- Show all roster details

---

## 9. REPORTS PAGE
**Flutter App Structure:**
- NO DUMMY DATA - all real metrics from backend
- Stats cards:
  - Total staff
  - Active staff
  - Department count
  - Branch count
  - Avg attendance rate
  - Monthly new hires
  - Monthly terminations
  - Promotions this month
- Charts:
  - Staff by department (bar chart)
  - Staff by branch (bar chart)
  - Attendance trends (line chart)
  - Performance ratings distribution

**Current Web:**
- Using dummy/hardcoded data
- Not pulling from real API

**Action:**
- Rebuild `/dashboard/reports` page
- Create API endpoints if missing:
  - `/api/v1/hr/stats` - all counts
  - `/api/v1/hr/reports/attendance`
  - `/api/v1/hr/reports/performance`
- Real-time data only
- Match Flutter charts

---

## 10. ADMIN MESSAGING
**Flutter App Structure:**
- Send to options:
  - All Staff
  - Specific Branch
  - Specific Department
  - Specific Role
- Message form:
  - Title/Subject
  - Message body (multiline)
  - Recipient selection
  - Send button
- Message history list
- Sent messages archive

**Current Web:**
- Basic form, missing history
- No sent messages view

**Action:**
- Rebuild `/dashboard/messaging` page
- Add recipient targeting options
- Message history section
- API endpoints:
  - `POST /api/v1/messages/send`
  - `GET /api/v1/messages/sent`

---

## API VERIFICATION CHECKLIST

Ensure these endpoints exist and return real data:
- ✅ `GET /api/v1/hr/staff` - All staff
- ✅ `GET /api/v1/staff/:id` - Staff details
- ✅ `POST /api/v1/hr/staff` - Create staff
- ❓ `POST /api/v1/hr/staff/:id/transfer` - Transfer staff
- ✅ `POST /api/v1/promotions` - Promote staff
- ✅ `GET /api/v1/promotions/history/:id` - Promotion history
- ✅ `POST /api/v1/staff/:id/terminate` - Terminate staff
- ✅ `GET /api/v1/departed-staff` - Terminated staff
- ❓ `GET /api/v1/hr/stats` - Dashboard stats
- ❓ `GET /api/v1/hr/reports/*` - Reports data
- ❓ `POST /api/v1/messages/send` - Send message
- ❓ `GET /api/v1/messages/sent` - Message history
- ❓ `POST /api/v1/upload/document` - Document upload

---

## IMPLEMENTATION ORDER:

1. Fix staff list page (immediate - branches.map error fixed)
2. Rebuild branches page with proper expansion
3. Rebuild departments page with proper expansion  
4. Implement complete staff creation form with uploads
5. Add staff transfer feature
6. Rebuild promotions page with 3 types
7. Fix terminated staff with department grouping
8. Rebuild reports with real data
9. Rebuild messaging with history
10. Verify all roster pages
11. Final testing and polish
