'use client';

import { useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { LoadingSpinner, BouncingDots } from '@/components/shared/LoadingSpinner';
import { toast } from '@/components/ui/toaster';
import api from '@/lib/api';
import {
  Lock,
  Mail,
  Bell,
  Moon,
  Eye,
  EyeOff,
  Shield,
  Check,
} from 'lucide-react';

export default function SettingsPage() {
  const { user } = useAuth();
  const [activeSection, setActiveSection] = useState<'password' | 'email' | 'notifications' | null>(null);
  
  // Password change state
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPasswords, setShowPasswords] = useState(false);
  const [isChangingPassword, setIsChangingPassword] = useState(false);
  
  // Email change state
  const [newEmail, setNewEmail] = useState('');
  const [emailPassword, setEmailPassword] = useState('');
  const [isChangingEmail, setIsChangingEmail] = useState(false);

  const handleChangePassword = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (newPassword.length < 6) {
      toast({ title: 'Password must be at least 6 characters', variant: 'destructive' });
      return;
    }
    
    if (newPassword !== confirmPassword) {
      toast({ title: 'Passwords do not match', variant: 'destructive' });
      return;
    }
    
    setIsChangingPassword(true);
    
    try {
      await api.changePassword(currentPassword, newPassword);
      toast({ title: 'Password changed successfully', variant: 'success' });
      setCurrentPassword('');
      setNewPassword('');
      setConfirmPassword('');
      setActiveSection(null);
    } catch (error) {
      toast({ 
        title: 'Failed to change password', 
        description: error instanceof Error ? error.message : 'Please try again',
        variant: 'destructive' 
      });
    } finally {
      setIsChangingPassword(false);
    }
  };

  const handleChangeEmail = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!newEmail.includes('@')) {
      toast({ title: 'Please enter a valid email', variant: 'destructive' });
      return;
    }
    
    setIsChangingEmail(true);
    
    try {
      await api.updateEmail(newEmail, emailPassword);
      toast({ title: 'Email updated successfully', variant: 'success' });
      setNewEmail('');
      setEmailPassword('');
      setActiveSection(null);
    } catch (error) {
      toast({ 
        title: 'Failed to update email', 
        description: error instanceof Error ? error.message : 'Please try again',
        variant: 'destructive' 
      });
    } finally {
      setIsChangingEmail(false);
    }
  };

  return (
    <div className="space-y-6 max-w-2xl mx-auto">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Settings</h1>
        <p className="text-gray-500">Manage your account preferences</p>
      </div>

      {/* Change Password */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-blue-100 rounded-lg">
                <Lock className="w-5 h-5 text-blue-600" />
              </div>
              <div>
                <CardTitle className="text-base">Change Password</CardTitle>
                <CardDescription>Update your account password</CardDescription>
              </div>
            </div>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setActiveSection(activeSection === 'password' ? null : 'password')}
            >
              {activeSection === 'password' ? 'Cancel' : 'Change'}
            </Button>
          </div>
        </CardHeader>
        {activeSection === 'password' && (
          <CardContent>
            <form onSubmit={handleChangePassword} className="space-y-4">
              <div>
                <label className="text-sm text-gray-500">Current Password</label>
                <div className="relative mt-1">
                  <Input
                    type={showPasswords ? 'text' : 'password'}
                    value={currentPassword}
                    onChange={(e) => setCurrentPassword(e.target.value)}
                    placeholder="Enter current password"
                  />
                </div>
              </div>
              <div>
                <label className="text-sm text-gray-500">New Password</label>
                <div className="relative mt-1">
                  <Input
                    type={showPasswords ? 'text' : 'password'}
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    placeholder="Enter new password"
                  />
                </div>
              </div>
              <div>
                <label className="text-sm text-gray-500">Confirm New Password</label>
                <div className="relative mt-1">
                  <Input
                    type={showPasswords ? 'text' : 'password'}
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    placeholder="Confirm new password"
                  />
                </div>
              </div>
              <div className="flex items-center gap-2">
                <button
                  type="button"
                  onClick={() => setShowPasswords(!showPasswords)}
                  className="text-sm text-gray-500 hover:text-gray-700 flex items-center gap-1"
                >
                  {showPasswords ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  {showPasswords ? 'Hide passwords' : 'Show passwords'}
                </button>
              </div>
              <Button type="submit" disabled={isChangingPassword} className="w-full">
                {isChangingPassword ? <BouncingDots /> : 'Update Password'}
              </Button>
            </form>
          </CardContent>
        )}
      </Card>

      {/* Change Email */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-green-100 rounded-lg">
                <Mail className="w-5 h-5 text-green-600" />
              </div>
              <div>
                <CardTitle className="text-base">Change Email</CardTitle>
                <CardDescription>Current: {user?.email}</CardDescription>
              </div>
            </div>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setActiveSection(activeSection === 'email' ? null : 'email')}
            >
              {activeSection === 'email' ? 'Cancel' : 'Change'}
            </Button>
          </div>
        </CardHeader>
        {activeSection === 'email' && (
          <CardContent>
            <form onSubmit={handleChangeEmail} className="space-y-4">
              <div>
                <label className="text-sm text-gray-500">New Email</label>
                <Input
                  type="email"
                  value={newEmail}
                  onChange={(e) => setNewEmail(e.target.value)}
                  placeholder="Enter new email"
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Confirm Password</label>
                <Input
                  type="password"
                  value={emailPassword}
                  onChange={(e) => setEmailPassword(e.target.value)}
                  placeholder="Enter your password to confirm"
                  className="mt-1"
                />
              </div>
              <Button type="submit" disabled={isChangingEmail} className="w-full">
                {isChangingEmail ? <BouncingDots /> : 'Update Email'}
              </Button>
            </form>
          </CardContent>
        )}
      </Card>

      {/* Notification Preferences */}
      <Card>
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="p-2 bg-purple-100 rounded-lg">
              <Bell className="w-5 h-5 text-purple-600" />
            </div>
            <div>
              <CardTitle className="text-base">Notification Preferences</CardTitle>
              <CardDescription>Manage how you receive notifications</CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {[
              { label: 'Roster Assignments', description: 'Get notified when assigned to a roster' },
              { label: 'Performance Reviews', description: 'Get notified when you receive a review' },
              { label: 'Announcements', description: 'Receive company-wide announcements' },
            ].map((pref, i) => (
              <div key={i} className="flex items-center justify-between py-2">
                <div>
                  <p className="font-medium text-gray-900">{pref.label}</p>
                  <p className="text-sm text-gray-500">{pref.description}</p>
                </div>
                <div className="w-12 h-6 bg-primary rounded-full relative cursor-pointer">
                  <div className="absolute right-1 top-1 w-4 h-4 bg-white rounded-full shadow" />
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Security */}
      <Card>
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="p-2 bg-orange-100 rounded-lg">
              <Shield className="w-5 h-5 text-orange-600" />
            </div>
            <div>
              <CardTitle className="text-base">Security</CardTitle>
              <CardDescription>Account security information</CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="flex items-center justify-between py-2">
              <div>
                <p className="font-medium text-gray-900">Two-Factor Authentication</p>
                <p className="text-sm text-gray-500">Add an extra layer of security</p>
              </div>
              <span className="text-sm text-gray-400">Coming soon</span>
            </div>
            <div className="flex items-center justify-between py-2">
              <div>
                <p className="font-medium text-gray-900">Last Login</p>
                <p className="text-sm text-gray-500">Track your account activity</p>
              </div>
              <span className="text-sm text-gray-600">
                {user?.last_login ? new Date(user.last_login).toLocaleDateString() : 'N/A'}
              </span>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
