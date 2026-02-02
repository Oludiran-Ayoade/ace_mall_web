import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

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
      // Handle error silently
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _apiService.markAllNotificationsAsRead();
      setState(() {
        for (var notification in _notifications) {
          notification['is_read'] = true;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All notifications marked as read', style: GoogleFonts.inter()),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      // Handle error silently
    }
  }

  String _getTimeAgo(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'shift_reminder':
        return Icons.alarm;
      case 'roster_assignment':
        return Icons.calendar_today;
      case 'schedule_change':
        return Icons.update;
      case 'review':
        return Icons.star;
      case 'general':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'shift_reminder':
        return const Color(0xFFFFA726); // Orange
      case 'roster_assignment':
        return const Color(0xFF42A5F5); // Blue
      case 'schedule_change':
        return const Color(0xFF7E57C2); // Purple
      case 'review':
        return const Color(0xFFFFCA28); // Amber
      case 'general':
        return const Color(0xFF66BB6A); // Green
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n['is_read'] == false).length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount unread',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: BouncingDotsLoader(color: Color(0xFF4CAF50)))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading notifications',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.inter(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadNotifications,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You\'re all caught up!',
                            style: GoogleFonts.inter(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      color: const Color(0xFF4CAF50),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return _buildNotificationCard(notification);
                        },
                      ),
                    ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['is_read'] as bool;
    final type = notification['type'] as String;
    final color = _getNotificationColor(type);

    return Dismissible(
      key: Key(notification['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.remove(notification);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification deleted', style: GoogleFonts.inter()),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          if (!isRead) {
            _markAsRead(notification['id'].toString());
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead ? Colors.grey[200]! : color.withValues(alpha: 0.3),
              width: isRead ? 1 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getNotificationIcon(type),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification['message'],
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getTimeAgo(notification['created_at']),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
