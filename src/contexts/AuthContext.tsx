'use client';

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { User } from '@/types';
import api from '@/lib/api';

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<{ success: boolean; error?: string }>;
  logout: () => void;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    checkAuth();
  }, []);

  const checkAuth = async () => {
    const token = localStorage.getItem('token');
    if (!token) {
      setIsLoading(false);
      return;
    }

    // Load cached user data immediately for faster UI
    const cachedUserStr = localStorage.getItem('user');
    let cachedUser: User | null = null;
    
    if (cachedUserStr) {
      try {
        cachedUser = JSON.parse(cachedUserStr);
        if (cachedUser && cachedUser.id && cachedUser.full_name) {
          setUser(cachedUser);
        }
      } catch (e) {
        console.error('Failed to parse cached user:', e);
      }
    }

    // Then try to fetch fresh data from API
    try {
      const userData = await api.getCurrentUser();
      if (userData && userData.id) {
        setUser(userData);
        // Update cache with fresh data
        localStorage.setItem('user', JSON.stringify(userData));
      }
    } catch (error) {
      console.error('API auth check failed:', error);
      // If API fails but we have valid cached user, keep using it
      if (cachedUser && cachedUser.id && cachedUser.full_name) {
        // Keep the cached user, don't clear anything
      } else {
        // No valid cached data and API failed - clear auth
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        localStorage.removeItem('login_time');
        setUser(null);
      }
    } finally {
      setIsLoading(false);
    }
  };

  const login = async (email: string, password: string): Promise<{ success: boolean; error?: string }> => {
    try {
      const response = await api.login(email, password);
      setUser(response.user);
      // Ensure user is cached in localStorage
      localStorage.setItem('user', JSON.stringify(response.user));
      return { success: true };
    } catch (error) {
      return { 
        success: false, 
        error: error instanceof Error ? error.message : 'Login failed' 
      };
    }
  };

  const logout = () => {
    api.logout();
    setUser(null);
    window.location.href = '/signin';
  };

  const refreshUser = async () => {
    try {
      const userData = await api.getCurrentUser();
      setUser(userData);
      // Update cache with fresh data
      localStorage.setItem('user', JSON.stringify(userData));
    } catch (error) {
      console.error('Failed to refresh user:', error);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isLoading,
        isAuthenticated: !!user,
        login,
        logout,
        refreshUser,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
