'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import api from '@/lib/api';
import { Department, User, Branch } from '@/types';
import { Card, CardContent } from '@/components/ui/card';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { 
  Layers, 
  ShoppingCart, 
  UtensilsCrossed, 
  Wine, 
  Gamepad2, 
  Shield, 
  Wrench,
  Users,
  Building2,
  ChevronDown,
  ChevronUp
} from 'lucide-react';
import { getInitials } from '@/lib/utils';

const departmentIcons: Record<string, React.ReactNode> = {
  'SuperMarket': <ShoppingCart className="w-6 h-6" />,
  'Eatery': <UtensilsCrossed className="w-6 h-6" />,
  'Lounge': <Wine className="w-6 h-6" />,
  'Fun & Arcade': <Gamepad2 className="w-6 h-6" />,
  'Compliance': <Shield className="w-6 h-6" />,
  'Facility Management': <Wrench className="w-6 h-6" />,
};

const departmentColors: Record<string, string> = {
  'SuperMarket': 'bg-green-100 text-green-600',
  'Eatery': 'bg-orange-100 text-orange-600',
  'Lounge': 'bg-purple-100 text-purple-600',
  'Fun & Arcade': 'bg-pink-100 text-pink-600',
  'Compliance': 'bg-blue-100 text-blue-600',
  'Facility Management': 'bg-gray-100 text-gray-600',
};

const subDepartments = [
  'Cinema',
  'Photo Studio',
  'Saloon',
  'Arcade and Kiddies Park',
  'Casino',
];

export default function DepartmentsPage() {
  const router = useRouter();
  const [departments, setDepartments] = useState<Department[]>([]);
  const [staff, setStaff] = useState<User[]>([]);
  const [branches, setBranches] = useState<Branch[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [expandedDepts, setExpandedDepts] = useState<Set<string>>(new Set());

  useEffect(() => {
    const fetchData = async () => {
      try {
        // Fetch departments (public endpoint)
        const deptData = await api.getDepartments().catch((err) => {
          console.error('Failed to fetch departments:', err);
          return [];
        });
        console.log('Departments loaded:', deptData?.length || 0);
        setDepartments(Array.isArray(deptData) ? deptData : []);

        // Fetch branches (public endpoint)
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
        setDepartments([]);
        setStaff([]);
        setBranches([]);
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []);

  const toggleDept = (deptId: string) => {
    const newExpanded = new Set(expandedDepts);
    if (newExpanded.has(deptId)) {
      newExpanded.delete(deptId);
    } else {
      newExpanded.add(deptId);
    }
    setExpandedDepts(newExpanded);
  };

  const getStaffByDepartment = (deptId: string) => {
    return Array.isArray(staff) ? staff.filter((s) => s.department_id === deptId) : [];
  };

  const groupStaffByBranch = (deptStaff: User[]) => {
    const grouped: Record<string, User[]> = {};
    deptStaff.forEach((s) => {
      const branchName = s.branch_name || 'Head Office';
      if (!grouped[branchName]) {
        grouped[branchName] = [];
      }
      grouped[branchName].push(s);
    });
    return grouped;
  };

  const totalStaff = Array.isArray(staff) ? staff.length : 0;

  const getDepartmentIcon = (name: string) => {
    return departmentIcons[name] || <Layers className="w-6 h-6" />;
  };

  const getDepartmentColor = (name: string) => {
    const colorMap: Record<string, string> = {
      'SuperMarket': 'green',
      'Eatery': 'orange',
      'Lounge': 'purple',
      'Fun & Arcade': 'pink',
      'Compliance': 'blue',
      'Facility Management': 'gray',
    };
    return colorMap[name] || 'gray';
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  // Count group heads
  const groupHeadCount = staff.filter(s => 
    s.role_name?.toLowerCase().includes('group head')
  ).length;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Manage Departments</h1>
        <p className="text-gray-500">Organizational structure</p>
      </div>

      {/* Summary Card */}
      <div className="bg-gradient-to-r from-green-500 to-green-700 rounded-xl p-6 text-white">
        <div className="flex items-center gap-4 mb-6">
          <div className="p-3 bg-white/20 rounded-xl">
            <Layers className="w-7 h-7" />
          </div>
          <div>
            <h2 className="text-xl font-semibold">Department Overview</h2>
            <p className="text-green-100 text-sm">Organizational structure</p>
          </div>
        </div>
        <div className="grid grid-cols-3 gap-4">
          <div className="text-center">
            <Building2 className="w-6 h-6 mx-auto mb-2 text-white/80" />
            <p className="text-2xl font-bold">{departments.length}</p>
            <p className="text-xs text-green-100">Departments</p>
          </div>
          <div className="text-center border-x border-white/20">
            <Users className="w-6 h-6 mx-auto mb-2 text-white/80" />
            <p className="text-2xl font-bold">{totalStaff}</p>
            <p className="text-xs text-green-100">Total Staff</p>
          </div>
          <div className="text-center">
            <Users className="w-6 h-6 mx-auto mb-2 text-white/80" />
            <p className="text-2xl font-bold">{groupHeadCount}</p>
            <p className="text-xs text-green-100">Group Heads</p>
          </div>
        </div>
      </div>

      {/* Expandable Department Cards */}
      <div className="space-y-4">
        {departments.map((dept) => {
          const deptStaff = getStaffByDepartment(dept.id);
          const isExpanded = expandedDepts.has(dept.id);
          const branchGroups = groupStaffByBranch(deptStaff);
          const color = getDepartmentColor(dept.name);
          const colorClasses = {
            green: { bg: 'bg-green-100', text: 'text-green-600', border: 'border-green-200', badge: 'bg-green-200 text-green-700' },
            orange: { bg: 'bg-orange-100', text: 'text-orange-600', border: 'border-orange-200', badge: 'bg-orange-200 text-orange-700' },
            purple: { bg: 'bg-purple-100', text: 'text-purple-600', border: 'border-purple-200', badge: 'bg-purple-200 text-purple-700' },
            pink: { bg: 'bg-pink-100', text: 'text-pink-600', border: 'border-pink-200', badge: 'bg-pink-200 text-pink-700' },
            blue: { bg: 'bg-blue-100', text: 'text-blue-600', border: 'border-blue-200', badge: 'bg-blue-200 text-blue-700' },
            gray: { bg: 'bg-gray-100', text: 'text-gray-600', border: 'border-gray-200', badge: 'bg-gray-200 text-gray-700' },
          };
          const classes = colorClasses[color as keyof typeof colorClasses] || colorClasses.gray;

          return (
            <Card key={dept.id} className="overflow-hidden">
              <div
                className="p-5 cursor-pointer hover:bg-gray-50 transition-colors"
                onClick={() => toggleDept(dept.id)}
              >
                <div className="flex items-center gap-4">
                  <div className={`p-3 ${classes.bg} rounded-xl`}>
                    <div className={classes.text}>
                      {getDepartmentIcon(dept.name)}
                    </div>
                  </div>
                  <div className="flex-1">
                    <h3 className="text-lg font-semibold text-gray-800">{dept.name}</h3>
                    <div className="flex items-center gap-2 mt-2">
                      <span className={`px-3 py-1 rounded-full text-xs font-medium flex items-center gap-1 ${classes.badge}`}>
                        <Users className="w-3 h-3" />
                        {deptStaff.length} Staff
                      </span>
                      <span className="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-medium flex items-center gap-1">
                        <Building2 className="w-3 h-3" />
                        {Object.keys(branchGroups).length} Branches
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

              {isExpanded && deptStaff.length > 0 && (
                <div className="px-5 pb-5 space-y-4 border-t border-gray-100 pt-4">
                  {Object.entries(branchGroups).map(([branchName, branchStaff]) => (
                    <div key={branchName} className="space-y-2">
                      <div className="flex items-center gap-2 px-4 py-2 bg-green-50 rounded-lg border border-green-200">
                        <Building2 className="w-4 h-4 text-green-600" />
                        <span className="font-semibold text-green-700 text-sm flex-1">{branchName}</span>
                        <span className="px-2 py-0.5 bg-green-200 text-green-700 rounded-full text-xs font-medium">
                          {branchStaff.length}
                        </span>
                      </div>
                      <div className="space-y-2 pl-4">
                        {branchStaff.map((member) => (
                          <div
                            key={member.id}
                            onClick={() => router.push(`/dashboard/staff/${member.id}`)}
                            className={`flex items-center gap-3 p-3 bg-white border ${classes.border} rounded-lg hover:shadow-sm transition-all cursor-pointer`}
                          >
                            <div className={`w-10 h-10 rounded-full ${classes.bg} flex items-center justify-center ${classes.text} font-semibold`}>
                              {getInitials(member.full_name)}
                            </div>
                            <div className="flex-1 min-w-0">
                              <p className="font-medium text-gray-900 text-sm">{member.full_name}</p>
                              <p className="text-xs text-gray-500 truncate">{member.role_name}</p>
                              <p className="text-xs text-gray-400">{branchName}</p>
                            </div>
                            <ChevronDown className="w-4 h-4 text-gray-400 -rotate-90" />
                          </div>
                        ))}
                      </div>
                    </div>
                  ))}
                </div>
              )}

              {isExpanded && deptStaff.length === 0 && (
                <div className="px-5 pb-5 text-center text-gray-500 text-sm border-t border-gray-100 pt-4">
                  No staff assigned to this department
                </div>
              )}
            </Card>
          );
        })}
      </div>
    </div>
  );
}
