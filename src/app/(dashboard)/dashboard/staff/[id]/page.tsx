'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import api from '@/lib/api';
import { User, PromotionHistory, WeeklyReview, Role } from '@/types';
import { formatDate, formatCurrency, getInitials } from '@/lib/utils';
import { decodeStaffId, isValidUUID } from '@/lib/urlEncoder';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { DocumentViewer } from '@/components/shared/DocumentViewer';
import { TerminateStaffDialog } from '@/components/dialogs/TerminateStaffDialog';
import { toast } from 'react-toastify';
import {
  ArrowLeft,
  User as UserIcon,
  Mail,
  Phone,
  MapPin,
  Calendar,
  Briefcase,
  Building2,
  GraduationCap,
  FileText,
  Users,
  Star,
  TrendingUp,
  Edit,
  UserMinus,
  Plus,
} from 'lucide-react';

export default function StaffDetailPage() {
  const params = useParams();
  const router = useRouter();
  const encodedId = params.id as string;
  
  // Decode the staff ID if it's encoded, otherwise use as-is
  const staffId = isValidUUID(encodedId) ? encodedId : decodeStaffId(encodedId);

  const [staff, setStaff] = useState<User | null>(null);
  const [permissionLevel, setPermissionLevel] = useState<string>('view_basic');
  const [promotions, setPromotions] = useState<PromotionHistory[]>([]);
  const [reviews, setReviews] = useState<WeeklyReview[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isEditingRole, setIsEditingRole] = useState(false);
  const [allRoles, setAllRoles] = useState<Role[]>([]);
  const [selectedRoleId, setSelectedRoleId] = useState<string>('');
  const [isSavingRole, setIsSavingRole] = useState(false);
  const [viewingDocument, setViewingDocument] = useState<{ url: string; title: string } | null>(null);
  const [isEditingExamScores, setIsEditingExamScores] = useState(false);
  const [examScoresValue, setExamScoresValue] = useState<string>('');
  const [isTerminateDialogOpen, setIsTerminateDialogOpen] = useState(false);
  const [isTerminating, setIsTerminating] = useState(false);

  useEffect(() => {
    const fetchStaffData = async () => {
      try {
        const [staffResponse, promotionData, reviewData, rolesData] = await Promise.all([
          api.getStaffById(staffId),
          api.getPromotionHistory(staffId).catch(() => []),
          api.getStaffReviews(staffId).catch(() => ({ reviews: [] })),
          api.getRoles().catch(() => []),
        ]);
        setStaff(staffResponse.user || null);
        setPermissionLevel(staffResponse.permission_level || 'view_basic');
        setPromotions(Array.isArray(promotionData) ? promotionData : []);
        const reviewsArray = reviewData?.reviews || [];
        setReviews(Array.isArray(reviewsArray) ? reviewsArray : []);
        setAllRoles(Array.isArray(rolesData) ? rolesData : []);
        setSelectedRoleId(staffResponse.user?.role_id || '');
      } catch (error) {
        setStaff(null);
        setPromotions([]);
        setReviews([]);
      } finally {
        setIsLoading(false);
      }
    };

    fetchStaffData();
  }, [staffId]);

  const handleSaveRole = async () => {
    if (!selectedRoleId || selectedRoleId === staff?.role_id) {
      setIsEditingRole(false);
      return;
    }

    setIsSavingRole(true);
    try {
      await api.updateStaffProfile(staffId, { role_id: selectedRoleId });
      
      // Find the new role name from allRoles
      const newRole = allRoles.find(r => r.id === selectedRoleId);
      const newRoleName = newRole?.name || staff?.role_name || '';
      
      // Update staff with new role immediately
      if (staff) {
        setStaff({
          ...staff,
          role_id: selectedRoleId,
          role_name: newRoleName,
        });
      }
      
      setIsEditingRole(false);
      toast.success('Role updated successfully!');
    } catch (error) {
      toast.error('Failed to update role. Please try again.');
    } finally {
      setIsSavingRole(false);
    }
  };

  const handleTerminateStaff = async (data: {
    termination_type: string;
    reason: string;
    last_working_day?: string;
  }) => {
    setIsTerminating(true);
    try {
      await api.terminateStaff(staffId, data);
      toast.success('Staff terminated successfully');
      setIsTerminateDialogOpen(false);
      // Redirect to terminated staff page after a short delay
      setTimeout(() => {
        router.push('/dashboard/terminated-staff');
      }, 1500);
    } catch (error) {
      toast.error('Failed to terminate staff. Please try again.');
    } finally {
      setIsTerminating(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (!staff) {
    return (
      <div className="text-center py-12">
        <h2 className="text-xl font-semibold text-gray-900">Staff not found</h2>
        <Button variant="outline" onClick={() => router.back()} className="mt-4">
          Go Back
        </Button>
      </div>
    );
  }

  const averageRating = Array.isArray(reviews) && reviews.length > 0
    ? (reviews.reduce((sum, r) => sum + (r.rating || 0), 0) / reviews.length).toFixed(1)
    : null;

  return (
    <div className="space-y-6 max-w-4xl mx-auto">
      {/* Back Button */}
      <button
        onClick={() => router.back()}
        className="flex items-center gap-2 text-gray-500 hover:text-gray-700"
      >
        <ArrowLeft className="w-4 h-4" />
        Back to Staff List
      </button>

      {/* Profile Header */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex flex-col sm:flex-row items-center gap-6">
            {staff.profile_image_url ? (
              <img
                src={staff.profile_image_url}
                alt={staff.full_name}
                className="w-24 h-24 rounded-full object-cover"
              />
            ) : (
              <div className="w-24 h-24 rounded-full bg-primary flex items-center justify-center text-white text-2xl font-bold">
                {getInitials(staff.full_name)}
              </div>
            )}
            <div className="text-center sm:text-left flex-1">
              <h1 className="text-2xl font-bold text-gray-900">{staff.full_name}</h1>
              
              {/* Role Display/Edit */}
              {isEditingRole ? (
                <div className="flex items-center gap-2 mt-2">
                  <select
                    value={selectedRoleId}
                    onChange={(e) => setSelectedRoleId(e.target.value)}
                    className="px-3 py-1 border border-gray-300 rounded-md focus:ring-2 focus:ring-green-500"
                  >
                    <option value="">Select Role</option>
                    {allRoles.map((role) => (
                      <option key={role.id} value={role.id}>
                        {role.name}
                      </option>
                    ))}
                  </select>
                  <Button
                    size="sm"
                    onClick={handleSaveRole}
                    disabled={isSavingRole}
                    className="bg-green-600 hover:bg-green-700"
                  >
                    {isSavingRole ? 'Saving...' : 'Save'}
                  </Button>
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => {
                      setIsEditingRole(false);
                      setSelectedRoleId(staff.role_id || '');
                    }}
                  >
                    Cancel
                  </Button>
                </div>
              ) : (
                <div className="flex items-center gap-2">
                  <p className="text-gray-500">{staff.role_name}</p>
                  <Button
                    size="sm"
                    variant="ghost"
                    onClick={() => setIsEditingRole(true)}
                    className="text-blue-600 hover:text-blue-700 hover:bg-blue-50"
                  >
                    <Edit className="w-4 h-4" />
                  </Button>
                </div>
              )}
              
              <div className="flex flex-wrap justify-center sm:justify-start gap-2 mt-2">
                {staff.department_name && (
                  <span className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded-full">
                    {staff.department_name}
                  </span>
                )}
                {staff.branch_name && (
                  <span className="text-xs bg-green-100 text-green-800 px-2 py-1 rounded-full">
                    {staff.branch_name}
                  </span>
                )}
                <span
                  className={`text-xs px-2 py-1 rounded-full ${
                    staff.is_active
                      ? 'bg-green-100 text-green-800'
                      : 'bg-red-100 text-red-800'
                  }`}
                >
                  {staff.is_active ? 'Active' : 'Inactive'}
                </span>
              </div>
            </div>
            {/* Only HR/CEO/COO can edit staff profiles */}
            {permissionLevel === 'view_full' && (
              <div className="flex gap-2">
                <Link href={`/dashboard/staff/${staffId}/edit`}>
                  <Button variant="outline">
                    <Edit className="w-4 h-4 mr-2" />
                    Edit
                  </Button>
                </Link>
                <Link href={`/dashboard/staff/${staffId}/upload-documents`}>
                  <Button variant="outline">
                    <FileText className="w-4 h-4 mr-2" />
                    Upload Documents
                  </Button>
                </Link>
                {staff.is_active && (
                  <Button
                    variant="outline"
                    onClick={() => setIsTerminateDialogOpen(true)}
                    className="text-red-600 hover:text-red-700 hover:bg-red-50 border-red-300"
                  >
                    <UserMinus className="w-4 h-4 mr-2" />
                    Terminate
                  </Button>
                )}
              </div>
            )}
          </div>

          {/* Quick Stats */}
          {averageRating && (
            <div className="mt-6 pt-6 border-t border-gray-100 flex items-center gap-6">
              <div className="flex items-center gap-2">
                <Star className="w-5 h-5 text-yellow-400 fill-yellow-400" />
                <span className="font-semibold">{averageRating}</span>
                <span className="text-gray-500">avg rating</span>
              </div>
              <div className="text-gray-500">
                {reviews.length} review{reviews.length !== 1 ? 's' : ''}
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Personal Information */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <UserIcon className="w-5 h-5 text-primary" />
            Personal Information
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="flex items-center gap-3">
              <Mail className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Email</p>
                <p className="font-medium">{staff.email}</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <Phone className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Phone</p>
                <p className="font-medium">{staff.phone_number || 'Not provided'}</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <UserIcon className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Gender</p>
                <p className="font-medium">{staff.gender || 'Not provided'}</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <Calendar className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Date of Birth</p>
                <p className="font-medium">
                  {staff.date_of_birth ? formatDate(staff.date_of_birth) : 'Not provided'}
                </p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <Users className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Marital Status</p>
                <p className="font-medium">{staff.marital_status || 'Not provided'}</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <MapPin className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">State of Origin</p>
                <p className="font-medium">{staff.state_of_origin || 'Not provided'}</p>
              </div>
            </div>
            <div className="flex items-center gap-3 md:col-span-2">
              <MapPin className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Home Address</p>
                <p className="font-medium">{staff.home_address || 'Not provided'}</p>
              </div>
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
              <p className="text-sm text-gray-500">Employee ID</p>
              <p className="font-medium">{staff.employee_id || 'Not assigned'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Role</p>
              <p className="font-medium">{staff.role_name}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Department</p>
              <p className="font-medium">{staff.department_name || 'Not assigned'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Branch</p>
              <p className="font-medium">{staff.branch_name || 'Not assigned'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500 mb-2">Date Joined</p>
              {permissionLevel === 'view_full' ? (
                <Input
                  type="date"
                  value={staff.date_joined ? staff.date_joined.split('T')[0] : ''}
                  onChange={async (e: React.ChangeEvent<HTMLInputElement>) => {
                    const newDate = e.target.value;
                    try {
                      await api.updateStaffProfile(staffId, { date_joined: newDate });
                      setStaff({ ...staff, date_joined: newDate });
                      toast.success('Date joined updated successfully!');
                    } catch (error) {
                      toast.error('Failed to update date joined');
                    }
                  }}
                  className="w-full sm:max-w-[200px] h-12 px-4 text-base font-medium border border-green-200 rounded-xl focus:border-green-500 focus:ring-2 focus:ring-green-200 transition-all bg-green-50/50 hover:bg-green-50"
                />
              ) : (
                <div className="inline-flex items-center gap-2 px-4 py-2.5 bg-gray-50 rounded-lg border border-gray-200">
                  <Calendar className="w-4 h-4 text-gray-500" />
                  <p className="font-medium text-gray-900">
                    {staff.date_joined ? formatDate(staff.date_joined) : 'Not provided'}
                  </p>
                </div>
              )}
            </div>
            {permissionLevel === 'view_full' && (
              <>
                <div>
                  <p className="text-sm text-gray-500">Salary</p>
                  <p className="font-medium text-primary">
                    {staff.current_salary ? formatCurrency(staff.current_salary) : 'Not disclosed'}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-gray-500 mb-2">Exam Scores</p>
                  {isEditingExamScores ? (
                    <div className="flex items-center gap-2">
                      <Input
                        type="text"
                        value={examScoresValue}
                        onChange={(e: React.ChangeEvent<HTMLInputElement>) => setExamScoresValue(e.target.value)}
                        className="flex-1 sm:max-w-[400px] h-12 px-4 text-base font-medium border border-purple-200 rounded-xl focus:border-purple-500 focus:ring-2 focus:ring-purple-200 transition-all bg-purple-50/50"
                      />
                      <Button
                        size="sm"
                        onClick={async () => {
                          try {
                            await api.updateStaffProfile(staffId, { exam_scores: examScoresValue } as any);
                            setStaff({ 
                              ...staff, 
                              exam_scores: examScoresValue ? [{ exam_type: 'General', score: examScoresValue }] : [] 
                            });
                            setIsEditingExamScores(false);
                            toast.success('Exam scores updated successfully!');
                          } catch (error) {
                            toast.error('Failed to update exam scores');
                          }
                        }}
                        className="bg-green-600 hover:bg-green-700 text-white"
                      >
                        Save
                      </Button>
                      <Button
                        size="sm"
                        variant="ghost"
                        onClick={() => {
                          setIsEditingExamScores(false);
                          setExamScoresValue(staff.exam_scores && staff.exam_scores.length > 0 ? staff.exam_scores[0].score : '');
                        }}
                      >
                        Cancel
                      </Button>
                    </div>
                  ) : (
                    <div className="flex items-center gap-2">
                      <p className="font-semibold text-gray-900">
                        {staff.exam_scores && staff.exam_scores.length > 0 ? staff.exam_scores[0].score : 'Not provided'}
                      </p>
                      <Button
                        size="sm"
                        variant="ghost"
                        onClick={() => {
                          setExamScoresValue(staff.exam_scores && staff.exam_scores.length > 0 ? staff.exam_scores[0].score : '');
                          setIsEditingExamScores(true);
                        }}
                        className="text-green-600 hover:text-green-700 hover:bg-green-50"
                      >
                        <Edit className="w-4 h-4" />
                      </Button>
                    </div>
                  )}
                </div>
              </>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Work Experience */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between w-full">
            <CardTitle className="flex items-center gap-2">
              <Briefcase className="w-5 h-5 text-primary" />
              Work Experience
            </CardTitle>
            <Button 
              size="lg" 
              className="bg-green-600 hover:bg-green-700 text-white font-bold px-6 py-3 shadow-lg"
              onClick={() => {
                router.push(`/dashboard/staff/${staffId}/edit-work-experience`);
              }}
            >
              <Edit className="w-5 h-5 mr-2" />
              EDIT
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          {staff.work_experience && staff.work_experience.length > 0 ? (
            <div className="space-y-4">
              {staff.work_experience.map((exp, index) => (
                <div
                  key={index}
                  className="flex items-start gap-4 p-4 bg-gray-50 rounded-xl"
                >
                  <div className="p-2 bg-blue-100 rounded-full">
                    <Briefcase className="w-4 h-4 text-blue-600" />
                  </div>
                  <div className="flex-1">
                    <p className="font-semibold text-gray-900">{exp.position}</p>
                    <p className="text-sm text-green-600 font-medium">{exp.company_name}</p>
                    <p className="text-sm text-gray-500 mt-1 flex items-center gap-1">
                      <Calendar className="w-3 h-3" />
                      {exp.start_date ? formatDate(exp.start_date) : ''} - {exp.end_date ? formatDate(exp.end_date) : 'Present'}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-8">
              <Briefcase className="w-12 h-12 text-gray-300 mx-auto mb-3" />
              <p className="text-gray-500 mb-4">No work experience recorded</p>
              <Button 
                size="lg"
                className="bg-green-600 hover:bg-green-700 text-white font-bold px-8 py-4 shadow-lg"
                onClick={() => {
                  router.push(`/dashboard/staff/${staffId}/edit-work-experience`);
                }}
              >
                <Plus className="w-5 h-5 mr-2" />
                ADD WORK EXPERIENCE
              </Button>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Role History (Roles Held at Ace Mall) */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between w-full">
            <CardTitle className="flex items-center gap-2">
              <Building2 className="w-5 h-5 text-primary" />
              Roles Held at Ace Mall
            </CardTitle>
            <Button 
              size="lg" 
              className="bg-green-600 hover:bg-green-700 text-white font-bold px-6 py-3 shadow-lg"
              onClick={() => {
                router.push(`/dashboard/staff/${staffId}/edit-role-history`);
              }}
            >
              <Edit className="w-5 h-5 mr-2" />
              EDIT
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          {staff.role_history && staff.role_history.length > 0 ? (
            <div className="space-y-4">
              {staff.role_history.map((role, index) => (
                <div
                  key={index}
                  className="flex items-start gap-4 p-4 bg-gray-50 rounded-xl"
                >
                  <div className="p-2 bg-purple-100 rounded-full">
                    <Briefcase className="w-4 h-4 text-purple-600" />
                  </div>
                  <div className="flex-1">
                    <p className="font-semibold text-gray-900">{role.role_name}</p>
                    {(role.department_name || role.branch_name) && (
                      <p className="text-sm text-purple-600 font-medium">
                        {[role.department_name, role.branch_name].filter(Boolean).join(' • ')}
                      </p>
                    )}
                    <p className="text-sm text-gray-500 mt-1 flex items-center gap-1">
                      <Calendar className="w-3 h-3" />
                      {formatDate(role.start_date)} - {role.end_date ? formatDate(role.end_date) : 'Present'}
                    </p>
                    {role.promotion_reason && (
                      <p className="text-sm text-gray-600 mt-2 italic">"{role.promotion_reason}"</p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-8">
              <Building2 className="w-12 h-12 text-gray-300 mx-auto mb-3" />
              <p className="text-gray-500 mb-4">No role history recorded at Ace Mall</p>
              <Button 
                size="lg"
                className="bg-green-600 hover:bg-green-700 text-white font-bold px-8 py-4 shadow-lg"
                onClick={() => {
                  router.push(`/dashboard/staff/${staffId}/edit-role-history`);
                }}
              >
                <Plus className="w-5 h-5 mr-2" />
                ADD ROLE HISTORY
              </Button>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Promotion & Transfer History */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <TrendingUp className="w-5 h-5 text-primary" />
            Promotion & Transfer History
          </CardTitle>
        </CardHeader>
        <CardContent>
          {promotions.length > 0 ? (
            <div className="space-y-4">
              {promotions.map((promo) => {
                const isTransfer = promo.type === 'Transfer' || promo.type === 'Transfer & Promotion';
                const isPromotion = promo.type === 'Promotion' || promo.type === 'Transfer & Promotion';
                const isSalaryIncrease = promo.type === 'Salary Increase';
                
                return (
                  <div
                    key={promo.id}
                    className="flex items-start gap-4 p-4 bg-gray-50 rounded-xl"
                  >
                    <div className={`p-2 rounded-full ${
                      isTransfer ? 'bg-blue-100' : 
                      isSalaryIncrease ? 'bg-yellow-100' : 'bg-green-100'
                    }`}>
                      {isTransfer ? (
                        <Building2 className={`w-4 h-4 ${isTransfer ? 'text-blue-600' : 'text-green-600'}`} />
                      ) : (
                        <TrendingUp className={`w-4 h-4 ${isSalaryIncrease ? 'text-yellow-600' : 'text-green-600'}`} />
                      )}
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center justify-between">
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                          isTransfer ? 'bg-blue-100 text-blue-800' :
                          isSalaryIncrease ? 'bg-yellow-100 text-yellow-800' : 'bg-green-100 text-green-800'
                        }`}>
                          {promo.type}
                        </span>
                        <span className="text-sm text-gray-500">
                          {formatDate(promo.date)}
                        </span>
                      </div>
                      {isPromotion && promo.previous_role !== promo.new_role && (
                        <p className="text-sm text-gray-600 mt-2">
                          <span className="font-medium">Role:</span> {promo.previous_role} → {promo.new_role}
                        </p>
                      )}
                      {isTransfer && promo.previous_branch && promo.new_branch && (
                        <p className="text-sm text-blue-600 mt-1">
                          <span className="font-medium">Branch:</span> {promo.previous_branch} → {promo.new_branch}
                        </p>
                      )}
                      {promo.previous_salary !== promo.new_salary && (
                        <p className="text-sm text-green-600 mt-1">
                          <span className="font-medium">Salary:</span> {formatCurrency(promo.previous_salary)} → {formatCurrency(promo.new_salary)}
                        </p>
                      )}
                      {promo.reason && (
                        <p className="text-sm text-gray-500 mt-2 italic">
                          &quot;{promo.reason}&quot;
                        </p>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          ) : (
            <div className="text-center py-8">
              <TrendingUp className="w-12 h-12 text-gray-300 mx-auto mb-3" />
              <p className="text-gray-500">No promotion or transfer history</p>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Recent Reviews */}
      {reviews.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Star className="w-5 h-5 text-primary" />
              Recent Reviews
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {reviews.slice(0, 5).map((review) => (
                <div
                  key={review.id}
                  className="flex items-start gap-4 p-4 bg-gray-50 rounded-xl"
                >
                  <div className="flex items-center gap-1">
                    {[1, 2, 3, 4, 5].map((star) => (
                      <Star
                        key={star}
                        className={`w-4 h-4 ${
                          star <= (review.rating || 0)
                            ? 'text-yellow-400 fill-yellow-400'
                            : 'text-gray-200'
                        }`}
                      />
                    ))}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center justify-between">
                      <p className="font-medium text-gray-900">
                        {review.reviewer_name || 'Manager'}
                      </p>
                      <span className="text-sm text-gray-500">
                        {formatDate(review.created_at)}
                      </span>
                    </div>
                    {review.comments && (
                      <p className="text-sm text-gray-600 mt-1">{review.comments}</p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Staff Documents - Only HR/CEO/COO */}
      {permissionLevel === 'view_full' && (
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <FileText className="w-5 h-5 text-primary" />
            Documents
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {[
              { label: 'Passport Photo', url: staff.passport_url },
              { label: 'National ID', url: staff.national_id_url },
              { label: 'Birth Certificate', url: staff.birth_certificate_url },
              { label: 'WAEC Certificate', url: staff.waec_certificate_url },
              { label: 'NECO Certificate', url: staff.neco_certificate_url },
              { label: 'JAMB Result', url: staff.jamb_result_url },
              { label: 'Degree Certificate', url: staff.degree_certificate_url },
              { label: 'NYSC Certificate', url: staff.nysc_certificate_url },
              { label: 'State of Origin', url: staff.state_of_origin_cert_url },
            ].map((doc) => (
              <div
                key={doc.label}
                className={`p-4 border rounded-lg ${
                  doc.url ? 'border-green-200 bg-green-50' : 'border-gray-200 bg-gray-50'
                }`}
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <FileText className={`w-5 h-5 ${doc.url ? 'text-green-600' : 'text-gray-400'}`} />
                    <span className="text-sm font-medium">{doc.label}</span>
                  </div>
                  {doc.url ? (
                    <button
                      onClick={() => setViewingDocument({ url: doc.url!, title: doc.label })}
                      className="text-xs text-primary hover:underline"
                    >
                      View
                    </button>
                  ) : (
                    <span className="text-xs text-gray-400">Not uploaded</span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
      )}

      {/* Next of Kin - Only HR/CEO/COO */}
      {permissionLevel === 'view_full' && (
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Users className="w-5 h-5 text-primary" />
            Next of Kin
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <p className="text-sm text-gray-500">Full Name</p>
              <p className="font-medium">{staff.next_of_kin_name || 'Not provided'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Relationship</p>
              <p className="font-medium">{staff.next_of_kin_relationship || 'Not provided'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Phone Number</p>
              <p className="font-medium">{staff.next_of_kin_phone || 'Not provided'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Email</p>
              <p className="font-medium">{staff.next_of_kin_email || 'Not provided'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Home Address</p>
              <p className="font-medium">{staff.next_of_kin_home_address || 'Not provided'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Work Address</p>
              <p className="font-medium">{staff.next_of_kin_work_address || 'Not provided'}</p>
            </div>
          </div>
        </CardContent>
      </Card>
      )}

      {/* Guarantor 1 - Only HR/CEO/COO */}
      {permissionLevel === 'view_full' && (
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <UserIcon className="w-5 h-5 text-primary" />
            Guarantor 1
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <p className="text-sm text-gray-500">Full Name</p>
              <p className="font-medium">{staff.guarantor1_name || 'Not provided'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Phone Number</p>
              <p className="font-medium">{staff.guarantor1_phone || 'Not provided'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Occupation</p>
              <p className="font-medium">{staff.guarantor1_occupation || 'Not provided'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Relationship</p>
              <p className="font-medium">{staff.guarantor1_relationship || 'Not provided'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Address</p>
              <p className="font-medium">{staff.guarantor1_address || 'Not provided'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Email</p>
              <p className="font-medium">{staff.guarantor1_email || 'Not provided'}</p>
            </div>
          </div>
          
          {/* Guarantor 1 Documents */}
          <div className="mt-6 pt-6 border-t">
            <h4 className="text-sm font-semibold text-gray-700 mb-4">Documents</h4>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              {[
                { label: 'Passport', url: staff.guarantor1_passport },
                { label: 'National ID', url: staff.guarantor1_national_id },
                { label: 'Work ID', url: staff.guarantor1_work_id },
              ].map((doc) => (
                <div
                  key={doc.label}
                  className={`p-3 border rounded-lg ${
                    doc.url ? 'border-green-200 bg-green-50' : 'border-gray-200 bg-gray-50'
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <span className="text-sm">{doc.label}</span>
                    {doc.url ? (
                      <button
                        onClick={() => setViewingDocument({ url: doc.url!, title: `Guarantor 1 - ${doc.label}` })}
                        className="text-xs text-primary hover:underline"
                      >
                        View
                      </button>
                    ) : (
                      <span className="text-xs text-gray-400">N/A</span>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </CardContent>
      </Card>
      )}

      {/* Guarantor 2 - Only HR/CEO/COO */}
      {permissionLevel === 'view_full' && (
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <UserIcon className="w-5 h-5 text-primary" />
            Guarantor 2
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <p className="text-sm text-gray-500">Full Name</p>
              <p className="font-medium">{staff.guarantor2_name || 'Not provided'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Phone Number</p>
              <p className="font-medium">{staff.guarantor2_phone || 'Not provided'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Occupation</p>
              <p className="font-medium">{staff.guarantor2_occupation || 'Not provided'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Relationship</p>
              <p className="font-medium">{staff.guarantor2_relationship || 'Not provided'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Address</p>
              <p className="font-medium">{staff.guarantor2_address || 'Not provided'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Email</p>
              <p className="font-medium">{staff.guarantor2_email || 'Not provided'}</p>
            </div>
          </div>
          
          {/* Guarantor 2 Documents */}
          <div className="mt-6 pt-6 border-t">
            <h4 className="text-sm font-semibold text-gray-700 mb-4">Documents</h4>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              {[
                { label: 'Passport', url: staff.guarantor2_passport },
                { label: 'National ID', url: staff.guarantor2_national_id },
                { label: 'Work ID', url: staff.guarantor2_work_id },
              ].map((doc) => (
                <div
                  key={doc.label}
                  className={`p-3 border rounded-lg ${
                    doc.url ? 'border-green-200 bg-green-50' : 'border-gray-200 bg-gray-50'
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <span className="text-sm">{doc.label}</span>
                    {doc.url ? (
                      <button
                        onClick={() => setViewingDocument({ url: doc.url!, title: `Guarantor 2 - ${doc.label}` })}
                        className="text-xs text-primary hover:underline"
                      >
                        View
                      </button>
                    ) : (
                      <span className="text-xs text-gray-400">N/A</span>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </CardContent>
      </Card>
      )}

      {/* Education */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <GraduationCap className="w-5 h-5 text-primary" />
            Education
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <p className="text-sm text-gray-500">Course of Study</p>
              <p className="font-medium">{staff.course_of_study || 'Not provided'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Grade</p>
              <p className="font-medium">{staff.grade || 'Not provided'}</p>
            </div>
            <div className="md:col-span-2">
              <p className="text-sm text-gray-500">Institution</p>
              <p className="font-medium">{staff.institution || 'Not provided'}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Document Viewer Modal */}
      {viewingDocument && (
        <DocumentViewer
          url={viewingDocument.url}
          title={viewingDocument.title}
          onClose={() => setViewingDocument(null)}
        />
      )}

      {/* Terminate Staff Dialog */}
      <TerminateStaffDialog
        isOpen={isTerminateDialogOpen}
        onClose={() => setIsTerminateDialogOpen(false)}
        onConfirm={handleTerminateStaff}
        staffName={staff?.full_name || ''}
        isLoading={isTerminating}
      />
    </div>
  );
}
