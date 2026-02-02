'use client';

import { useEffect, useState } from 'react';

interface Toast {
  id: string;
  title: string;
  description?: string;
  variant?: 'default' | 'destructive' | 'success';
}

let toastId = 0;
const toastListeners: ((toasts: Toast[]) => void)[] = [];
let toasts: Toast[] = [];

export function toast({ title, description, variant = 'default' }: Omit<Toast, 'id'>) {
  const id = String(++toastId);
  const newToast = { id, title, description, variant };
  toasts = [...toasts, newToast];
  toastListeners.forEach(listener => listener(toasts));
  
  setTimeout(() => {
    toasts = toasts.filter(t => t.id !== id);
    toastListeners.forEach(listener => listener(toasts));
  }, 5000);
}

export function Toaster() {
  const [currentToasts, setCurrentToasts] = useState<Toast[]>([]);

  useEffect(() => {
    toastListeners.push(setCurrentToasts);
    return () => {
      const index = toastListeners.indexOf(setCurrentToasts);
      if (index > -1) toastListeners.splice(index, 1);
    };
  }, []);

  if (currentToasts.length === 0) return null;

  return (
    <div className="fixed bottom-4 right-4 z-50 flex flex-col gap-2">
      {currentToasts.map((t) => (
        <div
          key={t.id}
          className={`
            px-4 py-3 rounded-xl shadow-lg min-w-[300px] animate-in slide-in-from-right
            ${t.variant === 'destructive' ? 'bg-red-500 text-white' : ''}
            ${t.variant === 'success' ? 'bg-green-500 text-white' : ''}
            ${t.variant === 'default' ? 'bg-white text-gray-900 border border-gray-200' : ''}
          `}
        >
          <p className="font-medium">{t.title}</p>
          {t.description && <p className="text-sm opacity-90 mt-1">{t.description}</p>}
        </div>
      ))}
    </div>
  );
}
