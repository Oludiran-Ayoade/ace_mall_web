'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { ShoppingCart, Mail, ArrowLeft, KeyRound, Lock, Eye, EyeOff, CheckCircle } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { BouncingDots } from '@/components/shared/LoadingSpinner';
import { toast } from '@/components/ui/toaster';
import api from '@/lib/api';

type Step = 'email' | 'otp' | 'password' | 'success';

export default function ForgotPasswordPage() {
  const [step, setStep] = useState<Step>('email');
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [resetToken, setResetToken] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  
  const router = useRouter();

  const handleSendOTP = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    
    if (!email || !email.includes('@')) {
      setError('Please enter a valid email');
      return;
    }
    
    setIsLoading(true);
    
    try {
      await api.forgotPassword(email);
      toast({ title: 'OTP sent!', description: 'Check your email for the verification code', variant: 'success' });
      setStep('otp');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to send OTP');
    } finally {
      setIsLoading(false);
    }
  };

  const handleVerifyOTP = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    
    if (!otp || otp.length !== 6) {
      setError('Please enter the 6-digit code');
      return;
    }
    
    setIsLoading(true);
    
    try {
      const result = await api.verifyResetOTP(email, otp);
      setResetToken(result.reset_token);
      toast({ title: 'Code verified!', variant: 'success' });
      setStep('password');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Invalid code');
    } finally {
      setIsLoading(false);
    }
  };

  const handleResetPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    
    if (newPassword.length < 6) {
      setError('Password must be at least 6 characters');
      return;
    }
    
    if (newPassword !== confirmPassword) {
      setError('Passwords do not match');
      return;
    }
    
    setIsLoading(true);
    
    try {
      await api.resetPassword(resetToken, newPassword);
      toast({ title: 'Password reset successful!', variant: 'success' });
      setStep('success');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to reset password');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-white flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-primary/10 mb-4">
            <ShoppingCart className="w-10 h-10 text-primary" />
          </div>
          <h1 className="text-2xl font-bold text-primary">Ace Mall</h1>
        </div>

        <Card className="border-0 shadow-lg">
          {/* Step: Email */}
          {step === 'email' && (
            <>
              <CardHeader className="text-center">
                <CardTitle>Forgot Password</CardTitle>
                <CardDescription>Enter your email to receive a verification code</CardDescription>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleSendOTP} className="space-y-4">
                  <div className="relative">
                    <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                    <Input
                      type="email"
                      placeholder="Email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      className="pl-10 h-12"
                      disabled={isLoading}
                    />
                  </div>
                  {error && <p className="text-sm text-red-500">{error}</p>}
                  <Button type="submit" className="w-full h-12" disabled={isLoading}>
                    {isLoading ? <BouncingDots /> : 'Send Code'}
                  </Button>
                </form>
              </CardContent>
            </>
          )}

          {/* Step: OTP */}
          {step === 'otp' && (
            <>
              <CardHeader className="text-center">
                <CardTitle>Verify Code</CardTitle>
                <CardDescription>Enter the 6-digit code sent to {email}</CardDescription>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleVerifyOTP} className="space-y-4">
                  <div className="relative">
                    <KeyRound className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                    <Input
                      type="text"
                      placeholder="Enter 6-digit code"
                      value={otp}
                      onChange={(e) => setOtp(e.target.value.replace(/\D/g, '').slice(0, 6))}
                      className="pl-10 h-12 text-center text-lg tracking-widest"
                      maxLength={6}
                      disabled={isLoading}
                    />
                  </div>
                  {error && <p className="text-sm text-red-500">{error}</p>}
                  <Button type="submit" className="w-full h-12" disabled={isLoading}>
                    {isLoading ? <BouncingDots /> : 'Verify Code'}
                  </Button>
                  <button
                    type="button"
                    onClick={() => setStep('email')}
                    className="w-full text-sm text-gray-500 hover:text-primary"
                  >
                    Didn&apos;t receive code? Try again
                  </button>
                </form>
              </CardContent>
            </>
          )}

          {/* Step: New Password */}
          {step === 'password' && (
            <>
              <CardHeader className="text-center">
                <CardTitle>New Password</CardTitle>
                <CardDescription>Create a new password for your account</CardDescription>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleResetPassword} className="space-y-4">
                  <div className="relative">
                    <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                    <Input
                      type={showPassword ? 'text' : 'password'}
                      placeholder="New Password"
                      value={newPassword}
                      onChange={(e) => setNewPassword(e.target.value)}
                      className="pl-10 pr-10 h-12"
                      disabled={isLoading}
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400"
                    >
                      {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                    </button>
                  </div>
                  <div className="relative">
                    <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                    <Input
                      type={showPassword ? 'text' : 'password'}
                      placeholder="Confirm Password"
                      value={confirmPassword}
                      onChange={(e) => setConfirmPassword(e.target.value)}
                      className="pl-10 h-12"
                      disabled={isLoading}
                    />
                  </div>
                  {error && <p className="text-sm text-red-500">{error}</p>}
                  <Button type="submit" className="w-full h-12" disabled={isLoading}>
                    {isLoading ? <BouncingDots /> : 'Reset Password'}
                  </Button>
                </form>
              </CardContent>
            </>
          )}

          {/* Step: Success */}
          {step === 'success' && (
            <CardContent className="py-10 text-center">
              <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-green-100 mb-4">
                <CheckCircle className="w-8 h-8 text-green-600" />
              </div>
              <h2 className="text-xl font-bold text-gray-900 mb-2">Password Reset!</h2>
              <p className="text-gray-500 mb-6">Your password has been reset successfully</p>
              <Button onClick={() => router.push('/signin')} className="w-full h-12">
                Sign In
              </Button>
            </CardContent>
          )}
        </Card>

        {/* Back to Sign In */}
        {step !== 'success' && (
          <div className="text-center mt-6">
            <Link href="/signin" className="inline-flex items-center text-gray-500 hover:text-primary">
              <ArrowLeft className="w-4 h-4 mr-2" />
              Back to Sign In
            </Link>
          </div>
        )}
      </div>
    </div>
  );
}
