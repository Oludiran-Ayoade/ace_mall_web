'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import api from '@/lib/api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { Download, Filter, Users, FileSpreadsheet } from 'lucide-react';
import * as XLSX from 'xlsx';

interface StaffReportItem {
  id: string;
  full_name: string;
  role_name: string;
  role_category: string;
  date_joined: string | null;
  date_of_birth: string | null;
  gender: string;
  course_of_study: string | null;
  grade: string | null;
  institution: string | null;
  department_name: string | null;
  branch_name: string | null;
  current_salary: number;
  employee_id: string | null;
}

interface Branch {
  id: string;
  name: string;
}

interface Department {
  id: string;
  name: string;
}

interface Role {
  id: string;
  name: string;
}

export default function StaffExportPage() {
  const router = useRouter();
  const [staff, setStaff] = useState<StaffReportItem[]>([]);
  const [branches, setBranches] = useState<Branch[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [roles, setRoles] = useState<Role[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isExporting, setIsExporting] = useState(false);

  // Filter states
  const [filterType, setFilterType] = useState('all');
  const [selectedBranch, setSelectedBranch] = useState('');
  const [selectedDepartment, setSelectedDepartment] = useState('');
  const [selectedRole, setSelectedRole] = useState('');
  const [selectedGender, setSelectedGender] = useState('');
  const [sortBy, setSortBy] = useState('date_joined');

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [branchData, deptData] = await Promise.all([
          api.getBranches(),
          api.getDepartments(),
        ]);
        setBranches(branchData);
        setDepartments(deptData);
      } catch (error) {
        console.error('Failed to fetch filter data:', error);
      }
    };
    fetchData();
  }, []);

  useEffect(() => {
    loadStaffReport();
  }, [filterType, selectedBranch, selectedDepartment, selectedRole, selectedGender, sortBy]);

  const loadStaffReport = async () => {
    setIsLoading(true);
    try {
      const params: Record<string, string> = {
        filter_type: filterType,
        sort_by: sortBy,
      };

      if (filterType === 'branch' && selectedBranch) params.branch_id = selectedBranch;
      if (filterType === 'department' && selectedDepartment) params.department_id = selectedDepartment;
      if (filterType === 'role' && selectedRole) params.role_id = selectedRole;
      if (filterType === 'gender' && selectedGender) params.gender = selectedGender;

      console.log('Fetching staff report with params:', params);
      const response = await api.getStaffReport(params);
      console.log('Staff report response:', response);
      console.log('Staff array:', response.staff);
      console.log('Staff count:', response.staff?.length);
      setStaff(response.staff || []);
    } catch (error) {
      console.error('Failed to fetch staff report:', error);
      setStaff([]);
    } finally {
      setIsLoading(false);
    }
  };

  const formatDate = (dateStr: string | null) => {
    if (!dateStr) return 'N/A';
    const date = new Date(dateStr);
    return date.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
  };

  const exportToExcel = () => {
    setIsExporting(true);
    try {
      const exportData = staff.map((s) => ({
        'Name': s.full_name,
        'Employee ID': s.employee_id || 'N/A',
        'Role/Designation': s.role_name,
        'Date Joined': formatDate(s.date_joined),
        'Date of Birth': formatDate(s.date_of_birth),
        'Gender': s.gender,
        'Course': s.course_of_study || 'N/A',
        'Grade': s.grade || 'N/A',
        'Institution': s.institution || 'N/A',
        'Department': s.department_name || 'N/A',
        'Branch': s.branch_name || 'N/A',
        'Salary': s.current_salary,
      }));

      const worksheet = XLSX.utils.json_to_sheet(exportData);
      const workbook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(workbook, worksheet, 'Staff Report');

      // Auto-size columns
      const maxWidth = exportData.reduce((w, r) => Math.max(w, r.Name.length), 10);
      worksheet['!cols'] = [
        { wch: maxWidth },
        { wch: 15 },
        { wch: 25 },
        { wch: 15 },
        { wch: 15 },
        { wch: 10 },
        { wch: 25 },
        { wch: 10 },
        { wch: 30 },
        { wch: 12 },
        { wch: 20 },
        { wch: 20 },
        { wch: 12 },
      ];

      const fileName = `Staff_Report_${new Date().toISOString().split('T')[0]}.xlsx`;
      XLSX.writeFile(workbook, fileName);
    } catch (error) {
      console.error('Failed to export:', error);
    } finally {
      setIsExporting(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Staff Reports</h1>
          <p className="text-gray-500">Generate and export staff data reports</p>
        </div>
        <Button onClick={exportToExcel} disabled={isExporting || staff.length === 0}>
          {isExporting ? (
            <>
              <LoadingSpinner size="sm" className="mr-2" />
              Exporting...
            </>
          ) : (
            <>
              <Download className="w-4 h-4 mr-2" />
              Export to Excel
            </>
          )}
        </Button>
      </div>

      {/* Filters */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Filter className="w-5 h-5" />
            Filter Options
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-4">
            <div>
              <label className="text-sm font-medium mb-2 block">Filter By</label>
              <select
                value={filterType}
                onChange={(e) => setFilterType(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              >
                <option value="all">All Staff</option>
                <option value="branch">Same Branch</option>
                <option value="department">Same Department</option>
                <option value="role">Similar Roles</option>
                <option value="gender">By Gender</option>
                <option value="senior">Senior Staff Only</option>
              </select>
            </div>

            {filterType === 'branch' && (
              <div>
                <label className="text-sm font-medium mb-2 block">Select Branch</label>
                <select
                  value={selectedBranch}
                  onChange={(e) => setSelectedBranch(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                >
                  <option value="">Choose branch</option>
                  {branches.map((b) => (
                    <option key={b.id} value={b.id}>{b.name}</option>
                  ))}
                </select>
              </div>
            )}

            {filterType === 'department' && (
              <div>
                <label className="text-sm font-medium mb-2 block">Select Department</label>
                <select
                  value={selectedDepartment}
                  onChange={(e) => setSelectedDepartment(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                >
                  <option value="">Choose department</option>
                  {departments.map((d) => (
                    <option key={d.id} value={d.id}>{d.name}</option>
                  ))}
                </select>
              </div>
            )}

            {filterType === 'gender' && (
              <div>
                <label className="text-sm font-medium mb-2 block">Select Gender</label>
                <select
                  value={selectedGender}
                  onChange={(e) => setSelectedGender(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                >
                  <option value="">Choose gender</option>
                  <option value="male">Male</option>
                  <option value="female">Female</option>
                </select>
              </div>
            )}

            <div>
              <label className="text-sm font-medium mb-2 block">Sort By</label>
              <select
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary text-sm"
              >
                <option value="date_joined">Date Joined (Oldest First)</option>
                <option value="name">Name (A-Z)</option>
                <option value="age">Age (Oldest First)</option>
              </select>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Staff Table */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <FileSpreadsheet className="w-5 h-5" />
              Staff Data ({staff.length} records)
            </div>
          </CardTitle>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="flex justify-center py-12">
              <LoadingSpinner size="lg" />
            </div>
          ) : staff.length === 0 ? (
            <div className="text-center py-12 text-gray-500">
              <Users className="w-12 h-12 mx-auto mb-4 text-gray-400" />
              <p>No staff found matching the selected filters</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead className="bg-gray-50 border-b">
                  <tr>
                    <th className="text-left p-3 font-semibold">Name</th>
                    <th className="text-left p-3 font-semibold">Role/Designation</th>
                    <th className="text-left p-3 font-semibold">Date Joined</th>
                    <th className="text-left p-3 font-semibold">Date of Birth</th>
                    <th className="text-left p-3 font-semibold">Gender</th>
                    <th className="text-left p-3 font-semibold">Course</th>
                    <th className="text-left p-3 font-semibold">Grade</th>
                    <th className="text-left p-3 font-semibold">Institution</th>
                    <th className="text-left p-3 font-semibold">Exam Score</th>
                  </tr>
                </thead>
                <tbody className="divide-y">
                  {staff.map((s) => (
                    <tr key={s.id} className="hover:bg-gray-50">
                      <td className="p-3">{s.full_name}</td>
                      <td className="p-3">{s.role_name}</td>
                      <td className="p-3">{formatDate(s.date_joined)}</td>
                      <td className="p-3">{formatDate(s.date_of_birth)}</td>
                      <td className="p-3 capitalize">{s.gender}</td>
                      <td className="p-3">{s.course_of_study || 'N/A'}</td>
                      <td className="p-3">{s.grade || 'N/A'}</td>
                      <td className="p-3">{s.institution || 'N/A'}</td>
                      <td className="p-3">{s.exam_scores || 'N/A'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
