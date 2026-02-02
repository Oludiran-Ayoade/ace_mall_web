# Latest Updates - December 15, 2025

## Summary of All Changes Made

This document outlines all the updates and new features implemented across the Ace Mall application.

---

## 1. ✅ CEO Dashboard - All Staff Active

**Backend Changes:**
- Updated `getCEOStats()` in `backend/handlers/dashboard.go`
- Added `active_staff` field that equals total employees
- Changed queries to use `weekly_reviews` table instead of old `reviews` table
- Updated roster queries to use `week_end_date` column

**Result:**
- CEO Dashboard now shows all staff as active (no filtering by login status)
- All statistics use real data from `weekly_reviews` table

---

## 2. ✅ General Staff Dashboard - Color Update

**Frontend Changes:**
- Updated `ace_mall_app/lib/pages/general_staff_dashboard_page.dart`
- Changed from bright cyan (`#00BCD4`) to simpler blue-grey (`#607D8B`)
- Updated AppBar, header gradient, and all action card colors

**Colors Changed:**
- AppBar: `#00BCD4` → `#607D8B`
- Header Gradient: `#00BCD4, #0097A7` → `#607D8B, #546E7A`
- Action Cards: Various cyan shades → Blue-grey palette (`#607D8B`, `#78909C`, `#90A4AE`, `#546E7A`)

---

## 3. ✅ Floor Manager Dashboard - Real Data

**Backend Changes:**
- Updated `getFloorManagerStats()` in `backend/handlers/dashboard.go`
- Changed to use `weekly_reviews` table for all review-related queries
- Added `active_staff` field (all staff in department are active)
- Updated pending reviews logic to check `weekly_reviews` for current week

**Frontend Changes:**
- Updated `ace_mall_app/lib/pages/floor_manager_dashboard_page.dart`
- Replaced `_activeRosters` with `_activeStaff`
- Changed stat card from "Active Rosters" to "Active Staff"

**Result:**
- **Members:** Real count of all staff in Floor Manager's department/sub-department
- **Active:** Same as Members (all staff are active)
- **Pending:** Real count of staff without reviews this week from `weekly_reviews` table

---

## 4. ✅ My Schedule Page - History View

**Frontend Changes:**
- Updated `ace_mall_app/lib/pages/my_schedule_page.dart`
- Added view mode selector: Week, Month, Year
- Implemented navigation for different time periods
- Added `_viewMode` state variable and period calculation methods

**Features:**
- **Week View:** Navigate week by week (existing functionality)
- **Month View:** Navigate month by month, shows all schedules for selected month
- **Year View:** Navigate year by year, shows all schedules for selected year
- Dynamic period label updates based on selected view mode

---

## 5. ✅ My Reviews Page - Verified Real Data

**Status:** Already using `weekly_reviews` table correctly
- Backend handler `GetMyReviews` in `backend/handlers/reviews.go` queries `weekly_reviews`
- Returns reviews with proper fields: rating, attendance, punctuality, performance
- Includes reviewer name and role from database joins

---

## 6. ✅ Admin Messaging System - NEW FEATURE

### Database Schema
**Created:** `backend/database/create_messages_table.sql`

**Tables:**
1. **messages**
   - Stores admin broadcast messages
   - Fields: id, sender_id, title, content, target_type, target_branch_id, created_at, expires_at, is_active
   - Target types: 'all' (all staff) or 'branch' (specific branch)
   - **Messages expire after 1 week**

2. **notifications**
   - Stores individual user notifications
   - Fields: id, user_id, title, message, type, message_id, is_read, created_at, expires_at
   - Types: 'message', 'shift_reminder', 'system'
   - **Notifications from messages expire after 1 week**
   - **System notifications expire after 24 hours**

### Backend API
**Created:** `backend/handlers/messages.go`

**Endpoints:**
1. `POST /api/v1/messages/send` - Send broadcast message
   - Admin only (CEO, Chairman, COO, HR)
   - Target all staff or specific branch
   - Creates notifications for all target users
   - Messages expire after 1 week

2. `GET /api/v1/messages/sent` - Get sent messages history
   - Returns all messages sent by current admin
   - Includes target info and expiry status

3. `GET /api/v1/notifications/my` - Get user's active notifications
   - Returns all non-expired notifications
   - Filters by expiry date automatically

4. `POST /api/v1/messages/cleanup` - Cleanup expired items
   - Removes expired notifications and messages
   - Can be run manually or scheduled

### Frontend
**Created:** `ace_mall_app/lib/pages/admin_messaging_page.dart`

**Features:**
- Clean, modern UI for sending messages
- Title and content input fields
- Target selection: All Staff or Specific Branch
- Branch dropdown (when targeting specific branch)
- Real-time validation
- Success/error feedback
- Info banner about 1-week expiry

**API Service Methods Added:**
- `sendMessage()` - Send broadcast message
- `getSentMessages()` - Get message history
- `getMyNotifications()` - Get user notifications
- `markNotificationAsRead()` - Mark notification as read (already existed)

---

## 7. ⚠️ Shift Notification System - REQUIRES SETUP

**Requirements for 30-Minute Shift Reminders:**

This feature requires additional setup that goes beyond simple code changes:

### Option 1: Background Service (Recommended for Production)
1. **Backend Cron Job:**
   - Create scheduled task that runs every 15 minutes
   - Queries roster assignments for shifts starting in 30 minutes
   - Creates shift_reminder notifications for affected staff
   - Example: `SELECT * FROM roster_assignments WHERE start_time BETWEEN NOW() + INTERVAL '25 minutes' AND NOW() + INTERVAL '35 minutes'`

2. **Push Notifications:**
   - Integrate Firebase Cloud Messaging (FCM) for both Android and iOS
   - Store device tokens in database
   - Send push notifications when shift reminders are created
   - Requires: `firebase_messaging` Flutter package

### Option 2: Client-Side (Simpler but less reliable)
1. **Local Notifications:**
   - Use `flutter_local_notifications` package
   - Schedule notifications when user views their schedule
   - Limitations: Only works if app is installed, may not fire if app is killed

### Implementation Steps:
1. Add notification permissions to Android/iOS manifests
2. Set up Firebase project and add config files
3. Implement device token registration
4. Create backend cron job or scheduled task
5. Test on both Android and iOS devices

**Note:** This requires infrastructure setup beyond code changes and should be implemented as a separate phase.

---

## Database Migration Required

**Before using the messaging system, run this SQL:**

```bash
cd /Users/Gracegold/Desktop/Ace\ App/backend/database
psql -U your_username -d your_database -f create_messages_table.sql
```

Or manually execute the SQL in your database client.

---

## Testing Checklist

### CEO Dashboard
- [ ] Login as CEO
- [ ] Verify "Active" stat shows same number as "Total Staff"
- [ ] Check that all stats use real data

### General Staff Dashboard
- [ ] Login as general staff
- [ ] Verify colors are blue-grey (not bright cyan)
- [ ] Check all 4 action cards have consistent color scheme

### Floor Manager Dashboard
- [ ] Login as Floor Manager
- [ ] Verify "Members" shows real staff count
- [ ] Verify "Active" equals "Members"
- [ ] Verify "Pending" shows staff without this week's reviews

### My Schedule Page
- [ ] Login as any staff
- [ ] Navigate to My Schedule
- [ ] Test Week/Month/Year view toggles
- [ ] Navigate backward and forward in each view mode
- [ ] Verify schedule data loads correctly

### My Reviews Page
- [ ] Login as general staff
- [ ] Navigate to My Reviews
- [ ] Verify reviews show real data from database
- [ ] Check reviewer names are displayed
- [ ] Verify ratings are correct

### Admin Messaging System
- [ ] Login as CEO/Chairman/COO/HR
- [ ] Navigate to Admin Messaging page (need to add route)
- [ ] Send message to "All Staff"
- [ ] Send message to specific branch
- [ ] Verify success messages appear
- [ ] Check notifications are created for target users
- [ ] Login as general staff and verify notification appears

---

## Routes to Add

Add these routes to your Flutter app's route configuration:

```dart
'/admin-messaging': (context) => const AdminMessagingPage(),
```

Add navigation button in CEO/HR/COO dashboards:
```dart
ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/admin-messaging'),
  child: const Text('Send Message to Staff'),
)
```

---

## Important Notes

1. **All Staff Are Active:** Throughout the app, all staff are now considered active unless you specify otherwise later.

2. **Message Expiry:**
   - Messages expire after **1 week**
   - System notifications expire after **24 hours**
   - Expired items are automatically filtered from queries
   - Run cleanup endpoint periodically to remove expired records

3. **Reviews Data:** All review-related features now use the `weekly_reviews` table exclusively.

4. **Shift Notifications:** The 30-minute shift reminder system requires additional infrastructure (Firebase, cron jobs) and should be implemented as a separate project phase.

5. **Database Migration:** Don't forget to run the `create_messages_table.sql` migration before using the messaging system.

---

## Files Modified

### Backend
- `backend/handlers/dashboard.go` - Updated CEO and Floor Manager stats
- `backend/handlers/messages.go` - NEW: Messaging system handlers
- `backend/main.go` - Added messaging routes
- `backend/database/create_messages_table.sql` - NEW: Database schema

### Frontend
- `ace_mall_app/lib/pages/general_staff_dashboard_page.dart` - Color updates
- `ace_mall_app/lib/pages/floor_manager_dashboard_page.dart` - Real data integration
- `ace_mall_app/lib/pages/my_schedule_page.dart` - History view added
- `ace_mall_app/lib/pages/admin_messaging_page.dart` - NEW: Admin messaging UI
- `ace_mall_app/lib/services/api_service.dart` - Added messaging API methods

---

## Next Steps

1. **Run Database Migration:**
   ```bash
   psql -U your_username -d your_database -f backend/database/create_messages_table.sql
   ```

2. **Add Routes:** Add admin messaging route to Flutter app

3. **Test All Features:** Go through the testing checklist above

4. **Hot Reload Flutter App:** Press 'r' in the terminal running your Flutter app

5. **Plan Shift Notifications:** Decide on implementation approach (backend cron vs client-side)

6. **Optional:** Set up automated cleanup job for expired notifications/messages

---

## Support

All features are now implemented and ready for testing. The backend server is running on port 8080.

For shift notifications, you'll need to decide whether to implement:
- **Backend approach:** More reliable, requires cron job setup
- **Client approach:** Simpler, but less reliable

Both approaches require Firebase setup for push notifications on mobile devices.
