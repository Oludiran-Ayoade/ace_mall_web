import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function formatDate(date: string | Date): string {
  return new Date(date).toLocaleDateString('en-NG', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

export function formatCurrency(amount: number): string {
  return new Intl.NumberFormat('en-NG', {
    style: 'currency',
    currency: 'NGN',
    minimumFractionDigits: 0,
  }).format(amount)
}

export function getInitials(name: string | undefined | null): string {
  if (!name) return 'NA';
  return name
    .split(' ')
    .map(n => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2)
}

export function getDashboardRoute(roleName: string): string {
  if (roleName.includes('CEO') || roleName.includes('Chairman') || roleName.includes('Group Head')) {
    return '/dashboard';
  } else if (roleName.includes('COO')) {
    return '/dashboard';
  } else if (roleName.includes('HR') || roleName.includes('Human Resource')) {
    return '/dashboard';
  } else if (roleName.includes('Auditor')) {
    return '/dashboard';
  } else if (roleName.includes('Branch Manager')) {
    return '/dashboard';
  } else if (roleName.includes('Floor Manager')) {
    return '/dashboard';
  } else {
    return '/dashboard';
  }
}

export function getRoleCategory(roleName: string): 'senior_admin' | 'admin' | 'general' {
  const seniorRoles = ['CEO', 'COO', 'HR', 'Human Resource', 'Chairman', 'Auditor', 'Group Head', 'Hospitality Unit'];
  const adminRoles = ['Branch Manager', 'Operations Manager', 'Floor Manager', 'Social Media Manager'];
  
  if (seniorRoles.some(role => roleName.includes(role))) {
    return 'senior_admin';
  }
  if (adminRoles.some(role => roleName.includes(role))) {
    return 'admin';
  }
  return 'general';
}

export function timeAgo(date: string | Date): string {
  const now = new Date();
  const past = new Date(date);
  const diffMs = now.getTime() - past.getTime();
  const diffMins = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMins / 60);
  const diffDays = Math.floor(diffHours / 24);

  if (diffMins < 1) return 'Just now';
  if (diffMins < 60) return `${diffMins}m ago`;
  if (diffHours < 24) return `${diffHours}h ago`;
  if (diffDays < 7) return `${diffDays}d ago`;
  return formatDate(date);
}
