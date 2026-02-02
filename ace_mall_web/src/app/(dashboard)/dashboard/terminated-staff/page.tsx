'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import api from '@/lib/api';
import { TerminatedStaff } from '@/types';
import { formatDate } from '@/lib/utils';
import { Card, CardContent } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { UserMinus, Search, Calendar, FileText, Eye, ChevronDown, ChevronUp, XCircle, LogOut, Users as UsersIcon } from 'lucide-react';
import { Button } from '@/components/ui/button';

export default function TerminatedStaffPage() {
  const router = useRouter();
  const [staff, setStaff] = useState<TerminatedStaff[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedType, setSelectedType] = useState<string>('All Types');
  const [expandedDepts, setExpandedDepts] = useState<Set<string>>(new Set());

  const terminationTypes = ['All Types', 'terminated', 'resigned', 'retired', 'contract_ended'];

  const getTypeColor = (type: string) => {
    switch (type) {
      case 'terminated': return 'red';
      case 'resigned': return 'orange';
      case 'retired': return 'blue';
      case 'contract_ended': return 'gray';
      default: return 'gray';
    }
  };

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'terminated': return <XCircle className="w-4 h-4" />;
      case 'resigned': return <LogOut className="w-4 h-4" />;
      case 'retired': return <UsersIcon className="w-4 h-4" />;
      case 'contract_ended': return <Calendar className="w-4 h-4" />;
      default: return <UserMinus className="w-4 h-4" />;
    }
  };

  const toggleDept = (deptName: string) => {
    const newExpanded = new Set(expandedDepts);
    if (newExpanded.has(deptName)) {
      newExpanded.delete(deptName);
    } else {
      newExpanded.add(deptName);
    }
    setExpandedDepts(newExpanded);
  };

  useEffect(() => {
    const fetchTerminatedStaff = async () => {
      try {
        const data = await api.getTerminatedStaff();
        setStaff(Array.isArray(data) ? data : []);
      } catch (error) {
        console.error('Failed to fetch terminated staff:', error);
        setStaff([]);
      } finally {
        setIsLoading(false);
      }
    };

    fetchTerminatedStaff();
  }, []);

  const filteredStaff = Array.isArray(staff)
    ? staff.filter((s) => {
        const query = searchQuery.toLowerCase();
        const matchesSearch = 
          s.full_name?.toLowerCase().includes(query) ||
          s.email?.toLowerCase().includes(query) ||
          s.employee_id?.toLowerCase().includes(query) ||
          s.termination_reason?.toLowerCase().includes(query);
        const matchesType = selectedType === 'All Types' || s.termination_type === selectedType;
        return matchesSearch && matchesType;
      })
    : [];

  const groupByDepartment = (staffList: TerminatedStaff[]) => {
    const grouped: Record<string, TerminatedStaff[]> = {};
    staffList.forEach((s) => {
      const dept = s.department_name || 'No Department';
      if (!grouped[dept]) {
        grouped[dept] = [];
      }
      grouped[dept].push(s);
    });
    return grouped;
  };

  const departmentGroups = groupByDepartment(filteredStaff);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-red-700">Departed Staff Archive</h1>
        <p className="text-gray-500">View departed employee records</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <Card>
          <CardContent className="pt-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">Filter by Type</label>
            <select
              value={selectedType}
              onChange={(e) => setSelectedType(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-transparent"
            >
              {terminationTypes.map((type) => (
                <option key={type} value={type}>
                  {type === 'All Types' ? type : type.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}
                </option>
              ))}
            </select>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">Search</label>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
              <Input
                type="text"
                placeholder="Search by name, email, ID..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-10"
              />
            </div>
          </CardContent>
        </Card>
      </div>

      {filteredStaff.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <UserMinus className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              {searchQuery || selectedType !== 'All Types' ? 'No matching records' : 'No departed staff'}
            </h3>
            <p className="text-gray-500">
              {searchQuery || selectedType !== 'All Types'
                ? 'Try adjusting your filters'
                : 'Departed employee records will appear here'}
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-4">
          {Object.entries(departmentGroups).map(([deptName, deptStaff]) => {
            const isExpanded = expandedDepts.has(deptName);
            return (
              <Card key={deptName} className="overflow-hidden">
                <div
                  className="p-5 cursor-pointer hover:bg-gray-50 transition-colors"
                  onClick={() => toggleDept(deptName)}
                >
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className="p-2 bg-red-100 rounded-lg">
                        <UsersIcon className="w-5 h-5 text-red-600" />
                      </div>
                      <div>
                        <h3 className="text-lg font-semibold text-gray-800">{deptName}</h3>
                        <p className="text-sm text-gray-500">{deptStaff.length} departed staff</p>
                      </div>
                    </div>
                    {isExpanded ? (
                      <ChevronUp className="w-5 h-5 text-gray-400" />
                    ) : (
                      <ChevronDown className="w-5 h-5 text-gray-400" />
                    )}
                  </div>
                </div>

                {isExpanded && (
                  <div className="px-5 pb-5 space-y-3 border-t border-gray-100 pt-4">
                    {deptStaff.map((member) => {
                      const color = getTypeColor(member.termination_type);
                      const colorClasses = {
                        red: 'bg-red-100 text-red-700 border-red-200',
                        orange: 'bg-orange-100 text-orange-700 border-orange-200',
                        blue: 'bg-blue-100 text-blue-700 border-blue-200',
                        gray: 'bg-gray-100 text-gray-700 border-gray-200',
                      };
                      const badgeClass = colorClasses[color as keyof typeof colorClasses] || colorClasses.gray;

                      return (
                        <div
                          key={member.id}
                          className="p-4 bg-white border border-gray-200 rounded-lg hover:shadow-sm transition-all"
                        >
                          <div className="flex items-start justify-between mb-3">
                            <div className="flex items-start gap-3">
                              <div className={`w-10 h-10 rounded-full ${badgeClass.split(' ')[0]} flex items-center justify-center`}>
                                {getTypeIcon(member.termination_type)}
                              </div>
                              <div>
                                <h4 className="font-semibold text-gray-900">{member.full_name}</h4>
                                <p className="text-sm text-gray-500">{member.role_name}</p>
                                <p className="text-xs text-gray-400 mt-1">{member.employee_id}</p>
                              </div>
                            </div>
                            <span className={`px-3 py-1 rounded-full text-xs font-medium flex items-center gap-1 ${badgeClass}`}>
                              {getTypeIcon(member.termination_type)}
                              {member.termination_type.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}
                            </span>
                          </div>
                          <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-sm">
                            <div className="flex items-center gap-2">
                              <Calendar className="w-4 h-4 text-gray-400" />
                              <span className="text-gray-600">
                                {formatDate(member.termination_date)}
                              </span>
                            </div>
                            <div className="flex items-center gap-2">
                              <FileText className="w-4 h-4 text-gray-400" />
                              <span className="text-gray-600">{member.termination_reason}</span>
                            </div>
                          </div>
                          <div className="mt-3 pt-3 border-t border-gray-100">
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => router.push(`/dashboard/staff/${member.user_id}`)}
                              className="w-full"
                            >
                              <Eye className="w-4 h-4 mr-2" />
                              View Full Details
                            </Button>
                          </div>
                        </div>
                      );
                    })}
                  </div>
                )}
              </Card>
            );
          })}
        </div>
      )}

      <div className="text-center text-sm text-gray-500">
        Showing {filteredStaff.length} of {staff.length} terminated staff
      </div>
    </div>
  );
}
