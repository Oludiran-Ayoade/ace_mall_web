# Terminated Staff Page - Debugging & Fixes

## Changes Made

### 1. ✅ Set Default Filter to "All Types"
**File:** `/ace_mall_app/lib/pages/terminated_staff_page.dart`

```dart
@override
void initState() {
  super.initState();
  _selectedType = 'All Types'; // Set default filter
  _loadTerminatedStaff();
}
```

This ensures the dropdown shows "All Types" by default when the page loads.

---

### 2. ✅ Added Debug Logging to API Service
**File:** `/ace_mall_app/lib/services/api_service.dart`

Added console logging to track:
- Request URL
- Response status code
- Response body
- Errors

This will help identify authentication or API issues.

---

### 3. ✅ Added Debug Logging to Backend
**File:** `/backend/handlers/termination.go`

Added logging to track:
- User ID making the request
- User role
- Any errors in role verification

---

## Current Status

### Database Check ✅
```sql
SELECT COUNT(*) FROM terminated_staff;
-- Result: 1 terminated staff member exists
```

**Terminated Staff:**
- Name: Mr. Segun Afolabi
- Email: waiter.ife1@acesupermarket.com
- Type: terminated
- Date: 2025-12-06

### Backend Status ✅
- Server running on port 8080
- Database connected successfully
- Endpoint: `GET /api/v1/staff/terminated`

---

## How to Debug

### Step 1: Check Flutter Console
When you navigate to the Terminated Staff page, look for these logs:
```
🔍 Fetching terminated staff from: http://localhost:8080/api/v1/staff/terminated
📡 Response status: [status_code]
📦 Response body: [response]
```

### Step 2: Check Backend Console
Look for these debug logs:
```
DEBUG: GetTerminatedStaff called by user: [user_id]
DEBUG: User role: [role_name]
```

### Step 3: Common Issues

**If you see "Invalid or expired token":**
- User is not logged in properly
- Token has expired
- Need to re-login

**If you see "Only top admin officers can view terminated staff":**
- User role doesn't match: CEO, COO, HR, Chairman, or Auditor
- Check user's actual role in database

**If you see "Failed to verify user role":**
- Database query failed
- User ID not found in database

---

## Testing Steps

1. **Login as HR/CEO/COO**
2. **Navigate to Dashboard**
3. **Click "Departed Staff" card**
4. **Check console logs** (both Flutter and Backend)
5. **Expected Result:**
   - Page loads successfully
   - Shows "All Types" in dropdown
   - Displays Mr. Segun Afolabi in the list

---

## Files Modified

### Frontend:
- `/ace_mall_app/lib/pages/terminated_staff_page.dart` - Set default filter
- `/ace_mall_app/lib/services/api_service.dart` - Added debug logging

### Backend:
- `/backend/handlers/termination.go` - Added debug logging

---

## Next Steps

After checking the logs, we'll know exactly what's failing:
- Authentication issue → Fix token handling
- Authorization issue → Fix role check
- API issue → Fix endpoint or query
- Data issue → Check database records

The debug logs will tell us the exact problem!
