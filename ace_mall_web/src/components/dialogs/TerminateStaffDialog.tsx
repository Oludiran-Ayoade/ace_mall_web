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
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-2 sm:p-4">
      <div className="bg-white rounded-lg shadow-xl max-w-md w-full max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-full bg-red-100 flex items-center justify-center">
              <UserMinus className="w-4 h-4 text-red-600" />
            </div>
            <div>
              <h2 className="text-base font-semibold text-gray-900">Terminate Staff</h2>
              <p className="text-xs text-gray-500 truncate max-w-[200px]">{staffName}</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600"
            disabled={isLoading}
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Body */}
        <div className="p-4 space-y-3">
          {/* Termination Type */}
          <div>
            <label className="block text-xs font-medium text-gray-700 mb-1">
              Type <span className="text-red-500">*</span>
            </label>
            <select
              value={terminationType}
              onChange={(e) => setTerminationType(e.target.value)}
              className="w-full px-2 py-1.5 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-transparent"
              disabled={isLoading}
            >
              <option value="terminated">Terminated</option>
              <option value="resigned">Resigned</option>
              <option value="retired">Retired</option>
              <option value="contract_ended">Contract Ended</option>
            </select>
          </div>

          {/* Reason */}
          <div>
            <label className="block text-xs font-medium text-gray-700 mb-1">
              Reason <span className="text-red-500">*</span>
            </label>
            <textarea
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              placeholder="Enter termination reason..."
              rows={2}
              className="w-full px-2 py-1.5 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-transparent resize-none"
              disabled={isLoading}
            />
          </div>

          {/* Last Working Day */}
          <div>
            <label className="block text-xs font-medium text-gray-700 mb-1">
              Last Working Day
            </label>
            <Input
              type="date"
              value={lastWorkingDay}
              onChange={(e) => setLastWorkingDay(e.target.value)}
              disabled={isLoading}
              className="text-sm h-8"
            />
          </div>

          {/* Warning */}
          <div className="bg-red-50 border border-red-200 rounded-lg p-2">
            <p className="text-xs text-red-800 font-medium">
              ⚠️ This will deactivate the account
            </p>
          </div>
        </div>

        {/* Footer */}
        <div className="flex items-center justify-end gap-2 p-4 border-t bg-gray-50">
          <Button
            variant="outline"
            onClick={onClose}
            disabled={isLoading}
            className="text-sm h-8 px-3"
          >
            Cancel
          </Button>
          <Button
            onClick={handleSubmit}
            disabled={isLoading || !reason.trim()}
            className="bg-red-600 hover:bg-red-700 text-sm h-8 px-3"
          >
            {isLoading ? 'Processing...' : 'Terminate'}
          </Button>
        </div>
      </div>
    </div>
  );
}
