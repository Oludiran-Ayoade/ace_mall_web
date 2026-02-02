'use client';

import { useEffect, useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import api from '@/lib/api';
import { RosterAssignment } from '@/types';
import { formatDate } from '@/lib/utils';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { DAYS_OF_WEEK, SHIFT_TYPES } from '@/lib/constants';
import { Calendar, Clock, User, Building2, CalendarX } from 'lucide-react';

export default function MySchedulePage() {
  const { user } = useAuth();
  const [assignments, setAssignments] = useState<RosterAssignment[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchSchedule = async () => {
      try {
        const data = await api.getPersonalSchedule();
        setAssignments(Array.isArray(data) ? data : []);
      } catch (error) {
        console.error('Failed to fetch schedule:', error);
        setAssignments([]);
      } finally {
        setIsLoading(false);
      }
    };

    fetchSchedule();
  }, []);

  // Get current week dates
  const getWeekDates = () => {
    const now = new Date();
    const dayOfWeek = now.getDay();
    const diff = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;
    const monday = new Date(now);
    monday.setDate(now.getDate() + diff);

    return Array.isArray(DAYS_OF_WEEK) ? DAYS_OF_WEEK.map((day, index) => {
      const date = new Date(monday);
      date.setDate(monday.getDate() + index);
      return {
        day,
        date,
        dateStr: date.toLocaleDateString('en-NG', { month: 'short', day: 'numeric' }),
        isToday: date.toDateString() === now.toDateString(),
      };
    }) : [];
  };

  const weekDates = getWeekDates();

  const getShiftForDay = (day: string) => {
    return Array.isArray(assignments) ? assignments.find(
      (a) => a.day_of_week?.toLowerCase() === day.toLowerCase()
    ) : undefined;
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
      <div>
        <h1 className="text-2xl font-bold text-gray-900">My Schedule</h1>
        <p className="text-gray-500">Your work schedule for this week</p>
      </div>

      {/* User Info */}
      <Card className="bg-gradient-to-r from-primary to-primary-dark text-white">
        <CardContent className="pt-6">
          <div className="flex items-center gap-4">
            <div className="p-3 bg-white/20 rounded-xl">
              <User className="w-6 h-6" />
            </div>
            <div>
              <p className="font-semibold text-lg">{user?.full_name}</p>
              <p className="text-white/80">
                {user?.role_name} • {user?.department_name}
              </p>
            </div>
          </div>
          <div className="mt-4 flex items-center gap-4 text-white/80 text-sm">
            <span className="flex items-center gap-1">
              <Building2 className="w-4 h-4" />
              {user?.branch_name || 'No Branch'}
            </span>
            <span className="flex items-center gap-1">
              <Calendar className="w-4 h-4" />
              {assignments.length} shifts this week
            </span>
          </div>
        </CardContent>
      </Card>

      {/* Weekly Schedule */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Calendar className="w-5 h-5 text-primary" />
            This Week
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {weekDates.map(({ day, dateStr, isToday }) => {
              const shift = getShiftForDay(day);
              
              return (
                <div
                  key={day}
                  className={`flex items-center p-4 rounded-xl border-2 transition-all ${
                    isToday
                      ? 'border-primary bg-primary/5'
                      : shift
                      ? 'border-gray-200 bg-gray-50'
                      : 'border-gray-100 bg-gray-50/50'
                  }`}
                >
                  <div className="w-24">
                    <p className={`font-semibold ${isToday ? 'text-primary' : 'text-gray-900'}`}>
                      {day}
                    </p>
                    <p className="text-sm text-gray-500">{dateStr}</p>
                  </div>

                  {shift ? (
                    <div className="flex-1 flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div
                          className={`px-3 py-1 rounded-full text-sm font-medium ${
                            SHIFT_TYPES[shift.shift_type]?.color || 'bg-gray-100 text-gray-800'
                          }`}
                        >
                          {SHIFT_TYPES[shift.shift_type]?.label || shift.shift_type}
                        </div>
                        <div className="flex items-center gap-1 text-gray-600">
                          <Clock className="w-4 h-4" />
                          <span>{shift.start_time} - {shift.end_time}</span>
                        </div>
                      </div>
                      {isToday && (
                        <span className="text-xs bg-primary text-white px-2 py-1 rounded-full">
                          Today
                        </span>
                      )}
                    </div>
                  ) : (
                    <div className="flex-1 text-gray-400 italic">
                      No shift assigned
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>

      {/* No Schedule Message */}
      {assignments.length === 0 && (
        <Card>
          <CardContent className="py-12 text-center">
            <CalendarX className="w-12 h-12 text-gray-300 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-1">
              No schedule assigned
            </h3>
            <p className="text-gray-500">
              Your manager hasn&apos;t assigned you to any shifts this week.
              Check back later or contact your floor manager.
            </p>
          </CardContent>
        </Card>
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
                <div className={`px-3 py-1 rounded-full text-xs ${value.color}`}>
                  {value.label}
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
