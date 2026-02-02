'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import api from '@/lib/api';
import { User, PromotionHistory, WeeklyReview, WorkExperience } from '@/types';
import { formatDate, formatCurrency, getInitials } from '@/lib/utils';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
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
} from 'lucide-react';

export default function StaffDetailPage() {
  const params = useParams();
  const router = useRouter();
  const staffId = params.id as string;

  const [staff, setStaff] = useState<User | null>(null);
  const [promotions, setPromotions] = useState<PromotionHistory[]>([]);
  const [reviews, setReviews] = useState<WeeklyReview[]>([]);
  const [workExperiences, setWorkExperiences] = useState<WorkExperience[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchStaffData = async () => {
      try {
        const [staffData, promotionData, reviewData] = await Promise.all([
          api.getStaffById(staffId),
          api.getPromotionHistory(staffId).catch(() => []),
          api.getStaffReviews(staffId).catch(() => ({ reviews: [] })),
        ]);
        setStaff(staffData || null);
        setPromotions(Array.isArray(promotionData) ? promotionData : []);
        const reviewsArray = reviewData?.reviews || [];
        setReviews(Array.isArray(reviewsArray) ? reviewsArray : []);
      } catch (error) {
        console.error('Failed to fetch staff:', error);
        setStaff(null);
        setPromotions([]);
        setReviews([]);
      } finally {
        setIsLoading(false);
      }
    };

    fetchStaffData();
  }, [staffId]);

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
              <p className="text-gray-500">{staff.role_name}</p>
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
              </div>
            </div>
            <div className="flex gap-2">
              <Link href={`/dashboard/staff/${staffId}/edit`}>
                <Button variant="outline">
                  <Edit className="w-4 h-4 mr-2" />
                  Edit
                </Button>
              </Link>
            </div>
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
            <div className="flex items-center gap-3 md:col-span-2">
              <MapPin className="w-5 h-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Address</p>
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
              <p className="text-sm text-gray-500">Date Joined</p>
              <p className="font-medium">
                {staff.date_joined ? formatDate(staff.date_joined) : 'Not provided'}
              </p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Salary</p>
              <p className="font-medium text-primary">
                {staff.current_salary ? formatCurrency(staff.current_salary) : 'Not disclosed'}
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
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <p className="text-sm text-gray-500">Institution</p>
              <p className="font-medium">{staff.institution || 'Not provided'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Course of Study</p>
              <p className="font-medium">{staff.course_of_study || 'Not provided'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Grade</p>
              <p className="font-medium">{staff.grade || 'Not provided'}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Work Experience */}
      {workExperiences.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Briefcase className="w-5 h-5 text-primary" />
              Work Experience
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {workExperiences.map((exp) => (
                <div
                  key={exp.id}
                  className="p-4 bg-gray-50 rounded-xl"
                >
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <h4 className="font-semibold text-gray-900">{exp.position}</h4>
                      <p className="text-sm text-gray-600 mt-1">{exp.company_name}</p>
                      <p className="text-xs text-gray-500 mt-2">
                        {formatDate(exp.start_date)} - {exp.end_date ? formatDate(exp.end_date) : 'Present'}
                      </p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Next of Kin */}
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
            <div className="md:col-span-2">
              <p className="text-sm text-gray-500">Home Address</p>
              <p className="font-medium">{staff.next_of_kin_home_address || 'Not provided'}</p>
            </div>
            <div className="md:col-span-2">
              <p className="text-sm text-gray-500">Work Address</p>
              <p className="font-medium">{staff.next_of_kin_work_address || 'Not provided'}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Guarantors */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Users className="w-5 h-5 text-primary" />
            Guarantors
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-6">
            {/* Guarantor 1 */}
            <div>
              <h4 className="font-semibold text-gray-900 mb-3">Guarantor 1</h4>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <p className="text-sm text-gray-500">Full Name</p>
                  <p className="font-medium">{staff.guarantor1_name || 'Not provided'}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Phone Number</p>
                  <p className="font-medium">{staff.guarantor1_phone || 'Not provided'}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Email</p>
                  <p className="font-medium">{staff.guarantor1_email || 'Not provided'}</p>
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
              </div>
            </div>

            {/* Divider */}
            <div className="border-t border-gray-200" />

            {/* Guarantor 2 */}
            <div>
              <h4 className="font-semibold text-gray-900 mb-3">Guarantor 2</h4>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <p className="text-sm text-gray-500">Full Name</p>
                  <p className="font-medium">{staff.guarantor2_name || 'Not provided'}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Phone Number</p>
                  <p className="font-medium">{staff.guarantor2_phone || 'Not provided'}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Email</p>
                  <p className="font-medium">{staff.guarantor2_email || 'Not provided'}</p>
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
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Promotion History */}
      {promotions.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <TrendingUp className="w-5 h-5 text-primary" />
              Promotion History
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {promotions.map((promo) => (
                <div
                  key={promo.id}
                  className="flex items-start gap-4 p-4 bg-gray-50 rounded-xl"
                >
                  <div className="p-2 bg-green-100 rounded-full">
                    <TrendingUp className="w-4 h-4 text-green-600" />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center justify-between">
                      <p className="font-medium text-gray-900">{promo.type}</p>
                      <span className="text-sm text-gray-500">
                        {formatDate(promo.date)}
                      </span>
                    </div>
                    <p className="text-sm text-gray-600 mt-1">
                      {promo.previous_role} → {promo.new_role}
                    </p>
                    {promo.previous_salary !== promo.new_salary && (
                      <p className="text-sm text-green-600 mt-1">
                        Salary: {formatCurrency(promo.previous_salary)} → {formatCurrency(promo.new_salary)}
                      </p>
                    )}
                    {promo.reason && (
                      <p className="text-sm text-gray-500 mt-2 italic">
                        &quot;{promo.reason}&quot;
                      </p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

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

      {/* Staff Documents */}
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
                    <a
                      href={doc.url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-xs text-primary hover:underline"
                    >
                      View
                    </a>
                  ) : (
                    <span className="text-xs text-gray-400">Not uploaded</span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
