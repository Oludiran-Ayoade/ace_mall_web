'use client';

import { cn } from '@/lib/utils';

interface LoadingSpinnerProps {
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

export function LoadingSpinner({ size = 'md', className }: LoadingSpinnerProps) {
  const sizeClasses = {
    sm: 'w-4 h-4',
    md: 'w-8 h-8',
    lg: 'w-12 h-12',
  };

  return (
    <div className={cn('flex items-center justify-center', className)}>
      <div
        className={cn(
          'animate-spin rounded-full border-2 border-gray-300 border-t-primary',
          sizeClasses[size]
        )}
      />
    </div>
  );
}

export function BouncingDots({ className }: { className?: string }) {
  return (
    <div className={cn('flex items-center justify-center gap-1', className)}>
      <div className="w-2 h-2 bg-current rounded-full animate-bounce [animation-delay:-0.3s]" />
      <div className="w-2 h-2 bg-current rounded-full animate-bounce [animation-delay:-0.15s]" />
      <div className="w-2 h-2 bg-current rounded-full animate-bounce" />
    </div>
  );
}

export function PageLoader() {
  return (
    <div className="flex items-center justify-center min-h-screen">
      <div className="flex flex-col items-center gap-4">
        <LoadingSpinner size="lg" />
        <p className="text-gray-500">Loading...</p>
      </div>
    </div>
  );
}
