-- Quick script to create test schedule for cashier
-- Run this to populate schedule data

-- Step 1: Find cashier and floor manager IDs
SELECT 
    'Cashier ID:' as type,
    u.id,
    u.email,
    u.full_name,
    b.name as branch,
    d.name as department
FROM users u
INNER JOIN branches b ON u.branch_id = b.id
INNER JOIN departments d ON u.department_id = d.id
INNER JOIN roles r ON u.role_id = r.id
WHERE b.name LIKE '%Abeokuta%'
AND r.name LIKE '%Cashier%'
LIMIT 1;

-- Step 2: Find floor manager
SELECT 
    'Floor Manager ID:' as type,
    u.id,
    u.email,
    u.full_name
FROM users u
INNER JOIN branches b ON u.branch_id = b.id
INNER JOIN departments d ON u.department_id = d.id
INNER JOIN roles r ON u.role_id = r.id
WHERE b.name LIKE '%Abeokuta%'
AND d.name = 'SuperMarket'
AND r.category = 'floor_manager'
LIMIT 1;

-- Step 3: After getting IDs above, manually insert roster
-- Replace CASHIER_ID and FLOOR_MGR_ID with actual UUIDs from above

-- Example (replace with actual IDs):
/*
INSERT INTO rosters (floor_manager_id, department_id, branch_id, week_start_date, week_end_date, status)
VALUES (
    'FLOOR_MGR_ID',
    (SELECT id FROM departments WHERE name = 'SuperMarket'),
    (SELECT id FROM branches WHERE name LIKE '%Abeokuta%'),
    DATE_TRUNC('week', CURRENT_DATE),
    DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '6 days',
    'active'
) RETURNING id;

-- Then insert assignments (replace ROSTER_ID and CASHIER_ID):
INSERT INTO roster_assignments (roster_id, staff_id, day_of_week, shift_type, start_time, end_time, status)
VALUES
    (ROSTER_ID, 'CASHIER_ID', 'Monday', 'day', '08:00', '16:00', 'scheduled'),
    (ROSTER_ID, 'CASHIER_ID', 'Tuesday', 'day', '08:00', '16:00', 'scheduled'),
    (ROSTER_ID, 'CASHIER_ID', 'Wednesday', 'day', '08:00', '16:00', 'scheduled'),
    (ROSTER_ID, 'CASHIER_ID', 'Thursday', 'day', '08:00', '16:00', 'scheduled'),
    (ROSTER_ID, 'CASHIER_ID', 'Friday', 'day', '08:00', '16:00', 'scheduled'),
    (ROSTER_ID, 'CASHIER_ID', 'Saturday', 'off', NULL, NULL, 'off'),
    (ROSTER_ID, 'CASHIER_ID', 'Sunday', 'off', NULL, NULL, 'off');
*/
