'use client';

import { useEffect, useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { formatDate, formatCurrency, getInitials } from '@/lib/utils';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import api from '@/lib/api';
import { WorkExperience, PromotionHistory } from '@/types';
import {
  User,
  Mail,
  Phone,
  MapPin,
  Calendar,
  Briefcase,
  Building2,
  GraduationCap,
  FileText,
  TrendingUp,
  DollarSign,
} from 'lucide-react';

export default function MyProfilePage() {
  const { user, isLoading: authLoading } = useAuth();
  const [workExperience, setWorkExperience] = useState<WorkExperience[]>([]);
  const [promotions, setPromotions] = useState<PromotionHistory[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (user?.id) {
      fetchProfileData();
    }
  }, [user?.id]);

  const fetchProfileData = async () => {
    try {
      setIsLoading(true);
      const [profileRes, promotionsRes] = await Promise.all([
        api.getStaffById(user!.id),
        api.getPromotionHistory(user!.id),
      ]);
      setWorkExperience(profileRes.user.work_experience || []);
      setPromotions(promotionsRes || []);
    } catch (error) {
      // Silent fail - just show empty sections
    } finally {
      setIsLoading(false);
    }
  };

  if (authLoading || isLoading || !user) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-5xl mx-auto p-4">
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
              <h1 className="text-3xl font-bold text-gray-900">{user.full_name}</h1>
              <p className="text-lg text-green-600 font-medium mt-1">{user.role_name}</p>
              <div className="flex flex-wrap justify-center sm:justify-start gap-2 mt-3">
                {user.department_name && (
                  <span className="inline-flex items-center gap-1 text-xs bg-blue-100 text-blue-800 px-3 py-1.5 rounded-full font-medium">
                    <Building2 className="w-3 h-3" />
                    {user.department_name}
                  </span>
                )}
                {user.branch_name && (
                  <span className="inline-flex items-center gap-1 text-xs bg-green-100 text-green-800 px-3 py-1.5 rounded-full font-medium">
                    <MapPin className="w-3 h-3" />
                    {user.branch_name}
                  </span>
                )}
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Personal Information */}
      <Card>
        <CardHeader className="bg-gradient-to-r from-green-50 to-white">
          <CardTitle className="flex items-center gap-2 text-green-700">
            <User className="w-5 h-5" />
            Personal Information
          </CardTitle>
        </CardHeader>
        <CardContent className="pt-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="text-sm text-gray-500 font-medium">Full Name</label>
              <p className="font-semibold text-gray-900 mt-1">{user.full_name}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500 font-medium">Email</label>
              <p className="font-semibold text-gray-900 mt-1">{user.email}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500 font-medium">Phone Number</label>
              <p className="font-semibold text-gray-900 mt-1">{user.phone_number || 'N/A'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500 font-medium">Gender</label>
              <p className="font-semibold text-gray-900 mt-1">{user.gender || 'N/A'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500 font-medium">Date of Birth</label>
              <p className="font-semibold text-gray-900 mt-1">
                {user.date_of_birth ? formatDate(user.date_of_birth) : 'N/A'}
              </p>
            </div>
            <div>
              <label className="text-sm text-gray-500 font-medium">Marital Status</label>
              <p className="font-semibold text-gray-900 mt-1">{user.marital_status || 'N/A'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500 font-medium">State of Origin</label>
              <p className="font-semibold text-gray-900 mt-1">{user.state_of_origin || 'N/A'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500 font-medium">Home Address</label>
              <p className="font-semibold text-gray-900 mt-1">{user.home_address || 'N/A'}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Work Information */}
      <Card>
        <CardHeader className="bg-gradient-to-r from-green-50 to-white">
          <CardTitle className="flex items-center gap-2 text-green-700">
            <Briefcase className="w-5 h-5" />
            Work Information
          </CardTitle>
        </CardHeader>
        <CardContent className="pt-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="text-sm text-gray-500 font-medium">Position</label>
              <p className="font-semibold text-gray-900 mt-1">{user.role_name}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500 font-medium">Department</label>
              <p className="font-semibold text-gray-900 mt-1">{user.department_name || 'N/A'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500 font-medium">Branch</label>
              <p className="font-semibold text-gray-900 mt-1">{user.branch_name || 'N/A'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500 font-medium">Employee ID</label>
              <p className="font-semibold text-gray-900 mt-1">{user.employee_id || 'N/A'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500 font-medium">Date Joined</label>
              <p className="font-semibold text-gray-900 mt-1">
                {user.date_joined ? formatDate(user.date_joined) : 'N/A'}
              </p>
            </div>
            <div>
              <label className="text-sm text-gray-500 font-medium">Salary</label>
              <p className="font-semibold text-green-600 mt-1">
                {user.current_salary ? formatCurrency(user.current_salary) : 'N/A'}
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Education */}
      <Card>
        <CardHeader className="bg-gradient-to-r from-green-50 to-white">
          <CardTitle className="flex items-center gap-2 text-green-700">
            <GraduationCap className="w-5 h-5" />
            Education
          </CardTitle>
        </CardHeader>
        <CardContent className="pt-6">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label className="text-sm text-gray-500 font-medium">Course of Study</label>
              <p className="font-semibold text-gray-900 mt-1">{user.course_of_study || 'N/A'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500 font-medium">Grade/Class</label>
              <p className="font-semibold text-gray-900 mt-1">{user.grade || 'N/A'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500 font-medium">Institution</label>
              <p className="font-semibold text-gray-900 mt-1">{user.institution || 'N/A'}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Work Experience */}
      <Card>
        <CardHeader className="bg-gradient-to-r from-green-50 to-white">
          <CardTitle className="flex items-center gap-2 text-green-700">
            <Briefcase className="w-5 h-5" />
            Work Experience
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
            <p className="text-gray-500 text-center py-8">No work experience added</p>
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
