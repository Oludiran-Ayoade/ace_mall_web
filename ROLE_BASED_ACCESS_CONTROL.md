# Role-Based Access Control & Profile Management System

## Overview
Complete implementation of role-based profile access, document management, roster creation, and weekly reviews for the Ace Mall Staff Management System.

---

## 🎯 Access Control Matrix

### Profile Viewing Permissions

| Role | Can View | Permission Level |
|------|----------|------------------|
| **Staff (Self)** | Own profile only | `view_basic` - Personal details, education, work experience (NO documents) |
| **HR** | All staff profiles | `view_full` - Everything including all documents |
| **CEO** | All staff profiles | `view_full` - Everything including all documents |
| **COO** | All staff profiles | `view_full` - Everything including all documents |
| **Group Head** | All staff in their department (all branches) | `view_team` - Profile + education + experience (NO documents) |
| **Branch Manager** | All staff in their branch | `view_team` - Profile + education + experience (NO documents) |
| **Floor Manager** | All staff in their department & branch | `view_team` - Profile + education + experience (NO documents) |

### Document Management Permissions

| Action | Who Can Do It |
|--------|---------------|
| **Upload Documents** | HR only |
| **Delete Documents** | HR only |
| **Replace Documents** | HR only |
| **View Documents** | HR, CEO, COO only |
| **Upload Profile Picture** | Staff (own picture only) |
| **View Document Access Logs** | HR only |

### Staff Creation Permissions

| Role | Can Create |
|------|------------|
| **HR** | All staff (any role, any department, any branch) |
| **Floor Manager** | General staff under them (same department & branch only) |
| **Others** | Cannot create staff |

### Roster & Review Permissions

| Action | Who Can Do It |
|--------|---------------|
| **Create Roster** | Floor Managers (for their team only) |
| **View Own Schedule** | All staff |
| **Create Weekly Review** | Floor Managers (for their team only) |
| **View Reviews** | Staff (own reviews), Floor Managers (team reviews), HR/CEO/COO (all reviews) |

---

## 📊 Database Schema

### New Tables Created

#### 1. `document_access_logs`
Audit trail for document access and modifications.

```sql
CREATE TABLE document_access_logs (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    accessed_by UUID REFERENCES users(id),
    document_type VARCHAR(100),
    action VARCHAR(50), -- 'view', 'upload', 'delete', 'replace'
    created_at TIMESTAMP
);
```

#### 2. `rosters`
Weekly rosters created by floor managers.

```sql
CREATE TABLE rosters (
    id UUID PRIMARY KEY,
    floor_manager_id UUID REFERENCES users(id),
    department_id UUID REFERENCES departments(id),
    branch_id UUID REFERENCES branches(id),
    week_start_date DATE,
    week_end_date DATE,
    status VARCHAR(50), -- 'draft', 'published', 'archived'
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

#### 3. `roster_assignments`
Individual shift assignments.

```sql
CREATE TABLE roster_assignments (
    id UUID PRIMARY KEY,
    roster_id UUID REFERENCES rosters(id),
    staff_id UUID REFERENCES users(id),
    day_of_week day_of_week, -- enum: monday-sunday
    shift_type shift_type, -- enum: day, afternoon, night
    start_time TIME,
    end_time TIME,
    notes TEXT,
    created_at TIMESTAMP
);
```

#### 4. `weekly_reviews`
Weekly performance reviews by floor managers.

```sql
CREATE TABLE weekly_reviews (
    id UUID PRIMARY KEY,
    staff_id UUID REFERENCES users(id),
    reviewer_id UUID REFERENCES users(id),
    roster_id UUID REFERENCES rosters(id),
    week_start_date DATE,
    week_end_date DATE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    punctuality_rating INTEGER,
    performance_rating INTEGER,
    attitude_rating INTEGER,
    comments TEXT,
    strengths TEXT,
    areas_for_improvement TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

#### 5. `shift_templates`
Predefined shift times for floor managers.

```sql
CREATE TABLE shift_templates (
    id UUID PRIMARY KEY,
    floor_manager_id UUID REFERENCES users(id),
    shift_type shift_type, -- day, afternoon, night
    start_time TIME,
    end_time TIME,
    is_default BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

### Document Fields Added to `users` Table

```sql
-- Educational Certificates
waec_certificate_url, waec_certificate_public_id
neco_certificate_url, neco_certificate_public_id
jamb_result_url, jamb_result_public_id
degree_certificate_url, degree_certificate_public_id
diploma_certificate_url, diploma_certificate_public_id

-- Identity Documents
birth_certificate_url, birth_certificate_public_id
national_id_url, national_id_public_id
passport_url, passport_public_id
drivers_license_url, drivers_license_public_id
voters_card_url, voters_card_public_id

-- Government Documents
nysc_certificate_url, nysc_certificate_public_id
state_of_origin_cert_url, state_of_origin_cert_public_id
lga_certificate_url, lga_certificate_public_id

-- Employment Documents
resume_url, resume_public_id
cover_letter_url, cover_letter_public_id
```

---

## 🔌 API Endpoints

### Profile Management

#### Get Profile
```http
GET /api/v1/profile
Authorization: Bearer <token>

Response:
{
  "user": { ...user object... },
  "permission_level": "view_basic" | "view_team" | "view_full"
}
```

#### Get Another User's Profile
```http
GET /api/v1/profile/:user_id
Authorization: Bearer <token>

Response:
{
  "user": { ...user object... },
  "permission_level": "view_team" | "view_full"
}
```

**Note:** Documents are only included if `permission_level` is `view_full`.

#### Update Profile Picture
```http
PUT /api/v1/profile/picture
Authorization: Bearer <token>
Content-Type: application/json

Body:
{
  "profile_image_url": "https://res.cloudinary.com/...",
  "profile_image_public_id": "staff_images/123_abc.jpg"
}

Response:
{
  "message": "Profile picture updated successfully",
  "profile_image_url": "https://..."
}
```

### Document Management (HR Only)

#### Upload/Update Document
```http
PUT /api/v1/profile/:user_id/document
Authorization: Bearer <token> (HR only)
Content-Type: application/json

Body:
{
  "document_type": "waec_certificate",
  "document_url": "https://res.cloudinary.com/...",
  "public_id": "certificates/waec/123_abc.pdf"
}

Response:
{
  "message": "Document updated successfully"
}
```

**Document Types:**
- `waec_certificate`, `neco_certificate`, `jamb_result`
- `degree_certificate`, `diploma_certificate`
- `birth_certificate`, `national_id`, `passport`
- `drivers_license`, `voters_card`
- `nysc_certificate`, `state_of_origin_cert`, `lga_certificate`
- `resume`, `cover_letter`

#### Delete Document
```http
DELETE /api/v1/profile/:user_id/document
Authorization: Bearer <token> (HR only)
Content-Type: application/json

Body:
{
  "document_type": "waec_certificate"
}

Response:
{
  "message": "Document deleted successfully"
}
```

#### Get Document Access Logs
```http
GET /api/v1/profile/:user_id/document-logs
Authorization: Bearer <token> (HR only)

Response:
{
  "logs": [
    {
      "id": "uuid",
      "document_type": "waec_certificate",
      "action": "upload",
      "accessed_by_name": "HR Administrator",
      "created_at": "2025-11-21T12:00:00Z"
    }
  ],
  "count": 1
}
```

### Roster Management (Floor Managers)

#### Create Roster
```http
POST /api/v1/roster
Authorization: Bearer <token> (Floor Manager only)
Content-Type: application/json

Body:
{
  "week_start_date": "2025-11-25",
  "week_end_date": "2025-12-01",
  "assignments": [
    {
      "staff_id": "uuid",
      "day_of_week": "monday",
      "shift_type": "day",
      "start_time": "08:00:00",
      "end_time": "16:00:00",
      "notes": "Opening shift"
    }
  ]
}

Response:
{
  "message": "Roster created successfully",
  "roster_id": "uuid"
}
```

**Shift Types:**
- `day` - Morning shift (default: 08:00-16:00)
- `afternoon` - Afternoon shift (default: 14:00-22:00)
- `night` - Night shift (default: 22:00-06:00)

**Days of Week:**
- `monday`, `tuesday`, `wednesday`, `thursday`, `friday`, `saturday`, `sunday`

#### Get My Team
```http
GET /api/v1/roster/my-team
Authorization: Bearer <token> (Floor Manager only)

Response:
{
  "team": [
    {
      "id": "uuid",
      "full_name": "John Doe",
      "email": "john@example.com",
      "phone_number": "+234...",
      "profile_image_url": "https://...",
      "role_name": "Cashier",
      "date_joined": "2025-01-01",
      "is_active": true
    }
  ],
  "count": 10
}
```

#### Get Shift Templates
```http
GET /api/v1/roster/shift-templates
Authorization: Bearer <token> (Floor Manager only)

Response:
{
  "templates": [
    {
      "id": "uuid",
      "shift_type": "day",
      "start_time": "08:00:00",
      "end_time": "16:00:00",
      "is_default": true
    }
  ]
}
```

#### Update Shift Template
```http
PUT /api/v1/roster/shift-templates/:id
Authorization: Bearer <token> (Floor Manager only)
Content-Type: application/json

Body:
{
  "start_time": "09:00:00",
  "end_time": "17:00:00"
}

Response:
{
  "message": "Shift template updated successfully"
}
```

### Weekly Reviews (Floor Managers)

#### Create Weekly Review
```http
POST /api/v1/review
Authorization: Bearer <token> (Floor Manager only)
Content-Type: application/json

Body:
{
  "staff_id": "uuid",
  "week_start_date": "2025-11-18",
  "week_end_date": "2025-11-24",
  "rating": 4,
  "punctuality_rating": 5,
  "performance_rating": 4,
  "attitude_rating": 5,
  "comments": "Excellent performance this week",
  "strengths": "Great customer service, punctual",
  "areas_for_improvement": "Could improve product knowledge"
}

Response:
{
  "message": "Review created successfully",
  "review_id": "uuid"
}
```

**Rating Scale:** 1-5 (1 = Poor, 5 = Excellent)

#### Get Staff Reviews
```http
GET /api/v1/review/staff/:staff_id
Authorization: Bearer <token>

Response:
{
  "reviews": [
    {
      "id": "uuid",
      "week_start_date": "2025-11-18",
      "week_end_date": "2025-11-24",
      "rating": 4,
      "punctuality_rating": 5,
      "performance_rating": 4,
      "attitude_rating": 5,
      "comments": "...",
      "strengths": "...",
      "areas_for_improvement": "...",
      "created_at": "2025-11-25T10:00:00Z",
      "reviewer_name": "Floor Manager Name"
    }
  ],
  "count": 10
}
```

---

## 🔐 Permission Logic

### View Profile Permission Check

```go
func CanViewProfile(db *sql.DB, requesterID string, targetUserID string) (PermissionLevel, error)
```

**Logic:**
1. If viewing own profile → `view_basic`
2. If HR/CEO/COO → `view_full`
3. If Group Head + same department → `view_team`
4. If Branch Manager + same branch → `view_team`
5. If Floor Manager + same department & branch → `view_team`
6. Otherwise → `none` (forbidden)

### Document Edit Permission Check

```go
func CanEditDocuments(db *sql.DB, requesterID string, targetUserID string) (bool, error)
```

**Logic:**
- Only HR role can edit/delete documents
- Returns `true` only if requester is HR

### Profile Picture Edit Permission

```go
func CanEditProfilePicture(requesterID string, targetUserID string) bool
```

**Logic:**
- Staff can only edit their own profile picture
- Returns `true` if requesterID == targetUserID

---

## 📱 User Flows

### Staff Member Flow
1. **Login** → Dashboard
2. **View Profile** → See personal details, education, work experience
3. **Upload Profile Picture** → Can change own picture
4. **View Schedule** → See assigned shifts
5. **View Reviews** → See performance reviews from floor manager
6. **Cannot:** View/edit documents, view other profiles

### Floor Manager Flow
1. **Login** → Dashboard
2. **View My Team** → See all general staff under them
3. **Create Roster** → Assign shifts for the week
4. **Create Weekly Review** → Review each team member's performance
5. **View Team Profiles** → See team member details (no documents)
6. **Cannot:** View/edit documents, create admin staff

### Branch Manager Flow
1. **Login** → Dashboard
2. **View Branch Staff** → See all staff in their branch
3. **View Staff Profiles** → See details of any staff in branch (no documents)
4. **Cannot:** Create rosters, edit documents, create staff

### Group Head Flow
1. **Login** → Dashboard
2. **View Department Staff** → See all staff in their department (all branches)
3. **View Staff Profiles** → See details of department staff (no documents)
4. **Cannot:** Create rosters, edit documents, create staff

### HR/CEO/COO Flow
1. **Login** → Dashboard
2. **View All Staff** → See any staff member
3. **View Full Profile** → See everything including all documents
4. **Upload/Delete Documents** → Manage all staff documents
5. **View Document Logs** → See who accessed what documents
6. **Create Staff** → Create any type of staff
7. **View All Reviews** → See performance reviews for any staff

---

## ✅ Implementation Status

### Backend ✅ Complete
- [x] Database migrations executed
- [x] Document fields added to users table
- [x] Roster tables created
- [x] Review tables created
- [x] Permission utility functions
- [x] Profile handlers with role-based access
- [x] Roster handlers
- [x] Review handlers
- [x] Document management handlers
- [x] All routes registered
- [x] Server running on port 8080

### Frontend 🔄 Pending
- [ ] Staff profile view page (limited access)
- [ ] HR/CEO/COO full profile view page
- [ ] Document upload/management UI
- [ ] Roster creation UI
- [ ] Weekly review UI
- [ ] Team management UI

---

## 🧪 Testing

### Test Credentials

**HR Account:**
- Email: hr@acemarket.com
- Password: password123
- Can: View all profiles with documents, edit documents

**Floor Manager Account:**
- Email: (check database for floor manager accounts)
- Can: View team, create rosters, create reviews

**General Staff Account:**
- Email: (check database for general staff accounts)
- Can: View own profile, view schedule, view reviews

### Test Scenarios

#### 1. Staff Views Own Profile
```bash
curl -X GET http://localhost:8080/api/v1/profile \
  -H "Authorization: Bearer <staff_token>"

# Should return: permission_level = "view_basic"
# Should NOT include document URLs
```

#### 2. HR Views Staff Profile
```bash
curl -X GET http://localhost:8080/api/v1/profile/<staff_id> \
  -H "Authorization: Bearer <hr_token>"

# Should return: permission_level = "view_full"
# Should include all document URLs
```

#### 3. Floor Manager Creates Roster
```bash
curl -X POST http://localhost:8080/api/v1/roster \
  -H "Authorization: Bearer <floor_manager_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "week_start_date": "2025-11-25",
    "week_end_date": "2025-12-01",
    "assignments": [...]
  }'

# Should return: 201 Created with roster_id
```

#### 4. HR Uploads Document
```bash
curl -X PUT http://localhost:8080/api/v1/profile/<staff_id>/document \
  -H "Authorization: Bearer <hr_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "document_type": "waec_certificate",
    "document_url": "https://...",
    "public_id": "certificates/waec/123.pdf"
  }'

# Should return: 200 OK
```

#### 5. Staff Tries to View Another Profile
```bash
curl -X GET http://localhost:8080/api/v1/profile/<other_staff_id> \
  -H "Authorization: Bearer <staff_token>"

# Should return: 403 Forbidden
```

---

## 📝 Notes

### Default Shift Times
When a floor manager is created, default shift templates are automatically created:
- **Day Shift:** 08:00 - 16:00
- **Afternoon Shift:** 14:00 - 22:00
- **Night Shift:** 22:00 - 06:00

Floor managers can customize these times via the shift templates API.

### Document Access Logging
Every time HR/CEO/COO views a profile with documents, an entry is logged in `document_access_logs`. This provides an audit trail for compliance.

### Roster Status
Rosters have three statuses:
- `draft` - Being created
- `published` - Active and visible to staff
- `archived` - Past rosters for history

### Review Visibility
- Staff can see their own reviews
- Floor managers can see reviews they created
- HR/CEO/COO can see all reviews
- Reviews are displayed on staff profiles for authorized viewers

---

**Last Updated:** November 21, 2025
**Backend Status:** ✅ Running on port 8080
**Database:** ✅ Migrations applied
**API Endpoints:** ✅ All registered and functional
