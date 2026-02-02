export const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'https://ace-supermarket-backend.onrender.com/api/v1';

export const CLOUDINARY_CONFIG = {
  cloud_name: 'desk7uuna',
  upload_preset: 'flutter_uploads',
  folders: {
    profile: 'ace_mall_staff/profiles',
    documents: 'ace_mall_staff/documents',
    guarantors: 'ace_mall_staff/guarantors'
  }
};

export const BRANCHES = [
  'Ace Oluyole', 'Ace Bodija', 'Ace Akobo', 'Ace Oyo', 'Ace Ogbomosho',
  'Ace Ilorin', 'Ace Iseyin', 'Ace Saki', 'Ace Ife', 'Ace Osogbo',
  'Ace Abeokuta', 'Ace Ijebu', 'Ace Sagamu'
];

export const DEPARTMENTS = [
  'SuperMarket', 'Eatery', 'Lounge', 'Fun & Arcade', 'Compliance', 'Facility Management'
];

export const SUB_DEPARTMENTS = [
  'Cinema', 'Photo Studio', 'Saloon', 'Arcade and Kiddies Park', 'Casino'
];

export const SHIFT_TYPES: Record<string, { label: string; color: string; startTime: string; endTime: string }> = {
  morning: { label: 'Morning', color: 'bg-orange-100 text-orange-800', startTime: '06:00', endTime: '14:00' },
  afternoon: { label: 'Afternoon', color: 'bg-blue-100 text-blue-800', startTime: '14:00', endTime: '22:00' },
  evening: { label: 'Evening', color: 'bg-purple-100 text-purple-800', startTime: '18:00', endTime: '02:00' },
  night: { label: 'Night', color: 'bg-indigo-100 text-indigo-800', startTime: '22:00', endTime: '06:00' },
};

export const DAYS_OF_WEEK = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

export const ROLE_CATEGORIES = {
  senior_admin: { label: 'Senior Admin', color: 'bg-purple-100 text-purple-800' },
  admin: { label: 'Admin', color: 'bg-blue-100 text-blue-800' },
  general: { label: 'General Staff', color: 'bg-green-100 text-green-800' },
};

export const NIGERIAN_STATES = [
  'Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi', 'Bayelsa', 'Benue', 'Borno',
  'Cross River', 'Delta', 'Ebonyi', 'Edo', 'Ekiti', 'Enugu', 'Gombe', 'Imo', 'Jigawa',
  'Kaduna', 'Kano', 'Katsina', 'Kebbi', 'Kogi', 'Kwara', 'Lagos', 'Nasarawa', 'Niger',
  'Ogun', 'Ondo', 'Osun', 'Oyo', 'Plateau', 'Rivers', 'Sokoto', 'Taraba', 'Yobe', 'Zamfara',
  'FCT (Abuja)'
];

export const GRADE_OPTIONS = [
  'First Class',
  '2:1 (Second Class Upper)',
  '2:2 (Second Class Lower)',
  'Third Class',
  'Pass',
  'Distinction',
  'Upper Credit',
  'Lower Credit',
  'Merit'
];
