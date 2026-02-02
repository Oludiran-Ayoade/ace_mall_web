-- Quick script to create roster data for testing schedule page
-- This will create a roster for the current week that shows up immediately

DO $$
DECLARE
    v_cashier_id UUID;
    v_floor_mgr_id UUID;
    v_branch_id UUID;
    v_dept_id UUID;
    v_roster_id UUID;
    v_week_start DATE;
    v_week_end DATE;
BEGIN
    -- Get current week dates (Monday to Sunday)
    v_week_start := DATE_TRUNC('week', CURRENT_DATE)::DATE;
    v_week_end := v_week_start + INTERVAL '6 days';
    
    -- Find a cashier (any cashier will do)
    SELECT u.id, u.branch_id, u.department_id
    INTO v_cashier_id, v_branch_id, v_dept_id
    FROM users u
    INNER JOIN roles r ON u.role_id = r.id
    WHERE r.name LIKE '%Cashier%'
    AND u.is_active = true
    LIMIT 1;
    
    IF v_cashier_id IS NULL THEN
        RAISE EXCEPTION 'No cashier found in database';
    END IF;
    
    -- Find floor manager for same branch and department
    SELECT u.id
    INTO v_floor_mgr_id
    FROM users u
    INNER JOIN roles r ON u.role_id = r.id
    WHERE u.branch_id = v_branch_id
    AND u.department_id = v_dept_id
    AND r.category = 'floor_manager'
    AND u.is_active = true
    LIMIT 1;
    
    IF v_floor_mgr_id IS NULL THEN
        RAISE EXCEPTION 'No floor manager found for this department';
    END IF;
    
    -- Delete existing roster for this week if it exists
    DELETE FROM roster_assignments 
    WHERE roster_id IN (
        SELECT id FROM rosters 
        WHERE floor_manager_id = v_floor_mgr_id 
        AND week_start_date = v_week_start
    );
    
    DELETE FROM rosters 
    WHERE floor_manager_id = v_floor_mgr_id 
    AND week_start_date = v_week_start;
    
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
    
    -- Create shift assignments (Monday-Friday: day shift, Weekend: off)
    INSERT INTO roster_assignments (roster_id, staff_id, day_of_week, shift_type, start_time, end_time, notes)
    VALUES
        (v_roster_id, v_cashier_id, 'Monday', 'day', '09:00', '17:00', 'Regular shift'),
        (v_roster_id, v_cashier_id, 'Tuesday', 'day', '09:00', '17:00', 'Regular shift'),
        (v_roster_id, v_cashier_id, 'Wednesday', 'day', '09:00', '17:00', 'Regular shift'),
        (v_roster_id, v_cashier_id, 'Thursday', 'day', '09:00', '17:00', 'Regular shift'),
        (v_roster_id, v_cashier_id, 'Friday', 'day', '09:00', '17:00', 'Regular shift'),
        (v_roster_id, v_cashier_id, 'Saturday', 'off', '00:00', '00:00', 'Day off'),
        (v_roster_id, v_cashier_id, 'Sunday', 'off', '00:00', '00:00', 'Day off');
    
    RAISE NOTICE '✅ SUCCESS! Created roster for week % to %', v_week_start, v_week_end;
    RAISE NOTICE 'Cashier ID: %', v_cashier_id;
    RAISE NOTICE 'Roster ID: %', v_roster_id;
    
END $$;

-- Verify the roster was created
SELECT 
    'ROSTER CREATED' as status,
    u.email as cashier_email,
    u.full_name as cashier_name,
    COUNT(ra.id) as total_shifts
FROM roster_assignments ra
INNER JOIN rosters r ON ra.roster_id = r.id
INNER JOIN users u ON ra.staff_id = u.id
WHERE r.week_start_date = DATE_TRUNC('week', CURRENT_DATE)::DATE
GROUP BY u.email, u.full_name;
