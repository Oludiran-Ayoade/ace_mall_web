'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import api from '@/lib/api';
import { Branch, User } from '@/types';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { Building2, Users, MapPin, Eye, ChevronDown, ChevronUp, User as UserIcon } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { getInitials } from '@/lib/utils';

export default function BranchesPage() {
  const router = useRouter();
  const [branches, setBranches] = useState<Branch[]>([]);
  const [staff, setStaff] = useState<User[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [expandedBranches, setExpandedBranches] = useState<Set<string>>(new Set());

  useEffect(() => {
    const fetchData = async () => {
      try {
        // Fetch branches first (public endpoint)
        const branchData = await api.getBranches().catch((err) => {
          console.error('Failed to fetch branches:', err);
          return [];
        });
        console.log('Branches loaded:', branchData?.length || 0);
        setBranches(Array.isArray(branchData) ? branchData : []);

        // Fetch staff (requires auth)
        const staffData = await api.getAllStaff().catch((err) => {
          console.error('Failed to fetch staff:', err);
          return [];
        });
        console.log('Staff loaded:', staffData?.length || 0);
        setStaff(Array.isArray(staffData) ? staffData : []);
      } catch (error) {
        console.error('Failed to fetch data:', error);
        setBranches([]);
        setStaff([]);
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []);

  const toggleBranch = (branchId: string) => {
    const newExpanded = new Set(expandedBranches);
    if (newExpanded.has(branchId)) {
      newExpanded.delete(branchId);
    } else {
      newExpanded.add(branchId);
    }
    setExpandedBranches(newExpanded);
  };

  const getStaffByBranch = (branchId: string) => {
    return Array.isArray(staff) ? staff.filter((s) => s.branch_id === branchId) : [];
  };

  const groupStaffByDepartment = (branchStaff: User[]) => {
    const grouped: Record<string, User[]> = {};
    branchStaff.forEach((s) => {
      const dept = s.department_name || 'Unassigned';
      if (!grouped[dept]) {
        grouped[dept] = [];
      }
      grouped[dept].push(s);
    });
    return grouped;
  };

  const totalStaff = Array.isArray(staff) ? staff.length : 0;

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
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Branches</h1>
        <p className="text-gray-500">
          {branches.length} branches • {totalStaff} total staff
        </p>
      </div>

      {/* Summary Card with Gradient */}
      <div className="bg-gradient-to-r from-green-500 to-green-700 rounded-xl p-6 text-white">
        <div className="flex items-center gap-4 mb-6">
          <div className="p-3 bg-white/20 rounded-xl">
            <Building2 className="w-7 h-7" />
          </div>
          <div>
            <h2 className="text-xl font-semibold">Branch Overview</h2>
            <p className="text-green-100 text-sm">All locations and staff distribution</p>
          </div>
        </div>
        <div className="grid grid-cols-3 gap-4">
          <div className="text-center">
            <Building2 className="w-6 h-6 mx-auto mb-2 text-white/80" />
            <p className="text-2xl font-bold">{branches.length}</p>
            <p className="text-xs text-green-100">Total Branches</p>
          </div>
          <div className="text-center border-x border-white/20">
            <Users className="w-6 h-6 mx-auto mb-2 text-white/80" />
            <p className="text-2xl font-bold">{totalStaff}</p>
            <p className="text-xs text-green-100">Total Staff</p>
          </div>
          <div className="text-center">
            <Users className="w-6 h-6 mx-auto mb-2 text-white/80" />
            <p className="text-2xl font-bold">
              {branches.length > 0 ? Math.round(totalStaff / branches.length) : 0}
            </p>
            <p className="text-xs text-green-100">Avg Staff/Branch</p>
          </div>
        </div>
      </div>

      {/* Expandable Branch Cards */}
      <div className="space-y-4">
        {branches.map((branch) => {
          const branchStaff = getStaffByBranch(branch.id);
          const isExpanded = expandedBranches.has(branch.id);
          const deptGroups = groupStaffByDepartment(branchStaff);

          return (
            <Card key={branch.id} className="overflow-hidden">
              <div
                className="p-5 cursor-pointer hover:bg-gray-50 transition-colors"
                onClick={() => toggleBranch(branch.id)}
              >
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-green-100 rounded-xl">
                    <Building2 className="w-7 h-7 text-green-600" />
                  </div>
                  <div className="flex-1">
                    <h3 className="text-lg font-semibold text-gray-800">{branch.name}</h3>
                    <p className="text-sm text-gray-500 flex items-center gap-1 mt-1">
                      <MapPin className="w-3 h-3" />
                      {branch.location || 'N/A'}
                    </p>
                    <div className="flex items-center gap-2 mt-2">
                      <span className="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-medium flex items-center gap-1">
                        <Users className="w-3 h-3" />
                        {branchStaff.length} Staff
                      </span>
                    </div>
                  </div>
                  {isExpanded ? (
                    <ChevronUp className="w-5 h-5 text-gray-400" />
                  ) : (
                    <ChevronDown className="w-5 h-5 text-gray-400" />
                  )}
                </div>
              </div>

              {isExpanded && branchStaff.length > 0 && (
                <div className="px-5 pb-5 space-y-4 border-t border-gray-100 pt-4">
                  {Object.entries(deptGroups).map(([deptName, deptStaff]) => (
                    <div key={deptName} className="space-y-2">
                      <div className="flex items-center gap-2 px-4 py-2 bg-purple-50 rounded-lg border border-purple-200">
                        <Users className="w-4 h-4 text-purple-600" />
                        <span className="font-semibold text-purple-700 text-sm flex-1">{deptName}</span>
                        <span className="px-2 py-0.5 bg-purple-200 text-purple-700 rounded-full text-xs font-medium">
                          {deptStaff.length}
                        </span>
                      </div>
                      <div className="space-y-2 pl-4">
                        {deptStaff.map((member) => (
                          <div
                            key={member.id}
                            onClick={() => router.push(`/dashboard/staff/${member.id}`)}
                            className="flex items-center gap-3 p-3 bg-white border border-gray-200 rounded-lg hover:border-green-300 hover:shadow-sm transition-all cursor-pointer"
                          >
                            <div className="w-10 h-10 rounded-full bg-green-100 flex items-center justify-center text-green-700 font-semibold">
                              {getInitials(member.full_name)}
                            </div>
                            <div className="flex-1 min-w-0">
                              <p className="font-medium text-gray-900 text-sm">{member.full_name}</p>
                              <p className="text-xs text-gray-500 truncate">{member.role_name}</p>
                              <p className="text-xs text-gray-400">{deptName}</p>
                            </div>
                            <ChevronDown className="w-4 h-4 text-gray-400 -rotate-90" />
                          </div>
                        ))}
                      </div>
                    </div>
                  ))}
                </div>
              )}

              {isExpanded && branchStaff.length === 0 && (
                <div className="px-5 pb-5 text-center text-gray-500 text-sm border-t border-gray-100 pt-4">
                  No staff assigned to this branch
                </div>
              )}
            </Card>
          );
        })}
      </div>
    </div>
  );
}
