'use client';

import { useEffect, useState } from 'react';
import api from '@/lib/api';
import { Branch, Department, User } from '@/types';
import { formatCurrency } from '@/lib/utils';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import {
  Building2,
  Users,
  TrendingUp,
  Calendar,
  Download,
  Printer,
  ChevronDown,
  BarChart3,
  UserMinus,
  Layers,
} from 'lucide-react';

interface BranchReport {
  branch: Branch;
  staffCount: number;
  departmentStats: { name: string; count: number }[];
  recentPromotions: number;
  recentTerminations: number;
  activeRosters: number;
}

export default function BranchReportsPage() {
  const [branches, setBranches] = useState<Branch[]>([]);
  const [selectedBranchId, setSelectedBranchId] = useState<string>('');
  const [report, setReport] = useState<BranchReport | null>(null);
  const [staff, setStaff] = useState<User[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isLoadingReport, setIsLoadingReport] = useState(false);

  useEffect(() => {
    const fetchInitialData = async () => {
      try {
        const [branchesData, deptsData] = await Promise.all([
          api.getBranches().catch(() => []),
          api.getDepartments().catch(() => []),
        ]);
        setBranches(Array.isArray(branchesData) ? branchesData : []);
        setDepartments(Array.isArray(deptsData) ? deptsData : []);
      } catch (error) {
        console.error('Failed to fetch data:', error);
      } finally {
        setIsLoading(false);
      }
    };
    fetchInitialData();
  }, []);

  const loadBranchReport = async (branchId: string) => {
    if (!branchId) return;
    
    setIsLoadingReport(true);
    try {
      const branch = branches.find(b => b.id === branchId);
      const allStaff = await api.getAllStaff();
      const branchStaff = Array.isArray(allStaff) 
        ? allStaff.filter((s: User) => s.branch_id === branchId)
        : [];
      
      // Calculate department stats
      const deptStats = departments.map(dept => ({
        name: dept.name,
        count: branchStaff.filter((s: User) => s.department_id === dept.id).length
      })).filter(d => d.count > 0);

      // Get promotions and terminations (mock data for now - would come from API)
      const promotions = await api.getAllPromotions().catch(() => []);
      const terminated = await api.getTerminatedStaff().catch(() => []);
      
      const branchPromotions = Array.isArray(promotions) 
        ? promotions.filter((p: any) => {
            const date = new Date(p.date);
            const thirtyDaysAgo = new Date();
            thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
            return date > thirtyDaysAgo;
          }).length
        : 0;

      const branchTerminations = Array.isArray(terminated)
        ? terminated.filter((t: any) => t.branch_id === branchId).length
        : 0;

      setStaff(branchStaff);
      setReport({
        branch: branch!,
        staffCount: branchStaff.length,
        departmentStats: deptStats,
        recentPromotions: branchPromotions,
        recentTerminations: branchTerminations,
        activeRosters: Math.floor(Math.random() * 5) + 1, // Would come from API
      });
    } catch (error) {
      console.error('Failed to load branch report:', error);
    } finally {
      setIsLoadingReport(false);
    }
  };

  useEffect(() => {
    if (selectedBranchId) {
      loadBranchReport(selectedBranchId);
    }
  }, [selectedBranchId]);

  const handlePrint = () => {
    window.print();
  };

  const handleExport = () => {
    // Simple CSV export
    if (!report) return;
    
    const csvContent = [
      ['Branch Report', report.branch.name],
      [''],
      ['Total Staff', report.staffCount],
      ['Recent Promotions', report.recentPromotions],
      ['Recent Terminations', report.recentTerminations],
      [''],
      ['Department', 'Staff Count'],
      ...report.departmentStats.map(d => [d.name, d.count]),
    ].map(row => row.join(',')).join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `branch-report-${report.branch.name}.csv`;
    a.click();
  };

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
      <div className="flex justify-between items-start">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Branch Reports</h1>
          <p className="text-gray-500">View detailed reports for each branch</p>
        </div>
        {report && (
          <div className="flex gap-2">
            <Button variant="outline" onClick={handlePrint}>
              <Printer className="w-4 h-4 mr-2" />
              Print
            </Button>
            <Button variant="outline" onClick={handleExport}>
              <Download className="w-4 h-4 mr-2" />
              Export
            </Button>
          </div>
        )}
      </div>

      {/* Branch Selector */}
      <Card>
        <CardContent className="pt-6">
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Select Branch
          </label>
          <select
            value={selectedBranchId}
            onChange={(e) => setSelectedBranchId(e.target.value)}
            className="w-full md:w-1/2 h-11 px-4 rounded-xl border border-input bg-background"
          >
            <option value="">Choose a branch...</option>
            {branches.map((branch) => (
              <option key={branch.id} value={branch.id}>
                {branch.name}
              </option>
            ))}
          </select>
        </CardContent>
      </Card>

      {isLoadingReport ? (
        <div className="flex items-center justify-center h-64">
          <LoadingSpinner size="lg" />
        </div>
      ) : report ? (
        <>
          {/* Summary Stats */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-blue-100 rounded-xl">
                    <Users className="w-6 h-6 text-blue-600" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Total Staff</p>
                    <p className="text-2xl font-bold">{report.staffCount}</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-green-100 rounded-xl">
                    <TrendingUp className="w-6 h-6 text-green-600" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Recent Promotions</p>
                    <p className="text-2xl font-bold">{report.recentPromotions}</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-6">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-red-100 rounded-xl">
                    <UserMinus className="w-6 h-6 text-red-600" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Terminations</p>
                    <p className="text-2xl font-bold">{report.recentTerminations}</p>
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
                    <p className="text-sm text-gray-500">Active Rosters</p>
                    <p className="text-2xl font-bold">{report.activeRosters}</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Department Breakdown */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Layers className="w-5 h-5" />
                Staff by Department
              </CardTitle>
            </CardHeader>
            <CardContent>
              {report.departmentStats.length === 0 ? (
                <p className="text-gray-500 text-center py-4">No staff in departments</p>
              ) : (
                <div className="space-y-4">
                  {report.departmentStats.map((dept, idx) => (
                    <div key={idx} className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div className={`w-3 h-3 rounded-full ${
                          ['bg-blue-500', 'bg-green-500', 'bg-purple-500', 'bg-orange-500', 'bg-red-500', 'bg-yellow-500'][idx % 6]
                        }`} />
                        <span className="font-medium">{dept.name}</span>
                      </div>
                      <div className="flex items-center gap-4">
                        <div className="w-32 bg-gray-200 rounded-full h-2">
                          <div 
                            className={`h-2 rounded-full ${
                              ['bg-blue-500', 'bg-green-500', 'bg-purple-500', 'bg-orange-500', 'bg-red-500', 'bg-yellow-500'][idx % 6]
                            }`}
                            style={{ width: `${(dept.count / report.staffCount) * 100}%` }}
                          />
                        </div>
                        <span className="text-sm font-medium w-8 text-right">{dept.count}</span>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>

          {/* Staff List Preview */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Users className="w-5 h-5" />
                Staff in {report.branch.name}
              </CardTitle>
            </CardHeader>
            <CardContent>
              {staff.length === 0 ? (
                <p className="text-gray-500 text-center py-4">No staff found</p>
              ) : (
                <div className="space-y-2 max-h-96 overflow-y-auto">
                  {staff.slice(0, 10).map((s) => (
                    <div key={s.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-primary/10 rounded-full flex items-center justify-center">
                          <span className="text-primary font-semibold text-sm">
                            {s.full_name?.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)}
                          </span>
                        </div>
                        <div>
                          <p className="font-medium">{s.full_name}</p>
                          <p className="text-sm text-gray-500">{s.role_name}</p>
                        </div>
                      </div>
                      <span className="text-sm text-gray-500">{s.department_name}</span>
                    </div>
                  ))}
                  {staff.length > 10 && (
                    <p className="text-center text-sm text-gray-500 pt-2">
                      +{staff.length - 10} more staff members
                    </p>
                  )}
                </div>
              )}
            </CardContent>
          </Card>
        </>
      ) : (
        <Card>
          <CardContent className="py-12 text-center">
            <Building2 className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">Select a Branch</h3>
            <p className="text-gray-500">Choose a branch above to view its detailed report</p>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
