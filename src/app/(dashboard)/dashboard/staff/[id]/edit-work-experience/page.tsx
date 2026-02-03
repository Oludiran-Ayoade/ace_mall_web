'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import api from '@/lib/api';
import { User } from '@/types';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { toast } from '@/components/ui/toaster';
import { ArrowLeft, Plus, X, Briefcase, Save } from 'lucide-react';

interface WorkExperience {
  company_name: string;
  position: string;
  start_date: string;
  end_date: string;
}

export default function EditWorkExperiencePage() {
  const params = useParams();
  const router = useRouter();
  const staffId = params.id as string;

  const [staff, setStaff] = useState<User | null>(null);
  const [workExperiences, setWorkExperiences] = useState<WorkExperience[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await api.getStaffById(staffId);
        setStaff(response.user);
        
        // Load existing work experience
        if (response.user.work_experience && Array.isArray(response.user.work_experience)) {
          setWorkExperiences(response.user.work_experience.map((exp: any) => ({
            company_name: exp.company_name || '',
            position: exp.position || '',
            start_date: exp.start_date || '',
            end_date: exp.end_date || '',
          })));
        } else {
          // Start with one empty entry
          setWorkExperiences([{ company_name: '', position: '', start_date: '', end_date: '' }]);
        }
      } catch (error) {
        toast({ title: 'Failed to load staff data', variant: 'destructive' });
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, [staffId]);

  const addExperience = () => {
    setWorkExperiences([...workExperiences, { company_name: '', position: '', start_date: '', end_date: '' }]);
  };

  const removeExperience = (index: number) => {
    setWorkExperiences(workExperiences.filter((_, i) => i !== index));
  };

  const updateExperience = (index: number, field: keyof WorkExperience, value: string) => {
    const updated = [...workExperiences];
    updated[index][field] = value;
    setWorkExperiences(updated);
  };

  const handleSave = async () => {
    // Filter out empty entries
    const validExperiences = workExperiences.filter(
      exp => exp.company_name.trim() !== '' && exp.position.trim() !== ''
    );

    setIsSaving(true);
    try {
      // Cast to the expected type for the API
      const experiencesForApi = validExperiences.map(exp => ({
        id: '', // Not needed for update
        user_id: staffId,
        company_name: exp.company_name,
        position: exp.position,
        start_date: exp.start_date,
        end_date: exp.end_date,
        created_at: new Date().toISOString(),
      }));
      
      await api.updateWorkExperience(staffId, experiencesForApi as any);
      toast({ title: 'Work experience updated successfully!', variant: 'success' });
      router.push(`/dashboard/staff/${staffId}`);
    } catch (error) {
      toast({ 
        title: 'Failed to update work experience', 
        description: error instanceof Error ? error.message : 'Please try again',
        variant: 'destructive' 
      });
    } finally {
      setIsSaving(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (!staff) {
    return (
      <div className="text-center py-12">
        <h2 className="text-xl font-semibold text-gray-900">Staff not found</h2>
        <Button variant="outline" onClick={() => router.back()} className="mt-4">
          Go Back
        </Button>
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-4xl mx-auto">
      {/* Header */}
      <div className="flex items-center gap-4">
        <button
          onClick={() => router.back()}
          className="p-2 hover:bg-gray-100 rounded-lg"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Edit Work Experience</h1>
          <p className="text-gray-500">{staff.full_name}</p>
        </div>
      </div>

      {/* Work Experience Form */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Briefcase className="w-5 h-5 text-primary" />
            Work Experience (Outside Ace)
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          {workExperiences.map((exp, index) => (
            <div key={index} className="border rounded-lg p-4 bg-gray-50 relative">
              <div className="absolute top-3 right-3">
                {workExperiences.length > 1 && (
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    onClick={() => removeExperience(index)}
                    className="text-red-500 hover:text-red-700 hover:bg-red-50"
                  >
                    <X className="w-4 h-4" />
                  </Button>
                )}
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="text-sm font-medium text-gray-700 mb-1 block">
                    Company Name *
                  </label>
                  <Input
                    value={exp.company_name}
                    onChange={(e) => updateExperience(index, 'company_name', e.target.value)}
                    placeholder="Enter company name"
                  />
                </div>

                <div>
                  <label className="text-sm font-medium text-gray-700 mb-1 block">
                    Position/Role *
                  </label>
                  <Input
                    value={exp.position}
                    onChange={(e) => updateExperience(index, 'position', e.target.value)}
                    placeholder="Enter position held"
                  />
                </div>

                <div>
                  <label className="text-sm font-medium text-gray-700 mb-1 block">
                    Start Date
                  </label>
                  <Input
                    type="date"
                    value={exp.start_date}
                    onChange={(e) => updateExperience(index, 'start_date', e.target.value)}
                  />
                </div>

                <div>
                  <label className="text-sm font-medium text-gray-700 mb-1 block">
                    End Date
                  </label>
                  <Input
                    type="date"
                    value={exp.end_date}
                    onChange={(e) => updateExperience(index, 'end_date', e.target.value)}
                  />
                  <p className="text-xs text-gray-500 mt-1">Leave empty if currently working</p>
                </div>
              </div>
            </div>
          ))}

          <Button
            type="button"
            variant="outline"
            onClick={addExperience}
            className="w-full"
          >
            <Plus className="w-4 h-4 mr-2" />
            Add Another Experience
          </Button>
        </CardContent>
      </Card>

      {/* Action Buttons */}
      <div className="flex justify-end gap-3">
        <Button
          variant="outline"
          onClick={() => router.back()}
          disabled={isSaving}
        >
          Cancel
        </Button>
        <Button
          onClick={handleSave}
          disabled={isSaving}
          className="bg-primary hover:bg-primary/90"
        >
          {isSaving ? (
            <>
              <LoadingSpinner size="sm" className="mr-2" />
              Saving...
            </>
          ) : (
            <>
              <Save className="w-4 h-4 mr-2" />
              Save Changes
            </>
          )}
        </Button>
      </div>
    </div>
  );
}
