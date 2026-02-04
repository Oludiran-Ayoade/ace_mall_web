'use client';

import { useEffect, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import api from '@/lib/api';
import { User } from '@/types';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { LoadingSpinner, BouncingDots } from '@/components/shared/LoadingSpinner';
import { toast } from '@/components/ui/toaster';
import { ArrowLeft, Star, User as UserIcon, Send } from 'lucide-react';

const ratingLabels = [
  { value: 1, label: 'Poor', color: 'text-red-500' },
  { value: 2, label: 'Below Average', color: 'text-orange-500' },
  { value: 3, label: 'Average', color: 'text-yellow-500' },
  { value: 4, label: 'Good', color: 'text-blue-500' },
  { value: 5, label: 'Excellent', color: 'text-green-500' },
];

export default function SubmitReviewPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const staffId = searchParams.get('staff_id');

  const [staff, setStaff] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [rating, setRating] = useState(0);
  const [hoveredRating, setHoveredRating] = useState(0);
  const [comment, setComment] = useState('');

  useEffect(() => {
    const fetchStaff = async () => {
      if (!staffId) {
        setIsLoading(false);
        return;
      }

      try {
        const staffData = await api.getStaffById(staffId);
        setStaff(staffData.user);
      } catch (error) {
        console.error('Failed to fetch staff:', error);
        toast({ title: 'Failed to load staff details', variant: 'destructive' });
      } finally {
        setIsLoading(false);
      }
    };

    fetchStaff();
  }, [staffId]);

  const handleSubmit = async () => {
    if (!staffId || rating === 0) {
      toast({ title: 'Please select a rating', variant: 'destructive' });
      return;
    }

    setIsSubmitting(true);
    try {
      await api.createReview({
        staff_id: staffId,
        attendance_score: rating,
        punctuality_score: rating,
        performance_score: rating,
        remarks: comment,
      });
      toast({ title: 'Review submitted successfully!', variant: 'success' });
      router.back();
    } catch (error) {
      toast({ title: 'Failed to submit review', variant: 'destructive' });
    } finally {
      setIsSubmitting(false);
    }
  };

  const currentRatingLabel = ratingLabels.find(r => r.value === (hoveredRating || rating));

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (!staffId) {
    return (
      <div className="space-y-6">
        <div className="flex items-center gap-4">
          <button onClick={() => router.back()} className="p-2 hover:bg-gray-100 rounded-lg">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-2xl font-bold text-gray-900">Submit Review</h1>
        </div>
        <Card>
          <CardContent className="py-12 text-center">
            <UserIcon className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No Staff Selected</h3>
            <p className="text-gray-500">Please select a staff member from your team to review</p>
            <Button className="mt-4" onClick={() => router.push('/dashboard/my-team')}>
              Go to My Team
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex items-center gap-4">
        <button onClick={() => router.back()} className="p-2 hover:bg-gray-100 rounded-lg">
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Submit Review</h1>
          <p className="text-gray-500">Weekly performance review</p>
        </div>
      </div>

      {/* Staff Info */}
      {staff && (
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-4">
              <div className="w-16 h-16 bg-primary/10 rounded-full flex items-center justify-center">
                {staff.profile_image_url ? (
                  <img 
                    src={staff.profile_image_url} 
                    alt={staff.full_name} 
                    className="w-16 h-16 rounded-full object-cover"
                  />
                ) : (
                  <span className="text-primary font-semibold text-2xl">
                    {staff.full_name?.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)}
                  </span>
                )}
              </div>
              <div>
                <h2 className="text-xl font-semibold">{staff.full_name}</h2>
                <p className="text-gray-500">{staff.role_name}</p>
                {staff.department_name && (
                  <p className="text-sm text-gray-400">{staff.department_name}</p>
                )}
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Rating */}
      <Card>
        <CardHeader>
          <CardTitle>Performance Rating</CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Star Rating */}
          <div className="flex flex-col items-center">
            <div className="flex gap-2">
              {[1, 2, 3, 4, 5].map((value) => (
                <button
                  key={value}
                  onClick={() => setRating(value)}
                  onMouseEnter={() => setHoveredRating(value)}
                  onMouseLeave={() => setHoveredRating(0)}
                  className="p-1 transition-transform hover:scale-110"
                >
                  <Star
                    className={`w-10 h-10 ${
                      value <= (hoveredRating || rating)
                        ? 'fill-yellow-400 text-yellow-400'
                        : 'text-gray-300'
                    }`}
                  />
                </button>
              ))}
            </div>
            {currentRatingLabel && (
              <p className={`mt-2 font-medium ${currentRatingLabel.color}`}>
                {currentRatingLabel.label}
              </p>
            )}
          </div>

          {/* Comment */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Review Comments
            </label>
            <textarea
              value={comment}
              onChange={(e) => setComment(e.target.value)}
              placeholder="Enter your feedback about this staff member's performance..."
              rows={5}
              className="w-full px-4 py-3 rounded-xl border border-input bg-background resize-none"
            />
          </div>

          {/* Submit Button */}
          <Button 
            className="w-full" 
            size="lg" 
            onClick={handleSubmit}
            disabled={isSubmitting || rating === 0}
          >
            {isSubmitting ? (
              <BouncingDots />
            ) : (
              <>
                <Send className="w-4 h-4 mr-2" />
                Submit Review
              </>
            )}
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}
