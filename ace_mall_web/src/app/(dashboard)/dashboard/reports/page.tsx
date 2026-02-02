'use client';

import { useEffect, useState } from 'react';
import api from '@/lib/api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { BarChart3, TrendingUp, Users, Calendar, Download } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface ReportStats {
  total_staff: number;
  active_staff: number;
  terminated_staff: number;
  total_branches: number;
  total_departments: number;
  monthly_promotions: number;
}

export default function ReportsPage() {
  const [stats, setStats] = useState<ReportStats | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const [staffData, branches, departments, promotions, terminated] = await Promise.all([
          api.getAllStaff().catch(() => []),
          api.getBranches().catch(() => []),
          api.getDepartments().catch(() => []),
          api.getAllPromotions().catch(() => []),
          api.getTerminatedStaff().catch(() => []),
        ]);

        const now = new Date();
        const currentMonth = now.getMonth();
        const currentYear = now.getFullYear();

        const monthlyPromotions = Array.isArray(promotions)
          ? promotions.filter((p: any) => {
              const date = new Date(p.date);
              return date.getMonth() === currentMonth && date.getFullYear() === currentYear;
            }).length
          : 0;

        const activeStaff = Array.isArray(staffData)
          ? staffData.filter((s: any) => s.is_active).length
          : 0;

        setStats({
          total_staff: Array.isArray(staffData) ? staffData.length : 0,
          active_staff: activeStaff,
          terminated_staff: Array.isArray(terminated) ? terminated.length : 0,
          total_branches: Array.isArray(branches) ? branches.length : 0,
          total_departments: Array.isArray(departments) ? departments.length : 0,
          monthly_promotions: monthlyPromotions,
        });
      } catch (error) {
        console.error('Failed to fetch stats:', error);
        setError('Failed to load report data');
      } finally {
        setIsLoading(false);
      }
    };

    fetchStats();
  }, []);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Reports & Analytics</h1>
          <p className="text-gray-500">Staff performance and organizational insights</p>
        </div>
        <Button>
          <Download className="w-4 h-4 mr-2" />
          Export Report
        </Button>
      </div>

      {error && (
        <Card className="border-red-200 bg-red-50">
          <CardContent className="pt-6">
            <p className="text-red-600 text-center">{error}</p>
          </CardContent>
        </Card>
      )}

      {stats && (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-blue-100 rounded-xl">
                    <Users className="w-6 h-6 text-blue-600" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Total Staff</p>
                    <p className="text-2xl font-bold">{stats.total_staff}</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-green-100 rounded-xl">
                    <TrendingUp className="w-6 h-6 text-green-600" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Active Staff</p>
                    <p className="text-2xl font-bold">{stats.active_staff}</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-red-100 rounded-xl">
                    <Users className="w-6 h-6 text-red-600" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Terminated Staff</p>
                    <p className="text-2xl font-bold">{stats.terminated_staff}</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-purple-100 rounded-xl">
                    <BarChart3 className="w-6 h-6 text-purple-600" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Branches</p>
                    <p className="text-2xl font-bold">{stats.total_branches}</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-indigo-100 rounded-xl">
                    <BarChart3 className="w-6 h-6 text-indigo-600" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Departments</p>
                    <p className="text-2xl font-bold">{stats.total_departments}</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-orange-100 rounded-xl">
                    <TrendingUp className="w-6 h-6 text-orange-600" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Promotions (This Month)</p>
                    <p className="text-2xl font-bold">{stats.monthly_promotions}</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>Staff Overview</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex justify-between items-center">
                  <span className="text-sm font-medium">Staff Retention Rate</span>
                  <span className="text-sm font-bold text-green-600">
                    {stats.total_staff > 0 ? ((stats.active_staff / stats.total_staff) * 100).toFixed(1) : 0}%
                  </span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div 
                    className="bg-green-500 h-2 rounded-full" 
                    style={{ width: `${stats.total_staff > 0 ? (stats.active_staff / stats.total_staff) * 100 : 0}%` }}
                  ></div>
                </div>

                <div className="grid grid-cols-3 gap-4 mt-6 pt-4 border-t">
                  <div className="text-center">
                    <p className="text-2xl font-bold text-blue-600">{stats.total_staff}</p>
                    <p className="text-sm text-gray-500 mt-1">Total</p>
                  </div>
                  <div className="text-center">
                    <p className="text-2xl font-bold text-green-600">{stats.active_staff}</p>
                    <p className="text-sm text-gray-500 mt-1">Active</p>
                  </div>
                  <div className="text-center">
                    <p className="text-2xl font-bold text-red-600">{stats.terminated_staff}</p>
                    <p className="text-sm text-gray-500 mt-1">Departed</p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </>
      )}
    </div>
  );
}
