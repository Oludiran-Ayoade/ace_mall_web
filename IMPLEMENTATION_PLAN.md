# Ace Mall Staff Management System - Implementation Plan

## ✅ Phase 1: Database & Backend Foundation (COMPLETED)

### Database Schema Created
- ✅ **13 Branches** - All Ace Mall locations across Nigeria
- ✅ **6 Main Departments** - SuperMarket, Eatery, Lounge, Fun & Arcade, Compliance, Facility Management
- ✅ **5 Sub-departments** - Cinema, Photo Studio, Saloon, Arcade & Kiddies, Casino
- ✅ **Complete Role Hierarchy** - 60+ roles from CEO to General Staff
- ✅ **User Management** - Comprehensive staff profiles with all required fields
- ✅ **Document Management** - Upload and track certificates, IDs, etc.
- ✅ **Next of Kin & Guarantors** - Complete emergency contact system
- ✅ **Work History** - Track experience and promotions
- ✅ **Roster System** - Weekly schedules and assignments
- ✅ **Review System** - Performance tracking
- ✅ **Terminated Staff** - Archive with reasons

### Backend Structure Created
- ✅ **Go Modules** - Dependencies configured
- ✅ **Database Config** - PostgreSQL connection setup
- ✅ **Models** - Complete data structures
- ✅ **Authentication** - JWT middleware
- ✅ **Authorization** - Role-based access control

## 🚧 Phase 2: Backend API Development (IN PROGRESS)

### To Build:
1. **Authentication Handlers**
   - Login endpoint
   - Password change
   - Token refresh

2. **HR Management APIs**
   - Create staff (all types)
   - Update staff profiles
   - Terminate staff
   - Add departments
   - Add roles
   - Promote staff
   - View all staff
   - Filter by branch/department

3. **Floor Manager APIs**
   - Create general staff
   - View team members
   - Create rosters
   - Update rosters
   - Submit reviews
   - Track attendance

4. **General Staff APIs**
   - View profile
   - Update email/password
   - View schedule
   - View reviews

5. **Data APIs**
   - Get branches
   - Get departments
   - Get roles (filtered by category/department)
   - Get sub-departments

6. **File Upload APIs**
   - Upload staff documents
   - Upload guarantor documents
   - Retrieve documents

## 📱 Phase 3: Flutter Frontend Development (PENDING)

### Pages to Build (Based on Your Design):

#### 1. **Staff Type Selection Page**
- Two cards: Administrative Staff vs General Staff
- Green theme with icons
- Description text for each type

#### 2. **Role Selection Page**
- List of roles based on staff type
- Search/filter functionality
- Grouped by category (Senior Admin, Admin, General)
- Radio button selection
- Role descriptions

#### 3. **Branch Selection Page**
- Grid of 13 branches
- Green cards with location icons
- Branch names and locations
- Multi-select or single-select based on role

#### 4. **Department Selection Page**
- 6 main departments
- Sub-department selection for Fun & Arcade
- Color-coded cards
- Department descriptions

#### 5. **Staff Profile Creation Form**
- Multi-step form
- Personal Information
- Work Information
- Education Details
- Next of Kin
- Guarantors (2)
- Document Uploads
- Review & Submit

#### 6. **HR Dashboard**
- Staff overview
- Quick actions (Add Staff, View Reports)
- Branch statistics
- Department distribution
- Recent activities

#### 7. **Floor Manager Dashboard**
- My Team view
- Create Roster
- Submit Reviews
- Attendance tracking
- Team performance

#### 8. **General Staff Dashboard**
- My Profile
- My Schedule
- My Reviews
- Update Email/Password

## 🎨 Design System (From Your Images)

### Colors:
- **Primary Green**: `#4CAF50`
- **Light Green**: `#66BB6A`
- **Dark Green**: `#2E7D32`
- **White**: `#FFFFFF`
- **Grey**: `#9E9E9E`

### Typography:
- **Font**: Inter (Bold for titles, Regular for body)
- **Title Size**: 32-38px
- **Body Size**: 14-16px

### Components:
- **Cards**: Rounded corners (12px), subtle shadows
- **Buttons**: Full-width, 16px padding, rounded
- **Input Fields**: White background, grey borders
- **Selection Cards**: Green accent when selected

## 🔄 User Flows

### HR Creating Admin Staff:
1. Login → HR Dashboard
2. Click "Add Staff"
3. Select "Administrative Staff"
4. Select Role (e.g., Branch Manager)
5. Select Department
6. Select Branch
7. Fill Personal Information
8. Fill Work Information
9. Fill Education Details
10. Add Next of Kin
11. Add 2 Guarantors
12. Upload Documents
13. Review & Submit
14. Staff receives login credentials via email

### Floor Manager Creating General Staff:
1. Login → Floor Manager Dashboard
2. Click "Add Team Member"
3. Select "General Staff"
4. Select Role (from their department only)
5. Fill Basic Information
6. Add Next of Kin
7. Add 1 Guarantor (simplified)
8. Upload Basic Documents (Passport, ID, WAEC)
9. Submit
10. Staff receives login credentials

### General Staff Viewing Schedule:
1. Login → Dashboard
2. Click "My Schedule"
3. View weekly roster
4. See shift times
5. Check attendance status

## 📊 Key Features Summary

### HR Powers:
- ✅ Create ALL staff types
- ✅ Add new departments
- ✅ Add new roles
- ✅ Promote staff
- ✅ Terminate staff
- ✅ View all staff across all branches
- ✅ Generate reports
- ✅ Manage documents

### Floor Manager Powers:
- ✅ Create general staff (their department only)
- ✅ Create weekly rosters
- ✅ Assign shifts
- ✅ Mark attendance
- ✅ Submit weekly reviews
- ✅ View team performance

### General Staff Access:
- ✅ View own profile
- ✅ Update email/password only
- ✅ View schedule
- ✅ View reviews
- ✅ View work history

## 🎯 Next Steps

### Immediate (Backend):
1. Create authentication handlers
2. Build HR management endpoints
3. Build Floor Manager endpoints
4. Build General Staff endpoints
5. Implement file upload
6. Add validation and error handling
7. Write API tests

### Immediate (Frontend):
1. Create Staff Type Selection page
2. Create Role Selection page
3. Create Branch Selection page
4. Create Department Selection page
5. Create Profile Creation forms
6. Implement API integration
7. Add file upload functionality

### Future Enhancements:
- Push notifications for roster assignments
- Email notifications for profile creation
- Analytics dashboard
- Export reports (PDF/Excel)
- Mobile app optimization
- Offline mode
- Real-time updates

## 📝 Notes

- **Branch Managers** have dual roles (manager + department member)
- **Floor Managers** are also floor members
- **Group Heads** oversee all branches
- **Terminated staff** are archived, not deleted
- **Documents** are required based on staff type
- **Guarantors** need full documentation for admin staff

## 🚀 Deployment Plan

### Backend:
- Deploy to cloud server (AWS/DigitalOcean)
- Set up PostgreSQL database
- Configure environment variables
- Set up SSL certificates
- Configure CORS for mobile app

### Frontend:
- Build Flutter app for iOS and Android
- Test on multiple devices
- Submit to App Store and Play Store
- Set up CI/CD pipeline

### Database:
- Set up automated backups
- Configure replication
- Set up monitoring
- Optimize queries

## 📞 Support & Maintenance

- Regular database backups
- Security updates
- Feature enhancements based on feedback
- Performance monitoring
- User training and documentation
