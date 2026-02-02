'use client';

import { useState, useEffect } from 'react';
import api from '@/lib/api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { toast } from '@/components/ui/toaster';
import { Send, Users, Building2, Layers, MessageSquare, CheckCircle } from 'lucide-react';
import { Branch, Department } from '@/types';

export default function MessagingPage() {
  const [recipientType, setRecipientType] = useState<'all' | 'branch' | 'department'>('all');
  const [title, setTitle] = useState('');
  const [message, setMessage] = useState('');
  const [isSending, setIsSending] = useState(false);
  const [branches, setBranches] = useState<Branch[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [selectedBranchId, setSelectedBranchId] = useState<string>('');
  const [selectedDepartmentId, setSelectedDepartmentId] = useState<string>('');
  const [isLoading, setIsLoading] = useState(true);
  const [sentMessages, setSentMessages] = useState<any[]>([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [branchData, deptData] = await Promise.all([
          api.getBranches().catch(() => []),
          api.getDepartments().catch(() => []),
        ]);
        setBranches(Array.isArray(branchData) ? branchData : []);
        setDepartments(Array.isArray(deptData) ? deptData : []);
      } catch (error) {
        console.error('Failed to load data:', error);
      } finally {
        setIsLoading(false);
      }
    };
    fetchData();
  }, []);

  const handleSend = async () => {
    if (!title || !message) {
      toast({ title: 'Please fill all fields', variant: 'destructive' });
      return;
    }

    if (recipientType === 'branch' && !selectedBranchId) {
      toast({ title: 'Please select a branch', variant: 'destructive' });
      return;
    }

    if (recipientType === 'department' && !selectedDepartmentId) {
      toast({ title: 'Please select a department', variant: 'destructive' });
      return;
    }

    setIsSending(true);
    try {
      const messageData = {
        title,
        content: message,
        target_type: recipientType,
        target_branch_id: recipientType === 'branch' ? selectedBranchId : undefined,
        target_department_id: recipientType === 'department' ? selectedDepartmentId : undefined,
      };

      // TODO: Replace with actual API call when backend endpoint is ready
      // await api.sendMessage(messageData);
      await new Promise(resolve => setTimeout(resolve, 1000));

      const newMessage = {
        id: Date.now(),
        ...messageData,
        sent_at: new Date().toISOString(),
      };
      setSentMessages([newMessage, ...sentMessages]);

      toast({ title: 'Message sent successfully', variant: 'success' });
      setTitle('');
      setMessage('');
      setRecipientType('all');
      setSelectedBranchId('');
      setSelectedDepartmentId('');
    } catch (error) {
      toast({ title: 'Failed to send message', variant: 'destructive' });
    } finally {
      setIsSending(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-green-700">Send Message</h1>
        <p className="text-gray-500">Send announcements to staff members</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <MessageSquare className="w-5 h-5" />
            New Announcement
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Send To
            </label>
            <div className="grid grid-cols-3 gap-3">
              <button
                onClick={() => {
                  setRecipientType('all');
                  setSelectedBranchId('');
                  setSelectedDepartmentId('');
                }}
                className={`p-4 border-2 rounded-lg flex flex-col items-center gap-2 transition-colors ${
                  recipientType === 'all'
                    ? 'border-green-500 bg-green-50'
                    : 'border-gray-200 hover:border-gray-300'
                }`}
              >
                <Users className={`w-6 h-6 ${recipientType === 'all' ? 'text-green-600' : 'text-gray-500'}`} />
                <span className="text-sm font-medium">All Staff</span>
              </button>
              <button
                onClick={() => {
                  setRecipientType('branch');
                  setSelectedDepartmentId('');
                }}
                className={`p-4 border-2 rounded-lg flex flex-col items-center gap-2 transition-colors ${
                  recipientType === 'branch'
                    ? 'border-green-500 bg-green-50'
                    : 'border-gray-200 hover:border-gray-300'
                }`}
              >
                <Building2 className={`w-6 h-6 ${recipientType === 'branch' ? 'text-green-600' : 'text-gray-500'}`} />
                <span className="text-sm font-medium">By Branch</span>
              </button>
              <button
                onClick={() => {
                  setRecipientType('department');
                  setSelectedBranchId('');
                }}
                className={`p-4 border-2 rounded-lg flex flex-col items-center gap-2 transition-colors ${
                  recipientType === 'department'
                    ? 'border-green-500 bg-green-50'
                    : 'border-gray-200 hover:border-gray-300'
                }`}
              >
                <Layers className={`w-6 h-6 ${recipientType === 'department' ? 'text-green-600' : 'text-gray-500'}`} />
                <span className="text-sm font-medium">By Department</span>
              </button>
            </div>
          </div>

          {recipientType === 'branch' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Select Branch
              </label>
              <select
                value={selectedBranchId}
                onChange={(e) => setSelectedBranchId(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
              >
                <option value="">Choose a branch...</option>
                {branches.map((branch) => (
                  <option key={branch.id} value={branch.id}>
                    {branch.name}
                  </option>
                ))}
              </select>
            </div>
          )}

          {recipientType === 'department' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Select Department
              </label>
              <select
                value={selectedDepartmentId}
                onChange={(e) => setSelectedDepartmentId(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
              >
                <option value="">Choose a department...</option>
                {departments.map((dept) => (
                  <option key={dept.id} value={dept.id}>
                    {dept.name}
                  </option>
                ))}
              </select>
            </div>
          )}

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Title
            </label>
            <Input
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Message title"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Message
            </label>
            <textarea
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              placeholder="Type your message here..."
              rows={6}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
            />
          </div>

          <Button
            onClick={handleSend}
            disabled={isSending}
            className="w-full bg-green-600 hover:bg-green-700"
          >
            <Send className="w-4 h-4 mr-2" />
            {isSending ? 'Sending...' : 'Send Message'}
          </Button>
        </CardContent>
      </Card>

      {sentMessages.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Sent Messages</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {sentMessages.map((msg) => (
                <div key={msg.id} className="p-4 border border-gray-200 rounded-lg">
                  <div className="flex items-start justify-between mb-2">
                    <div className="flex items-center gap-2">
                      <CheckCircle className="w-5 h-5 text-green-600" />
                      <h4 className="font-semibold text-gray-900">{msg.title}</h4>
                    </div>
                    <span className="text-xs text-gray-500">
                      {new Date(msg.sent_at).toLocaleString()}
                    </span>
                  </div>
                  <p className="text-sm text-gray-600 mb-2">{msg.content}</p>
                  <div className="flex items-center gap-2">
                    <span className="px-2 py-1 bg-green-100 text-green-700 rounded text-xs font-medium">
                      {msg.target_type === 'all' ? 'All Staff' : msg.target_type === 'branch' ? 'Branch' : 'Department'}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
