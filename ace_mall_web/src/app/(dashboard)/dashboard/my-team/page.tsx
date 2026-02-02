'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import api from '@/lib/api';
import { useAuth } from '@/contexts/AuthContext';
import { User } from '@/types';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { toast } from '@/components/ui/toaster';
import {
  Users,
  Search,
  Star,
  ChevronRight,
  Calendar,
  Clock,
  User as UserIcon,
  Briefcase,
  Building2,
} from 'lucide-react';

export default function MyTeamPage() {
  const router = useRouter();
  const { user } = useAuth();
  const [teamMembers, setTeamMembers] = useState<User[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    const fetchTeamMembers = async () => {
      try {
        // Fetch staff from same department and branch as current user
        const allStaff = await api.getAllStaff();
        
        // Filter to get team members (same department/branch, lower hierarchy)
        const filtered = Array.isArray(allStaff) 
          ? allStaff.filter((s: User) => {
              // If user has department, filter by it
              if (user?.department_id && s.department_id !== user.department_id) return false;
              // If user has branch, filter by it
              if (user?.branch_id && s.branch_id !== user.branch_id) return false;
              // Exclude self
              if (s.id === user?.id) return false;
              return true;
            })
          : [];
        
        setTeamMembers(filtered);
      } catch (error) {
        console.error('Failed to fetch team members:', error);
        toast({ title: 'Failed to load team members', variant: 'destructive' });
      } finally {
        setIsLoading(false);
      }
    };

    if (user) {
      fetchTeamMembers();
    }
  }, [user]);

  const filteredMembers = teamMembers.filter(member =>
    member.full_name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    member.role_name?.toLowerCase().includes(searchQuery.toLowerCase())
  );

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
      <div className="bg-gradient-to-r from-primary to-green-600 rounded-2xl p-6 text-white">
        <div className="flex items-center gap-4">
          <div className="p-3 bg-white/20 rounded-xl">
            <Users className="w-8 h-8" />
          </div>
          <div>
            <h1 className="text-2xl font-bold">My Team</h1>
            <p className="text-white/80">{teamMembers.length} Team Members</p>
          </div>
        </div>
        {user?.department_name && (
          <div className="mt-4 flex gap-4">
            <div className="flex items-center gap-2 text-white/80">
              <Building2 className="w-4 h-4" />
              <span>{user.department_name}</span>
            </div>
            {user?.branch_name && (
              <div className="flex items-center gap-2 text-white/80">
                <Briefcase className="w-4 h-4" />
                <span>{user.branch_name}</span>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Search */}
      <Card>
        <CardContent className="pt-6">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
            <Input
              type="text"
              placeholder="Search team members..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10"
            />
          </div>
        </CardContent>
      </Card>

      {/* Team Members List */}
      {filteredMembers.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <Users className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              {searchQuery ? 'No matching team members' : 'No team members found'}
            </h3>
            <p className="text-gray-500">
              {searchQuery ? 'Try adjusting your search' : 'Team members will appear here'}
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-4">
          {filteredMembers.map((member) => (
            <Card key={member.id} className="hover:shadow-md transition-shadow">
              <CardContent className="pt-6">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center">
                      {member.profile_image_url ? (
                        <img 
                          src={member.profile_image_url} 
                          alt={member.full_name} 
                          className="w-12 h-12 rounded-full object-cover"
                        />
                      ) : (
                        <span className="text-primary font-semibold text-lg">
                          {member.full_name?.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)}
                        </span>
                      )}
                    </div>
                    <div>
                      <h3 className="font-semibold text-gray-900">{member.full_name}</h3>
                      <p className="text-sm text-gray-500">{member.role_name}</p>
                      {member.employee_id && (
                        <p className="text-xs text-gray-400">ID: {member.employee_id}</p>
                      )}
                    </div>
                  </div>
                  
                  <div className="flex items-center gap-2">
                    {/* Review Button */}
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => router.push(`/dashboard/reviews/submit?staff_id=${member.id}`)}
                      className="text-orange-600 border-orange-200 hover:bg-orange-50"
                    >
                      <Star className="w-4 h-4 mr-1" />
                      Review
                    </Button>
                    
                    {/* View Profile */}
                    <Link href={`/dashboard/staff/${member.id}`}>
                      <Button variant="ghost" size="sm">
                        <ChevronRight className="w-5 h-5" />
                      </Button>
                    </Link>
                  </div>
                </div>

                {/* Additional Info */}
                <div className="mt-4 pt-4 border-t flex items-center gap-6 text-sm text-gray-500">
                  {member.phone_number && (
                    <span>{member.phone_number}</span>
                  )}
                  {member.email && (
                    <span>{member.email}</span>
                  )}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      {/* Quick Actions */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <Card className="cursor-pointer hover:shadow-md transition-shadow" onClick={() => router.push('/dashboard/rosters')}>
          <CardContent className="pt-6">
            <div className="flex items-center gap-4">
              <div className="p-3 bg-blue-100 rounded-xl">
                <Calendar className="w-6 h-6 text-blue-600" />
              </div>
              <div>
                <h3 className="font-semibold text-gray-900">Manage Roster</h3>
                <p className="text-sm text-gray-500">Create and edit schedules</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="cursor-pointer hover:shadow-md transition-shadow" onClick={() => router.push('/dashboard/reviews')}>
          <CardContent className="pt-6">
            <div className="flex items-center gap-4">
              <div className="p-3 bg-orange-100 rounded-xl">
                <Star className="w-6 h-6 text-orange-600" />
              </div>
              <div>
                <h3 className="font-semibold text-gray-900">Team Reviews</h3>
                <p className="text-sm text-gray-500">View and submit reviews</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
