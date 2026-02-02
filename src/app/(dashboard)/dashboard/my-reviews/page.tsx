'use client';

import { useEffect, useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import api from '@/lib/api';
import { WeeklyReview } from '@/types';
import { formatDate } from '@/lib/utils';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { Star, Calendar, User, MessageSquare, TrendingUp, Award } from 'lucide-react';

export default function MyReviewsPage() {
  const { user } = useAuth();
  const [reviews, setReviews] = useState<WeeklyReview[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchReviews = async () => {
      try {
        const data = await api.getMyReviews();
        setReviews(Array.isArray(data) ? data : []);
      } catch (error) {
        console.error('Failed to fetch reviews:', error);
        setReviews([]);
      } finally {
        setIsLoading(false);
      }
    };

    fetchReviews();
  }, []);

  const averageRating = Array.isArray(reviews) && reviews.length > 0
    ? (reviews.reduce((sum, r) => sum + (r.rating || 0), 0) / reviews.length).toFixed(1)
    : '0.0';

  const totalReviews = Array.isArray(reviews) ? reviews.length : 0;

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
        <h1 className="text-2xl font-bold text-gray-900">My Reviews</h1>
        <p className="text-gray-500">View your performance feedback</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-4">
              <div className="p-3 bg-yellow-100 rounded-xl">
                <Star className="w-6 h-6 text-yellow-600" />
              </div>
              <div>
                <p className="text-sm text-gray-500">Average Rating</p>
                <p className="text-2xl font-bold">{averageRating}</p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-4">
              <div className="p-3 bg-blue-100 rounded-xl">
                <MessageSquare className="w-6 h-6 text-blue-600" />
              </div>
              <div>
                <p className="text-sm text-gray-500">Total Reviews</p>
                <p className="text-2xl font-bold">{totalReviews}</p>
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
                <p className="text-sm text-gray-500">Performance</p>
                <p className="text-2xl font-bold">
                  {parseFloat(averageRating) >= 4 ? 'Excellent' : 
                   parseFloat(averageRating) >= 3 ? 'Good' : 
                   parseFloat(averageRating) >= 2 ? 'Average' : 'Needs Work'}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Reviews List */}
      {reviews.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <Award className="w-12 h-12 text-gray-300 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-1">No reviews yet</h3>
            <p className="text-gray-500">
              Your performance reviews will appear here once submitted by your manager.
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-4">
          {reviews.map((review) => (
            <Card key={review.id} className="hover:shadow-md transition-shadow">
              <CardContent className="pt-6">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className="p-2 bg-gray-100 rounded-full">
                      <User className="w-5 h-5 text-gray-600" />
                    </div>
                    <div>
                      <p className="font-medium text-gray-900">
                        {review.reviewer_name || 'Manager'}
                      </p>
                      <p className="text-sm text-gray-500 flex items-center gap-1">
                        <Calendar className="w-3 h-3" />
                        {formatDate(review.created_at)}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-1">
                    {[1, 2, 3, 4, 5].map((star) => (
                      <Star
                        key={star}
                        className={`w-5 h-5 ${
                          star <= (review.rating || 0)
                            ? 'text-yellow-400 fill-yellow-400'
                            : 'text-gray-200'
                        }`}
                      />
                    ))}
                    <span className="ml-2 font-semibold">{review.rating}/5</span>
                  </div>
                </div>

                {/* Rating Breakdown */}
                <div className="grid grid-cols-3 gap-4 mb-4 p-4 bg-gray-50 rounded-xl">
                  <div className="text-center">
                    <p className="text-sm text-gray-500">Punctuality</p>
                    <p className="text-lg font-semibold text-primary">
                      {review.punctuality_rating || '-'}/5
                    </p>
                  </div>
                  <div className="text-center border-x border-gray-200">
                    <p className="text-sm text-gray-500">Performance</p>
                    <p className="text-lg font-semibold text-primary">
                      {review.performance_rating || '-'}/5
                    </p>
                  </div>
                  <div className="text-center">
                    <p className="text-sm text-gray-500">Attitude</p>
                    <p className="text-lg font-semibold text-primary">
                      {review.attitude_rating || '-'}/5
                    </p>
                  </div>
                </div>

                {/* Comments */}
                {review.comments && (
                  <div className="p-4 bg-blue-50 rounded-xl border border-blue-100">
                    <p className="text-sm text-gray-500 mb-1">Feedback</p>
                    <p className="text-gray-700">{review.comments}</p>
                  </div>
                )}

                {/* Week Period */}
                <div className="mt-4 text-sm text-gray-500">
                  Week of {formatDate(review.week_start_date)} - {formatDate(review.week_end_date)}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
