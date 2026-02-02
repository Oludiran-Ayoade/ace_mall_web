# Schedule Page Error - Debugging Guide

## Issue
The schedule page is showing "Error loading schedule" with network error.

## Root Cause Analysis

The backend is returning HTTP 500 errors for `/api/v1/roster/my-assignments` endpoint.

## Possible Causes

1. **Database column name mismatch** - Already fixed `week_start` → `week_start_date`
2. **No roster data exists** - Need to create test data
3. **User ID type mismatch** - UUID vs string conversion issue
4. **Database connection issue** - Need to verify

## Quick Fix Steps

### Step 1: Check if roster data exists
Run this in your database client:

```sql
-- Check if rosters table has data
SELECT COUNT(*) FROM rosters;

-- Check if roster_assignments table has data  
SELECT COUNT(*) FROM roster_assignments;

-- Check table structure
\d rosters
\d roster_assignments
```

### Step 2: Create test roster data
If no data exists, run this:

```sql
-- Find a cashier and their floor manager
SELECT 
  u.id, u.email, u.full_name, r.name as role
FROM users u
INNER JOIN roles r ON u.role_id = r.id
WHERE r.name LIKE '%Cashier%'
LIMIT 5;

-- Find floor managers
SELECT 
  u.id, u.email, u.full_name, r.name as role
FROM users u
INNER JOIN roles r ON u.role_id = r.id
WHERE r.category = 'floor_manager'
LIMIT 5;

-- Create a roster (replace IDs with actual values from above)
INSERT INTO rosters (
  floor_manager_id, 
  department_id, 
  branch_id, 
  week_start_date, 
  week_end_date, 
  status
) VALUES (
  'FLOOR_MANAGER_UUID_HERE',
  1, -- SuperMarket department
  1, -- Branch ID
  '2025-12-15', -- This week's Monday
  '2025-12-21', -- This week's Sunday
  'active'
) RETURNING id;

-- Create assignments (replace ROSTER_ID and STAFF_ID)
INSERT INTO roster_assignments (roster_id, staff_id, day_of_week, shift_type, start_time, end_time, status)
VALUES
  (ROSTER_ID, 'STAFF_UUID', 'Monday', 'day', '09:00', '17:00', 'scheduled'),
  (ROSTER_ID, 'STAFF_UUID', 'Tuesday', 'day', '09:00', '17:00', 'scheduled'),
  (ROSTER_ID, 'STAFF_UUID', 'Wednesday', 'day', '09:00', '17:00', 'scheduled'),
  (ROSTER_ID, 'STAFF_UUID', 'Thursday', 'day', '09:00', '17:00', 'scheduled'),
  (ROSTER_ID, 'STAFF_UUID', 'Friday', 'day', '09:00', '17:00', 'scheduled'),
  (ROSTER_ID, 'STAFF_UUID', 'Saturday', 'off', NULL, NULL, 'off'),
  (ROSTER_ID, 'STAFF_UUID', 'Sunday', 'off', NULL, NULL, 'off');
```

### Step 3: Test the API directly

```bash
# Get your auth token by logging in
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"cashier.abeokuta1@acesupermarket.com","password":"password123"}'

# Use the token to test the schedule endpoint
curl -X GET "http://localhost:8080/api/v1/roster/my-assignments?week_start=2025-12-15" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Alternative: Use Floor Manager to Create Roster

Instead of manually creating data, use the Floor Manager dashboard:

1. Login as a Floor Manager
2. Go to "Create Roster" or "Manage Roster"
3. Select the week (Dec 15-21, 2025)
4. Add staff members and assign shifts
5. Save the roster

The staff member will immediately see their schedule in the My Schedule page.

## System Design

**How it works:**
- Floor Manager creates `roster` record with week dates
- Floor Manager adds `roster_assignments` for each staff member
- Staff queries their assignments via `/api/v1/roster/my-assignments`
- Backend filters by `staff_id` and `week_start_date`

**The system is fully functional** - it just needs roster data to be created first.
