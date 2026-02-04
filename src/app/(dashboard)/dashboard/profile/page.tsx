'use client';

import { useEffect, useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { formatDate, formatCurrency, getInitials } from '@/lib/utils';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import api from '@/lib/api';
import { User as UserType, WorkExperience, PromotionHistory } from '@/types';
import {
  User,
  Briefcase,
  GraduationCap,
  TrendingUp,
} from 'lucide-react';

export default function ProfilePage() {
  const { user: authUser, isLoading: authLoading } = useAuth();
  const [staffData, setStaffData] = useState<UserType | null>(null);
  const [workExperience, setWorkExperience] = useState<WorkExperience[]>([]);
  const [roleHistory, setRoleHistory] = useState<any[]>([]); // Ace Mall internal experience
  const [promotions, setPromotions] = useState<PromotionHistory[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (authUser?.id) {
      fetchFullProfile();
    }
  }, [authUser?.id]);

  const fetchFullProfile = async () => {
    try {
      setIsLoading(true);
      // Fetch FULL staff profile with all details
      const [profileRes, promotionsRes] = await Promise.all([
        api.getStaffById(authUser!.id),
        api.getPromotionHistory(authUser!.id),
      ]);
      setStaffData(profileRes.user);
      setWorkExperience(profileRes.user.work_experience || []);
      setRoleHistory(profileRes.user.role_history || []); // Internal Ace Mall roles
      setPromotions(promotionsRes || []);
    } catch (error) {
      console.error('Failed to load profile:', error);
    } finally {
      setIsLoading(false);
    }
  };

  if (authLoading || isLoading || !staffData) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  const user = staffData; // Use full profile data

  return (
    <div className="space-y-6 max-w-4xl mx-auto">
      {/* Profile Header */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex flex-col sm:flex-row items-center gap-6">
            <div className="relative">
              {user.profile_image_url ? (
                <img
                  src={user.profile_image_url}
                  alt={user.full_name}
                  className="w-24 h-24 rounded-full object-cover ring-4 ring-green-100"
                />
              ) : (
                <div className="w-24 h-24 rounded-full bg-gradient-to-br from-green-500 to-green-600 flex items-center justify-center text-white text-2xl font-bold ring-4 ring-green-100">
                  {getInitials(user.full_name)}
                </div>
              )}
            </div>
            <div className="text-center sm:text-left flex-1">
              <h1 className="text-2xl font-bold text-gray-900">{user.full_name}</h1>
              <p className="text-gray-500">{user.role_name}</p>
              <div className="flex flex-wrap justify-center sm:justify-start gap-2 mt-2">
                {user.department_name && (
                  <span className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded-full">
                    {user.department_name}
                  </span>
                )}
                {user.branch_name && (
                  <span className="text-xs bg-green-100 text-green-800 px-2 py-1 rounded-full">
                    {user.branch_name}
                  </span>
                )}
              </div>
            </div>
            {/* Profile is read-only - no edit button */}
          </div>
        </CardContent>
      </Card>

      {/* Personal Information */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <User className="w-5 h-5 text-primary" />
            Personal Information
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="text-sm text-gray-500">Full Name</label>
              <p className="font-medium">{user.full_name}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500">Email</label>
              <p className="font-medium">{user.email}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500">Phone</label>
              <p className="font-medium">{user.phone_number || 'N/A'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500">Gender</label>
              <p className="font-medium">{user.gender || 'N/A'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500">Date of Birth</label>
              <p className="font-medium">
                {user.date_of_birth ? formatDate(user.date_of_birth) : 'N/A'}
              </p>
            </div>
            <div>
              <label className="text-sm text-gray-500">Marital Status</label>
              <p className="font-medium">{user.marital_status || 'N/A'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500">State of Origin</label>
              <p className="font-medium">{user.state_of_origin || 'N/A'}</p>
            </div>
            <div className="md:col-span-2">
              <label className="text-sm text-gray-500">Address</label>
              <p className="font-medium">{user.home_address || 'N/A'}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Work Information */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Briefcase className="w-5 h-5 text-primary" />
            Work Information
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="text-sm text-gray-500">Employee ID</label>
              <p className="font-medium">{user.employee_id || 'Not assigned'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500">Role</label>
              <p className="font-medium">{user.role_name}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500">Department</label>
              <p className="font-medium">{user.department_name || 'Not assigned'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500">Branch</label>
              <p className="font-medium">{user.branch_name || 'Not assigned'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500">Date Joined</label>
              <p className="font-medium">
                {user.date_joined ? formatDate(user.date_joined) : 'N/A'}
              </p>
            </div>
            <div>
              <label className="text-sm text-gray-500">Salary</label>
              <p className="font-medium text-green-600">
                {user.current_salary ? formatCurrency(user.current_salary) : 'N/A'}
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Education */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <GraduationCap className="w-5 h-5 text-primary" />
            Education
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label className="text-sm text-gray-500">Course of Study</label>
              <p className="font-medium">{user.course_of_study || 'N/A'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500">Grade/Class</label>
              <p className="font-medium">{user.grade || 'N/A'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500">Institution</label>
              <p className="font-medium">{user.institution || 'N/A'}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Ace Mall Experience (Internal Role History) */}
      <Card>
        <CardHeader className="bg-gradient-to-r from-blue-50 to-white">
          <CardTitle className="flex items-center gap-2 text-blue-700">
            <Briefcase className="w-5 h-5" />
            Ace Mall Experience
          </CardTitle>
        </CardHeader>
        <CardContent className="pt-6">
          {roleHistory.length > 0 ? (
            <div className="space-y-4">
              {roleHistory.map((role, index) => (
                <div
                  key={index}
                  className="p-4 bg-blue-50 rounded-lg border border-blue-200"
                >
                  <div className="flex justify-between items-start mb-2">
                    <div>
                      <h4 className="font-bold text-gray-900">{role.role_name}</h4>
                      <div className="flex flex-wrap gap-2 mt-1">
                        {role.department_name && (
                          <span className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded-full">
                            {role.department_name}
                          </span>
                        )}
                        {role.branch_name && (
                          <span className="text-xs bg-green-100 text-green-800 px-2 py-1 rounded-full">
                            {role.branch_name}
                          </span>
                        )}
                      </div>
                    </div>
                    <span className="text-sm text-gray-500 bg-white px-3 py-1 rounded-full border">
                      {role.start_date && formatDate(role.start_date)} - {role.end_date ? formatDate(role.end_date) : 'Present'}
                    </span>
                  </div>
                  {role.promotion_reason && (
                    <p className="text-sm text-gray-600 mt-2">
                      <strong>Reason:</strong> {role.promotion_reason}
                    </p>
                  )}
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-500 text-center py-8">No Ace Mall role history</p>
          )}
        </CardContent>
      </Card>

      {/* Previous Work Experience (External) */}
      <Card>
        <CardHeader className="bg-gradient-to-r from-green-50 to-white">
          <CardTitle className="flex items-center gap-2 text-green-700">
            <Briefcase className="w-5 h-5" />
            Previous Work Experience
          </CardTitle>
        </CardHeader>
        <CardContent className="pt-6">
          {workExperience.length > 0 ? (
            <div className="space-y-4">
              {workExperience.map((exp, index) => (
                <div
                  key={index}
                  className="p-4 bg-gray-50 rounded-lg border border-gray-200"
                >
                  <div className="flex justify-between items-start mb-2">
                    <div>
                      <h4 className="font-bold text-gray-900">{exp.position}</h4>
                      <p className="text-green-600 font-medium">{exp.company_name}</p>
                    </div>
                    <span className="text-sm text-gray-500 bg-white px-3 py-1 rounded-full border">
                      {exp.start_date && formatDate(exp.start_date)} - {exp.end_date ? formatDate(exp.end_date) : 'Present'}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-500 text-center py-8">No previous work experience</p>
          )}
        </CardContent>
      </Card>

      {/* Promotion History */}
      <Card>
        <CardHeader className="bg-gradient-to-r from-green-50 to-white">
          <CardTitle className="flex items-center gap-2 text-green-700">
            <TrendingUp className="w-5 h-5" />
            Promotion History
          </CardTitle>
        </CardHeader>
        <CardContent className="pt-6">
          {promotions.length > 0 ? (
            <div className="space-y-4">
              {promotions.map((promo, index) => (
                <div
                  key={index}
                  className="p-4 bg-gradient-to-r from-green-50 to-white rounded-lg border-l-4 border-green-500"
                >
                  <div className="flex justify-between items-start mb-2">
                    <div>
                      <h4 className="font-bold text-gray-900">{promo.new_role}</h4>
                      <p className="text-sm text-gray-600">{promo.type}</p>
                      {promo.new_branch && (
                        <p className="text-xs text-gray-500 mt-1">{promo.new_branch}</p>
                      )}
                    </div>
                    <span className="text-sm text-gray-500 bg-white px-3 py-1 rounded-full border">
                      {promo.date && formatDate(promo.date)}
                    </span>
                  </div>
                  {promo.reason && (
                    <p className="text-sm text-gray-700 mt-2">
                      <strong>Reason:</strong> {promo.reason}
                    </p>
                  )}
                  {promo.previous_salary && promo.new_salary && (
                    <div className="flex items-center gap-2 mt-2 text-sm">
                      <span className="text-gray-600">{formatCurrency(promo.previous_salary)}</span>
                      <span className="text-green-600">→</span>
                      <span className="text-green-600 font-semibold">{formatCurrency(promo.new_salary)}</span>
                    </div>
                  )}
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-500 text-center py-8">No promotion history</p>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
