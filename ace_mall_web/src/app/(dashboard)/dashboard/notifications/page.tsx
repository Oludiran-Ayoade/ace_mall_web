'use client';

import { useEffect, useState } from 'react';
import api from '@/lib/api';
import { Notification } from '@/types';
import { timeAgo } from '@/lib/utils';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { toast } from '@/components/ui/toaster';
import {
  Bell,
  Calendar,
  Star,
  TrendingUp,
  MessageSquare,
  CheckCheck,
  Trash2,
  BellOff,
} from 'lucide-react';

const typeIcons = {
  roster_assignment: <Calendar className="w-5 h-5 text-blue-500" />,
  schedule_change: <Calendar className="w-5 h-5 text-orange-500" />,
  review: <Star className="w-5 h-5 text-yellow-500" />,
  promotion: <TrendingUp className="w-5 h-5 text-green-500" />,
  general: <MessageSquare className="w-5 h-5 text-gray-500" />,
};

const typeColors = {
  roster_assignment: 'bg-blue-50 border-blue-200',
  schedule_change: 'bg-orange-50 border-orange-200',
  review: 'bg-yellow-50 border-yellow-200',
  promotion: 'bg-green-50 border-green-200',
  general: 'bg-gray-50 border-gray-200',
};

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchNotifications();
  }, []);

  const fetchNotifications = async () => {
    try {
      const data = await api.getNotifications();
      setNotifications(Array.isArray(data) ? data : []);
    } catch (error) {
      console.error('Failed to fetch notifications:', error);
      setNotifications([]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleMarkAsRead = async (id: number) => {
    try {
      await api.markNotificationAsRead(id);
      setNotifications((prev) =>
        Array.isArray(prev) ? prev.map((n) => (n.id === id ? { ...n, is_read: true } : n)) : []
      );
    } catch (error) {
      console.error('Failed to mark as read:', error);
    }
  };

  const handleMarkAllAsRead = async () => {
    try {
      await api.markAllNotificationsAsRead();
      setNotifications((prev) => Array.isArray(prev) ? prev.map((n) => ({ ...n, is_read: true })) : []);
      toast({ title: 'All notifications marked as read', variant: 'success' });
    } catch (error) {
      toast({ title: 'Failed to mark all as read', variant: 'destructive' });
    }
  };

  const handleDelete = async (id: number) => {
    try {
      await api.deleteNotification(id);
      setNotifications((prev) => Array.isArray(prev) ? prev.filter((n) => n.id !== id) : []);
      toast({ title: 'Notification deleted', variant: 'success' });
    } catch (error) {
      toast({ title: 'Failed to delete', variant: 'destructive' });
    }
  };

  const unreadCount = Array.isArray(notifications) ? notifications.filter((n) => !n.is_read).length : 0;

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Notifications</h1>
          <p className="text-gray-500">
            {unreadCount > 0 ? `${unreadCount} unread` : 'All caught up!'}
          </p>
        </div>
        {unreadCount > 0 && (
          <Button variant="outline" onClick={handleMarkAllAsRead}>
            <CheckCheck className="w-4 h-4 mr-2" />
            Mark all as read
          </Button>
        )}
      </div>

      {/* Notifications List */}
      {notifications.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <BellOff className="w-12 h-12 text-gray-300 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-1">
              No notifications
            </h3>
            <p className="text-gray-500">
              You&apos;re all caught up! Check back later.
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-3">
          {notifications.map((notification) => (
            <Card
              key={notification.id}
              className={`transition-all cursor-pointer ${
                !notification.is_read ? 'ring-2 ring-primary/20' : ''
              } ${typeColors[notification.type] || 'bg-white'}`}
              onClick={() => !notification.is_read && handleMarkAsRead(notification.id)}
            >
              <CardContent className="py-4">
                <div className="flex items-start gap-4">
                  <div className="mt-1">
                    {typeIcons[notification.type] || <Bell className="w-5 h-5 text-gray-500" />}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-4">
                      <div>
                        <h4 className={`font-medium ${!notification.is_read ? 'text-gray-900' : 'text-gray-700'}`}>
                          {notification.title}
                        </h4>
                        <p className="text-sm text-gray-600 mt-1">
                          {notification.message}
                        </p>
                      </div>
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleDelete(notification.id);
                        }}
                        className="p-1 hover:bg-white/50 rounded"
                      >
                        <Trash2 className="w-4 h-4 text-gray-400 hover:text-red-500" />
                      </button>
                    </div>
                    <div className="flex items-center gap-4 mt-2">
                      <span className="text-xs text-gray-500">
                        {timeAgo(notification.created_at)}
                      </span>
                      {!notification.is_read && (
                        <span className="text-xs bg-primary text-white px-2 py-0.5 rounded-full">
                          New
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
