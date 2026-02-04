'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { useAuth } from '@/contexts/AuthContext';
import { getInitials } from '@/lib/utils';
import api from '@/lib/api';
import {
  Bell,
  ChevronDown,
  User,
  Settings,
  LogOut,
  Menu,
} from 'lucide-react';
import { Button } from '@/components/ui/button';

interface HeaderProps {
  onMenuClick?: () => void;
}

export function Header({ onMenuClick }: HeaderProps) {
  const { user, logout } = useAuth();
  const [showDropdown, setShowDropdown] = useState(false);
  const [unreadCount, setUnreadCount] = useState(0);

  useEffect(() => {
    const fetchUnreadCount = async () => {
      try {
        const data = await api.getUnreadNotificationCount();
        setUnreadCount(data.unread_count);
      } catch (error) {
        console.error('Failed to fetch notification count');
      }
    };

    if (user) {
      fetchUnreadCount();
      const interval = setInterval(fetchUnreadCount, 60000); // Refresh every minute
      return () => clearInterval(interval);
    }
  }, [user]);

  const handleLogout = () => {
    logout();
  };

  return (
    <header className="fixed top-0 right-0 lg:left-64 left-0 h-16 bg-white border-b border-gray-200 z-50 px-4 lg:px-6 flex items-center justify-between">
      {/* Left side - Mobile menu button */}
      <div className="flex items-center gap-3">
        <button
          onClick={onMenuClick}
          className="lg:hidden p-2 hover:bg-gray-100 rounded-lg transition-colors"
          aria-label="Open menu"
        >
          <Menu className="w-6 h-6 text-gray-700" />
        </button>
        <div className="hidden sm:block">
          <h1 className="text-base lg:text-lg font-semibold text-gray-900">
            Welcome, {user?.full_name?.split(' ')[0] || 'User'}
          </h1>
          <p className="text-xs lg:text-sm text-gray-500">{user?.role_name || 'Staff'}</p>
        </div>
      </div>

      {/* Right side - Notifications and Profile */}
      <div className="flex items-center gap-4">
        {/* Notifications */}
        <Link
          href="/dashboard/notifications"
          className="relative p-2 hover:bg-gray-100 rounded-lg"
        >
          <Bell className="w-5 h-5 text-gray-600" />
          {unreadCount > 0 && (
            <span className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 text-white text-xs font-bold rounded-full flex items-center justify-center">
              {unreadCount > 99 ? '99+' : unreadCount}
            </span>
          )}
        </Link>

        {/* Profile Dropdown */}
        <div className="relative">
          <button
            onClick={() => setShowDropdown(!showDropdown)}
            className="flex items-center gap-2 p-1.5 hover:bg-gray-100 rounded-lg"
          >
            {user?.profile_image_url ? (
              <img
                src={user.profile_image_url}
                alt={user.full_name}
                className="w-9 h-9 rounded-full object-cover"
              />
            ) : (
              <div className="w-9 h-9 rounded-full bg-primary flex items-center justify-center text-white text-sm font-semibold">
                {getInitials(user?.full_name || 'U')}
              </div>
            )}
            <ChevronDown className="w-4 h-4 text-gray-500" />
          </button>

          {showDropdown && (
            <>
              <div
                className="fixed inset-0 z-40"
                onClick={() => setShowDropdown(false)}
              />
              <div className="absolute right-0 top-full mt-2 w-56 bg-white rounded-xl shadow-lg border border-gray-200 py-2 z-50">
                <div className="px-4 py-2 border-b border-gray-100">
                  <p className="font-medium text-gray-900 truncate">
                    {user?.full_name}
                  </p>
                  <p className="text-sm text-gray-500 truncate">{user?.email}</p>
                </div>
                <Link
                  href="/dashboard/profile"
                  onClick={() => setShowDropdown(false)}
                  className="flex items-center gap-3 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50"
                >
                  <User className="w-4 h-4" />
                  My Profile
                </Link>
                <Link
                  href="/dashboard/settings"
                  onClick={() => setShowDropdown(false)}
                  className="flex items-center gap-3 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50"
                >
                  <Settings className="w-4 h-4" />
                  Settings
                </Link>
                <div className="border-t border-gray-100 mt-1 pt-1">
                  <button
                    onClick={handleLogout}
                    className="flex items-center gap-3 px-4 py-2.5 text-sm text-red-600 hover:bg-red-50 w-full"
                  >
                    <LogOut className="w-4 h-4" />
                    Logout
                  </button>
                </div>
              </div>
            </>
          )}
        </div>
      </div>
    </header>
  );
}
