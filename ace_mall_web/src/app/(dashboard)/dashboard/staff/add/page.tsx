'use client';

import { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
import api from '@/lib/api';
import { Branch, Department, Role } from '@/types';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { LoadingSpinner, BouncingDots } from '@/components/shared/LoadingSpinner';
import { toast } from '@/components/ui/toaster';
import {
  ArrowLeft,
  ArrowRight,
  User,
  Briefcase,
  GraduationCap,
  FileText,
  Users,
  Check,
  Upload,
  X,
  Plus,
  DollarSign,
  UserCheck,
  Shield,
} from 'lucide-react';

// 9 Steps matching Flutter app exactly
const steps = [
  { id: 1, title: 'Basic Info', icon: User },
  { id: 2, title: 'Education', icon: GraduationCap },
  { id: 3, title: 'Experience', icon: Briefcase },
  { id: 4, title: 'Ace Roles', icon: Briefcase },
  { id: 5, title: 'Salary', icon: DollarSign },
  { id: 6, title: 'Next of Kin', icon: Users },
  { id: 7, title: 'Guarantor 1', icon: UserCheck },
  { id: 8, title: 'Guarantor 2', icon: UserCheck },
  { id: 9, title: 'Documents', icon: FileText },
];

// Document types for staff
const staffDocuments = [
  { key: 'birthCertificate', label: 'Birth Certificate' },
  { key: 'passport', label: 'Passport Photo' },
  { key: 'validId', label: 'Valid ID' },
  { key: 'nyscCertificate', label: 'NYSC Certificate' },
  { key: 'degreeCertificate', label: 'Degree Certificate' },
  { key: 'waecCertificate', label: 'WAEC Certificate' },
  { key: 'stateOfOriginCert', label: 'State of Origin Certificate' },
  { key: 'firstLeavingCert', label: 'First Leaving Certificate' },
];

// Document types for guarantors
const guarantorDocuments = [
  { key: 'Passport', label: 'Passport Photo' },
  { key: 'NationalId', label: 'National ID' },
  { key: 'WorkId', label: 'Work ID' },
];

// Work experience interface
interface WorkExperience {
  company: string;
  roles: string;
  startDate: string;
  endDate: string;
}

// Ace role history interface
interface AceRoleHistory {
  roleId: string;
  roleName: string;
  branchId: string;
  branchName: string;
  startDate: string;
  endDate: string;
}

export default function AddStaffPage() {
  const router = useRouter();
  const [currentStep, setCurrentStep] = useState(1);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const stepsContainerRef = useRef<HTMLDivElement>(null);

  const [branches, setBranches] = useState<Branch[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [roles, setRoles] = useState<Role[]>([]);

  // Work experiences (multiple entries)
  const [workExperiences, setWorkExperiences] = useState<WorkExperience[]>([]);
  const [aceRoleHistory, setAceRoleHistory] = useState<AceRoleHistory[]>([]);

  // Document uploads
  const [documents, setDocuments] = useState<Record<string, File | null>>({});
  const [g1Documents, setG1Documents] = useState<Record<string, File | null>>({});
  const [g2Documents, setG2Documents] = useState<Record<string, File | null>>({});

  const [formData, setFormData] = useState({
    // Step 1: Basic Info
    full_name: '',
    email: '',
    phone_number: '',
    gender: '',
    date_of_birth: '',
    home_address: '',
    state_of_origin: '',
    marital_status: '',
    employee_id: '',
    date_joined: '',
    role_id: '',
    department_id: '',
    branch_id: '',

    // Step 2: Education
    course_of_study: '',
    grade: '',
    institution: '',
    exam_scores: '',

    // Step 5: Salary
    current_salary: '',

    // Step 6: Next of Kin
    nok_name: '',
    nok_relationship: '',
    nok_email: '',
    nok_phone: '',
    nok_home_address: '',
    nok_work_address: '',

    // Step 7: Guarantor 1
    g1_name: '',
    g1_phone: '',
    g1_occupation: '',
    g1_relationship: '',
    g1_sex: '',
    g1_age: '',
    g1_address: '',
    g1_email: '',
    g1_dob: '',
    g1_grade_level: '',

    // Step 8: Guarantor 2
    g2_name: '',
    g2_phone: '',
    g2_occupation: '',
    g2_relationship: '',
    g2_sex: '',
    g2_age: '',
    g2_address: '',
    g2_email: '',
    g2_dob: '',
    g2_grade_level: '',
  });

  // Temp state for adding work experience
  const [tempWorkExp, setTempWorkExp] = useState<WorkExperience>({
    company: '', roles: '', startDate: '', endDate: ''
  });

  // Temp state for adding ace role history
  const [tempAceRole, setTempAceRole] = useState({
    roleId: '', branchId: '', startDate: '', endDate: ''
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [branchData, deptData, roleData] = await Promise.all([
          api.getBranches().catch(() => []),
          api.getDepartments().catch(() => []),
          api.getRoles().catch(() => []),
        ]);
        setBranches(Array.isArray(branchData) ? branchData : []);
        setDepartments(Array.isArray(deptData) ? deptData : []);
        setRoles(Array.isArray(roleData) ? roleData : []);
      } catch (error) {
        console.error('Failed to fetch data:', error);
        setBranches([]);
        setDepartments([]);
        setRoles([]);
        toast({ title: 'Failed to load data', variant: 'destructive' });
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []);

  // Auto-scroll to active step
  useEffect(() => {
    if (stepsContainerRef.current) {
      const activeStep = stepsContainerRef.current.querySelector(`[data-step="${currentStep}"]`);
      if (activeStep) {
        activeStep.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
      }
    }
  }, [currentStep]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleNext = () => {
    if (currentStep < steps.length) {
      setCurrentStep((prev) => prev + 1);
    }
  };

  const handlePrev = () => {
    if (currentStep > 1) {
      setCurrentStep((prev) => prev - 1);
    }
  };

  const handleSubmit = async () => {
    if (!formData.full_name || !formData.email || !formData.role_id) {
      toast({ title: 'Please fill required fields', variant: 'destructive' });
      return;
    }

    setIsSubmitting(true);

    try {
      const staffData = {
        full_name: formData.full_name,
        email: formData.email,
        phone_number: formData.phone_number || undefined,
        gender: formData.gender || undefined,
        date_of_birth: formData.date_of_birth || undefined,
        home_address: formData.home_address || undefined,
        state_of_origin: formData.state_of_origin || undefined,
        marital_status: formData.marital_status || undefined,
        role_id: formData.role_id,
        department_id: formData.department_id || undefined,
        branch_id: formData.branch_id || undefined,
        employee_id: formData.employee_id || undefined,
        current_salary: formData.current_salary ? parseFloat(formData.current_salary) : undefined,
        course_of_study: formData.course_of_study || undefined,
        grade: formData.grade || undefined,
        institution: formData.institution || undefined,
      };

      await api.createStaff(staffData);
      toast({ title: 'Staff created successfully!', variant: 'success' });
      router.push('/dashboard/staff');
    } catch (error) {
      toast({
        title: 'Failed to create staff',
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

  return (
    <div className="space-y-6 max-w-3xl mx-auto">
      {/* Header */}
      <div className="flex items-center gap-4">
        <button
          onClick={() => router.back()}
          className="p-2 hover:bg-gray-100 rounded-lg"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Add New Staff</h1>
          <p className="text-gray-500">Create a new staff account</p>
        </div>
      </div>

      {/* Progress Steps - Auto-scrolling */}
      <div ref={stepsContainerRef} className="overflow-x-auto pb-2 scroll-smooth">
        <div className="flex items-center gap-2 min-w-max">
          {steps.map((step, index) => {
            const Icon = step.icon;
            const isActive = currentStep === step.id;
            const isCompleted = currentStep > step.id;

            return (
              <div key={step.id} data-step={step.id} className="flex items-center flex-shrink-0">
                <div
                  className={`flex items-center justify-center w-10 h-10 rounded-full ${
                    isCompleted
                      ? 'bg-primary text-white'
                      : isActive
                      ? 'bg-primary/20 text-primary border-2 border-primary'
                      : 'bg-gray-100 text-gray-400'
                  }`}
                >
                  {isCompleted ? <Check className="w-5 h-5" /> : <Icon className="w-5 h-5" />}
                </div>
                <span
                  className={`ml-2 text-sm font-medium whitespace-nowrap ${
                    isActive ? 'text-primary' : 'text-gray-500'
                  }`}
                >
                  {step.title}
                </span>
                {index < steps.length - 1 && (
                  <div
                    className={`w-8 h-0.5 mx-2 ${
                      isCompleted ? 'bg-primary' : 'bg-gray-200'
                    }`}
                  />
                )}
              </div>
            );
          })}
        </div>
      </div>

      {/* Form Card */}
      <Card>
        <CardContent className="pt-6">
          {/* Step 1: Basic Info */}
          {currentStep === 1 && (
            <div className="space-y-4">
              <h3 className="font-semibold text-lg mb-4">Basic Information</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="text-sm text-gray-500">Full Name *</label>
                  <Input
                    name="full_name"
                    value={formData.full_name}
                    onChange={handleChange}
                    placeholder="Enter full name"
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
                    placeholder="Enter email"
                    className="mt-1"
                  />
                </div>
                <div>
                  <label className="text-sm text-gray-500">Phone Number</label>
                  <Input
                    name="phone_number"
                    value={formData.phone_number}
                    onChange={handleChange}
                    placeholder="Enter phone number"
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
                  <Input
                    name="state_of_origin"
                    value={formData.state_of_origin}
                    onChange={handleChange}
                    placeholder="Enter state of origin"
                    className="mt-1"
                  />
                </div>
                <div className="md:col-span-2">
                  <label className="text-sm text-gray-500">Home Address</label>
                  <Input
                    name="home_address"
                    value={formData.home_address}
                    onChange={handleChange}
                    placeholder="Enter home address"
                    className="mt-1"
                  />
                </div>
              </div>
            </div>
          )}

          {/* Step 2: Education */}
          {currentStep === 2 && (
            <div className="space-y-4">
              <h3 className="font-semibold text-lg mb-4">Education</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="text-sm text-gray-500">Course of Study</label>
                  <Input name="course_of_study" value={formData.course_of_study} onChange={handleChange} placeholder="Enter course of study" className="mt-1" />
                </div>
                <div>
                  <label className="text-sm text-gray-500">Grade</label>
                  <select name="grade" value={formData.grade} onChange={handleChange} className="w-full h-11 mt-1 px-4 rounded-xl border border-input bg-background">
                    <option value="">Select grade</option>
                    <option value="First Class">First Class</option>
                    <option value="2-1">2:1 (Second Class Upper)</option>
                    <option value="2-2">2:2 (Second Class Lower)</option>
                    <option value="Third Class">Third Class</option>
                    <option value="Pass">Pass</option>
                  </select>
                </div>
                <div>
                  <label className="text-sm text-gray-500">Institution</label>
                  <Input name="institution" value={formData.institution} onChange={handleChange} placeholder="Enter institution" className="mt-1" />
                </div>
                <div>
                  <label className="text-sm text-gray-500">Exam Scores</label>
                  <Input name="exam_scores" value={formData.exam_scores} onChange={handleChange} placeholder="e.g., WAEC, NECO scores" className="mt-1" />
                </div>
              </div>
            </div>
          )}

          {/* Step 3: Work Experience */}
          {currentStep === 3 && (
            <div className="space-y-4">
              <h3 className="font-semibold text-lg mb-4">Work Experience</h3>
              <div className="border rounded-lg p-4 bg-gray-50">
                <h4 className="text-sm font-medium mb-3">Add Previous Employment</h4>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                  <Input placeholder="Company name" value={tempWorkExp.company} onChange={(e) => setTempWorkExp({...tempWorkExp, company: e.target.value})} />
                  <Input placeholder="Roles held" value={tempWorkExp.roles} onChange={(e) => setTempWorkExp({...tempWorkExp, roles: e.target.value})} />
                  <Input type="date" placeholder="Start date" value={tempWorkExp.startDate} onChange={(e) => setTempWorkExp({...tempWorkExp, startDate: e.target.value})} />
                  <Input type="date" placeholder="End date" value={tempWorkExp.endDate} onChange={(e) => setTempWorkExp({...tempWorkExp, endDate: e.target.value})} />
                </div>
                <Button type="button" variant="outline" className="mt-3" onClick={() => {
                  if (tempWorkExp.company && tempWorkExp.roles) {
                    setWorkExperiences([...workExperiences, tempWorkExp]);
                    setTempWorkExp({ company: '', roles: '', startDate: '', endDate: '' });
                  }
                }}>
                  <Plus className="w-4 h-4 mr-2" /> Add Experience
                </Button>
              </div>
              {workExperiences.length > 0 && (
                <div className="space-y-2">
                  <h4 className="text-sm font-medium">Added Experiences</h4>
                  {workExperiences.map((exp, idx) => (
                    <div key={idx} className="flex items-center justify-between p-3 border rounded-lg bg-white">
                      <div>
                        <p className="font-medium">{exp.company}</p>
                        <p className="text-sm text-gray-500">{exp.roles} • {exp.startDate} - {exp.endDate}</p>
                      </div>
                      <Button type="button" variant="ghost" size="sm" onClick={() => setWorkExperiences(workExperiences.filter((_, i) => i !== idx))}>
                        <X className="w-4 h-4 text-red-500" />
                      </Button>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {/* Step 4: Ace Mall Roles History */}
          {currentStep === 4 && (
            <div className="space-y-4">
              <h3 className="font-semibold text-lg mb-4">Ace Mall Roles History</h3>
              <p className="text-sm text-gray-500 mb-4">Add previous roles this staff has held within Ace Mall (if any)</p>
              <div className="border rounded-lg p-4 bg-gray-50">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                  <select value={tempAceRole.roleId} onChange={(e) => setTempAceRole({...tempAceRole, roleId: e.target.value})} className="w-full h-11 px-4 rounded-xl border border-input bg-background">
                    <option value="">Select previous role</option>
                    {roles.map((role) => <option key={role.id} value={role.id}>{role.name}</option>)}
                  </select>
                  <select value={tempAceRole.branchId} onChange={(e) => setTempAceRole({...tempAceRole, branchId: e.target.value})} className="w-full h-11 px-4 rounded-xl border border-input bg-background">
                    <option value="">Select branch</option>
                    {branches.map((b) => <option key={b.id} value={b.id}>{b.name}</option>)}
                  </select>
                  <Input type="date" placeholder="Start date" value={tempAceRole.startDate} onChange={(e) => setTempAceRole({...tempAceRole, startDate: e.target.value})} />
                  <Input type="date" placeholder="End date" value={tempAceRole.endDate} onChange={(e) => setTempAceRole({...tempAceRole, endDate: e.target.value})} />
                </div>
                <Button type="button" variant="outline" className="mt-3" onClick={() => {
                  if (tempAceRole.roleId && tempAceRole.branchId) {
                    const role = roles.find(r => r.id === tempAceRole.roleId);
                    const branch = branches.find(b => b.id === tempAceRole.branchId);
                    setAceRoleHistory([...aceRoleHistory, { ...tempAceRole, roleName: role?.name || '', branchName: branch?.name || '' }]);
                    setTempAceRole({ roleId: '', branchId: '', startDate: '', endDate: '' });
                  }
                }}>
                  <Plus className="w-4 h-4 mr-2" /> Add Role
                </Button>
              </div>
              {aceRoleHistory.length > 0 && (
                <div className="space-y-2">
                  {aceRoleHistory.map((role, idx) => (
                    <div key={idx} className="flex items-center justify-between p-3 border rounded-lg bg-white">
                      <div>
                        <p className="font-medium">{role.roleName}</p>
                        <p className="text-sm text-gray-500">{role.branchName} • {role.startDate} - {role.endDate}</p>
                      </div>
                      <Button type="button" variant="ghost" size="sm" onClick={() => setAceRoleHistory(aceRoleHistory.filter((_, i) => i !== idx))}>
                        <X className="w-4 h-4 text-red-500" />
                      </Button>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {/* Step 5: Salary */}
          {currentStep === 5 && (
            <div className="space-y-4">
              <h3 className="font-semibold text-lg mb-4">Salary Information</h3>
              <div className="grid grid-cols-1 gap-4">
                <div>
                  <label className="text-sm text-gray-500">Role *</label>
                  <select name="role_id" value={formData.role_id} onChange={handleChange} className="w-full h-11 mt-1 px-4 rounded-xl border border-input bg-background">
                    <option value="">Select role</option>
                    {roles.map((role) => <option key={role.id} value={role.id}>{role.name}</option>)}
                  </select>
                </div>
                <div>
                  <label className="text-sm text-gray-500">Department</label>
                  <select name="department_id" value={formData.department_id} onChange={handleChange} className="w-full h-11 mt-1 px-4 rounded-xl border border-input bg-background">
                    <option value="">Select department</option>
                    {departments.map((dept) => <option key={dept.id} value={dept.id}>{dept.name}</option>)}
                  </select>
                </div>
                <div>
                  <label className="text-sm text-gray-500">Branch</label>
                  <select name="branch_id" value={formData.branch_id} onChange={handleChange} className="w-full h-11 mt-1 px-4 rounded-xl border border-input bg-background">
                    <option value="">Select branch</option>
                    {branches.map((branch) => <option key={branch.id} value={branch.id}>{branch.name}</option>)}
                  </select>
                </div>
                <div>
                  <label className="text-sm text-gray-500">Monthly Salary (₦) *</label>
                  <Input name="current_salary" type="number" value={formData.current_salary} onChange={handleChange} placeholder="Enter monthly salary" className="mt-1" />
                </div>
              </div>
            </div>
          )}

          {/* Step 6: Next of Kin */}
          {currentStep === 6 && (
            <div className="space-y-4">
              <h3 className="font-semibold text-lg mb-4">Next of Kin</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div><label className="text-sm text-gray-500">Full Name *</label><Input name="nok_name" value={formData.nok_name} onChange={handleChange} placeholder="Enter full name" className="mt-1" /></div>
                <div><label className="text-sm text-gray-500">Relationship *</label><Input name="nok_relationship" value={formData.nok_relationship} onChange={handleChange} placeholder="e.g., Parent, Spouse" className="mt-1" /></div>
                <div><label className="text-sm text-gray-500">Email</label><Input name="nok_email" type="email" value={formData.nok_email} onChange={handleChange} placeholder="Enter email" className="mt-1" /></div>
                <div><label className="text-sm text-gray-500">Phone *</label><Input name="nok_phone" value={formData.nok_phone} onChange={handleChange} placeholder="Enter phone" className="mt-1" /></div>
                <div><label className="text-sm text-gray-500">Home Address</label><Input name="nok_home_address" value={formData.nok_home_address} onChange={handleChange} placeholder="Enter home address" className="mt-1" /></div>
                <div><label className="text-sm text-gray-500">Work Address</label><Input name="nok_work_address" value={formData.nok_work_address} onChange={handleChange} placeholder="Enter work address" className="mt-1" /></div>
              </div>
            </div>
          )}

          {/* Step 7: Guarantor 1 */}
          {currentStep === 7 && (
            <div className="space-y-4">
              <h3 className="font-semibold text-lg mb-4">Guarantor 1 Details</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div><label className="text-sm text-gray-500">Full Name *</label><Input name="g1_name" value={formData.g1_name} onChange={handleChange} placeholder="Enter full name" className="mt-1" /></div>
                <div><label className="text-sm text-gray-500">Phone *</label><Input name="g1_phone" value={formData.g1_phone} onChange={handleChange} placeholder="Enter phone" className="mt-1" /></div>
                <div><label className="text-sm text-gray-500">Occupation</label><Input name="g1_occupation" value={formData.g1_occupation} onChange={handleChange} placeholder="Enter occupation" className="mt-1" /></div>
                <div><label className="text-sm text-gray-500">Relationship</label><Input name="g1_relationship" value={formData.g1_relationship} onChange={handleChange} placeholder="e.g., Friend, Colleague" className="mt-1" /></div>
                <div>
                  <label className="text-sm text-gray-500">Sex</label>
                  <select name="g1_sex" value={formData.g1_sex} onChange={handleChange} className="w-full h-11 mt-1 px-4 rounded-xl border border-input bg-background">
                    <option value="">Select</option><option value="Male">Male</option><option value="Female">Female</option>
                  </select>
                </div>
                <div><label className="text-sm text-gray-500">Age</label><Input name="g1_age" type="number" value={formData.g1_age} onChange={handleChange} placeholder="Age" className="mt-1" /></div>
                <div className="md:col-span-2"><label className="text-sm text-gray-500">Address</label><Input name="g1_address" value={formData.g1_address} onChange={handleChange} placeholder="Enter address" className="mt-1" /></div>
                <div><label className="text-sm text-gray-500">Email</label><Input name="g1_email" type="email" value={formData.g1_email} onChange={handleChange} placeholder="Enter email" className="mt-1" /></div>
                <div><label className="text-sm text-gray-500">Date of Birth</label><Input name="g1_dob" type="date" value={formData.g1_dob} onChange={handleChange} className="mt-1" /></div>
                <div><label className="text-sm text-gray-500">Grade Level</label><Input name="g1_grade_level" value={formData.g1_grade_level} onChange={handleChange} placeholder="e.g., Level 12" className="mt-1" /></div>
              </div>
              <div className="mt-6">
                <h4 className="text-sm font-medium mb-3">Guarantor 1 Documents</h4>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  {guarantorDocuments.map((doc) => (
                    <div key={doc.key} className="border-2 border-dashed rounded-lg p-4 text-center hover:border-primary transition-colors">
                      <input type="file" id={`g1_${doc.key}`} className="hidden" accept=".pdf,.jpg,.jpeg,.png" onChange={(e) => {
                        if (e.target.files?.[0]) setG1Documents({...g1Documents, [doc.key]: e.target.files[0]});
                      }} />
                      <label htmlFor={`g1_${doc.key}`} className="cursor-pointer">
                        {g1Documents[doc.key] ? (
                          <div className="flex items-center justify-center gap-2 text-green-600">
                            <Check className="w-5 h-5" /><span className="text-sm">{g1Documents[doc.key]?.name}</span>
                          </div>
                        ) : (
                          <div className="flex flex-col items-center gap-2 text-gray-500">
                            <Upload className="w-6 h-6" /><span className="text-sm">{doc.label}</span>
                          </div>
                        )}
                      </label>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* Step 8: Guarantor 2 */}
          {currentStep === 8 && (
            <div className="space-y-4">
              <h3 className="font-semibold text-lg mb-4">Guarantor 2 Details</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div><label className="text-sm text-gray-500">Full Name *</label><Input name="g2_name" value={formData.g2_name} onChange={handleChange} placeholder="Enter full name" className="mt-1" /></div>
                <div><label className="text-sm text-gray-500">Phone *</label><Input name="g2_phone" value={formData.g2_phone} onChange={handleChange} placeholder="Enter phone" className="mt-1" /></div>
                <div><label className="text-sm text-gray-500">Occupation</label><Input name="g2_occupation" value={formData.g2_occupation} onChange={handleChange} placeholder="Enter occupation" className="mt-1" /></div>
                <div><label className="text-sm text-gray-500">Relationship</label><Input name="g2_relationship" value={formData.g2_relationship} onChange={handleChange} placeholder="e.g., Friend, Colleague" className="mt-1" /></div>
                <div>
                  <label className="text-sm text-gray-500">Sex</label>
                  <select name="g2_sex" value={formData.g2_sex} onChange={handleChange} className="w-full h-11 mt-1 px-4 rounded-xl border border-input bg-background">
                    <option value="">Select</option><option value="Male">Male</option><option value="Female">Female</option>
                  </select>
                </div>
                <div><label className="text-sm text-gray-500">Age</label><Input name="g2_age" type="number" value={formData.g2_age} onChange={handleChange} placeholder="Age" className="mt-1" /></div>
                <div className="md:col-span-2"><label className="text-sm text-gray-500">Address</label><Input name="g2_address" value={formData.g2_address} onChange={handleChange} placeholder="Enter address" className="mt-1" /></div>
                <div><label className="text-sm text-gray-500">Email</label><Input name="g2_email" type="email" value={formData.g2_email} onChange={handleChange} placeholder="Enter email" className="mt-1" /></div>
                <div><label className="text-sm text-gray-500">Date of Birth</label><Input name="g2_dob" type="date" value={formData.g2_dob} onChange={handleChange} className="mt-1" /></div>
                <div><label className="text-sm text-gray-500">Grade Level</label><Input name="g2_grade_level" value={formData.g2_grade_level} onChange={handleChange} placeholder="e.g., Level 12" className="mt-1" /></div>
              </div>
              <div className="mt-6">
                <h4 className="text-sm font-medium mb-3">Guarantor 2 Documents</h4>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  {guarantorDocuments.map((doc) => (
                    <div key={doc.key} className="border-2 border-dashed rounded-lg p-4 text-center hover:border-primary transition-colors">
                      <input type="file" id={`g2_${doc.key}`} className="hidden" accept=".pdf,.jpg,.jpeg,.png" onChange={(e) => {
                        if (e.target.files?.[0]) setG2Documents({...g2Documents, [doc.key]: e.target.files[0]});
                      }} />
                      <label htmlFor={`g2_${doc.key}`} className="cursor-pointer">
                        {g2Documents[doc.key] ? (
                          <div className="flex items-center justify-center gap-2 text-green-600">
                            <Check className="w-5 h-5" /><span className="text-sm">{g2Documents[doc.key]?.name}</span>
                          </div>
                        ) : (
                          <div className="flex flex-col items-center gap-2 text-gray-500">
                            <Upload className="w-6 h-6" /><span className="text-sm">{doc.label}</span>
                          </div>
                        )}
                      </label>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* Step 9: Staff Documents */}
          {currentStep === 9 && (
            <div className="space-y-4">
              <h3 className="font-semibold text-lg mb-4">Staff Documents</h3>
              <p className="text-sm text-gray-500 mb-4">Upload required documents (PDF, JPG, JPEG, PNG - Max 5MB each)</p>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {staffDocuments.map((doc) => (
                  <div key={doc.key} className="border-2 border-dashed rounded-lg p-4 hover:border-primary transition-colors">
                    <input type="file" id={doc.key} className="hidden" accept=".pdf,.jpg,.jpeg,.png" onChange={(e) => {
                      if (e.target.files?.[0]) setDocuments({...documents, [doc.key]: e.target.files[0]});
                    }} />
                    <label htmlFor={doc.key} className="cursor-pointer flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <FileText className="w-5 h-5 text-gray-400" />
                        <span className="text-sm">{doc.label}</span>
                      </div>
                      {documents[doc.key] ? (
                        <div className="flex items-center gap-2 text-green-600">
                          <Check className="w-4 h-4" /><span className="text-xs">{documents[doc.key]?.name.substring(0,15)}...</span>
                        </div>
                      ) : (
                        <Upload className="w-5 h-5 text-gray-400" />
                      )}
                    </label>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Navigation Buttons */}
          <div className="flex justify-between mt-8 pt-6 border-t">
            <Button
              variant="outline"
              onClick={handlePrev}
              disabled={currentStep === 1}
            >
              <ArrowLeft className="w-4 h-4 mr-2" />
              Previous
            </Button>

            {currentStep < steps.length ? (
              <Button onClick={handleNext}>
                Next
                <ArrowRight className="w-4 h-4 ml-2" />
              </Button>
            ) : (
              <Button onClick={handleSubmit} disabled={isSubmitting}>
                {isSubmitting ? <BouncingDots /> : 'Create Staff'}
              </Button>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
