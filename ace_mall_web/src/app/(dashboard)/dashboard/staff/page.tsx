'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useAuth } from '@/contexts/AuthContext';
import api from '@/lib/api';
import { User, Branch, Department } from '@/types';
import { getInitials, formatCurrency, getRoleCategory } from '@/lib/utils';
import { getStaffProfileUrl } from '@/lib/urlEncoder';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import {
  Search,
  UserPlus,
  Building2,
  Layers,
  Users,
} from 'lucide-react';

export default function StaffListPage() {
  const { user: currentUser } = useAuth();
  const [staff, setStaff] = useState<User[]>([]);
  const [branches, setBranches] = useState<Branch[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedBranch, setSelectedBranch] = useState<string>('');
  const [selectedDepartment, setSelectedDepartment] = useState<string>('');
  const [activeTab, setActiveTab] = useState<'branch' | 'department' | 'senior'>('branch');

  const roleCategory = currentUser?.role_name ? getRoleCategory(currentUser.role_name) : 'general';

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [staffData, branchData, deptData] = await Promise.all([
          api.getAllStaff().catch(() => []),
          api.getBranches().catch(() => []),
          api.getDepartments().catch(() => []),
        ]);
        setStaff(Array.isArray(staffData) ? staffData : []);
        setBranches(Array.isArray(branchData) ? branchData : []);
        setDepartments(Array.isArray(deptData) ? deptData : []);
      } catch (error) {
        console.error('Failed to fetch staff:', error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []);

  const filteredStaff = Array.isArray(staff) ? staff.filter((s) => {
    const matchesSearch =
      !searchQuery ||
      s.full_name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      s.email?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (s.employee_id && s.employee_id.toLowerCase().includes(searchQuery.toLowerCase()));

    const matchesBranch = !selectedBranch || s.branch_id === selectedBranch;
    const matchesDepartment = !selectedDepartment || s.department_id === selectedDepartment;

    if (activeTab === 'senior') {
      const seniorRoles = ['CEO', 'COO', 'HR', 'Chairman', 'Auditor', 'Group Head'];
      return matchesSearch && seniorRoles.some((role) => s.role_name?.includes(role));
    }

    return matchesSearch && matchesBranch && matchesDepartment;
  }) : [];

  const groupedByBranch = Array.isArray(branches) ? branches.map((branch) => ({
    ...branch,
    staff: filteredStaff.filter((s) => s.branch_id === branch.id),
  })).filter((b) => b.staff.length > 0) : [];

  const groupedByDepartment = Array.isArray(departments) ? departments.map((dept) => ({
    ...dept,
    staff: filteredStaff.filter((s) => s.department_id === dept.id),
  })).filter((d) => d.staff.length > 0) : [];

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Staff Management</h1>
          <p className="text-gray-500">{staff.length} total staff members</p>
        </div>
        {roleCategory === 'senior_admin' && (
          <Link href="/dashboard/staff/add">
            <Button>
              <UserPlus className="w-4 h-4 mr-2" />
              Add Staff
            </Button>
          </Link>
        )}
      </div>

      {/* Search and Filters */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
              <Input
                placeholder="Search by name, email, or ID..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-9"
              />
            </div>
            <select
              value={selectedBranch}
              onChange={(e) => setSelectedBranch(e.target.value)}
              className="h-11 px-4 rounded-xl border border-input bg-background"
            >
              <option value="">All Branches</option>
              {Array.isArray(branches) && branches.map((b) => (
                <option key={b.id} value={b.id}>
                  {b.name}
                </option>
              ))}
            </select>
            <select
              value={selectedDepartment}
              onChange={(e) => setSelectedDepartment(e.target.value)}
              className="h-11 px-4 rounded-xl border border-input bg-background"
            >
              <option value="">All Departments</option>
              {Array.isArray(departments) && departments.map((d) => (
                <option key={d.id} value={d.id}>
                  {d.name}
                </option>
              ))}
            </select>
          </div>
        </CardContent>
      </Card>

      {/* Tabs */}
      <div className="flex gap-2 border-b border-gray-200">
        <button
          onClick={() => setActiveTab('branch')}
          className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${
            activeTab === 'branch'
              ? 'border-primary text-primary'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          }`}
        >
          <Building2 className="w-4 h-4 inline mr-2" />
          By Branch
        </button>
        <button
          onClick={() => setActiveTab('department')}
          className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${
            activeTab === 'department'
              ? 'border-primary text-primary'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          }`}
        >
          <Layers className="w-4 h-4 inline mr-2" />
          By Department
        </button>
        <button
          onClick={() => setActiveTab('senior')}
          className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${
            activeTab === 'senior'
              ? 'border-primary text-primary'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          }`}
        >
          <Users className="w-4 h-4 inline mr-2" />
          Senior Staff
        </button>
      </div>

      {/* Staff List */}
      {activeTab === 'branch' && (
        <div className="space-y-6">
          {groupedByBranch.map((branch) => (
            <div key={branch.id}>
              <h3 className="text-lg font-semibold text-gray-900 mb-3 flex items-center gap-2">
                <Building2 className="w-5 h-5 text-primary" />
                {branch.name}
                <span className="text-sm font-normal text-gray-500">
                  ({branch.staff.length} staff)
                </span>
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {branch.staff.map((s) => (
                  <StaffCard key={s.id} staff={s} />
                ))}
              </div>
            </div>
          ))}
        </div>
      )}

      {activeTab === 'department' && (
        <div className="space-y-6">
          {groupedByDepartment.map((dept) => (
            <div key={dept.id}>
              <h3 className="text-lg font-semibold text-gray-900 mb-3 flex items-center gap-2">
                <Layers className="w-5 h-5 text-primary" />
                {dept.name}
                <span className="text-sm font-normal text-gray-500">
                  ({dept.staff.length} staff)
                </span>
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {dept.staff.map((s) => (
                  <StaffCard key={s.id} staff={s} />
                ))}
              </div>
            </div>
          ))}
        </div>
      )}

      {activeTab === 'senior' && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filteredStaff.map((s) => (
            <StaffCard key={s.id} staff={s} />
          ))}
        </div>
      )}

      {filteredStaff.length === 0 && (
        <div className="text-center py-12">
          <Users className="w-12 h-12 text-gray-300 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-1">No staff found</h3>
          <p className="text-gray-500">Try adjusting your search or filters</p>
        </div>
      )}
    </div>
  );
}

function StaffCard({ staff }: { staff: User }) {
  return (
    <Link href={getStaffProfileUrl(staff.id)} className="block">
      <Card className="hover:shadow-lg transition-shadow cursor-pointer">
        <CardContent className="pt-6">
          <div className="flex items-start gap-4">
            {staff.profile_image_url ? (
              <img
                src={staff.profile_image_url}
                alt={staff.full_name}
                className="w-12 h-12 rounded-full object-cover"
              />
            ) : (
              <div className="w-12 h-12 rounded-full bg-primary flex items-center justify-center text-white font-semibold">
                {getInitials(staff.full_name)}
              </div>
            )}
            <div className="flex-1 min-w-0">
              <h4 className="font-semibold text-gray-900 truncate">{staff.full_name}</h4>
              <p className="text-sm text-gray-500 truncate">{staff.role_name || 'Staff'}</p>
              <p className="text-xs text-gray-400 truncate">{staff.email}</p>
            </div>
          </div>
          <div className="mt-4 flex items-center justify-between text-xs text-gray-500">
            <span>{staff.department_name || 'No Department'}</span>
            <span>{staff.branch_name || 'No Branch'}</span>
          </div>
          {staff.current_salary && (
            <div className="mt-2 text-sm font-medium text-primary">
              {formatCurrency(staff.current_salary)}
            </div>
          )}
        </CardContent>
      </Card>
    </Link>
  );
}
