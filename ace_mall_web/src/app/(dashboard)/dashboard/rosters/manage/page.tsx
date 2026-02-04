'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/contexts/AuthContext';
import api from '@/lib/api';
import { User, RosterAssignment } from '@/types';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { LoadingSpinner, BouncingDots } from '@/components/shared/LoadingSpinner';
import { toast } from '@/components/ui/toaster';
import { DAYS_OF_WEEK, SHIFT_TYPES } from '@/lib/constants';
import {
  Calendar,
  ArrowLeft,
  Save,
  Users,
  Clock,
  ChevronLeft,
  ChevronRight,
  Check,
  X,
} from 'lucide-react';

interface StaffShift {
  staff_id: string;
  staff_name: string;
  shifts: Record<string, string>;
}

export default function RosterManagePage() {
  const router = useRouter();
  const { user } = useAuth();
  const [teamMembers, setTeamMembers] = useState<User[]>([]);
  const [staffShifts, setStaffShifts] = useState<StaffShift[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [currentWeekStart, setCurrentWeekStart] = useState(() => {
    const now = new Date();
    const dayOfWeek = now.getDay();
    const diff = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;
    const monday = new Date(now);
    monday.setDate(now.getDate() + diff);
    monday.setHours(0, 0, 0, 0);
    return monday;
  });

  useEffect(() => {
    const fetchTeamMembers = async () => {
      try {
        const allStaff = await api.getAllStaff();
        const filtered = Array.isArray(allStaff)
          ? allStaff.filter((s: User) => {
              if (user?.department_id && s.department_id !== user.department_id) return false;
              if (user?.branch_id && s.branch_id !== user.branch_id) return false;
              if (s.id === user?.id) return false;
              return true;
            })
          : [];

        setTeamMembers(filtered);
        
        // Initialize shifts for each team member
        const initialShifts: StaffShift[] = filtered.map((member: User) => ({
          staff_id: member.id,
          staff_name: member.full_name,
          shifts: {},
        }));
        setStaffShifts(initialShifts);
      } catch (error) {
        console.error('Failed to fetch team:', error);
        toast({ title: 'Failed to load team members', variant: 'destructive' });
      } finally {
        setIsLoading(false);
      }
    };

    if (user) {
      fetchTeamMembers();
    }
  }, [user]);

  const navigateWeek = (direction: 'prev' | 'next') => {
    setCurrentWeekStart((prev) => {
      const newDate = new Date(prev);
      newDate.setDate(newDate.getDate() + (direction === 'next' ? 7 : -7));
      return newDate;
    });
  };

  const getWeekDates = () => {
    return DAYS_OF_WEEK.map((day, index) => {
      const date = new Date(currentWeekStart);
      date.setDate(currentWeekStart.getDate() + index);
      return {
        day,
        date,
        dateStr: date.toLocaleDateString('en-NG', { month: 'short', day: 'numeric' }),
      };
    });
  };

  const weekDates = getWeekDates();

  const updateShift = (staffId: string, day: string, shiftType: string) => {
    setStaffShifts((prev) =>
      prev.map((staff) =>
        staff.staff_id === staffId
          ? {
              ...staff,
              shifts: {
                ...staff.shifts,
                [day]: staff.shifts[day] === shiftType ? '' : shiftType,
              },
            }
          : staff
      )
    );
  };

  const handleSave = async () => {
    setIsSaving(true);
    try {
      const assignments: RosterAssignment[] = [];
      
      staffShifts.forEach((staff) => {
        Object.entries(staff.shifts).forEach(([day, shiftType]) => {
          if (shiftType) {
            const shiftConfig = SHIFT_TYPES[shiftType];
            assignments.push({
              id: '',
              roster_id: '',
              staff_id: staff.staff_id,
              staff_name: staff.staff_name,
              day_of_week: day,
              shift_type: shiftType as 'morning' | 'afternoon' | 'evening' | 'night',
              start_time: shiftConfig?.startTime || '09:00',
              end_time: shiftConfig?.endTime || '17:00',
            });
          }
        });
      });

      const weekEnd = new Date(currentWeekStart);
      weekEnd.setDate(weekEnd.getDate() + 6);
      
      await api.createRoster({
        week_start_date: currentWeekStart.toISOString().split('T')[0],
        week_end_date: weekEnd.toISOString().split('T')[0],
        assignments: assignments.map(a => ({
          staff_id: a.staff_id,
          day_of_week: a.day_of_week,
          shift_type: a.shift_type,
          start_time: a.start_time,
          end_time: a.end_time,
        })),
      });

      toast({ title: 'Roster saved successfully!', variant: 'success' });
    } catch (error) {
      toast({ title: 'Failed to save roster', variant: 'destructive' });
    } finally {
      setIsSaving(false);
    }
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
        <div className="flex items-center gap-4">
          <button onClick={() => router.back()} className="p-2 hover:bg-gray-100 rounded-lg">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Manage Roster</h1>
            <p className="text-gray-500">Create weekly schedule for your team</p>
          </div>
        </div>
        <Button onClick={handleSave} disabled={isSaving}>
          {isSaving ? <BouncingDots /> : (
            <>
              <Save className="w-4 h-4 mr-2" />
              Save Roster
            </>
          )}
        </Button>
      </div>

      {/* Week Navigation */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex items-center justify-between">
            <Button variant="outline" size="sm" onClick={() => navigateWeek('prev')}>
              <ChevronLeft className="w-4 h-4 mr-1" />
              Previous Week
            </Button>
            <div className="text-center">
              <p className="font-semibold">
                {currentWeekStart.toLocaleDateString('en-NG', { month: 'long', day: 'numeric' })} -{' '}
                {new Date(currentWeekStart.getTime() + 6 * 24 * 60 * 60 * 1000).toLocaleDateString('en-NG', {
                  month: 'long',
                  day: 'numeric',
                  year: 'numeric',
                })}
              </p>
            </div>
            <Button variant="outline" size="sm" onClick={() => navigateWeek('next')}>
              Next Week
              <ChevronRight className="w-4 h-4 ml-1" />
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Shift Legend */}
      <Card>
        <CardContent className="pt-6">
          <p className="text-sm text-gray-500 mb-3">Click to assign shifts:</p>
          <div className="flex flex-wrap gap-3">
            {Object.entries(SHIFT_TYPES).map(([key, value]) => (
              <div key={key} className="flex items-center gap-2">
                <div className={`px-3 py-1 rounded-full text-xs font-medium ${value.color}`}>
                  {value.label}
                </div>
                <span className="text-xs text-gray-500">
                  {value.startTime} - {value.endTime}
                </span>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Roster Grid */}
      {teamMembers.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <Users className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No team members</h3>
            <p className="text-gray-500">Add staff to your team to create rosters</p>
          </CardContent>
        </Card>
      ) : (
        <Card>
          <CardContent className="pt-6 overflow-x-auto">
            <table className="w-full min-w-[800px]">
              <thead>
                <tr>
                  <th className="text-left p-3 border-b">Staff Member</th>
                  {weekDates.map(({ day, dateStr }) => (
                    <th key={day} className="text-center p-3 border-b min-w-[100px]">
                      <div className="font-medium">{day}</div>
                      <div className="text-xs text-gray-500">{dateStr}</div>
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {staffShifts.map((staff) => (
                  <tr key={staff.staff_id} className="border-b hover:bg-gray-50">
                    <td className="p-3">
                      <div className="flex items-center gap-2">
                        <div className="w-8 h-8 bg-primary/10 rounded-full flex items-center justify-center">
                          <span className="text-primary text-xs font-semibold">
                            {staff.staff_name?.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)}
                          </span>
                        </div>
                        <span className="font-medium">{staff.staff_name}</span>
                      </div>
                    </td>
                    {weekDates.map(({ day }) => (
                      <td key={day} className="p-2 text-center">
                        <div className="flex flex-col gap-1">
                          {Object.entries(SHIFT_TYPES).map(([shiftKey, shiftValue]) => (
                            <button
                              key={shiftKey}
                              onClick={() => updateShift(staff.staff_id, day, shiftKey)}
                              className={`px-2 py-1 rounded text-xs transition-all ${
                                staff.shifts[day] === shiftKey
                                  ? shiftValue.color + ' ring-2 ring-offset-1 ring-gray-400'
                                  : 'bg-gray-100 text-gray-400 hover:bg-gray-200'
                              }`}
                            >
                              {shiftValue.label.charAt(0)}
                            </button>
                          ))}
                        </div>
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
