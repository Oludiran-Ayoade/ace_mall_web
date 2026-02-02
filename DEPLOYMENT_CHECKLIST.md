# 🚀 Production Deployment Checklist

## ✅ COMPLETED IMPLEMENTATION

### Backend APIs Created
- ✅ **reviews.go** - Complete reviews API (GET my-reviews, POST create, GET manager reviews)
- ✅ **schedule.go** - Schedule API (GET my-assignments, GET upcoming shifts)
- ✅ **shifts.go** - Shift templates API (GET templates, PUT update, GET available)
- ✅ **notifications.go** - Full notifications system (GET, mark read, create, delete)
- ✅ **redis.go** - Redis caching configuration

### Database
- ✅ **Migration 006** - Notifications and shift_templates tables created
- ✅ Indexes added for performance
- ✅ Triggers for updated_at timestamps
- ✅ Default shift templates for existing floor managers

### Backend Routes Added (main.go)
- ✅ `/api/v1/reviews/*` - All review endpoints
- ✅ `/api/v1/notifications/*` - All notification endpoints
- ✅ `/api/v1/roster/my-assignments` - Staff schedule
- ✅ `/api/v1/shifts/*` - Shift template management
- ✅ `/api/v1/schedule/upcoming` - Upcoming shifts

### Frontend API Service Updated
- ✅ `getUserNotifications()` - Fetch notifications
- ✅ `markNotificationAsRead()` - Mark single as read
- ✅ `markAllNotificationsAsRead()` - Bulk mark
- ✅ `getMyReviews()` - Fetch staff reviews
- ✅ `createReview()` - Floor manager creates review
- ✅ `getMyAssignments()` - Fetch weekly schedule
- ✅ `getShiftTemplates()` - Get customizable shifts
- ✅ `updateShiftTemplate()` - Update shift times

### Frontend Pages Updated (Mock Data Removed)
- ✅ **my_reviews_page.dart** - Now uses `getMyReviews()`
- ✅ **my_schedule_page.dart** - Now uses `getMyAssignments()`
- ✅ **notifications_page.dart** - Now uses `getUserNotifications()`
- ✅ **floor_manager_team_reviews_page.dart** - Now uses `createReview()`

## 📋 DEPLOYMENT STEPS

### Step 1: Database Migration
```bash
# Connect to your PostgreSQL database
psql -U postgres -d ace_mall_db

# Run the migration
\i /Users/Gracegold/Desktop/Ace\ App/backend/database/migrations/006_notifications_and_shift_templates.sql

# Verify tables created
\dt notifications
\dt shift_templates

# Check indexes
\di notifications*
\di shift_templates*
```

### Step 2: Install Redis (Optional but Recommended)
```bash
# macOS
brew install redis
brew services start redis

# Verify Redis is running
redis-cli ping
# Should return: PONG

# Or use Docker
docker run -d --name redis -p 6379:6379 redis:latest
```

### Step 3: Install Go Dependencies
```bash
cd /Users/Gracegold/Desktop/Ace\ App/backend

# Install Redis client (if using Redis)
go get github.com/redis/go-redis/v9

# Tidy up dependencies
go mod tidy

# Verify no errors
go build
```

### Step 4: Update Environment Variables
Create or update `.env` file in backend directory:

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=ace_mall_db

# Redis (optional)
REDIS_HOST=localhost:6379
REDIS_PASSWORD=
REDIS_DB=0

# JWT
JWT_SECRET=your_secret_key_here

# Server
PORT=8080
```

### Step 5: Start Backend Server
```bash
cd /Users/Gracegold/Desktop/Ace\ App/backend

# Run the server
go run main.go

# You should see:
# ✅ Database connected successfully
# ✅ Redis connected successfully (if enabled)
# 🚀 Server running on port 8080
```

### Step 6: Test Backend APIs
```bash
# Test health endpoint
curl http://localhost:8080/health

# Test notifications (requires auth token)
curl -H "Authorization: Bearer YOUR_TOKEN" \
     http://localhost:8080/api/v1/notifications

# Test reviews
curl -H "Authorization: Bearer YOUR_TOKEN" \
     http://localhost:8080/api/v1/reviews/my-reviews

# Test schedule
curl -H "Authorization: Bearer YOUR_TOKEN" \
     http://localhost:8080/api/v1/roster/my-assignments?week_start=2025-12-01
```

### Step 7: Run Flutter App
```bash
cd /Users/Gracegold/Desktop/Ace\ App/ace_mall_app

# Get dependencies
flutter pub get

# Run on your device
flutter run

# Or for web
flutter run -d chrome

# Or for iOS simulator
flutter run -d ios
```

### Step 8: Test Frontend Features
1. **Login** as a general staff member
2. **Navigate to "My Reviews"** - Should load real reviews from database
3. **Navigate to "My Schedule"** - Should show actual roster assignments
4. **Navigate to "Notifications"** - Should display real notifications
5. **Login as Floor Manager**
6. **Create a Review** - Should save to database and create notification
7. **Verify** staff receives notification

## 🔍 VERIFICATION CHECKLIST

### Database Verification
- [ ] Notifications table exists with correct schema
- [ ] Shift_templates table exists with correct schema
- [ ] Default shift templates created for floor managers
- [ ] Indexes created successfully
- [ ] Triggers working for updated_at

### Backend Verification
- [ ] Server starts without errors
- [ ] All new routes accessible
- [ ] Authentication working on all endpoints
- [ ] Reviews API returns data
- [ ] Notifications API returns data
- [ ] Schedule API returns data
- [ ] Shift templates API returns data

### Frontend Verification
- [ ] No more mock data in production
- [ ] Reviews page loads real data
- [ ] Schedule page loads real data
- [ ] Notifications page loads real data
- [ ] Review submission works
- [ ] Notifications mark as read works
- [ ] No console errors
- [ ] Loading states working
- [ ] Error handling working

### Integration Verification
- [ ] Floor manager creates review → Staff receives notification
- [ ] Roster saved → Staff can see schedule
- [ ] Shift times customizable by floor manager
- [ ] Multiple users can use app simultaneously
- [ ] No data conflicts between users

## 🐛 TROUBLESHOOTING

### Database Connection Issues
```bash
# Check PostgreSQL is running
pg_isready

# Check connection
psql -U postgres -d ace_mall_db -c "SELECT 1"

# View recent logs
tail -f /usr/local/var/log/postgres.log
```

### Redis Connection Issues
```bash
# Check Redis is running
redis-cli ping

# View Redis logs
redis-cli monitor

# Check connections
redis-cli client list
```

### Backend Errors
```bash
# Check for compilation errors
go build

# Run with verbose logging
go run main.go --verbose

# Check for missing dependencies
go mod verify
```

### Frontend Errors
```bash
# Clean build
flutter clean
flutter pub get

# Check for errors
flutter analyze

# Run with verbose
flutter run --verbose
```

## 📊 PERFORMANCE MONITORING

### Database Queries to Monitor
```sql
-- Check slow queries
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Check table sizes
SELECT schemaname, tablename, 
       pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Check index usage
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

### Redis Monitoring
```bash
# Check memory usage
redis-cli info memory

# Check hit rate
redis-cli info stats | grep keyspace

# Monitor commands
redis-cli monitor
```

## 🔒 SECURITY CHECKLIST

- [ ] JWT secret is strong and not committed to git
- [ ] Database password is secure
- [ ] Redis password set (if exposed to internet)
- [ ] CORS configured properly
- [ ] Rate limiting enabled
- [ ] Input validation on all endpoints
- [ ] SQL injection prevention (using parameterized queries)
- [ ] XSS protection enabled
- [ ] HTTPS enabled in production

## 📈 NEXT STEPS

### Immediate
1. Run database migration
2. Test all APIs manually
3. Test frontend integration
4. Fix any bugs found

### Short Term (Week 1)
1. Add Redis caching layer
2. Monitor performance
3. Optimize slow queries
4. Add error logging

### Medium Term (Week 2-4)
1. Add automated tests
2. Set up CI/CD pipeline
3. Configure production server
4. Set up monitoring/alerts

### Long Term
1. Scale horizontally if needed
2. Add backup/disaster recovery
3. Implement analytics
4. Add advanced features

## 📞 SUPPORT

For issues or questions:
1. Check `PRODUCTION_READINESS_PLAN.md`
2. Check `PRODUCTION_IMPLEMENTATION_GUIDE.md`
3. Review API handler files for implementation details
4. Check database migration file for schema

## 🎉 SUCCESS CRITERIA

Your app is production-ready when:
- ✅ All mock data replaced with real APIs
- ✅ Database migration completed
- ✅ All features working end-to-end
- ✅ No errors in console/logs
- ✅ Multiple users can use simultaneously
- ✅ Performance is acceptable (<200ms API responses)
- ✅ Error handling graceful
- ✅ Security measures in place

**You're almost there! Just run the migration and test! 🚀**
