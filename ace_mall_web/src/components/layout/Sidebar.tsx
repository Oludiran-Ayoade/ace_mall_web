'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import { useAuth } from '@/contexts/AuthContext';
import { getRoleCategory } from '@/lib/utils';
import {
  LayoutDashboard,
  Users,
  Building2,
  Layers,
  Calendar,
  Star,
  TrendingUp,
  UserMinus,
  BarChart3,
  MessageSquare,
  Settings,
  ChevronDown,
  ChevronRight,
  UserPlus,
  Upload,
  History,
  Clock,
  User,
  Bell,
  ShoppingCart,
} from 'lucide-react';

interface NavItem {
  label: string;
  href?: string;
  icon: React.ReactNode;
  children?: { label: string; href: string }[];
  roles?: ('senior_admin' | 'admin' | 'general')[];
}

const navItems: NavItem[] = [
  {
    label: 'Dashboard',
    href: '/dashboard',
    icon: <LayoutDashboard className="w-5 h-5" />,
  },
  {
    label: 'Staff Management',
    icon: <Users className="w-5 h-5" />,
    roles: ['senior_admin'],
    children: [
      { label: 'All Staff', href: '/dashboard/staff' },
      { label: 'Add Staff', href: '/dashboard/staff/add' },
    ],
  },
  {
    label: 'My Team',
    href: '/dashboard/my-team',
    icon: <Users className="w-5 h-5" />,
    roles: ['admin'],
  },
  {
    label: 'Branches',
    href: '/dashboard/branches',
    icon: <Building2 className="w-5 h-5" />,
    roles: ['senior_admin'],
  },
  {
    label: 'Departments',
    href: '/dashboard/departments',
    icon: <Layers className="w-5 h-5" />,
    roles: ['senior_admin'],
  },
  {
    label: 'Rosters',
    icon: <Calendar className="w-5 h-5" />,
    roles: ['senior_admin', 'admin'],
    children: [
      { label: 'View Rosters', href: '/dashboard/rosters' },
      { label: 'Roster History', href: '/dashboard/rosters/history' },
    ],
  },
  {
    label: 'Roster Management',
    href: '/dashboard/rosters/manage',
    icon: <Calendar className="w-5 h-5" />,
    roles: ['admin'],
  },
  {
    label: 'Shift Times',
    href: '/dashboard/shifts',
    icon: <Clock className="w-5 h-5" />,
    roles: ['admin'],
  },
  {
    label: 'My Schedule',
    href: '/dashboard/schedule',
    icon: <Calendar className="w-5 h-5" />,
    roles: ['general'],
  },
  {
    label: 'Reviews & Ratings',
    href: '/dashboard/reviews',
    icon: <Star className="w-5 h-5" />,
    roles: ['senior_admin', 'admin'],
  },
  {
    label: 'My Reviews',
    href: '/dashboard/my-reviews',
    icon: <Star className="w-5 h-5" />,
    roles: ['general', 'admin'],
  },
  {
    label: 'Promotions',
    href: '/dashboard/promotions',
    icon: <TrendingUp className="w-5 h-5" />,
    roles: ['senior_admin'],
  },
  {
    label: 'Terminated Staff',
    href: '/dashboard/terminated-staff',
    icon: <UserMinus className="w-5 h-5" />,
    roles: ['senior_admin'],
  },
  {
    label: 'Reports',
    href: '/dashboard/reports',
    icon: <BarChart3 className="w-5 h-5" />,
    roles: ['senior_admin', 'admin'],
  },
  {
    label: 'Messaging',
    href: '/dashboard/messaging',
    icon: <MessageSquare className="w-5 h-5" />,
    roles: ['senior_admin'],
  },
  {
    label: 'Notifications',
    href: '/dashboard/notifications',
    icon: <Bell className="w-5 h-5" />,
  },
  {
    label: 'My Profile',
    href: '/dashboard/profile',
    icon: <User className="w-5 h-5" />,
  },
  {
    label: 'Settings',
    href: '/dashboard/settings',
    icon: <Settings className="w-5 h-5" />,
  },
];

export function Sidebar() {
  const pathname = usePathname();
  const { user } = useAuth();
  const [expandedItems, setExpandedItems] = useState<string[]>([]);

  const roleCategory = user?.role_name ? getRoleCategory(user.role_name) : 'general';

  const toggleExpand = (label: string) => {
    setExpandedItems((prev) =>
      prev.includes(label) ? prev.filter((l) => l !== label) : [...prev, label]
    );
  };

  const filteredNavItems = navItems.filter((item) => {
    if (!item.roles) return true;
    return item.roles.includes(roleCategory);
  });

  return (
    <aside className="fixed left-0 top-0 h-full w-64 bg-white border-r border-gray-200 z-40 overflow-y-auto">
      {/* Logo */}
      <div className="flex items-center gap-3 px-6 py-5 border-b border-gray-100">
        <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
          <ShoppingCart className="w-5 h-5 text-primary" />
        </div>
        <span className="text-xl font-bold text-primary">Ace Mall</span>
      </div>

      {/* Navigation */}
      <nav className="p-4 space-y-1">
        {filteredNavItems.map((item) => {
          const isActive = item.href === pathname;
          const isExpanded = expandedItems.includes(item.label);
          const hasChildren = item.children && item.children.length > 0;

          if (hasChildren) {
            return (
              <div key={item.label}>
                <button
                  onClick={() => toggleExpand(item.label)}
                  className={cn(
                    'w-full flex items-center justify-between px-3 py-2.5 rounded-lg text-sm font-medium transition-colors',
                    'hover:bg-gray-100 text-gray-700'
                  )}
                >
                  <div className="flex items-center gap-3">
                    {item.icon}
                    {item.label}
                  </div>
                  {isExpanded ? (
                    <ChevronDown className="w-4 h-4" />
                  ) : (
                    <ChevronRight className="w-4 h-4" />
                  )}
                </button>
                {isExpanded && (
                  <div className="ml-8 mt-1 space-y-1">
                    {item.children!.map((child) => (
                      <Link
                        key={child.href}
                        href={child.href}
                        className={cn(
                          'block px-3 py-2 rounded-lg text-sm transition-colors',
                          pathname === child.href
                            ? 'bg-primary/10 text-primary font-medium'
                            : 'text-gray-600 hover:bg-gray-100'
                        )}
                      >
                        {child.label}
                      </Link>
                    ))}
                  </div>
                )}
              </div>
            );
          }

          return (
            <Link
              key={item.label}
              href={item.href!}
              className={cn(
                'flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors',
                isActive
                  ? 'bg-primary text-white'
                  : 'text-gray-700 hover:bg-gray-100'
              )}
            >
              {item.icon}
              {item.label}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
