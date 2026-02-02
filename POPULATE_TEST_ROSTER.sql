-- ============================================================================
-- POPULATE TEST ROSTER FOR CASHIER IN ABEOKUTA
-- This creates a roster that will show up in the general staff schedule page
-- ============================================================================

-- This script will:
-- 1. Find a cashier in Abeokuta branch
-- 2. Find their floor manager
-- 3. Create a roster for this week
-- 4. Create shift assignments for the cashier

DO $$
DECLARE
    v_cashier_id UUID;
    v_cashier_email TEXT;
    v_floor_mgr_id UUID;
    v_floor_mgr_email TEXT;
    v_branch_id INTEGER;
    v_dept_id INTEGER;
    v_roster_id INTEGER;
    v_week_start DATE;
    v_week_end DATE;
BEGIN
    -- Get current week dates (Monday to Sunday)
    v_week_start := DATE_TRUNC('week', CURRENT_DATE)::DATE;
    v_week_end := v_week_start + INTERVAL '6 days';
    
    RAISE NOTICE '=== Creating roster for week: % to % ===', v_week_start, v_week_end;
    
    -- Find a cashier in Abeokuta (SuperMarket department)
    SELECT u.id, u.email, u.branch_id, u.department_id
    INTO v_cashier_id, v_cashier_email, v_branch_id, v_dept_id
    FROM users u
    INNER JOIN branches b ON u.branch_id = b.id
    INNER JOIN roles r ON u.role_id = r.id
    INNER JOIN departments d ON u.department_id = d.id
    WHERE b.name LIKE '%Abeokuta%'
    AND d.name = 'SuperMarket'
    AND r.name LIKE '%Cashier%'
    AND u.is_active = true
    LIMIT 1;
    
    IF v_cashier_id IS NULL THEN
        RAISE EXCEPTION 'ERROR: No cashier found in Abeokuta SuperMarket department';
    END IF;
    
    RAISE NOTICE 'Found cashier: % (%)', v_cashier_email, v_cashier_id;
    
    -- Find floor manager for SuperMarket in Abeokuta
    SELECT u.id, u.email
    INTO v_floor_mgr_id, v_floor_mgr_email
    FROM users u
    INNER JOIN roles r ON u.role_id = r.id
    WHERE u.branch_id = v_branch_id
    AND u.department_id = v_dept_id
    AND r.category = 'floor_manager'
    AND u.is_active = true
    LIMIT 1;
    
    IF v_floor_mgr_id IS NULL THEN
        RAISE EXCEPTION 'ERROR: No floor manager found for SuperMarket in Abeokuta';
    END IF;
    
    RAISE NOTICE 'Found floor manager: % (%)', v_floor_mgr_email, v_floor_mgr_id;
    
    -- Check if roster already exists for this week
    SELECT id INTO v_roster_id
    FROM rosters
    WHERE floor_manager_id = v_floor_mgr_id
    AND week_start_date = v_week_start
    AND department_id = v_dept_id;
    
    -- Delete old roster if exists
    IF v_roster_id IS NOT NULL THEN
        RAISE NOTICE 'Deleting existing roster: %', v_roster_id;
        DELETE FROM roster_assignments WHERE roster_id = v_roster_id;
        DELETE FROM rosters WHERE id = v_roster_id;
    END IF;
    
    -- Create new roster
    INSERT INTO rosters (
        floor_manager_id,
        department_id,
        branch_id,
        week_start_date,
        week_end_date,
        status,
        created_at,
        updated_at
    ) VALUES (
        v_floor_mgr_id,
        v_dept_id,
        v_branch_id,
        v_week_start,
        v_week_end,
        'active',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) RETURNING id INTO v_roster_id;
    
    RAISE NOTICE 'Created roster ID: %', v_roster_id;
    
    -- Create roster assignments for the cashier (Monday to Friday: day shift, Weekend: off)
    INSERT INTO roster_assignments (roster_id, staff_id, day_of_week, shift_type, start_time, end_time, status)
    VALUES
        (v_roster_id, v_cashier_id, 'Monday', 'day', '08:00', '16:00', 'scheduled'),
        (v_roster_id, v_cashier_id, 'Tuesday', 'day', '08:00', '16:00', 'scheduled'),
        (v_roster_id, v_cashier_id, 'Wednesday', 'day', '08:00', '16:00', 'scheduled'),
        (v_roster_id, v_cashier_id, 'Thursday', 'day', '08:00', '16:00', 'scheduled'),
        (v_roster_id, v_cashier_id, 'Friday', 'day', '08:00', '16:00', 'scheduled'),
        (v_roster_id, v_cashier_id, 'Saturday', 'off', NULL, NULL, 'off'),
        (v_roster_id, v_cashier_id, 'Sunday', 'off', NULL, NULL, 'off');
    
    RAISE NOTICE 'Created 7 roster assignments for cashier';
    RAISE NOTICE '=== SUCCESS: Roster created successfully! ===';
    RAISE NOTICE 'Cashier % can now view their schedule in the app', v_cashier_email;
    
END $$;

-- Verify the roster was created
SELECT 
    'VERIFICATION' as status,
    r.id as roster_id,
    u_fm.email as floor_manager,
    b.name as branch,
    d.name as department,
    r.week_start_date,
    r.week_end_date,
    COUNT(ra.id) as assignments_count
FROM rosters r
INNER JOIN users u_fm ON r.floor_manager_id = u_fm.id
INNER JOIN branches b ON r.branch_id = b.id
INNER JOIN departments d ON r.department_id = d.id
LEFT JOIN roster_assignments ra ON ra.roster_id = r.id
WHERE r.week_start_date = DATE_TRUNC('week', CURRENT_DATE)::DATE
AND b.name LIKE '%Abeokuta%'
AND d.name = 'SuperMarket'
GROUP BY r.id, u_fm.email, b.name, d.name, r.week_start_date, r.week_end_date;

-- Show the assignments
SELECT 
    'ASSIGNMENTS' as type,
    u.email as staff_email,
    ra.day_of_week,
    ra.shift_type,
    ra.start_time,
    ra.end_time,
    ra.status
FROM roster_assignments ra
INNER JOIN rosters r ON ra.roster_id = r.id
INNER JOIN users u ON ra.staff_id = u.id
INNER JOIN branches b ON r.branch_id = b.id
WHERE r.week_start_date = DATE_TRUNC('week', CURRENT_DATE)::DATE
AND b.name LIKE '%Abeokuta%'
ORDER BY 
    CASE ra.day_of_week
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;
