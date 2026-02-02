# Production Readiness Plan for Ace Mall App

## Overview
This document outlines all the changes needed to make the app production-ready by replacing mock data with real database integration and adding Redis caching.

## 1. Mock Data to Replace

### Frontend (Flutter)
1. **My Reviews Page** (`my_reviews_page.dart`)
   - `_getMockReviews()` - Replace with API call to `/api/v1/reviews/my-reviews`
   - Currently returns 8 hardcoded reviews

2. **My Schedule Page** (`my_schedule_page.dart`)
   - `_getMockSchedule()` - Replace with API call to `/api/v1/roster/my-assignments`
   - Currently returns hardcoded weekly schedule

3. **Notifications Page** (`notifications_page.dart`)
   - `_getMockNotifications()` - Replace with API call to `/api/v1/notifications`
   - Currently returns 6 hardcoded notifications

4. **Roster Management Page** (`roster_management_page.dart`)
   - Hardcoded shift times - Should fetch from `/api/v1/shifts/templates`
   - Lines 209-215: Default shift times

5. **Floor Manager Dashboard** (`floor_manager_dashboard_page.dart`)
   - Line 53: `_teamMembers = 12` - Should fetch from API
   - Lines 54-55: `_activeRosters` and `_pendingReviews` - Mock data

6. **Floor Manager Team Reviews** (`floor_manager_team_reviews_page.dart`)
   - Line 228: Review submission - Not connected to API

7. **Profile Page** (`profile_page.dart`)
   - Line 69: Profile update - Not connected to API

8. **Add General Staff Page** (`add_general_staff_page.dart`)
   - Line 222: Staff creation - Not fully implemented

9. **Shift Times Page** (`shift_times_page.dart`)
   - Lines 33-34: Load/save shifts - Not connected to API

10. **View Ratings Page** (`view_ratings_page.dart`)
    - Line 68: Ratings data - Mock data

11. **View Rosters Page** (`view_rosters_page.dart`)
    - Line 68: Rosters data - Mock data

12. **Staff Detail Page** (`staff_detail_page.dart`)
    - Line 972: Reviews tab - Mock data

## 2. Backend APIs to Create

### Reviews API
```go
// GET /api/v1/reviews/my-reviews
// Returns all reviews for the authenticated staff member
// Response: [{id, date, week_start, week_end, rating, attendance_score, punctuality_score, performance_score, remarks, reviewer_name, reviewer_role}]

// POST /api/v1/reviews
// Create a new review (floor manager only)
// Request: {staff_id, attendance_score, punctuality_score, performance_score, remarks}
```

### Schedule/Roster Assignments API
```go
// GET /api/v1/roster/my-assignments?week_start=YYYY-MM-DD
// Returns roster assignments for the authenticated staff member
// Response: [{day, date, shift_type, start_time, end_time, status}]
```

### Notifications API
```go
// GET /api/v1/notifications
// Returns all notifications for the authenticated user
// Response: [{id, type, title, message, created_at, is_read}]

// PUT /api/v1/notifications/:id/read
// Mark a notification as read

// PUT /api/v1/notifications/mark-all-read
// Mark all notifications as read

// POST /api/v1/notifications
// Create a notification (system/manager use)
// Request: {user_id, type, title, message}
```

### Shift Templates API
```go
// GET /api/v1/shifts/templates
// Get shift templates for the authenticated floor manager
// Response: [{id, shift_type, start_time, end_time}]

// PUT /api/v1/shifts/templates/:id
// Update shift template times
// Request: {start_time, end_time}
```

### Dashboard Stats API
```go
// GET /api/v1/dashboard/stats
// Get dashboard statistics for the authenticated user
// Response: {team_members, active_rosters, pending_reviews, ...}
```

## 3. Database Schema Additions

### Notifications Table
```sql
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- 'shift_reminder', 'roster_assignment', 'schedule_change', 'review', 'general'
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
```

### Shift Templates Table (if not exists)
```sql
CREATE TABLE IF NOT EXISTS shift_templates (
    id SERIAL PRIMARY KEY,
    floor_manager_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    shift_type VARCHAR(20) NOT NULL, -- 'day', 'afternoon', 'night'
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(floor_manager_id, shift_type)
);
```

## 4. Redis Caching Strategy

### Cache Keys Structure
```
user:{user_id}:profile
user:{user_id}:reviews
user:{user_id}:schedule:{week_start}
user:{user_id}:notifications
roster:{roster_id}
shifts:{floor_manager_id}:templates
dashboard:{user_id}:stats
```

### Cache Expiration Times
- User profile: 1 hour
- Reviews: 30 minutes
- Schedule: 15 minutes
- Notifications: 5 minutes
- Roster: 1 hour
- Shift templates: 24 hours
- Dashboard stats: 10 minutes

### Cache Invalidation Rules
- Profile updated → Invalidate `user:{user_id}:profile`
- Review created → Invalidate `user:{staff_id}:reviews`
- Roster saved → Invalidate all `user:*:schedule:*` for assigned staff
- Notification created → Invalidate `user:{user_id}:notifications`
- Shift template updated → Invalidate `shifts:{floor_manager_id}:templates`

## 5. Implementation Priority

### Phase 1: Critical Features (Week 1)
1. ✅ Reviews API (GET my-reviews, POST create review)
2. ✅ Schedule API (GET my-assignments)
3. ✅ Notifications API (GET, mark as read)
4. ✅ Update frontend to use real APIs

### Phase 2: Enhanced Features (Week 2)
1. ✅ Shift templates API
2. ✅ Dashboard stats API
3. ✅ Profile update API
4. ✅ Redis caching layer

### Phase 3: Optimization (Week 3)
1. ✅ Performance testing
2. ✅ Load testing with multiple users
3. ✅ Cache hit rate monitoring
4. ✅ Database query optimization

## 6. Environment Variables Needed

```env
# Redis Configuration
REDIS_HOST=localhost:6379
REDIS_PASSWORD=
REDIS_DB=0

# Cache Settings
CACHE_ENABLED=true
CACHE_DEFAULT_TTL=900  # 15 minutes in seconds
```

## 7. Testing Checklist

- [ ] All mock data replaced with real API calls
- [ ] Redis caching working for all endpoints
- [ ] Cache invalidation working correctly
- [ ] Multiple concurrent users tested
- [ ] Database queries optimized with indexes
- [ ] Error handling for cache failures
- [ ] Fallback to database when cache misses
- [ ] API response times < 200ms
- [ ] No memory leaks in Redis
- [ ] Proper cleanup of expired cache entries

## 8. Deployment Steps

1. Install Redis on production server
2. Update environment variables
3. Run database migrations for new tables
4. Deploy backend with Redis support
5. Deploy frontend with API integration
6. Monitor cache hit rates
7. Adjust TTL values based on usage patterns

## 9. Monitoring & Alerts

### Metrics to Track
- Redis cache hit/miss ratio
- API response times
- Database query times
- Active user count
- Notification delivery rate
- Review submission rate

### Alerts to Set Up
- Redis connection failures
- Cache hit rate < 70%
- API response time > 500ms
- Database connection pool exhausted
- High memory usage in Redis

## 10. Security Considerations

- [ ] All API endpoints require authentication
- [ ] Rate limiting on API endpoints
- [ ] Input validation on all requests
- [ ] SQL injection prevention
- [ ] XSS protection
- [ ] CORS properly configured
- [ ] Sensitive data encrypted in cache
- [ ] Redis password protected
- [ ] Regular security audits
