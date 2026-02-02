'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import api from '@/lib/api';
import { Branch, Department } from '@/types';
import { formatDate } from '@/lib/utils';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { 
  Calendar, 
  Building2, 
  Layers, 
  Users, 
  CheckCircle, 
  XCircle,
  Clock,
  RefreshCw,
  ChevronRight
} from 'lucide-react';

interface RosterHistoryItem {
  id: string;
  week_start_date: string;
  week_end_date: string;
  branch_name: string;
  branch_id: string;
  department_name: string;
  department_id: string;
  floor_manager_name: string;
  staff_count: number;
  present_count: number;
  absent_count: number;
  pending_count: number;
}

export default function RosterHistoryPage() {
  const router = useRouter();
  const [rosters, setRosters] = useState<RosterHistoryItem[]>([]);
  const [branches, setBranches] = useState<Branch[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedYear, setSelectedYear] = useState(new Date().getFullYear());
  const [selectedMonth, setSelectedMonth] = useState<number | null>(null);
  const [selectedBranch, setSelectedBranch] = useState('All');
  const [selectedDepartment, setSelectedDepartment] = useState('All');

  const years = [2026, 2025, 2024, 2023];
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  useEffect(() => {
    loadData();
  }, [selectedYear, selectedMonth, selectedBranch, selectedDepartment]);

  const loadData = async () => {
    setIsLoading(true);
    try {
      const [branchData, deptData] = await Promise.all([
        api.getBranches().catch(() => []),
        api.getDepartments().catch(() => []),
      ]);

      setBranches(Array.isArray(branchData) ? branchData : []);
      setDepartments(Array.isArray(deptData) ? deptData : []);

      // Fetch roster history from backend
      // For now, set empty array since backend doesn't have this endpoint yet
      setRosters([]);
      console.log('Roster history will be implemented when backend API is available');
    } catch (error) {
      console.error('Failed to load data:', error);
    } finally {
      setIsLoading(false);
    }
  };

  // Filter rosters
  const filteredRosters = rosters.filter(roster => {
    const rosterDate = new Date(roster.week_start_date);
    
    if (selectedMonth !== null && rosterDate.getMonth() !== selectedMonth) return false;
    if (selectedBranch !== 'All' && roster.branch_name !== selectedBranch) return false;
    if (selectedDepartment !== 'All' && roster.department_name !== selectedDepartment) return false;
    
    return true;
  });

  const getAttendanceColor = (rate: number) => {
    if (rate >= 90) return 'text-green-600 bg-green-100';
    if (rate >= 75) return 'text-yellow-600 bg-yellow-100';
    return 'text-red-600 bg-red-100';
  };

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
          <h1 className="text-2xl font-bold text-gray-900">Roster History</h1>
          <p className="text-gray-500">View past roster schedules and attendance</p>
        </div>
        <Button variant="outline" onClick={loadData}>
          <RefreshCw className="w-4 h-4 mr-2" />
          Refresh
        </Button>
      </div>

      {/* Filters */}
      <div className="bg-gradient-to-r from-blue-500 to-blue-700 rounded-xl p-6 text-white">
        {/* Year Filter */}
        <div className="mb-4">
          <label className="text-sm text-blue-100 mb-2 block">Year</label>
          <div className="flex flex-wrap gap-2">
            {years.map(year => (
              <button
                key={year}
                onClick={() => setSelectedYear(year)}
                className={`px-4 py-2 rounded-full text-sm font-semibold transition-all ${
                  selectedYear === year
                    ? 'bg-white text-blue-600 shadow-md'
                    : 'bg-blue-800/50 text-white hover:bg-blue-800'
                }`}
              >
                {year}
              </button>
            ))}
          </div>
        </div>

        {/* Month Filter */}
        <div className="mb-4">
          <label className="text-sm text-blue-100 mb-2 block">Month</label>
          <div className="flex flex-wrap gap-2">
            <button
              onClick={() => setSelectedMonth(null)}
              className={`px-3 py-1.5 rounded-full text-xs font-semibold transition-all ${
                selectedMonth === null
                  ? 'bg-white text-blue-600 shadow-md'
                  : 'bg-blue-800/50 text-white hover:bg-blue-800'
              }`}
            >
              All
            </button>
            {months.map((month, idx) => (
              <button
                key={month}
                onClick={() => setSelectedMonth(idx)}
                className={`px-3 py-1.5 rounded-full text-xs font-semibold transition-all ${
                  selectedMonth === idx
                    ? 'bg-white text-blue-600 shadow-md'
                    : 'bg-blue-800/50 text-white hover:bg-blue-800'
                }`}
              >
                {month.slice(0, 3)}
              </button>
            ))}
          </div>
        </div>

        {/* Branch & Department Filters */}
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="text-sm text-blue-100 mb-2 block">Branch</label>
            <select
              value={selectedBranch}
              onChange={(e) => setSelectedBranch(e.target.value)}
              className="w-full h-10 px-3 rounded-lg bg-white/20 border border-white/30 text-white text-sm"
            >
              <option value="All" className="text-gray-900">All Branches</option>
              {branches.map(b => (
                <option key={b.id} value={b.name} className="text-gray-900">{b.name}</option>
              ))}
            </select>
          </div>
          <div>
            <label className="text-sm text-blue-100 mb-2 block">Department</label>
            <select
              value={selectedDepartment}
              onChange={(e) => setSelectedDepartment(e.target.value)}
              className="w-full h-10 px-3 rounded-lg bg-white/20 border border-white/30 text-white text-sm"
            >
              <option value="All" className="text-gray-900">All Departments</option>
              {departments.map(d => (
                <option key={d.id} value={d.name} className="text-gray-900">{d.name}</option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Results Count */}
      <p className="text-sm text-gray-500">
        Showing {filteredRosters.length} roster records
      </p>

      {/* Roster History Cards */}
      {filteredRosters.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <Calendar className="w-12 h-12 text-gray-300 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-1">No Roster History</h3>
            <p className="text-gray-500">No rosters found for the selected filters</p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-3">
          {filteredRosters.map(roster => {
            const attendanceRate = roster.staff_count > 0 
              ? Math.round((roster.present_count / roster.staff_count) * 100) 
              : 0;

            return (
              <Card 
                key={roster.id} 
                className="hover:shadow-md transition-shadow cursor-pointer"
                onClick={() => router.push('/dashboard/rosters')}
              >
                <CardContent className="p-4">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-2">
                        <Calendar className="w-4 h-4 text-blue-500" />
                        <span className="font-semibold text-gray-900">
                          {formatDate(roster.week_start_date)}
                        </span>
                        <span className="text-gray-400">-</span>
                        <span className="text-gray-600">{formatDate(roster.week_end_date)}</span>
                      </div>

                      <div className="flex items-center gap-4 text-sm text-gray-500 mb-3">
                        <span className="flex items-center gap-1">
                          <Building2 className="w-3 h-3" />
                          {roster.branch_name.replace('Ace Mall, ', '')}
                        </span>
                        <span className="flex items-center gap-1">
                          <Layers className="w-3 h-3" />
                          {roster.department_name}
                        </span>
                        <span className="flex items-center gap-1">
                          <Users className="w-3 h-3" />
                          {roster.floor_manager_name}
                        </span>
                      </div>

                      {/* Stats */}
                      <div className="flex items-center gap-4">
                        <div className="flex items-center gap-1 text-sm">
                          <Users className="w-4 h-4 text-gray-400" />
                          <span className="font-medium">{roster.staff_count}</span>
                          <span className="text-gray-500">staff</span>
                        </div>
                        <div className="flex items-center gap-1 text-sm text-green-600">
                          <CheckCircle className="w-4 h-4" />
                          <span className="font-medium">{roster.present_count}</span>
                          <span>present</span>
                        </div>
                        <div className="flex items-center gap-1 text-sm text-red-600">
                          <XCircle className="w-4 h-4" />
                          <span className="font-medium">{roster.absent_count}</span>
                          <span>absent</span>
                        </div>
                      </div>
                    </div>

                    {/* Attendance Rate Badge */}
                    <div className="flex items-center gap-3">
                      <div className={`px-3 py-1.5 rounded-lg text-sm font-semibold ${getAttendanceColor(attendanceRate)}`}>
                        {attendanceRate}%
                      </div>
                      <ChevronRight className="w-5 h-5 text-gray-400" />
                    </div>
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
