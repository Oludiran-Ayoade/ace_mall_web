'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import api from '@/lib/api';
import { User, Role, Branch, Department } from '@/types';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { toast } from '@/components/ui/toaster';
import { ArrowLeft, Plus, X, Building2, Save } from 'lucide-react';

interface RoleHistoryEntry {
  role_id: string;
  department_id: string;
  branch_id: string;
  start_date: string;
  end_date: string;
  promotion_reason: string;
}

export default function EditRoleHistoryPage() {
  const params = useParams();
  const router = useRouter();
  const staffId = params.id as string;

  const [staff, setStaff] = useState<User | null>(null);
  const [roleHistory, setRoleHistory] = useState<RoleHistoryEntry[]>([]);
  const [roles, setRoles] = useState<Role[]>([]);
  const [branches, setBranches] = useState<Branch[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [staffResponse, rolesData, branchesData, departmentsData] = await Promise.all([
          api.getStaffById(staffId),
          api.getRoles(),
          api.getBranches(),
          api.getDepartments(),
        ]);
        
        setStaff(staffResponse.user);
        setRoles(rolesData);
        setBranches(branchesData);
        setDepartments(departmentsData);
        
        // Load existing role history
        if (staffResponse.user.role_history && Array.isArray(staffResponse.user.role_history)) {
          setRoleHistory(staffResponse.user.role_history.map((role: any) => ({
            role_id: role.role_id || '',
            department_id: role.department_id || '',
            branch_id: role.branch_id || '',
            start_date: role.start_date || '',
            end_date: role.end_date || '',
            promotion_reason: role.promotion_reason || '',
          })));
        } else {
          // Start with one empty entry
          setRoleHistory([{
            role_id: '',
            department_id: '',
            branch_id: '',
            start_date: '',
            end_date: '',
            promotion_reason: '',
          }]);
        }
      } catch (error) {
        toast({ title: 'Failed to load data', variant: 'destructive' });
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, [staffId]);

  const addRole = () => {
    setRoleHistory([...roleHistory, {
      role_id: '',
      department_id: '',
      branch_id: '',
      start_date: '',
      end_date: '',
      promotion_reason: '',
    }]);
  };

  const removeRole = (index: number) => {
    setRoleHistory(roleHistory.filter((_, i) => i !== index));
  };

  const updateRole = (index: number, field: keyof RoleHistoryEntry, value: string) => {
    const updated = [...roleHistory];
    updated[index][field] = value;
    setRoleHistory(updated);
  };

  const handleSave = async () => {
    // Filter out empty entries
    const validRoles = roleHistory.filter(
      role => role.role_id.trim() !== '' && role.start_date.trim() !== ''
    );

    setIsSaving(true);
    try {
      await api.updateRoleHistory(staffId, validRoles);
      toast({ title: 'Role history updated successfully!', variant: 'success' });
      router.push(`/dashboard/staff/${staffId}`);
    } catch (error) {
      toast({ title: 'Failed to update role history', variant: 'destructive' });
    } finally {
      setIsSaving(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <LoadingSpinner />
      </div>
    );
  }

  if (!staff) {
    return (
      <div className="p-8 text-center">
        <p className="text-gray-500">Staff member not found</p>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-6xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex items-center gap-4">
        <Button
          variant="ghost"
          onClick={() => router.push(`/dashboard/staff/${staffId}`)}
          className="flex items-center gap-2"
        >
          <ArrowLeft className="w-4 h-4" />
          Back to Profile
        </Button>
      </div>

      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="flex items-center gap-2">
                <Building2 className="w-6 h-6 text-primary" />
                Edit Role History - {staff.full_name}
              </CardTitle>
              <p className="text-sm text-gray-500 mt-1">
                Add or update roles held at Ace Mall
              </p>
            </div>
            <Button
              onClick={handleSave}
              disabled={isSaving}
              className="bg-green-600 hover:bg-green-700 text-white font-bold px-8 py-3 shadow-lg"
            >
              <Save className="w-5 h-5 mr-2" />
              {isSaving ? 'SAVING...' : 'SAVE CHANGES'}
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          <div className="space-y-6">
            {roleHistory.map((role, index) => (
              <div key={index} className="p-6 border border-gray-200 rounded-xl bg-gray-50">
                <div className="flex items-start justify-between mb-4">
                  <h3 className="text-lg font-semibold text-gray-900">
                    Role #{index + 1}
                  </h3>
                  {roleHistory.length > 1 && (
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => removeRole(index)}
                      className="text-red-600 hover:text-red-700 hover:bg-red-50"
                    >
                      <X className="w-4 h-4" />
                    </Button>
                  )}
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {/* Role Selection */}
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Role <span className="text-red-500">*</span>
                    </label>
                    <select
                      value={role.role_id}
                      onChange={(e) => updateRole(index, 'role_id', e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                    >
                      <option value="">Select Role</option>
                      {roles.map((r) => (
                        <option key={r.id} value={r.id}>
                          {r.name}
                        </option>
                      ))}
                    </select>
                  </div>

                  {/* Department Selection */}
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Department
                    </label>
                    <select
                      value={role.department_id}
                      onChange={(e) => updateRole(index, 'department_id', e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                    >
                      <option value="">Select Department</option>
                      {departments.map((d) => (
                        <option key={d.id} value={d.id}>
                          {d.name}
                        </option>
                      ))}
                    </select>
                  </div>

                  {/* Branch Selection */}
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Branch
                    </label>
                    <select
                      value={role.branch_id}
                      onChange={(e) => updateRole(index, 'branch_id', e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                    >
                      <option value="">Select Branch</option>
                      {branches.map((b) => (
                        <option key={b.id} value={b.id}>
                          {b.name}
                        </option>
                      ))}
                    </select>
                  </div>

                  {/* Start Date */}
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Start Date <span className="text-red-500">*</span>
                    </label>
                    <Input
                      type="date"
                      value={role.start_date}
                      onChange={(e) => updateRole(index, 'start_date', e.target.value)}
                      className="w-full"
                    />
                  </div>

                  {/* End Date */}
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      End Date <span className="text-sm text-gray-500">(Leave empty if current)</span>
                    </label>
                    <Input
                      type="date"
                      value={role.end_date}
                      onChange={(e) => updateRole(index, 'end_date', e.target.value)}
                      className="w-full"
                    />
                  </div>

                  {/* Promotion Reason */}
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Reason for Role Change
                    </label>
                    <Input
                      type="text"
                      value={role.promotion_reason}
                      onChange={(e) => updateRole(index, 'promotion_reason', e.target.value)}
                      placeholder="e.g., Promotion, Transfer, Initial Hire"
                      className="w-full"
                    />
                  </div>
                </div>
              </div>
            ))}

            {/* Add More Button */}
            <Button
              onClick={addRole}
              variant="outline"
              className="w-full border-dashed border-2 border-gray-300 hover:border-primary hover:bg-primary/5"
            >
              <Plus className="w-5 h-5 mr-2" />
              Add Another Role
            </Button>
          </div>

          {/* Action Buttons */}
          <div className="flex items-center justify-end gap-4 mt-8 pt-6 border-t">
            <Button
              variant="outline"
              onClick={() => router.push(`/dashboard/staff/${staffId}`)}
              disabled={isSaving}
            >
              Cancel
            </Button>
            <Button
              onClick={handleSave}
              disabled={isSaving}
              className="bg-green-600 hover:bg-green-700 text-white font-bold px-8"
            >
              <Save className="w-5 h-5 mr-2" />
              {isSaving ? 'SAVING...' : 'SAVE CHANGES'}
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
