'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import api from '@/lib/api';
import { User, Branch, Department, Role, WorkExperience, PromotionHistory } from '@/types';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { toast } from '@/components/ui/toaster';
import { NIGERIAN_STATES, GRADE_OPTIONS } from '@/lib/constants';
import { ArrowLeft, Save, Plus, Trash2, Briefcase } from 'lucide-react';

export default function EditStaffPage() {
  const params = useParams();
  const router = useRouter();
  const staffId = params.id as string;

  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [staff, setStaff] = useState<User | null>(null);

  const [branches, setBranches] = useState<Branch[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [roles, setRoles] = useState<Role[]>([]);
  const [workExperiences, setWorkExperiences] = useState<WorkExperience[]>([]);
  const [promotions, setPromotions] = useState<PromotionHistory[]>([]);

  const [formData, setFormData] = useState({
    full_name: '',
    email: '',
    phone_number: '',
    gender: '',
    date_of_birth: '',
    home_address: '',
    state_of_origin: '',
    marital_status: '',
    employee_id: '',
    role_id: '',
    department_id: '',
    branch_id: '',
    current_salary: '',
    course_of_study: '',
    grade: '',
    institution: '',
    // Next of Kin
    next_of_kin_name: '',
    next_of_kin_relationship: '',
    next_of_kin_phone: '',
    next_of_kin_email: '',
    next_of_kin_home_address: '',
    next_of_kin_work_address: '',
    // Guarantor 1
    guarantor1_name: '',
    guarantor1_phone: '',
    guarantor1_occupation: '',
    guarantor1_relationship: '',
    guarantor1_address: '',
    guarantor1_email: '',
    // Guarantor 2
    guarantor2_name: '',
    guarantor2_phone: '',
    guarantor2_occupation: '',
    guarantor2_relationship: '',
    guarantor2_address: '',
    guarantor2_email: '',
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [staffResponse, branchData, deptData, roleData, promotionData] = await Promise.all([
          api.getStaffById(staffId),
          api.getBranches().catch(() => []),
          api.getDepartments().catch(() => []),
          api.getRoles().catch(() => []),
          api.getPromotionHistory(staffId).catch(() => []),
        ]);

        const staffData = staffResponse.user;
        setStaff(staffData);
        setBranches(Array.isArray(branchData) ? branchData : []);
        setDepartments(Array.isArray(deptData) ? deptData : []);
        setRoles(Array.isArray(roleData) ? roleData : []);

        // Pre-populate form with existing data
        if (staffData) {
          setFormData({
            full_name: staffData.full_name || '',
            email: staffData.email || '',
            phone_number: staffData.phone_number || '',
            gender: staffData.gender || '',
            date_of_birth: staffData.date_of_birth || '',
            home_address: staffData.home_address || '',
            state_of_origin: staffData.state_of_origin || '',
            marital_status: staffData.marital_status || '',
            employee_id: staffData.employee_id || '',
            role_id: staffData.role_id || '',
            department_id: staffData.department_id || '',
            branch_id: staffData.branch_id || '',
            current_salary: staffData.current_salary ? staffData.current_salary.toString() : '',
            course_of_study: staffData.course_of_study || '',
            grade: staffData.grade || '',
            institution: staffData.institution || '',
            // Next of Kin
            next_of_kin_name: staffData.next_of_kin_name || '',
            next_of_kin_relationship: staffData.next_of_kin_relationship || '',
            next_of_kin_phone: staffData.next_of_kin_phone || '',
            next_of_kin_email: staffData.next_of_kin_email || '',
            next_of_kin_home_address: staffData.next_of_kin_home_address || '',
            next_of_kin_work_address: staffData.next_of_kin_work_address || '',
            // Guarantor 1
            guarantor1_name: staffData.guarantor1_name || '',
            guarantor1_phone: staffData.guarantor1_phone || '',
            guarantor1_occupation: staffData.guarantor1_occupation || '',
            guarantor1_relationship: staffData.guarantor1_relationship || '',
            guarantor1_address: staffData.guarantor1_address || '',
            guarantor1_email: staffData.guarantor1_email || '',
            // Guarantor 2
            guarantor2_name: staffData.guarantor2_name || '',
            guarantor2_phone: staffData.guarantor2_phone || '',
            guarantor2_occupation: staffData.guarantor2_occupation || '',
            guarantor2_relationship: staffData.guarantor2_relationship || '',
            guarantor2_address: staffData.guarantor2_address || '',
            guarantor2_email: staffData.guarantor2_email || '',
          });
          
          // Load work experiences
          if (staffData.work_experience && Array.isArray(staffData.work_experience)) {
            setWorkExperiences(staffData.work_experience.map((exp: any) => ({
              id: exp.id || '',
              user_id: staffData.id,
              company_name: exp.company_name || '',
              position: exp.position || '',
              start_date: exp.start_date || '',
              end_date: exp.end_date || '',
            })));
          }
          
          // Load promotion history
          if (promotionData && Array.isArray(promotionData)) {
            setPromotions(promotionData);
          }
        }
      } catch (error) {
        console.error('Failed to fetch data:', error);
        toast({ title: 'Failed to load staff data', variant: 'destructive' });
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, [staffId]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleAddWorkExperience = () => {
    setWorkExperiences(prev => [...prev, {
      id: '',
      user_id: staffId,
      company_name: '',
      position: '',
      start_date: '',
      end_date: '',
    }]);
  };

  const handleWorkExperienceChange = (index: number, field: keyof WorkExperience, value: string) => {
    setWorkExperiences(prev => prev.map((exp, i) => 
      i === index ? { ...exp, [field]: value } : exp
    ));
  };

  const handleDeleteWorkExperience = (index: number) => {
    setWorkExperiences(prev => prev.filter((_, i) => i !== index));
  };

  const handleDeletePromotion = async (promotionId: number) => {
    if (!confirm('Are you sure you want to delete this promotion record?')) return;
    
    try {
      await api.deletePromotion(promotionId);
      setPromotions(prev => prev.filter(p => p.id !== promotionId));
      toast({ title: 'Promotion record deleted', variant: 'success' });
    } catch (error) {
      toast({ 
        title: 'Failed to delete promotion', 
        description: error instanceof Error ? error.message : 'Please try again',
        variant: 'destructive' 
      });
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);

    try {
      const updateData: any = {
        full_name: formData.full_name,
        email: formData.email,
        phone_number: formData.phone_number || undefined,
        gender: formData.gender || undefined,
        date_of_birth: formData.date_of_birth || undefined,
        home_address: formData.home_address || undefined,
        state_of_origin: formData.state_of_origin || undefined,
        marital_status: formData.marital_status || undefined,
        employee_id: formData.employee_id || undefined,
        role_id: formData.role_id,
        department_id: formData.department_id || undefined,
        branch_id: formData.branch_id || undefined,
        current_salary: formData.current_salary ? parseFloat(formData.current_salary) : undefined,
        course_of_study: formData.course_of_study || undefined,
        grade: formData.grade || undefined,
        institution: formData.institution || undefined,
        // Next of Kin
        next_of_kin_name: formData.next_of_kin_name || undefined,
        next_of_kin_relationship: formData.next_of_kin_relationship || undefined,
        next_of_kin_phone: formData.next_of_kin_phone || undefined,
        next_of_kin_email: formData.next_of_kin_email || undefined,
        next_of_kin_home_address: formData.next_of_kin_home_address || undefined,
        next_of_kin_work_address: formData.next_of_kin_work_address || undefined,
        // Guarantor 1
        guarantor1_name: formData.guarantor1_name || undefined,
        guarantor1_phone: formData.guarantor1_phone || undefined,
        guarantor1_occupation: formData.guarantor1_occupation || undefined,
        guarantor1_relationship: formData.guarantor1_relationship || undefined,
        guarantor1_address: formData.guarantor1_address || undefined,
        guarantor1_email: formData.guarantor1_email || undefined,
        // Guarantor 2
        guarantor2_name: formData.guarantor2_name || undefined,
        guarantor2_phone: formData.guarantor2_phone || undefined,
        guarantor2_occupation: formData.guarantor2_occupation || undefined,
        guarantor2_relationship: formData.guarantor2_relationship || undefined,
        guarantor2_address: formData.guarantor2_address || undefined,
        guarantor2_email: formData.guarantor2_email || undefined,
      };

      // Update basic profile
      await api.updateStaffProfile(staffId, updateData);
      
      // Update work experience separately
      const validWorkExperiences = workExperiences.filter(
        exp => exp.company_name.trim() !== '' || exp.position.trim() !== ''
      );
      if (validWorkExperiences.length > 0) {
        await api.updateWorkExperience(staffId, validWorkExperiences);
      }
      toast({ title: 'Staff updated successfully!', variant: 'success' });
      router.push(`/dashboard/staff/${staffId}`);
    } catch (error) {
      toast({
        title: 'Failed to update staff',
        description: error instanceof Error ? error.message : 'Please try again',
        variant: 'destructive',
      });
    } finally {
      setIsSubmitting(false);
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

  return (
    <div className="space-y-6 max-w-4xl mx-auto">
      {/* Header */}
      <div className="flex items-center gap-4">
        <button
          onClick={() => router.back()}
          className="p-2 hover:bg-gray-100 rounded-lg"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Edit Staff Profile</h1>
          <p className="text-gray-500">Update {staff.full_name}'s information</p>
        </div>
      </div>

      <form onSubmit={handleSubmit}>
        {/* Personal Information */}
        <Card className="mb-6">
          <CardContent className="pt-6">
            <h3 className="font-semibold text-lg mb-4">Personal Information</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="text-sm text-gray-500">Full Name *</label>
                <Input
                  name="full_name"
                  value={formData.full_name}
                  onChange={handleChange}
                  required
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Email *</label>
                <Input
                  name="email"
                  type="email"
                  value={formData.email}
                  onChange={handleChange}
                  required
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Phone Number</label>
                <Input
                  name="phone_number"
                  value={formData.phone_number}
                  onChange={handleChange}
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Gender</label>
                <select
                  name="gender"
                  value={formData.gender}
                  onChange={handleChange}
                  className="w-full h-11 mt-1 px-4 rounded-xl border border-input bg-background"
                >
                  <option value="">Select gender</option>
                  <option value="Male">Male</option>
                  <option value="Female">Female</option>
                </select>
              </div>
              <div>
                <label className="text-sm text-gray-500">Date of Birth</label>
                <Input
                  name="date_of_birth"
                  type="date"
                  value={formData.date_of_birth}
                  onChange={handleChange}
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">State of Origin</label>
                <select
                  name="state_of_origin"
                  value={formData.state_of_origin}
                  onChange={handleChange}
                  className="w-full h-11 mt-1 px-4 rounded-xl border border-input bg-background"
                >
                  <option value="">Select state</option>
                  {NIGERIAN_STATES.map((state) => (
                    <option key={state} value={state}>
                      {state}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="text-sm text-gray-500">Marital Status</label>
                <select
                  name="marital_status"
                  value={formData.marital_status}
                  onChange={handleChange}
                  className="w-full h-11 mt-1 px-4 rounded-xl border border-input bg-background"
                >
                  <option value="">Select marital status</option>
                  <option value="Single">Single</option>
                  <option value="Married">Married</option>
                  <option value="Divorced">Divorced</option>
                  <option value="Widowed">Widowed</option>
                </select>
              </div>
              <div>
                <label className="text-sm text-gray-500">Employee ID</label>
                <Input
                  name="employee_id"
                  value={formData.employee_id}
                  onChange={handleChange}
                  className="mt-1"
                />
              </div>
              <div className="md:col-span-2">
                <label className="text-sm text-gray-500">Home Address</label>
                <Input
                  name="home_address"
                  value={formData.home_address}
                  onChange={handleChange}
                  className="mt-1"
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Work Information */}
        <Card className="mb-6">
          <CardContent className="pt-6">
            <h3 className="font-semibold text-lg mb-4">Work Information</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="text-sm text-gray-500">Role *</label>
                <select
                  name="role_id"
                  value={formData.role_id}
                  onChange={handleChange}
                  required
                  className="w-full h-11 mt-1 px-4 rounded-xl border border-input bg-background"
                >
                  <option value="">Select role</option>
                  {roles.map((role) => (
                    <option key={role.id} value={role.id}>
                      {role.name}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="text-sm text-gray-500">Department</label>
                <select
                  name="department_id"
                  value={formData.department_id}
                  onChange={handleChange}
                  className="w-full h-11 mt-1 px-4 rounded-xl border border-input bg-background"
                >
                  <option value="">Select department</option>
                  {departments.map((dept) => (
                    <option key={dept.id} value={dept.id}>
                      {dept.name}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="text-sm text-gray-500">Branch</label>
                <select
                  name="branch_id"
                  value={formData.branch_id}
                  onChange={handleChange}
                  className="w-full h-11 mt-1 px-4 rounded-xl border border-input bg-background"
                >
                  <option value="">Select branch</option>
                  {branches.map((branch) => (
                    <option key={branch.id} value={branch.id}>
                      {branch.name}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="text-sm text-gray-500">Current Salary</label>
                <Input
                  name="current_salary"
                  type="number"
                  value={formData.current_salary}
                  onChange={handleChange}
                  placeholder="Enter salary"
                  className="mt-1"
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Education */}
        <Card className="mb-6">
          <CardContent className="pt-6">
            <h3 className="font-semibold text-lg mb-4">Education</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="text-sm text-gray-500">Course of Study</label>
                <Input
                  name="course_of_study"
                  value={formData.course_of_study}
                  onChange={handleChange}
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Grade</label>
                <select
                  name="grade"
                  value={formData.grade}
                  onChange={handleChange}
                  className="w-full h-11 mt-1 px-4 rounded-xl border border-input bg-background"
                >
                  <option value="">Select grade</option>
                  {GRADE_OPTIONS.map((grade) => (
                    <option key={grade} value={grade}>
                      {grade}
                    </option>
                  ))}
                </select>
              </div>
              <div className="md:col-span-2">
                <label className="text-sm text-gray-500">Institution</label>
                <Input
                  name="institution"
                  value={formData.institution}
                  onChange={handleChange}
                  className="mt-1"
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Next of Kin */}
        <Card className="mb-6">
          <CardContent className="pt-6">
            <h3 className="font-semibold text-lg mb-4">Next of Kin</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="text-sm text-gray-500">Full Name</label>
                <Input
                  name="next_of_kin_name"
                  value={formData.next_of_kin_name}
                  onChange={handleChange}
                  placeholder="Enter next of kin name"
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Relationship</label>
                <Input
                  name="next_of_kin_relationship"
                  value={formData.next_of_kin_relationship}
                  onChange={handleChange}
                  placeholder="e.g., Spouse, Parent, Sibling"
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Phone Number</label>
                <Input
                  name="next_of_kin_phone"
                  value={formData.next_of_kin_phone}
                  onChange={handleChange}
                  placeholder="Enter phone number"
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Email</label>
                <Input
                  name="next_of_kin_email"
                  type="email"
                  value={formData.next_of_kin_email}
                  onChange={handleChange}
                  placeholder="Enter email"
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Home Address</label>
                <Input
                  name="next_of_kin_home_address"
                  value={formData.next_of_kin_home_address}
                  onChange={handleChange}
                  placeholder="Enter home address"
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Work Address</label>
                <Input
                  name="next_of_kin_work_address"
                  value={formData.next_of_kin_work_address}
                  onChange={handleChange}
                  placeholder="Enter work address"
                  className="mt-1"
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Work Experience */}
        <Card className="mb-6">
          <CardContent className="pt-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-semibold text-lg flex items-center gap-2">
                <Briefcase className="w-5 h-5" />
                Work Experience
              </h3>
              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={handleAddWorkExperience}
              >
                <Plus className="w-4 h-4 mr-1" />
                Add Experience
              </Button>
            </div>

            {workExperiences.length === 0 ? (
              <div className="text-center py-8 text-gray-500">
                No work experience added. Click "Add Experience" to add one.
              </div>
            ) : (
              <div className="space-y-4">
                {workExperiences.map((exp, index) => (
                  <div key={index} className="p-4 border border-gray-200 rounded-lg bg-gray-50">
                    <div className="flex items-center justify-between mb-3">
                      <h4 className="font-medium text-sm text-gray-700">Experience #{index + 1}</h4>
                      <Button
                        type="button"
                        variant="ghost"
                        size="sm"
                        onClick={() => handleDeleteWorkExperience(index)}
                        className="text-red-600 hover:text-red-700 hover:bg-red-50"
                      >
                        <Trash2 className="w-4 h-4" />
                      </Button>
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                      <div>
                        <label className="text-sm text-gray-500">Company Name</label>
                        <Input
                          value={exp.company_name}
                          onChange={(e) => handleWorkExperienceChange(index, 'company_name', e.target.value)}
                          placeholder="Enter company name"
                          className="mt-1"
                        />
                      </div>
                      <div>
                        <label className="text-sm text-gray-500">Position</label>
                        <Input
                          value={exp.position}
                          onChange={(e) => handleWorkExperienceChange(index, 'position', e.target.value)}
                          placeholder="Enter position"
                          className="mt-1"
                        />
                      </div>
                      <div>
                        <label className="text-sm text-gray-500">Start Date</label>
                        <Input
                          type="date"
                          value={exp.start_date}
                          onChange={(e) => handleWorkExperienceChange(index, 'start_date', e.target.value)}
                          className="mt-1"
                        />
                      </div>
                      <div>
                        <label className="text-sm text-gray-500">End Date (Leave empty if current)</label>
                        <Input
                          type="date"
                          value={exp.end_date}
                          onChange={(e) => handleWorkExperienceChange(index, 'end_date', e.target.value)}
                          className="mt-1"
                        />
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Promotion History */}
        <Card className="mb-6">
          <CardContent className="pt-6">
            <h3 className="font-semibold text-lg mb-4">Promotion History</h3>
            {promotions.length === 0 ? (
              <div className="text-center py-8 text-gray-500">
                No promotion history. Use the Promote Staff feature to create promotions.
              </div>
            ) : (
              <div className="space-y-3">
                {promotions.map((promo) => (
                  <div key={promo.id} className="p-4 border border-gray-200 rounded-lg bg-gray-50 flex justify-between items-start">
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-2">
                        <span className="text-sm font-medium text-gray-900">
                          {new Date(promo.date).toLocaleDateString()}
                        </span>
                        <span className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded">
                          {promo.previous_role} → {promo.new_role}
                        </span>
                      </div>
                      <div className="text-sm text-gray-600">
                        Salary: ₦{promo.previous_salary?.toLocaleString()} → ₦{promo.new_salary?.toLocaleString()}
                      </div>
                      {(promo.previous_branch || promo.new_branch) && (
                        <div className="text-sm text-gray-600 mt-1">
                          Branch: {promo.previous_branch || 'N/A'} → {promo.new_branch || 'N/A'}
                        </div>
                      )}
                    </div>
                    <Button
                      type="button"
                      variant="ghost"
                      size="sm"
                      onClick={() => handleDeletePromotion(promo.id)}
                      className="text-red-600 hover:text-red-700 hover:bg-red-50"
                    >
                      <Trash2 className="w-4 h-4" />
                    </Button>
                  </div>
                ))}
              </div>
            )}
            <p className="text-xs text-gray-500 mt-4">
              Note: To add new promotions, use the "Promote Staff" feature from the staff profile page.
            </p>
          </CardContent>
        </Card>

        {/* Guarantor 1 */}
        <Card className="mb-6">
          <CardContent className="pt-6">
            <h3 className="font-semibold text-lg mb-4">Guarantor 1</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="text-sm text-gray-500">Full Name</label>
                <Input
                  name="guarantor1_name"
                  value={formData.guarantor1_name}
                  onChange={handleChange}
                  placeholder="Enter guarantor name"
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Phone Number</label>
                <Input
                  name="guarantor1_phone"
                  value={formData.guarantor1_phone}
                  onChange={handleChange}
                  placeholder="Enter phone number"
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Occupation</label>
                <Input
                  name="guarantor1_occupation"
                  value={formData.guarantor1_occupation}
                  onChange={handleChange}
                  placeholder="Enter occupation"
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Relationship</label>
                <Input
                  name="guarantor1_relationship"
                  value={formData.guarantor1_relationship}
                  onChange={handleChange}
                  placeholder="Enter relationship"
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Address</label>
                <Input
                  name="guarantor1_address"
                  value={formData.guarantor1_address}
                  onChange={handleChange}
                  placeholder="Enter address"
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Email</label>
                <Input
                  name="guarantor1_email"
                  type="email"
                  value={formData.guarantor1_email}
                  onChange={handleChange}
                  placeholder="Enter email"
                  className="mt-1"
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Guarantor 2 */}
        <Card className="mb-6">
          <CardContent className="pt-6">
            <h3 className="font-semibold text-lg mb-4">Guarantor 2</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="text-sm text-gray-500">Full Name</label>
                <Input
                  name="guarantor2_name"
                  value={formData.guarantor2_name}
                  onChange={handleChange}
                  placeholder="Enter guarantor name"
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Phone Number</label>
                <Input
                  name="guarantor2_phone"
                  value={formData.guarantor2_phone}
                  onChange={handleChange}
                  placeholder="Enter phone number"
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Occupation</label>
                <Input
                  name="guarantor2_occupation"
                  value={formData.guarantor2_occupation}
                  onChange={handleChange}
                  placeholder="Enter occupation"
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Relationship</label>
                <Input
                  name="guarantor2_relationship"
                  value={formData.guarantor2_relationship}
                  onChange={handleChange}
                  placeholder="Enter relationship"
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Address</label>
                <Input
                  name="guarantor2_address"
                  value={formData.guarantor2_address}
                  onChange={handleChange}
                  placeholder="Enter address"
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Email</label>
                <Input
                  name="guarantor2_email"
                  type="email"
                  value={formData.guarantor2_email}
                  onChange={handleChange}
                  placeholder="Enter email"
                  className="mt-1"
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Action Buttons */}
        <div className="flex gap-4 justify-end">
          <Button
            type="button"
            variant="outline"
            onClick={() => router.back()}
            disabled={isSubmitting}
          >
            Cancel
          </Button>
          <Button type="submit" disabled={isSubmitting}>
            {isSubmitting ? 'Saving...' : (
              <>
                <Save className="w-4 h-4 mr-2" />
                Save Changes
              </>
            )}
          </Button>
        </div>
      </form>
    </div>
  );
}
