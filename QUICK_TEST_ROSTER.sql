-- Quick test to create roster data for current week
-- This will create a roster that shows up immediately in the schedule

-- Get a cashier and floor manager
WITH test_data AS (
  SELECT 
    u_cashier.id as cashier_id,
    u_cashier.email as cashier_email,
    u_fm.id as fm_id,
    u_fm.email as fm_email,
    u_cashier.branch_id,
    u_cashier.department_id
  FROM users u_cashier
  INNER JOIN users u_fm ON u_cashier.branch_id = u_fm.branch_id 
    AND u_cashier.department_id = u_fm.department_id
  INNER JOIN roles r_cashier ON u_cashier.role_id = r_cashier.id
  INNER JOIN roles r_fm ON u_fm.role_id = r_fm.id
  WHERE r_cashier.name LIKE '%Cashier%'
  AND r_fm.category = 'floor_manager'
  AND u_cashier.is_active = true
  AND u_fm.is_active = true
  LIMIT 1
)
-- Create roster for this week
INSERT INTO rosters (floor_manager_id, department_id, branch_id, week_start_date, week_end_date, status)
SELECT 
  fm_id,
  department_id, 
  branch_id,
  DATE_TRUNC('week', CURRENT_DATE)::DATE,
  (DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '6 days')::DATE,
  'active'
FROM test_data
ON CONFLICT DO NOTHING
RETURNING id;

-- Create assignments for the cashier
WITH roster_info AS (
  SELECT r.id as roster_id, td.cashier_id
  FROM rosters r, test_data td
  WHERE r.floor_manager_id = td.fm_id
  AND r.week_start_date = DATE_TRUNC('week', CURRENT_DATE)::DATE
)
INSERT INTO roster_assignments (roster_id, staff_id, day_of_week, shift_type, start_time, end_time, status)
SELECT roster_id, cashier_id, day, type, start_t, end_t, 'scheduled'
FROM roster_info,
VALUES 
  ('Monday', 'day', '09:00', '17:00'),
  ('Tuesday', 'day', '09:00', '17:00'),
  ('Wednesday', 'day', '09:00', '17:00'),
  ('Thursday', 'day', '09:00', '17:00'),
  ('Friday', 'day', '09:00', '17:00'),
  ('Saturday', 'off', NULL, NULL),
  ('Sunday', 'off', NULL, NULL)
AS shifts(day, type, start_t, end_t)
ON CONFLICT DO NOTHING;

-- Show what was created
SELECT 
  'SUCCESS - Created roster for:' as result,
  u.email as staff_email,
  ra.day_of_week,
  ra.shift_type,
  ra.start_time,
  ra.end_time
FROM roster_assignments ra
INNER JOIN rosters r ON ra.roster_id = r.id  
INNER JOIN users u ON ra.staff_id = u.id
WHERE r.week_start_date = DATE_TRUNC('week', CURRENT_DATE)::DATE
ORDER BY CASE ra.day_of_week
  WHEN 'Monday' THEN 1
  WHEN 'Tuesday' THEN 2
  WHEN 'Wednesday' THEN 3  
  WHEN 'Thursday' THEN 4
  WHEN 'Friday' THEN 5
  WHEN 'Saturday' THEN 6
  WHEN 'Sunday' THEN 7
END;
