'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useAuth } from '@/contexts/AuthContext';
import { getRoleCategory, formatDate } from '@/lib/utils';
import api from '@/lib/api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import {
  Users,
  Building2,
  Layers,
  Calendar,
  Star,
  TrendingUp,
  UserMinus,
  BarChart3,
  MessageSquare,
  UserPlus,
  Clock,
  ClipboardList,
  ChevronRight,
} from 'lucide-react';

interface StatsData {
  total_staff?: number;
  active_staff?: number;
  total_branches?: number;
  total_departments?: number;
}

interface RosterSummary {
  id: string;
  week_start_date: string;
  week_end_date: string;
  floor_manager?: string;
  floor_manager_name?: string;
  department_name?: string;
  branch_name?: string;
  staff_count?: number;
  assignment_count?: number;
}

interface ReviewSummary {
  id: string;
  staff_name?: string;
  staff_id?: string;
  role_name?: string;
  branch_name?: string;
  department_name?: string;
  overall_rating?: number;
  rating?: number;
  week_start_date?: string;
  reviewer_name?: string;
}

interface ActionCard {
  title: string;
  description: string;
  href: string;
  icon: React.ReactNode;
  color: string;
}

export default function DashboardPage() {
  const { user } = useAuth();
  const [stats, setStats] = useState<StatsData>({});
  const [recentRosters, setRecentRosters] = useState<RosterSummary[]>([]);
  const [recentReviews, setRecentReviews] = useState<ReviewSummary[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const roleCategory = user?.role_name ? getRoleCategory(user.role_name) : 'general';

  useEffect(() => {
    const fetchStats = async () => {
      try {
        if (roleCategory === 'senior_admin') {
          const [staffStats, branches, departments, rostersData, reviewsData] = await Promise.all([
            api.getStaffStats().catch(() => ({ total_staff: 0, active_staff: 0 })),
            api.getBranches().catch(() => []),
            api.getDepartments().catch(() => []),
            api.getAllRosters().catch(() => ({ rosters: [] })),
            api.getAllStaffReviews().catch(() => []),
          ]);
          setStats({
            total_staff: staffStats?.total_staff || 0,
            active_staff: staffStats?.active_staff || 0,
            total_branches: Array.isArray(branches) ? branches.length : 0,
            total_departments: Array.isArray(departments) ? departments.length : 0,
          });
          // Get latest 5 rosters
          const rosters = rostersData?.rosters || [];
          setRecentRosters(rosters.slice(0, 5) as RosterSummary[]);
          // Get latest 5 reviews
          const reviews = Array.isArray(reviewsData) ? reviewsData : [];
          setRecentReviews(reviews.slice(0, 5) as ReviewSummary[]);
        }
      } catch (error) {
        console.error('Failed to fetch stats:', error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchStats();
  }, [roleCategory]);

  const seniorAdminCards: ActionCard[] = [
    {
      title: 'Staff Oversight',
      description: 'View and manage all staff',
      href: '/dashboard/staff',
      icon: <Users className="w-6 h-6" />,
      color: 'bg-blue-500',
    },
    {
      title: 'Branch Reports',
      description: 'View branch analytics',
      href: '/dashboard/branch-reports',
      icon: <Building2 className="w-6 h-6" />,
      color: 'bg-indigo-500',
    },
    {
      title: 'View Rosters',
      description: 'Check department schedules',
      href: '/dashboard/rosters',
      icon: <Calendar className="w-6 h-6" />,
      color: 'bg-green-500',
    },
    {
      title: 'Reports & Analytics',
      description: 'View performance reports',
      href: '/dashboard/reports',
      icon: <BarChart3 className="w-6 h-6" />,
      color: 'bg-purple-500',
    },
    {
      title: 'Admin Messaging',
      description: 'Send announcements',
      href: '/dashboard/messaging',
      icon: <MessageSquare className="w-6 h-6" />,
      color: 'bg-orange-500',
    },
    {
      title: 'Promotions',
      description: 'Promote & transfer staff',
      href: '/dashboard/promotions',
      icon: <TrendingUp className="w-6 h-6" />,
      color: 'bg-teal-500',
    },
  ];

  const hrCards: ActionCard[] = [
    {
      title: 'Add New Staff',
      description: 'Create staff accounts',
      href: '/dashboard/staff/add',
      icon: <UserPlus className="w-6 h-6" />,
      color: 'bg-green-500',
    },
    {
      title: 'All Staff',
      description: 'View staff directory',
      href: '/dashboard/staff',
      icon: <Users className="w-6 h-6" />,
      color: 'bg-blue-500',
    },
    {
      title: 'Promotions',
      description: 'Promote staff members',
      href: '/dashboard/promotions',
      icon: <TrendingUp className="w-6 h-6" />,
      color: 'bg-purple-500',
    },
    {
      title: 'Terminated Staff',
      description: 'View departed employees',
      href: '/dashboard/terminated-staff',
      icon: <UserMinus className="w-6 h-6" />,
      color: 'bg-red-500',
    },
  ];

  const adminCards: ActionCard[] = [
    {
      title: 'Roster Management',
      description: 'Create and manage rosters',
      href: '/dashboard/rosters/manage',
      icon: <Calendar className="w-6 h-6" />,
      color: 'bg-green-500',
    },
    {
      title: 'My Team',
      description: 'View team members',
      href: '/dashboard/my-team',
      icon: <Users className="w-6 h-6" />,
      color: 'bg-blue-500',
    },
    {
      title: 'Team Reviews',
      description: 'Review staff performance',
      href: '/dashboard/reviews',
      icon: <Star className="w-6 h-6" />,
      color: 'bg-yellow-500',
    },
    {
      title: 'Shift Times',
      description: 'Configure shift schedules',
      href: '/dashboard/shifts',
      icon: <Clock className="w-6 h-6" />,
      color: 'bg-purple-500',
    },
  ];

  const generalStaffCards: ActionCard[] = [
    {
      title: 'My Schedule',
      description: 'View your work schedule',
      href: '/dashboard/schedule',
      icon: <Calendar className="w-6 h-6" />,
      color: 'bg-green-500',
    },
    {
      title: 'My Reviews',
      description: 'View performance feedback',
      href: '/dashboard/my-reviews',
      icon: <Star className="w-6 h-6" />,
      color: 'bg-yellow-500',
    },
    {
      title: 'My Profile',
      description: 'View your personal information',
      href: '/dashboard/my-profile',
      icon: <Users className="w-6 h-6" />,
      color: 'bg-blue-500',
    },
    {
      title: 'Notifications',
      description: 'View announcements',
      href: '/dashboard/notifications',
      icon: <ClipboardList className="w-6 h-6" />,
      color: 'bg-purple-500',
    },
  ];

  const getActionCards = () => {
    if (user?.role_name?.includes('HR') || user?.role_name?.includes('Human Resource')) {
      return hrCards;
    }
    switch (roleCategory) {
      case 'senior_admin':
        return seniorAdminCards;
      case 'admin':
        return adminCards;
      default:
        return generalStaffCards;
    }
  };

  const actionCards = getActionCards();

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Welcome Banner */}
      <div className="bg-gradient-to-r from-primary to-primary-dark rounded-2xl p-6 text-white">
        <h1 className="text-2xl font-bold mb-1">
          Welcome back, {user?.full_name || 'User'}!
        </h1>
        <p className="text-white/80">
          {user?.role_name} {user?.branch_name ? `• ${user.branch_name}` : ''}
        </p>
      </div>

      {/* Stats Cards - Only for Senior Admin */}
      {roleCategory === 'senior_admin' && (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center gap-4">
                <div className="p-3 bg-blue-100 rounded-xl">
                  <Users className="w-6 h-6 text-blue-600" />
                </div>
                <div>
                  <p className="text-sm text-gray-500">Total Staff</p>
                  <p className="text-2xl font-bold">{stats.total_staff || 0}</p>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center gap-4">
                <div className="p-3 bg-green-100 rounded-xl">
                  <Building2 className="w-6 h-6 text-green-600" />
                </div>
                <div>
                  <p className="text-sm text-gray-500">Branches</p>
                  <p className="text-2xl font-bold">{stats.total_branches || 14}</p>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center gap-4">
                <div className="p-3 bg-purple-100 rounded-xl">
                  <Layers className="w-6 h-6 text-purple-600" />
                </div>
                <div>
                  <p className="text-sm text-gray-500">Departments</p>
                  <p className="text-2xl font-bold">{stats.total_departments || 6}</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Action Cards */}
      <div>
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {actionCards.map((card) => (
            <Link key={card.href} href={card.href}>
              <Card className="hover:shadow-lg transition-shadow cursor-pointer h-full">
                <CardContent className="pt-6">
                  <div className={`inline-flex p-3 rounded-xl ${card.color} text-white mb-4`}>
                    {card.icon}
                  </div>
                  <h3 className="font-semibold text-gray-900 mb-1">{card.title}</h3>
                  <p className="text-sm text-gray-500">{card.description}</p>
                </CardContent>
              </Card>
            </Link>
          ))}
        </div>
      </div>

      {/* Recent Rosters Section - Only for Senior Admin */}
      {roleCategory === 'senior_admin' && recentRosters.length > 0 && (
        <div>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Recent Rosters</h2>
            <Link href="/dashboard/rosters">
              <Button variant="ghost" size="sm">
                View All <ChevronRight className="w-4 h-4 ml-1" />
              </Button>
            </Link>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {recentRosters.map((roster) => (
              <Card key={roster.id} className="hover:shadow-md transition-shadow">
                <CardContent className="pt-5">
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex items-center gap-2">
                      <div className="p-2 bg-green-100 rounded-lg">
                        <Calendar className="w-4 h-4 text-green-600" />
                      </div>
                      <div>
                        <p className="font-medium text-sm text-gray-900">
                          {formatDate(roster.week_start_date)}
                        </p>
                        <p className="text-xs text-gray-500">
                          to {formatDate(roster.week_end_date)}
                        </p>
                      </div>
                    </div>
                    <span className="text-xs bg-blue-100 text-blue-700 px-2 py-1 rounded-full">
                      {roster.staff_count || 0} staff
                    </span>
                  </div>
                  <div className="space-y-1 text-sm">
                    <p className="text-gray-600">
                      <span className="font-medium">Branch:</span> {roster.branch_name || 'N/A'}
                    </p>
                    <p className="text-gray-600">
                      <span className="font-medium">Dept:</span> {roster.department_name || 'N/A'}
                    </p>
                    <p className="text-gray-600">
                      <span className="font-medium">Manager:</span> {roster.floor_manager || roster.floor_manager_name || 'N/A'}
                    </p>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      )}

      {/* Recent Reviews Section - Only for Senior Admin */}
      {roleCategory === 'senior_admin' && recentReviews.length > 0 && (
        <div>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Recent Reviews</h2>
            <Link href="/dashboard/reviews">
              <Button variant="ghost" size="sm">
                View All <ChevronRight className="w-4 h-4 ml-1" />
              </Button>
            </Link>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {recentReviews.map((review) => (
              <Card key={review.id} className="hover:shadow-md transition-shadow">
                <CardContent className="pt-5">
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex items-center gap-2">
                      <div className="p-2 bg-yellow-100 rounded-lg">
                        <Star className="w-4 h-4 text-yellow-600" />
                      </div>
                      <div>
                        <p className="font-medium text-sm text-gray-900">
                          {review.staff_name || 'Unknown Staff'}
                        </p>
                        <p className="text-xs text-gray-500">
                          {review.role_name || 'N/A'}
                        </p>
                      </div>
                    </div>
                    <div className="flex items-center gap-1">
                      <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
                      <span className="text-sm font-medium">
                        {(review.overall_rating || review.rating || 0).toFixed(1)}
                      </span>
                    </div>
                  </div>
                  <div className="space-y-1 text-sm">
                    <p className="text-gray-600">
                      <span className="font-medium">Branch:</span> {review.branch_name || 'N/A'}
                    </p>
                    <p className="text-gray-600">
                      <span className="font-medium">Dept:</span> {review.department_name || 'N/A'}
                    </p>
                    <p className="text-gray-600">
                      <span className="font-medium">By:</span> {review.reviewer_name || 'N/A'}
                    </p>
                    {review.week_start_date && (
                      <p className="text-xs text-gray-400">
                        Week of {formatDate(review.week_start_date)}
                      </p>
                    )}
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      )}

      {/* User Info Card for General Staff */}
      {roleCategory === 'general' && (
        <Card>
          <CardHeader>
            <CardTitle>Your Information</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <p className="text-gray-500">Department</p>
                <p className="font-medium">{user?.department_name || 'N/A'}</p>
              </div>
              <div>
                <p className="text-gray-500">Branch</p>
                <p className="font-medium">{user?.branch_name || 'N/A'}</p>
              </div>
              <div>
                <p className="text-gray-500">Employee ID</p>
                <p className="font-medium">{user?.employee_id || 'N/A'}</p>
              </div>
              <div>
                <p className="text-gray-500">Email</p>
                <p className="font-medium">{user?.email || 'N/A'}</p>
              </div>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
