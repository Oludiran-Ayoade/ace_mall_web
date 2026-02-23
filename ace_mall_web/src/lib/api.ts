import { API_BASE_URL } from './constants';
import type { 
  User, Branch, Department, Role, Roster, RosterAssignment, 
  WeeklyReview, Notification, PromotionHistory, TerminatedStaff,
  ShiftTemplate, AuthResponse, WorkExperience
} from '@/types';

class ApiClient {
  private baseUrl: string;

  constructor() {
    this.baseUrl = API_BASE_URL;
  }

  private getToken(): string | null {
    if (typeof window !== 'undefined') {
      const token = localStorage.getItem('token');
      const loginTime = localStorage.getItem('login_time');
      
      // Check if token is expired (12 hours = 43200000 ms)
      if (token && loginTime) {
        const elapsed = Date.now() - parseInt(loginTime);
        if (elapsed > 43200000) {
          // Token expired after 12 hours
          this.clearAuthAndRedirect();
          return null;
        }
      }
      
      return token;
    }
    return null;
  }

  private clearAuthAndRedirect(): void {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      localStorage.removeItem('login_time');
      window.location.href = '/signin';
    }
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {},
    includeAuth = true
  ): Promise<T> {
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      ...options.headers,
    };

    if (includeAuth) {
      const token = this.getToken();
      if (token) {
        (headers as Record<string, string>)['Authorization'] = `Bearer ${token}`;
      }
    }

    const url = `${this.baseUrl}${endpoint}`;

    try {
      const response = await fetch(url, {
        ...options,
        headers,
      });

      if (response.status === 401) {
        // Only redirect on actual auth failures, not on navigation
        const isAuthEndpoint = endpoint.includes('/auth/');
        if (!isAuthEndpoint) {
          this.clearAuthAndRedirect();
        }
        throw new Error('Unauthorized');
      }

      if (!response.ok) {
        const error = await response.json().catch(() => ({ error: 'Request failed' }));
        throw new Error(error.error || error.message || 'Request failed');
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error(`[API] Error fetching ${endpoint}:`, error);
      // Provide user-friendly error messages
      if (error instanceof TypeError && error.message.includes('fetch')) {
        throw new Error('Unable to connect. Please check your internet connection and try again.');
      }
      if (error instanceof Error) {
        // Keep specific error messages but make generic ones friendly
        if (error.message === 'Request failed' || error.message === 'Failed to fetch') {
          throw new Error('Something went wrong. Please try again later.');
        }
        throw error;
      }
      throw new Error('An unexpected error occurred. Please try again later.');
    }
  }

  // ============================================
  // AUTHENTICATION
  // ============================================

  async login(email: string, password: string): Promise<AuthResponse> {
    const data = await this.request<AuthResponse>(
      '/auth/login',
      {
        method: 'POST',
        body: JSON.stringify({ email, password }),
      },
      false
    );
    
    if (data.token) {
      localStorage.setItem('token', data.token);
      localStorage.setItem('user', JSON.stringify(data.user));
      localStorage.setItem('login_time', Date.now().toString());
    }
    
    return data;
  }

  async logout(): Promise<void> {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    localStorage.removeItem('login_time');
  }

  async getCurrentUser(): Promise<User> {
    const response = await this.request<{ user: User }>('/auth/me');
    return response.user;
  }

  async forgotPassword(email: string): Promise<{ message: string }> {
    return this.request('/auth/forgot-password', {
      method: 'POST',
      body: JSON.stringify({ email }),
    }, false);
  }

  async verifyResetOTP(email: string, otp: string): Promise<{ message: string; reset_token: string }> {
    return this.request('/auth/verify-reset-otp', {
      method: 'POST',
      body: JSON.stringify({ email, otp }),
    }, false);
  }

  async resetPassword(resetToken: string, newPassword: string): Promise<{ message: string }> {
    return this.request('/auth/reset-password', {
      method: 'POST',
      body: JSON.stringify({ reset_token: resetToken, new_password: newPassword }),
    }, false);
  }

  async changePassword(currentPassword: string, newPassword: string): Promise<{ message: string }> {
    return this.request('/auth/change-password', {
      method: 'POST',
      body: JSON.stringify({ current_password: currentPassword, new_password: newPassword }),
    });
  }

  async updateEmail(newEmail: string, password: string): Promise<{ message: string }> {
    return this.request('/auth/update-email', {
      method: 'PUT',
      body: JSON.stringify({ new_email: newEmail, password }),
    });
  }

  // ============================================
  // DATA ENDPOINTS
  // ============================================

  async getBranches(): Promise<Branch[]> {
    const response = await this.request<{ branches: Branch[] }>('/data/branches', {}, false);
    return response.branches || [];
  }

  async getDepartments(): Promise<Department[]> {
    const response = await this.request<{ departments: Department[] }>('/data/departments', {}, false);
    return response.departments || [];
  }

  async getRoles(): Promise<Role[]> {
    const response = await this.request<{ roles: Role[] }>('/data/roles', {}, false);
    return response.roles || [];
  }

  async getRolesByCategory(category: string): Promise<Role[]> {
    const response = await this.request<{ roles: Role[]; category: string }>(`/data/roles/category/${category}`, {}, false);
    return response.roles || [];
  }

  // ============================================
  // STAFF MANAGEMENT (HR)
  // ============================================

  async getAllStaff(params?: { branch_id?: string; department_id?: string; search?: string }): Promise<User[]> {
    const queryParams = new URLSearchParams();
    if (params?.branch_id) queryParams.append('branch_id', params.branch_id);
    if (params?.department_id) queryParams.append('department_id', params.department_id);
    if (params?.search) queryParams.append('search', params.search);
    
    const query = queryParams.toString();
    const response = await this.request<{ staff: User[] } | User[]>(`/hr/staff${query ? `?${query}` : ''}`);
    // Handle both wrapped and unwrapped responses
    if (Array.isArray(response)) return response;
    return response.staff || [];
  }

  async getStaffById(id: string): Promise<{ user: User; permission_level: string }> {
    const response = await this.request<{ user: User; permission_level: string }>(`/staff/${id}`);
    return response;
  }

  async getStaffStats(): Promise<{ total_staff: number; active_staff: number; terminated_staff: number }> {
    return this.request('/hr/stats');
  }

  async createStaff(staffData: Partial<User>): Promise<{ id: string; message: string }> {
    return this.request('/hr/staff', {
      method: 'POST',
      body: JSON.stringify(staffData),
    });
  }

  async updateStaffProfile(id: string, data: Partial<User>): Promise<{ message: string }> {
    return this.request(`/staff/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async getTerminatedStaff(): Promise<TerminatedStaff[]> {
    const response = await this.request<{ departed_staff: TerminatedStaff[]; count: number } | TerminatedStaff[]>('/hr/terminated-staff');
    if (Array.isArray(response)) return response;
    return response.departed_staff || [];
  }

  async getAllPromotions(): Promise<PromotionHistory[]> {
    const response = await this.request<{ promotions: PromotionHistory[] } | PromotionHistory[]>('/hr/promotions');
    if (Array.isArray(response)) return response;
    return response.promotions || [];
  }

  async getStaffReport(params: Record<string, string>): Promise<{ staff: any[]; count: number }> {
    const queryString = new URLSearchParams(params).toString();
    return this.request<{ staff: any[]; count: number }>(`/hr/staff-report?${queryString}`);
  }

  // ============================================
  // ROSTER MANAGEMENT
  // ============================================

  async createRoster(data: {
    week_start_date: string;
    week_end_date: string;
    assignments: Array<{
      staff_id: string;
      day_of_week: string;
      shift_type: string;
      start_time: string;
      end_time: string;
      notes?: string;
    }>;
  }): Promise<{ roster_id: string; message: string }> {
    return this.request('/roster', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async getRosterForWeek(startDate: string): Promise<Roster> {
    return this.request(`/roster/week?start_date=${startDate}`);
  }

  async getRostersByBranchDepartment(branchId: string, departmentId: string, startDate?: string, history?: boolean): Promise<{ rosters?: Roster[]; data?: Roster }> {
    const params = new URLSearchParams({
      branch_id: branchId,
      department_id: departmentId,
    });
    if (startDate) params.append('start_date', startDate);
    if (history) params.append('history', 'true');
    
    return this.request(`/roster/by-branch-department?${params.toString()}`);
  }

  async getAllRosters(filters?: { branch_id?: string; department_id?: string; year?: string; month?: string }): Promise<{ success: boolean; rosters: Roster[]; count: number }> {
    const params = new URLSearchParams();
    if (filters?.branch_id) params.append('branch_id', filters.branch_id);
    if (filters?.department_id) params.append('department_id', filters.department_id);
    if (filters?.year) params.append('year', filters.year);
    if (filters?.month) params.append('month', filters.month);
    
    const queryString = params.toString();
    return this.request(`/roster/all${queryString ? `?${queryString}` : ''}`);
  }

  async getMyTeam(): Promise<{ team: User[]; count: number }> {
    return this.request('/roster/my-team');
  }

  async getShiftTemplates(): Promise<ShiftTemplate[]> {
    const response = await this.request<{ templates: ShiftTemplate[] } | ShiftTemplate[]>('/shifts/templates');
    if (Array.isArray(response)) return response;
    return response.templates || [];
  }

  async updateShiftTemplate(id: string, data: { start_time: string; end_time: string }): Promise<{ message: string }> {
    return this.request(`/shifts/templates/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async getPersonalSchedule(): Promise<RosterAssignment[]> {
    const response = await this.request<{ assignments: RosterAssignment[] } | RosterAssignment[]>('/roster/my-assignments');
    if (Array.isArray(response)) return response;
    return response.assignments || [];
  }

  // ============================================
  // REVIEWS
  // ============================================

  async createReview(data: {
    staff_id: string;
    attendance_score: number;
    punctuality_score: number;
    performance_score: number;
    remarks: string;
  }): Promise<{ id: string; message: string }> {
    return this.request('/reviews', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async getMyReviews(): Promise<WeeklyReview[]> {
    const response = await this.request<{ reviews: WeeklyReview[] } | WeeklyReview[]>('/reviews/my-reviews');
    if (Array.isArray(response)) return response;
    return response.reviews || [];
  }

  async getAllStaffReviews(): Promise<WeeklyReview[]> {
    const response = await this.request<{ reviews: WeeklyReview[] } | WeeklyReview[]>('/hr/reviews');
    if (Array.isArray(response)) return response;
    return response.reviews || [];
  }

  async getStaffReviews(staffId: string): Promise<{ reviews: WeeklyReview[]; count: number }> {
    return this.request(`/reviews/staff/${staffId}`);
  }

  async getRatingsByDepartment(branchId: string, departmentId: string, period?: string): Promise<{ data: any[] }> {
    const params = new URLSearchParams({ branch_id: branchId, department_id: departmentId });
    if (period) params.append('period', period);
    return this.request(`/reviews/by-department?${params.toString()}`);
  }

  // ============================================
  // PROMOTIONS
  // ============================================

  async promoteStaff(data: {
    staff_id: string;
    new_role_id?: string;
    new_salary: number;
    reason?: string;
    branch_id?: string;
    department_id?: string;
  }): Promise<{ promotion_id: number; message: string }> {
    return this.request('/promotions', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async getPromotionHistory(staffId: string): Promise<PromotionHistory[]> {
    const response = await this.request<{ history: PromotionHistory[] } | PromotionHistory[]>(`/promotions/history/${staffId}`);
    if (Array.isArray(response)) return response;
    return response.history || [];
  }

  async deletePromotion(promotionId: number): Promise<{ message: string }> {
    return this.request(`/promotions/${promotionId}`, {
      method: 'DELETE',
    });
  }

  // ============================================
  // TERMINATIONS
  // ============================================

  async terminateStaff(id: string, data: {
    termination_type: string;
    reason: string;
    last_working_day?: string;
    clearance_notes?: string;
  }): Promise<{ terminated_id: string; message: string }> {
    return this.request(`/staff/${id}/terminate`, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async restoreStaff(id: string): Promise<{ message: string }> {
    return this.request(`/staff/${id}/restore`, {
      method: 'POST',
    });
  }

  async getDepartedStaff(filters?: { type?: string; branch?: string; department?: string }): Promise<{ departed_staff: TerminatedStaff[]; count: number }> {
    const params = new URLSearchParams();
    if (filters?.type) params.append('type', filters.type);
    if (filters?.branch) params.append('branch', filters.branch);
    if (filters?.department) params.append('department', filters.department);
    
    const query = params.toString();
    return this.request(`/staff/departed${query ? `?${query}` : ''}`);
  }

  // ============================================
  // NOTIFICATIONS
  // ============================================

  async getNotifications(limit = 50, offset = 0): Promise<Notification[]> {
    const response = await this.request<{ notifications: Notification[] } | Notification[]>(`/notifications?limit=${limit}&offset=${offset}`);
    if (Array.isArray(response)) return response;
    return response.notifications || [];
  }

  async markNotificationAsRead(id: number): Promise<{ message: string }> {
    return this.request(`/notifications/${id}/read`, {
      method: 'PUT',
    });
  }

  async markAllNotificationsAsRead(): Promise<{ message: string; count: number }> {
    return this.request('/notifications/mark-all-read', {
      method: 'PUT',
    });
  }

  async getUnreadNotificationCount(): Promise<{ unread_count: number }> {
    return this.request('/notifications/unread-count');
  }

  async deleteNotification(id: number): Promise<{ message: string }> {
    return this.request(`/notifications/${id}`, {
      method: 'DELETE',
    });
  }

  // ============================================
  // WORK EXPERIENCE
  // ============================================

  async updateWorkExperience(staffId: string, experiences: WorkExperience[]): Promise<{ message: string }> {
    return this.request(`/staff/${staffId}/work-experience`, {
      method: 'PUT',
      body: JSON.stringify({ work_experience: experiences }),
    });
  }

  async updateRoleHistory(staffId: string, roleHistory: any[]): Promise<{ message: string }> {
    return this.request(`/staff/${staffId}/role-history`, {
      method: 'PUT',
      body: JSON.stringify({ role_history: roleHistory }),
    });
  }

  async uploadGuarantorDocument(
    staffId: string, 
    guarantorNumber: number, 
    documentType: string, 
    documentUrl: string
  ): Promise<{ message: string }> {
    return this.request(`/staff/${staffId}/guarantor-document`, {
      method: 'POST',
      body: JSON.stringify({
        guarantor_number: guarantorNumber,
        document_type: documentType,
        document_url: documentUrl,
      }),
    });
  }

  // ============================================
  // PROFILE
  // ============================================

  async updateProfilePicture(imageUrl: string): Promise<{ message: string }> {
    return this.request('/profile/picture', {
      method: 'PUT',
      body: JSON.stringify({ profile_image_url: imageUrl }),
    });
  }
}

export const api = new ApiClient();
export default api;
