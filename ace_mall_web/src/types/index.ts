export interface User {
  id: string;
  email: string;
  full_name: string;
  phone_number?: string;
  gender?: string;
  date_of_birth?: string;
  home_address?: string;
  state_of_origin?: string;
  marital_status?: string;
  profile_image_url?: string;
  
  // Work Info
  employee_id?: string;
  role_id?: string;
  role_name?: string;
  role_category?: string;
  department_id?: string;
  department_name?: string;
  branch_id?: string;
  branch_name?: string;
  date_joined?: string;
  current_salary?: number;
  
  // Education
  course_of_study?: string;
  grade?: string;
  institution?: string;
  
  // Documents
  passport_url?: string;
  national_id_url?: string;
  birth_certificate_url?: string;
  waec_certificate_url?: string;
  neco_certificate_url?: string;
  jamb_result_url?: string;
  degree_certificate_url?: string;
  nysc_certificate_url?: string;
  state_of_origin_cert_url?: string;
  
  // Next of Kin
  next_of_kin_name?: string;
  next_of_kin_relationship?: string;
  next_of_kin_phone?: string;
  next_of_kin_email?: string;
  next_of_kin_home_address?: string;
  next_of_kin_work_address?: string;
  
  // Guarantor 1
  guarantor1_name?: string;
  guarantor1_phone?: string;
  guarantor1_occupation?: string;
  guarantor1_relationship?: string;
  guarantor1_address?: string;
  guarantor1_email?: string;
  guarantor1_passport?: string;
  guarantor1_national_id?: string;
  guarantor1_work_id?: string;
  
  // Guarantor 2
  guarantor2_name?: string;
  guarantor2_phone?: string;
  guarantor2_occupation?: string;
  guarantor2_relationship?: string;
  guarantor2_address?: string;
  guarantor2_email?: string;
  guarantor2_passport?: string;
  guarantor2_national_id?: string;
  guarantor2_work_id?: string;
  
  // Work Experience
  work_experience?: WorkExperience[];
  
  // Role History (roles held at Ace Mall)
  role_history?: RoleHistory[];
  
  // Exam Scores
  exam_scores?: ExamScore[];
  
  // Status
  is_active: boolean;
  is_terminated: boolean;
  
  // Metadata
  created_at: string;
  updated_at: string;
  last_login?: string;
}

export interface Branch {
  id: string;
  name: string;
  location?: string;
  manager_name?: string;
  staff_count?: number;
  is_active: boolean;
}

export interface Department {
  id: string;
  name: string;
  description?: string;
  is_active: boolean;
}

export interface Role {
  id: string;
  name: string;
  category: 'senior_admin' | 'admin' | 'general';
  department_id?: string;
}

export interface Roster {
  id: string;
  floor_manager_id: string;
  floor_manager_name?: string;
  department_id?: string;
  department_name?: string;
  branch_id?: string;
  branch_name?: string;
  week_start_date: string;
  week_end_date: string;
  status: 'draft' | 'published' | 'archived';
  assignments?: RosterAssignment[];
}

export interface RosterAssignment {
  id: string;
  roster_id: string;
  staff_id: string;
  staff_name?: string;
  staff_role?: string;
  day_of_week: string;
  shift_type: 'morning' | 'afternoon' | 'evening' | 'night';
  start_time: string;
  end_time: string;
  notes?: string;
}

export interface WeeklyReview {
  id: string;
  staff_id: string;
  staff_name?: string;
  role_name?: string;
  department_name?: string;
  branch_name?: string;
  reviewer_id: string;
  reviewer_name?: string;
  week_start_date: string;
  week_end_date: string;
  rating?: number;
  overall_rating?: number;
  punctuality_rating?: number;
  performance_rating?: number;
  attitude_rating?: number;
  attendance_rating?: number;
  attendance_score?: number;
  comments?: string;
  created_at: string;
}

export interface Notification {
  id: number;
  type: 'roster_assignment' | 'schedule_change' | 'review' | 'promotion' | 'general';
  title: string;
  message: string;
  is_read: boolean;
  created_at: string;
}

export interface NextOfKin {
  id: string;
  user_id: string;
  full_name: string;
  relationship: string;
  phone_number?: string;
  email?: string;
  home_address?: string;
  work_address?: string;
}

export interface Guarantor {
  id: string;
  user_id: string;
  guarantor_number: 1 | 2;
  full_name: string;
  phone_number?: string;
  occupation?: string;
  relationship?: string;
  home_address?: string;
  email?: string;
  passport_url?: string;
  national_id_url?: string;
  work_id_url?: string;
}

export interface WorkExperience {
  id: string;
  user_id: string;
  company_name: string;
  position: string;
  start_date?: string;
  end_date?: string;
}

export interface RoleHistory {
  id: string;
  role_name: string;
  department_name?: string;
  branch_name?: string;
  start_date: string;
  end_date?: string;
  promotion_reason?: string;
}

export interface ExamScore {
  exam_type: string;
  score: string;
  year_taken?: number;
}

export interface PromotionHistory {
  id: number;
  date: string;
  previous_role: string;
  new_role: string;
  previous_salary: number;
  new_salary: number;
  previous_branch?: string;
  new_branch?: string;
  reason?: string;
  promoted_by: string;
  type: 'Promotion' | 'Transfer' | 'Salary Increase' | 'Transfer & Promotion';
}

export interface TerminatedStaff {
  id: string;
  user_id: string;
  full_name: string;
  email: string;
  employee_id?: string;
  role_name?: string;
  department_name?: string;
  branch_name?: string;
  termination_type: 'terminated' | 'resigned' | 'retired' | 'contract_ended';
  termination_reason: string;
  terminated_by_name: string;
  terminated_by_role: string;
  termination_date: string;
  last_working_day?: string;
  final_salary?: number;
}

export interface ShiftTemplate {
  id: string;
  floor_manager_id: string;
  shift_type: 'morning' | 'afternoon' | 'evening' | 'night';
  start_time: string;
  end_time: string;
  is_default: boolean;
}

export interface AuthResponse {
  token: string;
  user: User;
  role_name: string;
}

export interface ApiError {
  error: string;
  message?: string;
}
