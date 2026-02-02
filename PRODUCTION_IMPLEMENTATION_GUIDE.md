# Production Implementation Guide

## ✅ Files Created

### Backend
1. **`backend/config/redis.go`** - Redis configuration and caching helpers
2. **`backend/database/migrations/006_notifications_and_shift_templates.sql`** - Database schema for notifications and shift templates
3. **`backend/handlers/notifications.go`** - Complete notifications API handlers

### Documentation
1. **`PRODUCTION_READINESS_PLAN.md`** - Comprehensive production readiness plan

## 🚀 Quick Start Implementation Steps

### Step 1: Install Redis (Required for caching)
```bash
# macOS
brew install redis
brew services start redis

# Or use Docker
docker run -d -p 6379:6379 redis:latest
```

### Step 2: Install Go Redis Package
```bash
cd backend
go get github.com/redis/go-redis/v9
go mod tidy
```

### Step 3: Run Database Migration
```bash
# Connect to your PostgreSQL database
psql -U postgres -d ace_mall_db -f database/migrations/006_notifications_and_shift_templates.sql
```

### Step 4: Update Backend Main File
Add these routes to `backend/main.go`:

```go
// Notifications routes
api.GET("/notifications", middleware.AuthMiddleware(), handlers.GetUserNotifications)
api.GET("/notifications/unread-count", middleware.AuthMiddleware(), handlers.GetUnreadCount)
api.PUT("/notifications/:id/read", middleware.AuthMiddleware(), handlers.MarkNotificationAsRead)
api.PUT("/notifications/mark-all-read", middleware.AuthMiddleware(), handlers.MarkAllNotificationsAsRead)
api.POST("/notifications", middleware.AuthMiddleware(), handlers.CreateNotification)
api.DELETE("/notifications/:id", middleware.AuthMiddleware(), handlers.DeleteNotification)
```

### Step 5: Initialize Redis in Main
Add to `backend/main.go`:

```go
import "your-module/config"

func main() {
    // ... existing code ...
    
    // Initialize Redis
    if err := config.InitRedis(); err != nil {
        log.Printf("Warning: Redis not available: %v", err)
        // App can still run without Redis (will just be slower)
    }
    
    // ... rest of code ...
}
```

## 📋 Remaining Implementation Tasks

### Backend APIs to Create

#### 1. Reviews API (`backend/handlers/reviews.go`)
```go
// GET /api/v1/reviews/my-reviews
func GetMyReviews(c *gin.Context) {
    // Fetch all reviews for authenticated staff member
    // Include: attendance_score, punctuality_score, performance_score
}

// POST /api/v1/reviews
func CreateReview(c *gin.Context) {
    // Floor manager creates review for staff
    // Send notification to staff member
}
```

#### 2. Schedule API (Add to `backend/handlers/roster.go`)
```go
// GET /api/v1/roster/my-assignments
func GetMyAssignments(c *gin.Context) {
    // Get roster assignments for authenticated staff
    // Filter by week_start parameter
    // Return: day, date, shift_type, start_time, end_time
}
```

#### 3. Shift Templates API (`backend/handlers/shifts.go`)
```go
// GET /api/v1/shifts/templates
func GetShiftTemplates(c *gin.Context) {
    // Get customizable shift times for floor manager
}

// PUT /api/v1/shifts/templates/:id
func UpdateShiftTemplate(c *gin.Context) {
    // Update shift start/end times
}
```

### Frontend Updates

#### 1. Update API Service (`ace_mall_app/lib/services/api_service.dart`)
Add these methods:

```dart
// Notifications
Future<List<Map<String, dynamic>>> getUserNotifications({int limit = 50}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/notifications?limit=$limit'),
    headers: await _getHeaders(),
  );
  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }
  throw Exception('Failed to load notifications');
}

Future<void> markNotificationAsRead(int notificationId) async {
  await http.put(
    Uri.parse('$baseUrl/notifications/$notificationId/read'),
    headers: await _getHeaders(),
  );
}

Future<void> markAllNotificationsAsRead() async {
  await http.put(
    Uri.parse('$baseUrl/notifications/mark-all-read'),
    headers: await _getHeaders(),
  );
}

// Reviews
Future<List<Map<String, dynamic>>> getMyReviews() async {
  final response = await http.get(
    Uri.parse('$baseUrl/reviews/my-reviews'),
    headers: await _getHeaders(),
  );
  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }
  throw Exception('Failed to load reviews');
}

Future<void> createReview({
  required int staffId,
  required double attendanceScore,
  required double punctualityScore,
  required double performanceScore,
  required String remarks,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/reviews'),
    headers: await _getHeaders(),
    body: json.encode({
      'staff_id': staffId,
      'attendance_score': attendanceScore,
      'punctuality_score': punctualityScore,
      'performance_score': performanceScore,
      'remarks': remarks,
    }),
  );
  if (response.statusCode != 201) {
    throw Exception('Failed to create review');
  }
}

// Schedule
Future<List<Map<String, dynamic>>> getMyAssignments(String weekStart) async {
  final response = await http.get(
    Uri.parse('$baseUrl/roster/my-assignments?week_start=$weekStart'),
    headers: await _getHeaders(),
  );
  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }
  throw Exception('Failed to load schedule');
}

// Shift Templates
Future<List<Map<String, dynamic>>> getShiftTemplates() async {
  final response = await http.get(
    Uri.parse('$baseUrl/shifts/templates'),
    headers: await _getHeaders(),
  );
  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }
  throw Exception('Failed to load shift templates');
}
```

#### 2. Replace Mock Data in Pages

**my_reviews_page.dart:**
```dart
Future<void> _loadReviews() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final reviews = await _apiService.getMyReviews();
    setState(() {
      _reviews = reviews;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = e.toString();
      _isLoading = false;
    });
  }
}
```

**my_schedule_page.dart:**
```dart
Future<void> _loadSchedule() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final weekStart = DateFormat('yyyy-MM-dd').format(_selectedWeekStart);
    final schedules = await _apiService.getMyAssignments(weekStart);
    setState(() {
      _schedules = schedules;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = e.toString();
      _isLoading = false;
    });
  }
}
```

**notifications_page.dart:**
```dart
Future<void> _loadNotifications() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final notifications = await _apiService.getUserNotifications();
    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = e.toString();
      _isLoading = false;
    });
  }
}

Future<void> _markAsRead(String notificationId) async {
  try {
    await _apiService.markNotificationAsRead(int.parse(notificationId));
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'].toString() == notificationId);
      if (index != -1) {
        _notifications[index]['is_read'] = true;
      }
    });
  } catch (e) {
    // Handle error
  }
}
```

**floor_manager_team_reviews_page.dart:**
```dart
Future<void> _submitReview(
  dynamic staffId,
  double rating,
  double attendanceScore,
  double punctualityScore,
  double performanceScore,
  String comment,
) async {
  try {
    await _apiService.createReview(
      staffId: int.parse(staffId.toString()),
      attendanceScore: attendanceScore,
      punctualityScore: punctualityScore,
      performanceScore: performanceScore,
      remarks: comment,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit review: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

**roster_management_page.dart:**
```dart
// Replace hardcoded shift times with API call
Future<void> _loadShiftTemplates() async {
  try {
    final templates = await _apiService.getShiftTemplates();
    setState(() {
      _shiftTemplates = templates;
    });
  } catch (e) {
    // Use default times if API fails
    _shiftTemplates = [
      {'shift_type': 'day', 'start_time': '07:00:00', 'end_time': '15:00:00'},
      {'shift_type': 'afternoon', 'start_time': '15:00:00', 'end_time': '23:00:00'},
      {'shift_type': 'night', 'start_time': '23:00:00', 'end_time': '07:00:00'},
    ];
  }
}
```

## 🔍 Testing Checklist

- [ ] Redis is running and accessible
- [ ] Database migration completed successfully
- [ ] All notification endpoints working
- [ ] Reviews API integrated
- [ ] Schedule API integrated
- [ ] Shift templates customizable
- [ ] No more mock data in production
- [ ] Error handling for API failures
- [ ] Loading states working properly
- [ ] Cache invalidation working

## 📊 Performance Targets

- API response time: < 200ms (with cache)
- Cache hit rate: > 70%
- Database query time: < 50ms
- Concurrent users supported: 100+
- Notification delivery: < 1 second

## 🔐 Security Checklist

- [ ] All endpoints require authentication
- [ ] Input validation on all requests
- [ ] SQL injection prevention
- [ ] Rate limiting enabled
- [ ] CORS properly configured
- [ ] Redis password protected
- [ ] Environment variables secured

## 📝 Next Steps

1. Complete remaining backend API handlers
2. Update all frontend pages to use real APIs
3. Test with multiple concurrent users
4. Monitor Redis cache performance
5. Optimize database queries
6. Deploy to production environment

## 🐛 Known Issues to Fix

1. Remove unused `_apiService` fields in pages
2. Remove unused `staffId` variables
3. Remove unreferenced `_showReviewDialog` methods
4. Add proper error handling for all API calls
5. Implement retry logic for failed requests

## 📞 Support

For issues or questions, refer to:
- `PRODUCTION_READINESS_PLAN.md` for detailed planning
- Backend API documentation in respective handler files
- Database schema in migration files
