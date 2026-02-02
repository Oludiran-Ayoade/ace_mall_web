'use client';

import { useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { formatDate, formatCurrency, getInitials } from '@/lib/utils';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { toast } from '@/components/ui/toaster';
import api from '@/lib/api';
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
  Users,
  Edit,
  Save,
  X,
  Camera,
} from 'lucide-react';

export default function ProfilePage() {
  const { user, refreshUser, isLoading: authLoading } = useAuth();
  const [isEditing, setIsEditing] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [formData, setFormData] = useState({
    full_name: user?.full_name || '',
    phone_number: user?.phone_number || '',
    home_address: user?.home_address || '',
  });

  if (authLoading || !user) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  const handleSave = async () => {
    setIsSaving(true);
    try {
      await api.updateStaffProfile(user.id, formData);
      await refreshUser();
      setIsEditing(false);
      toast({ title: 'Profile updated successfully', variant: 'success' });
    } catch (error) {
      toast({ title: 'Failed to update profile', variant: 'destructive' });
    } finally {
      setIsSaving(false);
    }
  };

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
                  className="w-24 h-24 rounded-full object-cover"
                />
              ) : (
                <div className="w-24 h-24 rounded-full bg-primary flex items-center justify-center text-white text-2xl font-bold">
                  {getInitials(user.full_name)}
                </div>
              )}
              <button className="absolute bottom-0 right-0 p-2 bg-white rounded-full shadow-lg border hover:bg-gray-50">
                <Camera className="w-4 h-4 text-gray-600" />
              </button>
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
            <Button
              variant={isEditing ? 'outline' : 'default'}
              onClick={() => {
                if (isEditing) {
                  setFormData({
                    full_name: user.full_name,
                    phone_number: user.phone_number || '',
                    home_address: user.home_address || '',
                  });
                }
                setIsEditing(!isEditing);
              }}
            >
              {isEditing ? (
                <>
                  <X className="w-4 h-4 mr-2" />
                  Cancel
                </>
              ) : (
                <>
                  <Edit className="w-4 h-4 mr-2" />
                  Edit Profile
                </>
              )}
            </Button>
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
              {isEditing ? (
                <Input
                  value={formData.full_name}
                  onChange={(e) => setFormData({ ...formData, full_name: e.target.value })}
                  className="mt-1"
                />
              ) : (
                <p className="font-medium">{user.full_name}</p>
              )}
            </div>
            <div>
              <label className="text-sm text-gray-500">Email</label>
              <p className="font-medium">{user.email}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500">Phone</label>
              {isEditing ? (
                <Input
                  value={formData.phone_number}
                  onChange={(e) => setFormData({ ...formData, phone_number: e.target.value })}
                  className="mt-1"
                />
              ) : (
                <p className="font-medium">{user.phone_number || 'Not provided'}</p>
              )}
            </div>
            <div>
              <label className="text-sm text-gray-500">Gender</label>
              <p className="font-medium">{user.gender || 'Not provided'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500">Date of Birth</label>
              <p className="font-medium">
                {user.date_of_birth ? formatDate(user.date_of_birth) : 'Not provided'}
              </p>
            </div>
            <div>
              <label className="text-sm text-gray-500">State of Origin</label>
              <p className="font-medium">{user.state_of_origin || 'Not provided'}</p>
            </div>
            <div className="md:col-span-2">
              <label className="text-sm text-gray-500">Address</label>
              {isEditing ? (
                <Input
                  value={formData.home_address}
                  onChange={(e) => setFormData({ ...formData, home_address: e.target.value })}
                  className="mt-1"
                />
              ) : (
                <p className="font-medium">{user.home_address || 'Not provided'}</p>
              )}
            </div>
          </div>
          {isEditing && (
            <div className="mt-6 flex justify-end">
              <Button onClick={handleSave} disabled={isSaving}>
                {isSaving ? (
                  <LoadingSpinner size="sm" className="mr-2" />
                ) : (
                  <Save className="w-4 h-4 mr-2" />
                )}
                Save Changes
              </Button>
            </div>
          )}
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
                {user.date_joined ? formatDate(user.date_joined) : 'Not provided'}
              </p>
            </div>
            <div>
              <label className="text-sm text-gray-500">Salary</label>
              <p className="font-medium text-primary">
                {user.current_salary ? formatCurrency(user.current_salary) : 'Not disclosed'}
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
              <p className="font-medium">{user.course_of_study || 'Not provided'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500">Grade</label>
              <p className="font-medium">{user.grade || 'Not provided'}</p>
            </div>
            <div>
              <label className="text-sm text-gray-500">Institution</label>
              <p className="font-medium">{user.institution || 'Not provided'}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Documents */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <FileText className="w-5 h-5 text-primary" />
            Documents
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {[
              { label: 'Passport', url: user.passport_url },
              { label: 'National ID', url: user.national_id_url },
              { label: 'WAEC Certificate', url: user.waec_certificate_url },
              { label: 'Degree Certificate', url: user.degree_certificate_url },
              { label: 'NYSC Certificate', url: user.nysc_certificate_url },
              { label: 'Birth Certificate', url: user.birth_certificate_url },
            ].map((doc) => (
              <div
                key={doc.label}
                className={`p-4 rounded-xl border-2 border-dashed text-center ${
                  doc.url ? 'border-green-300 bg-green-50' : 'border-gray-200 bg-gray-50'
                }`}
              >
                <FileText className={`w-8 h-8 mx-auto mb-2 ${doc.url ? 'text-green-500' : 'text-gray-300'}`} />
                <p className="text-sm font-medium text-gray-700">{doc.label}</p>
                <p className="text-xs text-gray-500 mt-1">
                  {doc.url ? 'Uploaded' : 'Not uploaded'}
                </p>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
