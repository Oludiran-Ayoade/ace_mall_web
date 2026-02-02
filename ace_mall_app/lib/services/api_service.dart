import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/branch.dart';
import '../models/department.dart';
import '../models/role.dart';
import '../utils/error_handler.dart';

class ApiService {
  // Production backend URL (Render)
  static const String baseUrl = 'https://ace-supermarket-backend.onrender.com/api/v1';
  
  // For local development, use:
  // - iOS simulator: http://localhost:8080/api/v1
  // - Android emulator: http://10.0.2.2:8080/api/v1
  // - Physical device: http://YOUR_IP:8080/api/v1
  // - Flutter web: http://localhost:8080/api/v1

  // HTTP client with SSL bypass and timeout settings
  static http.Client? _client;
  static const Duration _timeout = Duration(seconds: 30);

  // Cache for frequently accessed data
  static List<Branch>? _cachedBranches;
  static List<Department>? _cachedDepartments;
  static DateTime? _branchCacheTime;
  static DateTime? _departmentCacheTime;
  static const Duration _cacheExpiry = Duration(hours: 1);

  static http.Client _getClient() {
    if (_client != null) return _client!;

    final ioClient = HttpClient();
    ioClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    _client = IOClient(ioClient);
    return _client!;
  }

  // Check if cache is still valid
  static bool _isCacheValid(DateTime? cacheTime) {
    if (cacheTime == null) return false;
    return DateTime.now().difference(cacheTime) < _cacheExpiry;
  }

  // Token management
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> logout() async {
    await clearToken();
  }

  // Get headers with authentication
  Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Helper method to handle HTTP requests with timeout and error handling
  Future<http.Response> _makeRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(_timeout);
    } on TimeoutException {
      throw Exception('Failed to fetch data. Please try again.');
    } on SocketException {
      throw Exception('Failed to fetch data. Please check your connection.');
    } on HandshakeException {
      throw Exception('Failed to fetch data. Please try again.');
    } catch (e) {
      throw Exception('Failed to fetch data. Please try again.');
    }
  }

  // ============================================
  // AUTHENTICATION
  // ============================================

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final client = _getClient();
      final response = await _makeRequest(() async => await client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Save token if provided
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return {'success': true, 'data': data};
      } else {
        // Handle HTTP error with proper message
        final errorMessage = ErrorHandler.handleHttpError(
          response.statusCode, 
          response.body
        );
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      ErrorHandler.logError('login', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      return {'success': false, 'error': errorMessage};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: await _getHeaders(),
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['error'] ?? 'Failed to send reset code'};
      }
    } catch (e) {
      ErrorHandler.logError('forgotPassword', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      return {'success': false, 'error': errorMessage};
    }
  }

  Future<Map<String, dynamic>> verifyResetOTP(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-reset-otp'),
        headers: await _getHeaders(),
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['error'] ?? 'Invalid OTP'};
      }
    } catch (e) {
      ErrorHandler.logError('verifyResetOTP', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      return {'success': false, 'error': errorMessage};
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email, String otp, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['error'] ?? 'Failed to reset password'};
      }
    } catch (e) {
      ErrorHandler.logError('resetPassword', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      return {'success': false, 'error': errorMessage};
    }
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['error'] ?? 'Failed to change password'};
      }
    } catch (e) {
      ErrorHandler.logError('changePassword', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      return {'success': false, 'error': errorMessage};
    }
  }

  Future<Map<String, dynamic>> updateEmail(String newEmail, String currentPassword) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/update-email'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({
          'new_email': newEmail,
          'current_password': currentPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['error'] ?? 'Failed to update email'};
      }
    } catch (e) {
      ErrorHandler.logError('updateEmail', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      return {'success': false, 'error': errorMessage};
    }
  }

  // ============================================
  // ROSTER MANAGEMENT
  // ============================================

  Future<Map<String, dynamic>> createRoster({
    required String weekStartDate,
    required String weekEndDate,
    required List<Map<String, dynamic>> assignments,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/roster'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({
          'week_start_date': weekStartDate,
          'week_end_date': weekEndDate,
          'assignments': assignments,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['error'] ?? 'Failed to create roster'};
      }
    } catch (e) {
      ErrorHandler.logError('createRoster', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      return {'success': false, 'error': errorMessage};
    }
  }

  Future<Map<String, dynamic>> getRosterForWeek(String weekStartDate) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/roster/week?start_date=$weekStartDate'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 404) {
        return {'success': true, 'data': null};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['error'] ?? 'Failed to fetch roster'};
      }
    } catch (e) {
      ErrorHandler.logError('getRosterForWeek', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      return {'success': false, 'error': errorMessage};
    }
  }

  Future<Map<String, dynamic>> getRostersByBranchDepartment({
    required String branchId,
    required String departmentId,
    String? weekStartDate,
    bool history = false,
  }) async {
    try {
      String url = '$baseUrl/roster/by-branch-department?branch_id=$branchId&department_id=$departmentId';
      if (history) {
        url += '&history=true';
      } else if (weekStartDate != null) {
        url += '&start_date=$weekStartDate';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['error'] ?? 'Failed to fetch roster'};
      }
    } catch (e) {
      ErrorHandler.logError('getRostersByBranchDepartment', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      return {'success': false, 'error': errorMessage};
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final client = _getClient();
      final response = await client.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: await _getHeaders(includeAuth: true),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['user'];
      } else {
        throw Exception('Failed to get current user');
      }
    } catch (e) {
      ErrorHandler.logError('getCurrentUser', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  // ==================== NOTIFICATIONS API ====================
  
  Future<List<Map<String, dynamic>>> getUserNotifications({int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications?limit=$limit'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      ErrorHandler.logError('getUserNotifications', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      ErrorHandler.logError('markNotificationAsRead', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/mark-all-read'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read');
      }
    } catch (e) {
      ErrorHandler.logError('markAllNotificationsAsRead', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/$notificationId'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      ErrorHandler.logError('deleteNotification', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<int> getUnreadNotificationCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread-count'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['unread_count'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      ErrorHandler.logError('getUnreadNotificationCount', e);
      return 0;
    }
  }

  // ==================== REVIEWS API ====================
  
  Future<List<Map<String, dynamic>>> getMyReviews() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/my-reviews'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      ErrorHandler.logError('getMyReviews', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }
  
  Future<List<Map<String, dynamic>>> getAllStaffReviews() async {
    try {
      
      final response = await http.get(
        Uri.parse('$baseUrl/hr/reviews'),
        headers: await _getHeaders(includeAuth: true),
      );
      

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      ErrorHandler.logError('getAllStaffReviews', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getStaffReviews(String staffId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/staff/$staffId'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reviews = data['reviews'] as List;
        return reviews.map((r) => r as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load staff reviews');
      }
    } catch (e) {
      ErrorHandler.logError('getStaffReviews', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<void> createReview({
    required String staffId,
    required double attendanceScore,
    required double punctualityScore,
    required double performanceScore,
    required String remarks,
    int? rosterId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({
          'staff_id': staffId,
          'attendance_score': attendanceScore,
          'punctuality_score': punctualityScore,
          'performance_score': performanceScore,
          'remarks': remarks,
          if (rosterId != null) 'roster_id': rosterId,
        }),
      );

      if (response.statusCode != 201) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create review');
      }
    } catch (e) {
      ErrorHandler.logError('createReview', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> getRatingsByDepartment({
    required String branchId,
    required String departmentId,
    String period = 'month', // week, month, year
  }) async {
    try {
      
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/by-department?branch_id=$branchId&department_id=$departmentId&period=$period'),
        headers: await _getHeaders(includeAuth: true),
      );
      

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to load ratings');
      }
    } catch (e) {
      ErrorHandler.logError('getRatingsByDepartment', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  // ==================== SCHEDULE API ====================
  
  Future<List<Map<String, dynamic>>> getMyAssignments(String weekStart) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/roster/my-assignments?week_start=$weekStart'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load schedule');
      }
    } catch (e) {
      ErrorHandler.logError('getMyAssignments', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getUpcomingShifts({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schedule/upcoming?limit=$limit'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load upcoming shifts');
      }
    } catch (e) {
      ErrorHandler.logError('getUpcomingShifts', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  // ==================== SHIFT TEMPLATES API ====================
  
  Future<List<Map<String, dynamic>>> getShiftTemplates() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shifts/templates'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load shift templates');
      }
    } catch (e) {
      ErrorHandler.logError('getShiftTemplates', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<void> updateShiftTemplate({
    required int templateId,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/shifts/templates/$templateId'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({
          'start_time': startTime,
          'end_time': endTime,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update shift template');
      }
    } catch (e) {
      ErrorHandler.logError('updateShiftTemplate', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableShifts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shifts/available'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load available shifts');
      }
    } catch (e) {
      ErrorHandler.logError('getAvailableShifts', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  // ==================== DASHBOARD API ====================
  
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/stats'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load dashboard stats');
      }
    } catch (e) {
      ErrorHandler.logError('getDashboardStats', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  // ============================================
  // DATA ENDPOINTS
  // ============================================

  Future<List<Branch>> getBranches() async {
    // Return cached data if available and valid
    if (_isCacheValid(_branchCacheTime) && _cachedBranches != null) {
      print('[API] Returning ${_cachedBranches!.length} cached branches');
      return _cachedBranches!;
    }

    try {
      final client = _getClient();
      final response = await _makeRequest(() async => await client.get(
        Uri.parse('$baseUrl/data/branches'),
        headers: await _getHeaders(),
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final branchesJson = data['branches'] as List;
        final branches = branchesJson.map((json) => Branch.fromJson(json)).toList();
        
        print('[API] Fetched ${branches.length} branches from backend');
        
        // Cache the result
        _cachedBranches = branches;
        _branchCacheTime = DateTime.now();
        
        return branches;
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      ErrorHandler.logError('getBranches', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<List<Department>> getDepartments() async {
    // Return cached data if available and valid
    if (_isCacheValid(_departmentCacheTime) && _cachedDepartments != null) {
      return _cachedDepartments!;
    }

    try {
      final client = _getClient();
      final response = await _makeRequest(() async => await client.get(
        Uri.parse('$baseUrl/data/departments'),
        headers: await _getHeaders(),
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final departmentsJson = data['departments'] as List;
        final departments = departmentsJson.map((json) => Department.fromJson(json)).toList();
        
        // Cache the result
        _cachedDepartments = departments;
        _departmentCacheTime = DateTime.now();
        
        return departments;
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      ErrorHandler.logError('getDepartments', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<List<SubDepartment>> getSubDepartments(String departmentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/data/departments/$departmentId/sub-departments'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final subDepartmentsJson = data['sub_departments'] as List;
        return subDepartmentsJson.map((json) => SubDepartment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sub-departments');
      }
    } catch (e) {
      ErrorHandler.logError('getSubDepartments', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<List<Role>> getRoles({String? category, String? departmentId}) async {
    try {
      var url = '$baseUrl/data/roles';
      final queryParams = <String>[];
      
      if (category != null) {
        queryParams.add('category=$category');
      }
      if (departmentId != null) {
        queryParams.add('department_id=$departmentId');
      }
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final client = _getClient();
      final response = await client.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rolesJson = data['roles'] as List;
        return rolesJson.map((json) => Role.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load roles');
      }
    } catch (e) {
      ErrorHandler.logError('getRoles', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<List<Role>> getRolesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/data/roles/category/$category'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rolesJson = data['roles'] as List;
        return rolesJson.map((json) => Role.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load roles');
      }
    } catch (e) {
      ErrorHandler.logError('getRolesByCategory', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  // ============================================
  // HR ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> getStaffStats() async {
    try {
      final token = await getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/hr/stats'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load staff stats: ${response.statusCode}');
      }
    } catch (e) {
      ErrorHandler.logError('getStaffStats', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> getBranchStats() async {
    try {
      final token = await getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/branch/stats'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load branch stats: ${response.statusCode}');
      }
    } catch (e) {
      ErrorHandler.logError('getBranchStats', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<List<dynamic>> getAllStaff({
    String? branchId,
    String? departmentId,
    String? roleCategory,
    String? search,
    bool useBranchEndpoint = false,
  }) async {
    try {
      var endpoint = useBranchEndpoint ? '$baseUrl/branch/staff' : '$baseUrl/hr/staff';
      var url = '$endpoint?';
      if (branchId != null) url += 'branch_id=$branchId&';
      if (departmentId != null) url += 'department_id=$departmentId&';
      if (roleCategory != null) url += 'role_category=$roleCategory&';
      if (search != null) url += 'search=$search&';

      final token = await getToken();

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['staff'] as List;
      } else {
        throw Exception('Failed to load staff: ${response.statusCode}');
      }
    } catch (e) {
      ErrorHandler.logError('getAllStaff', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  // Create staff by Floor Manager (limited to their department)
  Future<Map<String, dynamic>> createStaffByFloorManager({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String roleId,
    required String departmentId,
    required String branchId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/floor-manager/create-staff'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'password': password,
          'role_id': roleId,
          'department_id': departmentId,
          'branch_id': branchId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['error'] ?? 'Failed to create staff'};
      }
    } catch (e) {
      ErrorHandler.logError('createStaffByFloorManager', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      return {'success': false, 'error': errorMessage};
    }
  }

  // Create staff by HR (can create ANY type of staff including senior_admin)
  Future<Map<String, dynamic>> createStaffByHR({
    required String fullName,
    required String email,
    required String phone,
    String? employeeId,
    required String roleId,
    String? departmentId,
    String? branchId,
    String? gender,
    String? maritalStatus,
    String? stateOfOrigin,
    String? dateOfBirth,
    String? homeAddress,
    String? courseOfStudy,
    String? grade,
    String? institution,
    double? salary,
    Map<String, dynamic>? nextOfKin,
    Map<String, dynamic>? guarantor1,
    Map<String, dynamic>? guarantor2,
    String? passportUrl,
    String? nationalIdUrl,
    String? birthCertificateUrl,
    String? waecCertificateUrl,
    String? nyscCertificateUrl,
    String? degreeCertificateUrl,
    String? stateOfOriginCertUrl,
    String? profileImageUrl,
    String? g1PassportUrl,
    String? g1NationalIdUrl,
    String? g1WorkIdUrl,
    String? g2PassportUrl,
    String? g2NationalIdUrl,
    String? g2WorkIdUrl,
    List<Map<String, dynamic>>? workExperience,
  }) async {
    try {
      
      final body = {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'employee_id': employeeId,
        'role_id': roleId,
        'department_id': departmentId,
        'branch_id': branchId,
        'gender': gender,
        'marital_status': maritalStatus,
        'state_of_origin': stateOfOrigin,
        'date_of_birth': dateOfBirth,
        'home_address': homeAddress,
        'course_of_study': courseOfStudy,
        'grade': grade,
        'institution': institution,
        'salary': salary,
      };
      
      // Add optional nested data
      if (nextOfKin != null) body['next_of_kin'] = nextOfKin;
      if (guarantor1 != null) body['guarantor_1'] = guarantor1;
      if (guarantor2 != null) body['guarantor_2'] = guarantor2;
      
      // Add document URLs
      if (passportUrl != null) body['passport_url'] = passportUrl;
      if (nationalIdUrl != null) body['national_id_url'] = nationalIdUrl;
      if (birthCertificateUrl != null) body['birth_certificate_url'] = birthCertificateUrl;
      if (waecCertificateUrl != null) body['waec_certificate_url'] = waecCertificateUrl;
      if (nyscCertificateUrl != null) body['nysc_certificate_url'] = nyscCertificateUrl;
      if (degreeCertificateUrl != null) body['degree_certificate_url'] = degreeCertificateUrl;
      if (stateOfOriginCertUrl != null) body['state_of_origin_cert_url'] = stateOfOriginCertUrl;
      if (profileImageUrl != null) body['profile_image_url'] = profileImageUrl;
      
      // Guarantor 1 documents
      if (g1PassportUrl != null) body['g1_passport_url'] = g1PassportUrl;
      if (g1NationalIdUrl != null) body['g1_national_id_url'] = g1NationalIdUrl;
      if (g1WorkIdUrl != null) body['g1_work_id_url'] = g1WorkIdUrl;
      
      // Guarantor 2 documents
      if (g2PassportUrl != null) body['g2_passport_url'] = g2PassportUrl;
      if (g2NationalIdUrl != null) body['g2_national_id_url'] = g2NationalIdUrl;
      if (g2WorkIdUrl != null) body['g2_work_id_url'] = g2WorkIdUrl;
      
      // Work experience
      if (workExperience != null) body['work_experience'] = workExperience;
      
      
      final response = await http.post(
        Uri.parse('$baseUrl/hr/staff'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode(body),
      );


      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['error'] ?? 'Failed to create staff'};
      }
    } catch (e) {
      ErrorHandler.logError('createStaffByHR', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      return {'success': false, 'error': errorMessage};
    }
  }
  
  // Upload document to Cloudinary using existing credentials
  Future<Map<String, dynamic>> uploadDocumentToCloudinary(String filePath, String documentType) async {
    try {
      
      // Use existing Cloudinary credentials
      const cloudName = 'desk7uuna';
      const uploadPreset = 'flutter_uploads';
      
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload');
      
      var request = http.MultipartRequest('POST', uri);
      
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'ace_mall_staff/$documentType';
      
      final file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'url': data['secure_url'],
          'public_id': data['public_id'],
          'file_name': data['original_filename'] ?? documentType,
          'file_size': data['bytes'] ?? 0,
        };
      } else {
        return {'success': false, 'error': 'Upload failed: ${response.body}'};
      }
    } catch (e) {
      ErrorHandler.logError('uploadDocumentToCloudinary', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      return {'success': false, 'error': errorMessage};
    }
  }

  // ============================================
  // WORK EXPERIENCE
  // ============================================
  
  Future<void> updateWorkExperience(String userId, List<Map<String, dynamic>> workExperiences) async {
    print('🔵 API updateWorkExperience called');
    print('🔵 User ID: $userId');
    print('🔵 Base URL: $baseUrl');
    print('🔵 Work experiences count: ${workExperiences.length}');
    print('🔵 Work experiences data: $workExperiences');
    
    final url = '$baseUrl/staff/$userId/work-experience';
    print('🔵 Full URL: $url');
    
    final headers = await _getHeaders(includeAuth: true);
    print('🔵 Headers: $headers');
    
    final body = jsonEncode({'work_experience': workExperiences});
    print('🔵 Request body: $body');
    
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    
    print('🔵 Response status: ${response.statusCode}');
    print('🔵 Response body: ${response.body}');
    
    if (response.statusCode != 200) {
      print('❌ API call failed with status ${response.statusCode}');
      throw Exception('Failed to update work experience: ${response.body}');
    }
    
    print('✅ API updateWorkExperience completed successfully');
  }

  Future<void> uploadGuarantorDocument(String userId, int guarantorNumber, String documentType, String documentUrl) async {
    final response = await http.post(
      Uri.parse('$baseUrl/staff/$userId/guarantor-document'),
      headers: await _getHeaders(includeAuth: true),
      body: jsonEncode({
        'guarantor_number': guarantorNumber,
        'document_type': documentType,
        'document_url': documentUrl,
      }),
    );
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to upload guarantor document: ${response.body}');
    }
  }

  // ============================================
  // STAFF TERMINATION (see methods at end of class)
  // ============================================

  Future<List<Map<String, dynamic>>> getTerminatedStaff({
    String? type,
    String? department,
    String? branch,
    String? search,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: true);
      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;
      if (department != null) queryParams['department'] = department;
      if (branch != null) queryParams['branch'] = branch;
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse('$baseUrl/staff/departed').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['terminated_staff'] ?? []);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to fetch terminated staff');
      }
    } catch (e) {
      ErrorHandler.logError('getTerminatedStaff', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> updateClearanceStatus({
    required String terminationId,
    required String clearanceStatus,
    String? clearanceNotes,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: true);
      final response = await http.put(
        Uri.parse('$baseUrl/staff/terminated/$terminationId/clearance'),
        headers: headers,
        body: jsonEncode({
          'clearance_status': clearanceStatus,
          if (clearanceNotes != null) 'clearance_notes': clearanceNotes,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['error'] ?? 'Failed to update clearance status'};
      }
    } catch (e) {
      ErrorHandler.logError('updateClearanceStatus', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      return {'success': false, 'error': errorMessage};
    }
  }

  // ============================================
  // PROMOTION
  // ============================================

  Future<Map<String, dynamic>> promoteStaff({
    required String staffId,
    String? newRoleId,
    required double newSalary,
    String? reason,
    String? branchId,
    String? departmentId,
  }) async {
    try {
      final requestBody = {
        'staff_id': staffId,
        if (newRoleId != null) 'new_role_id': newRoleId,
        'new_salary': newSalary,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
        if (branchId != null) 'branch_id': branchId,
        if (departmentId != null) 'department_id': departmentId,
      };
      
      print('📤 Promotion Request: $requestBody');
      
      final response = await http.post(
        Uri.parse('$baseUrl/promotions'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode(requestBody),
      );

      print('📥 Promotion Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to promote staff');
      }
    } catch (e) {
      ErrorHandler.logError('promoteStaff', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getPromotionHistory(String staffId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/promotions/history/$staffId'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Backend returns array directly, not wrapped in data key
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        } else if (decoded is Map && decoded['data'] != null) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
        return [];
      } else {
        throw Exception('Failed to fetch promotion history');
      }
    } catch (e) {
      ErrorHandler.logError('getPromotionHistory', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  // ============================================
  // HEALTH CHECK
  // ============================================

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl.replaceAll('/api/v1', '')}/health'),
      );
      return response.statusCode == 200;
    } catch (e) {
      ErrorHandler.logError('checkHealth', e);
      return false;
    }
  }

  // ============================================
  // PROFILE MANAGEMENT
  // ============================================

  Future<Map<String, dynamic>> getStaffById(String userId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/staff/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Return full response including permission_level
        return data;
      } else {
        throw Exception('Failed to load staff profile: ${response.body}');
      }
    } catch (e) {
      ErrorHandler.logError('getStaffById', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<void> updateStaffProfile(String userId, Map<String, dynamic> updates) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/staff/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      ErrorHandler.logError('updateStaffProfile', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  // ==================== MESSAGING API ====================
  
  Future<void> sendMessage({
    required String title,
    required String content,
    required String targetType,
    int? targetBranchId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages/send'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({
          'title': title,
          'content': content,
          'target_type': targetType,
          'target_branch_id': targetBranchId,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to send message');
      }
    } catch (e) {
      ErrorHandler.logError('sendMessage', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getSentMessages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/sent'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load sent messages');
      }
    } catch (e) {
      ErrorHandler.logError('getSentMessages', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getMyNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/my'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ==================== STAFF TERMINATION API ====================

  Future<void> terminateStaff({
    required String userId,
    required String terminationType,
    required String terminationReason,
    String? lastWorkingDay,
    String? clearanceNotes,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/staff/$userId/terminate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'termination_type': terminationType,
          'reason': terminationReason,
          if (lastWorkingDay != null) 'last_working_day': lastWorkingDay,
          if (clearanceNotes != null) 'clearance_notes': clearanceNotes,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to terminate staff');
      }
    } catch (e) {
      ErrorHandler.logError('terminateStaff', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<void> restoreStaff(String userId) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/staff/$userId/restore'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to restore staff');
      }
    } catch (e) {
      ErrorHandler.logError('restoreStaff', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  Future<List<Map<String, dynamic>>> getDepartedStaff({
    String? terminationType,
    String? branch,
    String? department,
  }) async {
    try {
      final token = await getToken();
      final queryParams = <String, String>{};
      if (terminationType != null) queryParams['type'] = terminationType;
      if (branch != null) queryParams['branch'] = branch;
      if (department != null) queryParams['department'] = department;

      final uri = Uri.parse('$baseUrl/staff/departed').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['departed_staff'] ?? []);
      } else {
        throw Exception('Failed to load departed staff');
      }
    } catch (e) {
      ErrorHandler.logError('getDepartedStaff', e);
      final errorMessage = await ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }
}
