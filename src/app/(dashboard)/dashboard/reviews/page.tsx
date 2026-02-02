'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import api from '@/lib/api';
import { WeeklyReview, Branch, Department } from '@/types';
import { getInitials } from '@/lib/utils';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { 
  Star, 
  TrendingUp, 
  TrendingDown, 
  Minus, 
  CheckCircle, 
  MessageSquare,
  MapPin,
  RefreshCw
} from 'lucide-react';

interface StaffPerformance {
  id: string;
  name: string;
  role: string;
  department: string;
  branch: string;
  rating: number;
  attendance: number;
  reviews: number;
  trend: 'up' | 'down' | 'stable';
}

export default function ReviewsPage() {
  const router = useRouter();
  const [reviews, setReviews] = useState<WeeklyReview[]>([]);
  const [branches, setBranches] = useState<Branch[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [staffPerformance, setStaffPerformance] = useState<StaffPerformance[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedBranch, setSelectedBranch] = useState('All');
  const [selectedDepartment, setSelectedDepartment] = useState('All');
  const [selectedSort, setSelectedSort] = useState('Rating');

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setIsLoading(true);
    try {
      const [reviewsData, branchesData, deptsData] = await Promise.all([
        api.getAllStaffReviews().catch(() => []),
        api.getBranches().catch(() => []),
        api.getDepartments().catch(() => []),
      ]);

      setBranches(Array.isArray(branchesData) ? branchesData : []);
      setDepartments(Array.isArray(deptsData) ? deptsData : []);
      setReviews(Array.isArray(reviewsData) ? reviewsData : []);

      // Process reviews to get performance data per staff
      const staffMap: Record<string, {
        id: string;
        name: string;
        role: string;
        department: string;
        branch: string;
        totalRating: number;
        totalAttendance: number;
        reviewCount: number;
      }> = {};

      const reviewsList = Array.isArray(reviewsData) ? reviewsData : [];
      
      for (const review of reviewsList) {
        const staffId = review.staff_id?.toString() || '';
        if (!staffId) continue;

        if (!staffMap[staffId]) {
          staffMap[staffId] = {
            id: staffId,
            name: review.staff_name || 'Unknown',
            role: review.role_name || 'N/A',
            department: review.department_name || 'N/A',
            branch: review.branch_name || 'N/A',
            totalRating: 0,
            totalAttendance: 0,
            reviewCount: 0,
          };
        }

        const staff = staffMap[staffId];
        const rating = review.rating || review.overall_rating || 0;
        const attendance = review.attendance_rating || review.attendance_score || 0;

        staff.totalRating += rating;
        staff.totalAttendance += attendance;
        staff.reviewCount += 1;
      }

      // Calculate averages and create final list
      const performanceList: StaffPerformance[] = Object.values(staffMap)
        .filter(staff => staff.reviewCount > 0)
        .map(staff => {
          const avgRating = staff.totalRating / staff.reviewCount;
          const avgAttendance = (staff.totalAttendance / staff.reviewCount) * 20; // Convert 1-5 to percentage

          return {
            id: staff.id,
            name: staff.name,
            role: staff.role,
            department: staff.department,
            branch: staff.branch,
            rating: avgRating,
            attendance: avgAttendance,
            reviews: staff.reviewCount,
            trend: avgRating >= 4.0 ? 'up' : avgRating >= 3.0 ? 'stable' : 'down',
          };
        });

      setStaffPerformance(performanceList);
    } catch (error) {
      console.error('Failed to load data:', error);
    } finally {
      setIsLoading(false);
    }
  };

  // Filter and sort staff
  const filteredStaff = staffPerformance
    .filter(staff => {
      if (selectedBranch !== 'All' && staff.branch !== selectedBranch) return false;
      if (selectedDepartment !== 'All' && staff.department !== selectedDepartment) return false;
      return true;
    })
    .sort((a, b) => {
      switch (selectedSort) {
        case 'Rating':
          return b.rating - a.rating;
        case 'Attendance':
          return b.attendance - a.attendance;
        case 'Reviews':
          return b.reviews - a.reviews;
        default:
          return 0;
      }
    });

  // Calculate summary stats
  const summaryStats = {
    avgRating: filteredStaff.length > 0 
      ? filteredStaff.reduce((sum, s) => sum + s.rating, 0) / filteredStaff.length 
      : 0,
    avgAttendance: filteredStaff.length > 0 
      ? filteredStaff.reduce((sum, s) => sum + s.attendance, 0) / filteredStaff.length 
      : 0,
    totalReviews: filteredStaff.reduce((sum, s) => sum + s.reviews, 0),
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
      {/* Header with gradient */}
      <div className="bg-gradient-to-r from-blue-500 to-blue-700 rounded-xl p-6 text-white">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h1 className="text-2xl font-bold">Staff Performance</h1>
            <p className="text-blue-100">Reviews and ratings by branch & department</p>
          </div>
          <Button variant="outline" size="sm" onClick={loadData} className="bg-white/20 border-white/30 text-white hover:bg-white/30">
            <RefreshCw className="w-4 h-4 mr-2" />
            Refresh
          </Button>
        </div>

        {/* Branch Filter Chips */}
        <div className="mb-3">
          <div className="flex flex-wrap gap-2">
            <button
              onClick={() => setSelectedBranch('All')}
              className={`px-4 py-2 rounded-full text-sm font-semibold transition-all ${
                selectedBranch === 'All'
                  ? 'bg-white text-blue-600 shadow-md'
                  : 'bg-blue-800/50 text-white hover:bg-blue-800'
              }`}
            >
              All Branches
            </button>
            {branches.map((b) => (
              <button
                key={b.id}
                onClick={() => setSelectedBranch(b.name)}
                className={`px-4 py-2 rounded-full text-sm font-semibold transition-all ${
                  selectedBranch === b.name
                    ? 'bg-white text-blue-600 shadow-md'
                    : 'bg-blue-800/50 text-white hover:bg-blue-800'
                }`}
              >
                {b.name.replace('Ace Mall, ', '')}
              </button>
            ))}
          </div>
        </div>

        {/* Department Filter Chips */}
        <div className="mb-3">
          <div className="flex flex-wrap gap-2">
            <button
              onClick={() => setSelectedDepartment('All')}
              className={`px-4 py-2 rounded-full text-sm font-semibold transition-all ${
                selectedDepartment === 'All'
                  ? 'bg-white text-blue-600 shadow-md'
                  : 'bg-blue-800/50 text-white hover:bg-blue-800'
              }`}
            >
              All Departments
            </button>
            {departments.map((d) => (
              <button
                key={d.id}
                onClick={() => setSelectedDepartment(d.name)}
                className={`px-4 py-2 rounded-full text-sm font-semibold transition-all ${
                  selectedDepartment === d.name
                    ? 'bg-white text-blue-600 shadow-md'
                    : 'bg-blue-800/50 text-white hover:bg-blue-800'
                }`}
              >
                {d.name}
              </button>
            ))}
          </div>
        </div>

        {/* Sort Options */}
        <div className="flex items-center gap-3">
          <span className="text-sm text-blue-100">Sort by:</span>
          {['Rating', 'Attendance', 'Reviews'].map((option) => (
            <button
              key={option}
              onClick={() => setSelectedSort(option)}
              className={`px-3 py-1.5 rounded-full text-xs font-semibold transition-all ${
                selectedSort === option
                  ? 'bg-white text-blue-600 shadow-md'
                  : 'bg-blue-800/50 text-white hover:bg-blue-800'
              }`}
            >
              {option}
            </button>
          ))}
        </div>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-3 gap-4">
        <Card>
          <CardContent className="p-4 text-center">
            <Star className="w-6 h-6 text-amber-500 mx-auto mb-2" />
            <p className="text-2xl font-bold">{summaryStats.avgRating.toFixed(1)}</p>
            <p className="text-xs text-gray-500">Avg Rating</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-4 text-center">
            <CheckCircle className="w-6 h-6 text-green-500 mx-auto mb-2" />
            <p className="text-2xl font-bold">{summaryStats.avgAttendance.toFixed(1)}%</p>
            <p className="text-xs text-gray-500">Avg Attendance</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-4 text-center">
            <MessageSquare className="w-6 h-6 text-blue-500 mx-auto mb-2" />
            <p className="text-2xl font-bold">{summaryStats.totalReviews}</p>
            <p className="text-xs text-gray-500">Total Reviews</p>
          </CardContent>
        </Card>
      </div>

      {/* Staff Performance List */}
      {filteredStaff.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <Star className="w-12 h-12 text-gray-300 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-1">No Performance Data</h3>
            <p className="text-gray-500">Staff reviews will appear here once submitted</p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-3">
          {filteredStaff.map((staff) => (
            <Card 
              key={staff.id} 
              className="hover:shadow-md transition-shadow cursor-pointer"
              onClick={() => router.push(`/dashboard/staff/${staff.id}`)}
            >
              <CardContent className="p-4">
                <div className="flex items-start gap-4">
                  {/* Avatar */}
                  <div className="w-14 h-14 rounded-full bg-gradient-to-br from-blue-500 to-blue-700 flex items-center justify-center text-white font-bold text-lg shadow-md">
                    {getInitials(staff.name)}
                  </div>

                  {/* Info */}
                  <div className="flex-1 min-w-0">
                    <h3 className="font-bold text-gray-900">{staff.name}</h3>
                    <p className="text-sm text-gray-500">{staff.role}</p>
                    <div className="flex items-center gap-1 text-xs text-gray-400 mt-1">
                      <MapPin className="w-3 h-3" />
                      <span>{staff.branch} • {staff.department}</span>
                    </div>
                  </div>

                  {/* Trend Icon */}
                  <div className={`p-2 rounded-lg ${
                    staff.trend === 'up' ? 'bg-green-100' :
                    staff.trend === 'down' ? 'bg-red-100' : 'bg-gray-100'
                  }`}>
                    {staff.trend === 'up' ? (
                      <TrendingUp className="w-5 h-5 text-green-600" />
                    ) : staff.trend === 'down' ? (
                      <TrendingDown className="w-5 h-5 text-red-600" />
                    ) : (
                      <Minus className="w-5 h-5 text-gray-500" />
                    )}
                  </div>
                </div>

                {/* Stats Row */}
                <div className="grid grid-cols-3 gap-4 mt-4 pt-4 border-t border-gray-100">
                  <div className="text-center">
                    <Star className="w-5 h-5 text-amber-500 mx-auto mb-1" />
                    <p className="text-sm font-bold">{staff.rating.toFixed(1)}</p>
                    <p className="text-xs text-gray-500">Rating</p>
                  </div>
                  <div className="text-center">
                    <CheckCircle className="w-5 h-5 text-green-500 mx-auto mb-1" />
                    <p className="text-sm font-bold">{staff.attendance.toFixed(1)}%</p>
                    <p className="text-xs text-gray-500">Attendance</p>
                  </div>
                  <div className="text-center">
                    <MessageSquare className="w-5 h-5 text-blue-500 mx-auto mb-1" />
                    <p className="text-sm font-bold">{staff.reviews}</p>
                    <p className="text-xs text-gray-500">Reviews</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      <p className="text-center text-sm text-gray-500">
        Showing {filteredStaff.length} staff members
      </p>
    </div>
  );
}
