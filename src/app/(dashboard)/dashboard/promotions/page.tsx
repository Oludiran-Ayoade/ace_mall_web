'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import api from '@/lib/api';
import { PromotionHistory, User, Branch, Role, Department } from '@/types';
import { formatDate, formatCurrency } from '@/lib/utils';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { LoadingSpinner, BouncingDots } from '@/components/shared/LoadingSpinner';
import { toast } from '@/components/ui/toaster';
import { 
  TrendingUp, Search, Plus, ArrowRight, DollarSign, Users, Calendar, 
  ArrowLeft, Check, Building2, Briefcase, X, ChevronRight 
} from 'lucide-react';

// Promotion Types matching Flutter app
type PromotionType = 'promotion' | 'salary_increase' | 'transfer';

const promotionTypes = [
  { 
    id: 'promotion' as PromotionType, 
    title: 'Promotion', 
    description: 'New role with salary increase', 
    icon: TrendingUp, 
    color: 'bg-green-500' 
  },
  { 
    id: 'salary_increase' as PromotionType, 
    title: 'Salary Increase', 
    description: 'Same role, new salary only', 
    icon: DollarSign, 
    color: 'bg-purple-500' 
  },
  { 
    id: 'transfer' as PromotionType, 
    title: 'Transfer & Promotion', 
    description: 'New branch/department with optional role change', 
    icon: Building2, 
    color: 'bg-blue-500' 
  },
];

export default function PromotionsPage() {
  const router = useRouter();
  const [promotions, setPromotions] = useState<PromotionHistory[]>([]);
  const [staff, setStaff] = useState<User[]>([]);
  const [branches, setBranches] = useState<Branch[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [roles, setRoles] = useState<Role[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [staffSearchQuery, setStaffSearchQuery] = useState('');
  
  // Multi-step wizard state
  const [showWizard, setShowWizard] = useState(false);
  const [currentStep, setCurrentStep] = useState(1);
  const [selectedStaff, setSelectedStaff] = useState<User | null>(null);
  const [selectedType, setSelectedType] = useState<PromotionType | null>(null);
  
  // Hierarchical selection for step 1
  const [selectedBranch, setSelectedBranch] = useState<string>('');
  const [selectedDepartment, setSelectedDepartment] = useState<string>('');
  
  const [formData, setFormData] = useState({
    new_role_id: '',
    new_salary: '',
    new_branch_id: '',
    new_department_id: '',
    reason: '',
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [promotionsData, staffData, branchesData, deptsData, rolesData] = await Promise.all([
          api.getAllPromotions().catch(() => []),
          api.getAllStaff().catch(() => []),
          api.getBranches().catch(() => []),
          api.getDepartments().catch(() => []),
          api.getRoles().catch(() => []),
        ]);
        setPromotions(Array.isArray(promotionsData) ? promotionsData : []);
        setStaff(Array.isArray(staffData) ? staffData : []);
        setBranches(Array.isArray(branchesData) ? branchesData : []);
        setDepartments(Array.isArray(deptsData) ? deptsData : []);
        setRoles(Array.isArray(rolesData) ? rolesData : []);
      } catch (error) {
        console.error('Failed to fetch data:', error);
      } finally {
        setIsLoading(false);
      }
    };
    fetchData();
  }, []);

  const resetWizard = () => {
    setShowWizard(false);
    setCurrentStep(1);
    setSelectedStaff(null);
    setSelectedType(null);
    setSelectedBranch('');
    setSelectedDepartment('');
    setFormData({ new_role_id: '', new_salary: '', new_branch_id: '', new_department_id: '', reason: '' });
    setStaffSearchQuery('');
  };

  const handlePromote = async () => {
    if (!selectedStaff) {
      toast({ title: 'Please select a staff member', variant: 'destructive' });
      return;
    }

    // At least one change must be specified
    const hasChanges = formData.new_role_id || formData.new_salary || 
                       formData.new_branch_id || formData.new_department_id;
    
    if (!hasChanges) {
      toast({ title: 'Please specify at least one change (role, salary, branch, or department)', variant: 'destructive' });
      return;
    }

    setIsSubmitting(true);
    try {
      // Always provide new_salary - use current salary if not changed
      const newSalary = formData.new_salary ? Number(formData.new_salary) : (selectedStaff.current_salary || 0);
      
      await api.promoteStaff({
        staff_id: selectedStaff.id,
        new_role_id: formData.new_role_id || undefined,
        new_salary: newSalary,
        branch_id: formData.new_branch_id || undefined,
        department_id: formData.new_department_id || undefined,
        reason: formData.reason || undefined,
      });
      toast({ title: 'Staff updated successfully!', variant: 'success' });
      resetWizard();
      const updatedPromotions = await api.getAllPromotions();
      setPromotions(Array.isArray(updatedPromotions) ? updatedPromotions : []);
    } catch (error) {
      toast({ title: 'Failed to update staff', variant: 'destructive' });
    } finally {
      setIsSubmitting(false);
    }
  };

  // Filter staff by selected branch and department
  const filteredStaff = staff.filter(s => {
    const matchesBranch = !selectedBranch || s.branch_id === selectedBranch;
    const matchesDept = !selectedDepartment || s.department_id === selectedDepartment;
    const matchesSearch = !staffSearchQuery || 
      s.full_name?.toLowerCase().includes(staffSearchQuery.toLowerCase()) ||
      s.role_name?.toLowerCase().includes(staffSearchQuery.toLowerCase());
    return matchesBranch && matchesDept && matchesSearch;
  });

  const filteredPromotions = Array.isArray(promotions)
    ? promotions.filter((p) => {
        const query = searchQuery.toLowerCase();
        return (
          p.new_role?.toLowerCase().includes(query) ||
          p.previous_role?.toLowerCase().includes(query) ||
          p.reason?.toLowerCase().includes(query)
        );
      })
    : [];

  // Step labels for wizard
  const wizardSteps = ['Select Staff', 'Choose Type', 'Enter Details', 'Review & Confirm'];

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  // Multi-step Wizard UI
  if (showWizard) {
    return (
      <div className="max-w-3xl mx-auto space-y-6">
        {/* Wizard Header */}
        <div className="flex items-center gap-4">
          <button onClick={resetWizard} className="p-2 hover:bg-gray-100 rounded-lg">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Transfer / Promote Staff</h1>
            <p className="text-gray-500">Step {currentStep} of 4: {wizardSteps[currentStep - 1]}</p>
          </div>
        </div>

        {/* Step Indicators */}
        <div className="bg-gradient-to-r from-primary to-green-600 rounded-xl p-6">
          <div className="flex justify-between mb-4">
            {wizardSteps.map((label, idx) => (
              <div key={idx} className="flex flex-col items-center">
                <div className={`w-10 h-10 rounded-full flex items-center justify-center font-semibold ${
                  idx + 1 < currentStep ? 'bg-white text-primary' : 
                  idx + 1 === currentStep ? 'bg-white/20 text-white border-2 border-white' : 
                  'bg-white/10 text-white/50'
                }`}>
                  {idx + 1 < currentStep ? <Check className="w-5 h-5" /> : idx + 1}
                </div>
                <span className="text-xs text-white/80 mt-1 hidden sm:block">{label}</span>
              </div>
            ))}
          </div>
        </div>

        <Card>
          <CardContent className="pt-6">
            {/* Step 1: Select Staff (Hierarchical: Branch -> Department -> Staff) */}
            {currentStep === 1 && (
              <div className="space-y-4">
                <h3 className="font-semibold text-lg">Select Staff Member</h3>
                
                {/* Branch Selection */}
                <div>
                  <label className="text-sm text-gray-500 mb-2 block">1. Select Branch *</label>
                  <select
                    value={selectedBranch}
                    onChange={(e) => {
                      setSelectedBranch(e.target.value);
                      setSelectedDepartment('');
                      setSelectedStaff(null);
                    }}
                    className="w-full h-11 px-4 rounded-xl border border-input bg-background"
                  >
                    <option value="">Choose a branch</option>
                    {branches.map(b => (
                      <option key={b.id} value={b.id}>{b.name}</option>
                    ))}
                  </select>
                </div>

                {/* Department Selection (only show if branch selected) */}
                {selectedBranch && (
                  <div>
                    <label className="text-sm text-gray-500 mb-2 block">2. Select Department *</label>
                    <select
                      value={selectedDepartment}
                      onChange={(e) => {
                        setSelectedDepartment(e.target.value);
                        setSelectedStaff(null);
                      }}
                      className="w-full h-11 px-4 rounded-xl border border-input bg-background"
                    >
                      <option value="">Choose a department</option>
                      {departments.map(d => (
                        <option key={d.id} value={d.id}>{d.name}</option>
                      ))}
                    </select>
                  </div>
                )}

                {/* Staff Selection (only show if department selected) */}
                {selectedBranch && selectedDepartment && (
                  <div>
                    <label className="text-sm text-gray-500 mb-2 block">3. Select Staff Member *</label>
                    <div className="relative mb-3">
                      <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
                      <Input
                        placeholder="Search by name or role..."
                        value={staffSearchQuery}
                        onChange={(e) => setStaffSearchQuery(e.target.value)}
                        className="pl-10"
                      />
                    </div>
                    <div className="max-h-96 overflow-y-auto space-y-2">
                      {filteredStaff.length === 0 ? (
                        <p className="text-center text-gray-500 py-8">No staff found in this branch/department</p>
                      ) : (
                        filteredStaff.map((s) => (
                          <div
                            key={s.id}
                            onClick={() => setSelectedStaff(s)}
                            className={`p-4 border rounded-lg cursor-pointer transition-all ${
                              selectedStaff?.id === s.id ? 'border-primary bg-primary/5' : 'hover:border-gray-300'
                            }`}
                          >
                            <div className="flex items-center justify-between">
                              <div className="flex items-center gap-3">
                                <div className="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center">
                                  <Users className="w-5 h-5 text-gray-500" />
                                </div>
                                <div>
                                  <p className="font-medium">{s.full_name}</p>
                                  <p className="text-sm text-gray-500">{s.role_name}</p>
                                  <p className="text-xs text-gray-400">{formatCurrency(s.current_salary || 0)}</p>
                                </div>
                              </div>
                              {selectedStaff?.id === s.id && <Check className="w-5 h-5 text-primary" />}
                            </div>
                          </div>
                        ))
                      )}
                    </div>
                  </div>
                )}
              </div>
            )}

            {/* Step 2: Choose Promotion Type */}
            {currentStep === 2 && (
              <div className="space-y-4">
                <h3 className="font-semibold text-lg">Choose Action Type</h3>
                {selectedStaff && (
                  <div className="p-4 bg-gray-50 rounded-lg mb-4">
                    <p className="text-sm text-gray-600">Selected: <span className="font-medium">{selectedStaff.full_name}</span></p>
                    <p className="text-sm text-gray-500">Current: {selectedStaff.role_name} • {formatCurrency(selectedStaff.current_salary || 0)}</p>
                  </div>
                )}
                <div className="grid gap-4">
                  {promotionTypes.map((type) => {
                    const Icon = type.icon;
                    return (
                      <div
                        key={type.id}
                        onClick={() => setSelectedType(type.id)}
                        className={`p-4 border rounded-lg cursor-pointer transition-all ${
                          selectedType === type.id ? 'border-primary bg-primary/5' : 'hover:border-gray-300'
                        }`}
                      >
                        <div className="flex items-center gap-4">
                          <div className={`p-3 rounded-xl ${type.color} text-white`}>
                            <Icon className="w-6 h-6" />
                          </div>
                          <div className="flex-1">
                            <p className="font-semibold">{type.title}</p>
                            <p className="text-sm text-gray-500">{type.description}</p>
                          </div>
                          {selectedType === type.id && <Check className="w-5 h-5 text-primary" />}
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            )}

            {/* Step 3: Enter Details */}
            {currentStep === 3 && (
              <div className="space-y-4">
                <h3 className="font-semibold text-lg">
                  {selectedType === 'promotion' && 'Promotion Details'}
                  {selectedType === 'salary_increase' && 'Salary Increase Details'}
                  {selectedType === 'transfer' && 'Transfer Details'}
                </h3>

                {selectedType === 'promotion' && (
                  <div>
                    <label className="text-sm text-gray-500">New Role *</label>
                    <select
                      value={formData.new_role_id}
                      onChange={(e) => setFormData({...formData, new_role_id: e.target.value})}
                      className="w-full h-11 mt-1 px-4 rounded-xl border border-input bg-background"
                    >
                      <option value="">Select new role</option>
                      {roles.map(r => <option key={r.id} value={r.id}>{r.name}</option>)}
                    </select>
                  </div>
                )}

                {selectedType === 'transfer' && (
                  <>
                    <div>
                      <label className="text-sm text-gray-500">New Branch *</label>
                      <select
                        value={formData.new_branch_id}
                        onChange={(e) => setFormData({...formData, new_branch_id: e.target.value})}
                        className="w-full h-11 mt-1 px-4 rounded-xl border border-input bg-background"
                      >
                        <option value="">Select new branch</option>
                        {branches.map(b => <option key={b.id} value={b.id}>{b.name}</option>)}
                      </select>
                    </div>
                    <div>
                      <label className="text-sm text-gray-500">New Department (Optional)</label>
                      <select
                        value={formData.new_department_id}
                        onChange={(e) => setFormData({...formData, new_department_id: e.target.value})}
                        className="w-full h-11 mt-1 px-4 rounded-xl border border-input bg-background"
                      >
                        <option value="">Keep current department</option>
                        {departments.map(d => <option key={d.id} value={d.id}>{d.name}</option>)}
                      </select>
                    </div>
                    <div>
                      <label className="text-sm text-gray-500">New Role (Optional)</label>
                      <select
                        value={formData.new_role_id}
                        onChange={(e) => setFormData({...formData, new_role_id: e.target.value})}
                        className="w-full h-11 mt-1 px-4 rounded-xl border border-input bg-background"
                      >
                        <option value="">Keep current role</option>
                        {roles.map(r => <option key={r.id} value={r.id}>{r.name}</option>)}
                      </select>
                    </div>
                  </>
                )}

                <div>
                  <label className="text-sm text-gray-500">New Salary (₦) *</label>
                  <Input
                    type="number"
                    value={formData.new_salary}
                    onChange={(e) => setFormData({...formData, new_salary: e.target.value})}
                    placeholder="Enter new salary"
                    className="mt-1"
                  />
                  {selectedStaff && (
                    <p className="text-xs text-gray-500 mt-1">Current salary: {formatCurrency(selectedStaff.current_salary || 0)}</p>
                  )}
                </div>

                <div>
                  <label className="text-sm text-gray-500">Reason</label>
                  <textarea
                    value={formData.reason}
                    onChange={(e) => setFormData({...formData, reason: e.target.value})}
                    placeholder="Enter reason for this change..."
                    rows={3}
                    className="w-full mt-1 px-4 py-3 rounded-xl border border-input bg-background"
                  />
                </div>
              </div>
            )}

            {/* Step 4: Review & Confirm */}
            {currentStep === 4 && (
              <div className="space-y-4">
                <h3 className="font-semibold text-lg">Review & Confirm</h3>
                
                <div className="space-y-3">
                  <div className="flex justify-between p-3 bg-gray-50 rounded-lg">
                    <span className="text-gray-500">Staff Member</span>
                    <span className="font-medium">{selectedStaff?.full_name}</span>
                  </div>
                  
                  <div className="flex justify-between p-3 bg-gray-50 rounded-lg">
                    <span className="text-gray-500">Action Type</span>
                    <span className="font-medium capitalize">{selectedType?.replace('_', ' ')}</span>
                  </div>

                  {selectedType === 'promotion' && (
                    <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                      <div>
                        <p className="text-xs text-gray-500">Previous Role</p>
                        <p className="font-medium">{selectedStaff?.role_name}</p>
                      </div>
                      <ArrowRight className="w-5 h-5 text-gray-400" />
                      <div className="text-right">
                        <p className="text-xs text-gray-500">New Role</p>
                        <p className="font-medium text-green-600">{roles.find(r => r.id === formData.new_role_id)?.name}</p>
                      </div>
                    </div>
                  )}

                  {selectedType === 'transfer' && formData.new_branch_id && (
                    <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                      <div>
                        <p className="text-xs text-gray-500">Previous Branch</p>
                        <p className="font-medium">{selectedStaff?.branch_name || 'N/A'}</p>
                      </div>
                      <ArrowRight className="w-5 h-5 text-gray-400" />
                      <div className="text-right">
                        <p className="text-xs text-gray-500">New Branch</p>
                        <p className="font-medium text-blue-600">{branches.find(b => b.id === formData.new_branch_id)?.name}</p>
                      </div>
                    </div>
                  )}

                  <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                    <div>
                      <p className="text-xs text-gray-500">Previous Salary</p>
                      <p className="font-medium">{formatCurrency(selectedStaff?.current_salary || 0)}</p>
                    </div>
                    <ArrowRight className="w-5 h-5 text-gray-400" />
                    <div className="text-right">
                      <p className="text-xs text-gray-500">New Salary</p>
                      <p className="font-medium text-green-600">{formatCurrency(Number(formData.new_salary))}</p>
                    </div>
                  </div>

                  {formData.reason && (
                    <div className="p-3 bg-blue-50 rounded-lg">
                      <p className="text-xs text-gray-500 mb-1">Reason</p>
                      <p className="text-sm">{formData.reason}</p>
                    </div>
                  )}
                </div>
              </div>
            )}

            {/* Navigation Buttons */}
            <div className="flex justify-between mt-8 pt-6 border-t">
              <Button variant="outline" onClick={() => currentStep > 1 ? setCurrentStep(currentStep - 1) : resetWizard()}>
                <ArrowLeft className="w-4 h-4 mr-2" />
                {currentStep === 1 ? 'Cancel' : 'Previous'}
              </Button>

              {currentStep < 4 ? (
                <Button 
                  onClick={() => setCurrentStep(currentStep + 1)}
                  disabled={
                    (currentStep === 1 && !selectedStaff) ||
                    (currentStep === 2 && !selectedType)
                  }
                >
                  Next
                  <ArrowRight className="w-4 h-4 ml-2" />
                </Button>
              ) : (
                <Button onClick={handlePromote} disabled={isSubmitting}>
                  {isSubmitting ? <BouncingDots /> : 'Confirm'}
                </Button>
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Staff Promotions</h1>
          <p className="text-gray-500">Manage staff promotions and transfers</p>
        </div>
        <Button onClick={() => setShowWizard(true)}>
          <Plus className="w-4 h-4 mr-2" />
          New Promotion
        </Button>
      </div>

      <Card>
        <CardContent className="pt-6">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
            <Input
              type="text"
              placeholder="Search promotions..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10"
            />
          </div>
        </CardContent>
      </Card>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-4">
              <div className="p-3 bg-green-100 rounded-xl">
                <TrendingUp className="w-6 h-6 text-green-600" />
              </div>
              <div>
                <p className="text-sm text-gray-500">Total Promotions</p>
                <p className="text-2xl font-bold">{promotions.length}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-4">
              <div className="p-3 bg-blue-100 rounded-xl">
                <Users className="w-6 h-6 text-blue-600" />
              </div>
              <div>
                <p className="text-sm text-gray-500">This Month</p>
                <p className="text-2xl font-bold">
                  {Array.isArray(promotions) ? promotions.filter(p => {
                    const date = new Date(p.date);
                    const now = new Date();
                    return date.getMonth() === now.getMonth() && date.getFullYear() === now.getFullYear();
                  }).length : 0}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-4">
              <div className="p-3 bg-purple-100 rounded-xl">
                <Calendar className="w-6 h-6 text-purple-600" />
              </div>
              <div>
                <p className="text-sm text-gray-500">This Year</p>
                <p className="text-2xl font-bold">
                  {Array.isArray(promotions) ? promotions.filter(p => {
                    const date = new Date(p.date);
                    const now = new Date();
                    return date.getFullYear() === now.getFullYear();
                  }).length : 0}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {filteredPromotions.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <TrendingUp className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              {searchQuery ? 'No matching promotions' : 'No promotions yet'}
            </h3>
            <p className="text-gray-500">
              {searchQuery ? 'Try adjusting your search' : 'Promotion records will appear here'}
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-4">
          {filteredPromotions.map((promotion) => (
            <Card key={promotion.id} className="hover:shadow-md transition-shadow">
              <CardContent className="pt-6">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
                      <TrendingUp className="w-6 h-6 text-green-600" />
                    </div>
                    <div>
                      <p className="text-sm text-gray-500">{formatDate(promotion.date)}</p>
                      <h3 className="font-semibold text-gray-900">{promotion.type}</h3>
                    </div>
                  </div>
                  <span className={`px-3 py-1 rounded-full text-xs font-medium ${
                    promotion.type === 'Promotion' ? 'bg-green-100 text-green-700' :
                    promotion.type === 'Transfer' ? 'bg-blue-100 text-blue-700' :
                    'bg-purple-100 text-purple-700'
                  }`}>
                    {promotion.type}
                  </span>
                </div>

                <div className="space-y-3">
                  <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                    <div>
                      <p className="text-xs text-gray-500">Previous Role</p>
                      <p className="font-medium text-gray-900">{promotion.previous_role}</p>
                    </div>
                    <ArrowRight className="w-5 h-5 text-gray-400" />
                    <div>
                      <p className="text-xs text-gray-500">New Role</p>
                      <p className="font-medium text-gray-900">{promotion.new_role}</p>
                    </div>
                  </div>

                  <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                    <div>
                      <p className="text-xs text-gray-500">Previous Salary</p>
                      <p className="font-medium text-gray-900">{formatCurrency(promotion.previous_salary)}</p>
                    </div>
                    <ArrowRight className="w-5 h-5 text-gray-400" />
                    <div>
                      <p className="text-xs text-gray-500">New Salary</p>
                      <p className="font-medium text-green-600">{formatCurrency(promotion.new_salary)}</p>
                    </div>
                  </div>

                  {promotion.reason && (
                    <div className="p-3 bg-blue-50 rounded-lg">
                      <p className="text-xs text-gray-500 mb-1">Reason</p>
                      <p className="text-sm text-gray-700">{promotion.reason}</p>
                    </div>
                  )}

                  <div className="pt-3 border-t border-gray-200 text-sm text-gray-600">
                    Promoted by: <span className="font-medium">{promotion.promoted_by}</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
