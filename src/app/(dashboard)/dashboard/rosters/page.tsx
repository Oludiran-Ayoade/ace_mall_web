'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useAuth } from '@/contexts/AuthContext';
import api from '@/lib/api';
import { Roster, Branch, Department } from '@/types';
import { getRoleCategory, formatDate } from '@/lib/utils';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { DAYS_OF_WEEK, SHIFT_TYPES } from '@/lib/constants';
import {
  Calendar,
  ChevronLeft,
  ChevronRight,
  Users,
  Clock,
  Building2,
  Layers,
  Filter,
} from 'lucide-react';

export default function RostersPage() {
  const { user } = useAuth();
  const [rosters, setRosters] = useState<Roster[]>([]);
  const [branches, setBranches] = useState<Branch[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedBranch, setSelectedBranch] = useState<string>('');
  const [selectedDepartment, setSelectedDepartment] = useState<string>('');
  const [currentWeekStart, setCurrentWeekStart] = useState(() => {
    const now = new Date();
    const dayOfWeek = now.getDay();
    const diff = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;
    const monday = new Date(now);
    monday.setDate(now.getDate() + diff);
    monday.setHours(0, 0, 0, 0);
    return monday;
  });

  const roleCategory = user?.role_name ? getRoleCategory(user.role_name) : 'general';

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [branchData, deptData] = await Promise.all([
          api.getBranches().catch(() => []),
          api.getDepartments().catch(() => []),
        ]);
        
        const branchList = Array.isArray(branchData) ? branchData : [];
        const deptList = Array.isArray(deptData) ? deptData : [];
        
        setBranches(branchList);
        setDepartments(deptList);
        
        // Auto-select first branch and department for better UX
        if (branchList.length > 0 && !selectedBranch) {
          setSelectedBranch(user?.branch_id || branchList[0].id);
        }
        if (deptList.length > 0 && !selectedDepartment) {
          setSelectedDepartment(user?.department_id || deptList[0].id);
        }
      } catch (error) {
        console.error('Failed to fetch data:', error);
        setBranches([]);
        setDepartments([]);
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, [user, selectedBranch, selectedDepartment]);

  useEffect(() => {
    const fetchRosters = async () => {
      if (!selectedBranch || !selectedDepartment) return;
      
      setIsLoading(true);
      try {
        const startDate = currentWeekStart.toISOString().split('T')[0];
        const data = await api.getRostersByBranchDepartment(
          selectedBranch,
          selectedDepartment,
          startDate
        );
        const rostersData = data?.rosters || (data?.data ? [data.data] : []);
        setRosters(Array.isArray(rostersData) ? rostersData : []);
      } catch (error) {
        console.error('Failed to fetch rosters:', error);
        setRosters([]);
      } finally {
        setIsLoading(false);
      }
    };

    fetchRosters();
  }, [selectedBranch, selectedDepartment, currentWeekStart]);

  const navigateWeek = (direction: 'prev' | 'next') => {
    setCurrentWeekStart((prev) => {
      const newDate = new Date(prev);
      newDate.setDate(prev.getDate() + (direction === 'next' ? 7 : -7));
      return newDate;
    });
  };

  const getWeekEndDate = () => {
    const end = new Date(currentWeekStart);
    end.setDate(currentWeekStart.getDate() + 6);
    return end;
  };

  if (isLoading && rosters.length === 0) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Rosters</h1>
          <p className="text-gray-500">View staff schedules and assignments</p>
        </div>
        {roleCategory === 'admin' && (
          <Link href="/dashboard/rosters/manage">
            <Button>
              <Calendar className="w-4 h-4 mr-2" />
              Manage Roster
            </Button>
          </Link>
        )}
      </div>

      {/* Filters - Show for all users */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="flex-1">
              <label className="text-sm text-gray-500 mb-1 block">Branch</label>
              <select
                value={selectedBranch}
                onChange={(e) => setSelectedBranch(e.target.value)}
                className="w-full h-11 px-4 rounded-xl border border-input bg-background"
              >
                <option value="">Select Branch</option>
                {Array.isArray(branches) && branches.map((b) => (
                  <option key={b.id} value={b.id}>
                    {b.name}
                  </option>
                ))}
              </select>
            </div>
            <div className="flex-1">
              <label className="text-sm text-gray-500 mb-1 block">Department</label>
              <select
                value={selectedDepartment}
                onChange={(e) => setSelectedDepartment(e.target.value)}
                className="w-full h-11 px-4 rounded-xl border border-input bg-background"
              >
                <option value="">Select Department</option>
                {Array.isArray(departments) && departments.map((d) => (
                  <option key={d.id} value={d.id}>
                    {d.name}
                  </option>
                ))}
              </select>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Week Navigator */}
      <Card>
        <CardContent className="py-4">
          <div className="flex items-center justify-between">
            <Button variant="outline" size="sm" onClick={() => navigateWeek('prev')}>
              <ChevronLeft className="w-4 h-4 mr-1" />
              Previous
            </Button>
            <div className="text-center">
              <p className="font-semibold text-gray-900">
                {formatDate(currentWeekStart)} - {formatDate(getWeekEndDate())}
              </p>
              <p className="text-sm text-gray-500">Week Schedule</p>
            </div>
            <Button variant="outline" size="sm" onClick={() => navigateWeek('next')}>
              Next
              <ChevronRight className="w-4 h-4 ml-1" />
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Roster Display */}
      {rosters.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <Calendar className="w-12 h-12 text-gray-300 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-1">No roster found</h3>
            <p className="text-gray-500">
              No roster has been created for this week and department.
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-6">
          {rosters.map((roster) => (
            <Card key={roster.id}>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle className="flex items-center gap-2">
                    <Users className="w-5 h-5 text-primary" />
                    {roster.department_name} Roster
                  </CardTitle>
                  <div className="text-sm text-gray-500">
                    Manager: {roster.floor_manager_name || 'N/A'}
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                {/* Weekly Grid */}
                <div className="overflow-x-auto">
                  <div className="grid grid-cols-7 gap-2 min-w-[700px]">
                    {DAYS_OF_WEEK.map((day) => (
                      <div key={day} className="text-center">
                        <div className="font-medium text-gray-900 py-2 bg-gray-100 rounded-t-lg">
                          {day.slice(0, 3)}
                        </div>
                        <div className="border border-t-0 border-gray-200 rounded-b-lg p-2 min-h-[100px]">
                          {roster.assignments
                            ?.filter((a) => a.day_of_week.toLowerCase() === day.toLowerCase())
                            .map((assignment) => (
                              <div
                                key={assignment.id}
                                className={`text-xs p-2 rounded mb-1 ${
                                  SHIFT_TYPES[assignment.shift_type]?.color || 'bg-gray-100'
                                }`}
                              >
                                <p className="font-medium truncate">
                                  {assignment.staff_name}
                                </p>
                                <p className="text-gray-600">
                                  {assignment.start_time} - {assignment.end_time}
                                </p>
                              </div>
                            ))}
                          {!roster.assignments?.some(
                            (a) => a.day_of_week.toLowerCase() === day.toLowerCase()
                          ) && (
                            <p className="text-xs text-gray-400 italic">No shifts</p>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Summary */}
                <div className="mt-4 flex items-center gap-6 text-sm text-gray-500">
                  <span className="flex items-center gap-1">
                    <Users className="w-4 h-4" />
                    {roster.assignments?.length || 0} assignments
                  </span>
                  <span className="flex items-center gap-1">
                    <Building2 className="w-4 h-4" />
                    {roster.branch_name}
                  </span>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      {/* Shift Legend */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Shift Types</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex flex-wrap gap-4">
            {Object.entries(SHIFT_TYPES).map(([key, value]) => (
              <div key={key} className="flex items-center gap-2">
                <div className={`w-4 h-4 rounded ${value.color.split(' ')[0]}`} />
                <span className="text-sm text-gray-600">{value.label}</span>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
