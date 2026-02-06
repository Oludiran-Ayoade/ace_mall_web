'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { UserMinus, X } from 'lucide-react';

interface TerminateStaffDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: (data: {
    termination_type: string;
    reason: string;
    last_working_day?: string;
  }) => void;
  staffName: string;
  isLoading?: boolean;
}

export function TerminateStaffDialog({
  isOpen,
  onClose,
  onConfirm,
  staffName,
  isLoading = false,
}: TerminateStaffDialogProps) {
  const [terminationType, setTerminationType] = useState<string>('terminated');
  const [reason, setReason] = useState<string>('');
  const [lastWorkingDay, setLastWorkingDay] = useState<string>('');

  const handleSubmit = () => {
    if (!reason.trim()) {
      alert('Please provide a reason for termination');
      return;
    }

    onConfirm({
      termination_type: terminationType,
      reason: reason.trim(),
      last_working_day: lastWorkingDay || undefined,
    });
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-xl max-w-md w-full">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-red-100 flex items-center justify-center">
              <UserMinus className="w-5 h-5 text-red-600" />
            </div>
            <div>
              <h2 className="text-lg font-semibold text-gray-900">Terminate Staff</h2>
              <p className="text-sm text-gray-500">{staffName}</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600"
            disabled={isLoading}
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Body */}
        <div className="p-6 space-y-4">
          {/* Termination Type */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Termination Type <span className="text-red-500">*</span>
            </label>
            <select
              value={terminationType}
              onChange={(e) => setTerminationType(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-transparent"
              disabled={isLoading}
            >
              <option value="terminated">Terminated (Fired)</option>
              <option value="resigned">Resigned (Staff Left)</option>
              <option value="retired">Retired</option>
              <option value="contract_ended">Contract Ended</option>
            </select>
          </div>

          {/* Reason */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Reason <span className="text-red-500">*</span>
            </label>
            <textarea
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              placeholder={
                terminationType === 'terminated'
                  ? 'e.g., Poor performance, misconduct, policy violation...'
                  : terminationType === 'resigned'
                  ? 'e.g., Better opportunity, personal reasons, relocation...'
                  : 'Enter reason...'
              }
              rows={4}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-transparent resize-none"
              disabled={isLoading}
            />
            <p className="mt-1 text-xs text-gray-500">
              This will be stored on the staff's profile
            </p>
          </div>

          {/* Last Working Day */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Last Working Day (Optional)
            </label>
            <Input
              type="date"
              value={lastWorkingDay}
              onChange={(e) => setLastWorkingDay(e.target.value)}
              disabled={isLoading}
            />
          </div>

          {/* Warning */}
          <div className="bg-red-50 border border-red-200 rounded-lg p-4">
            <p className="text-sm text-red-800">
              <strong>⚠️ Warning:</strong> This action will:
            </p>
            <ul className="mt-2 text-sm text-red-700 list-disc list-inside space-y-1">
              <li>Deactivate the staff's account</li>
              <li>Prevent them from logging in</li>
              <li>Move them to "Terminated Staff" section</li>
              <li>Record the termination reason</li>
            </ul>
          </div>
        </div>

        {/* Footer */}
        <div className="flex items-center justify-end gap-3 p-6 border-t bg-gray-50">
          <Button
            variant="outline"
            onClick={onClose}
            disabled={isLoading}
          >
            Cancel
          </Button>
          <Button
            onClick={handleSubmit}
            disabled={isLoading || !reason.trim()}
            className="bg-red-600 hover:bg-red-700"
          >
            {isLoading ? 'Processing...' : 'Terminate Staff'}
          </Button>
        </div>
      </div>
    </div>
  );
}
