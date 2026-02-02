'use client';

import { useEffect, useState } from 'react';
import api from '@/lib/api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { LoadingSpinner, BouncingDots } from '@/components/shared/LoadingSpinner';
import { toast } from '@/components/ui/toaster';
import {
  Clock,
  Plus,
  Edit2,
  Trash2,
  Save,
  X,
  Coffee,
  Sun,
  Moon,
  Sunrise,
} from 'lucide-react';

interface ShiftTemplate {
  id: string;
  name: string;
  start_time: string;
  end_time: string;
  break_duration: number;
  total_hours: number;
  is_active: boolean;
}

const defaultShifts: ShiftTemplate[] = [
  { id: '1', name: 'Morning Shift', start_time: '06:00', end_time: '14:00', break_duration: 60, total_hours: 7, is_active: true },
  { id: '2', name: 'Afternoon Shift', start_time: '14:00', end_time: '22:00', break_duration: 60, total_hours: 7, is_active: true },
  { id: '3', name: 'Night Shift', start_time: '22:00', end_time: '06:00', break_duration: 60, total_hours: 7, is_active: true },
  { id: '4', name: 'Full Day', start_time: '08:00', end_time: '17:00', break_duration: 60, total_hours: 8, is_active: true },
];

export default function ShiftTimesPage() {
  const [shifts, setShifts] = useState<ShiftTemplate[]>(defaultShifts);
  const [isLoading, setIsLoading] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [showAddForm, setShowAddForm] = useState(false);
  const [isSaving, setIsSaving] = useState(false);

  const [formData, setFormData] = useState({
    name: '',
    start_time: '',
    end_time: '',
    break_duration: 60,
  });

  const calculateTotalHours = (start: string, end: string, breakMins: number): number => {
    if (!start || !end) return 0;
    const [startH, startM] = start.split(':').map(Number);
    const [endH, endM] = end.split(':').map(Number);
    
    let startMins = startH * 60 + startM;
    let endMins = endH * 60 + endM;
    
    if (endMins < startMins) endMins += 24 * 60; // Overnight shift
    
    const totalMins = endMins - startMins - breakMins;
    return Math.round(totalMins / 60 * 10) / 10;
  };

  const getShiftIcon = (name: string) => {
    const lower = name.toLowerCase();
    if (lower.includes('morning')) return <Sunrise className="w-5 h-5" />;
    if (lower.includes('afternoon')) return <Sun className="w-5 h-5" />;
    if (lower.includes('night')) return <Moon className="w-5 h-5" />;
    return <Clock className="w-5 h-5" />;
  };

  const getShiftColor = (name: string) => {
    const lower = name.toLowerCase();
    if (lower.includes('morning')) return 'bg-orange-100 text-orange-600';
    if (lower.includes('afternoon')) return 'bg-yellow-100 text-yellow-600';
    if (lower.includes('night')) return 'bg-indigo-100 text-indigo-600';
    return 'bg-blue-100 text-blue-600';
  };

  const handleAdd = () => {
    if (!formData.name || !formData.start_time || !formData.end_time) {
      toast({ title: 'Please fill all required fields', variant: 'destructive' });
      return;
    }

    const totalHours = calculateTotalHours(formData.start_time, formData.end_time, formData.break_duration);
    
    const newShift: ShiftTemplate = {
      id: Date.now().toString(),
      name: formData.name,
      start_time: formData.start_time,
      end_time: formData.end_time,
      break_duration: formData.break_duration,
      total_hours: totalHours,
      is_active: true,
    };

    setShifts([...shifts, newShift]);
    setShowAddForm(false);
    setFormData({ name: '', start_time: '', end_time: '', break_duration: 60 });
    toast({ title: 'Shift template added', variant: 'success' });
  };

  const handleEdit = (shift: ShiftTemplate) => {
    setEditingId(shift.id);
    setFormData({
      name: shift.name,
      start_time: shift.start_time,
      end_time: shift.end_time,
      break_duration: shift.break_duration,
    });
  };

  const handleUpdate = (id: string) => {
    if (!formData.name || !formData.start_time || !formData.end_time) {
      toast({ title: 'Please fill all required fields', variant: 'destructive' });
      return;
    }

    const totalHours = calculateTotalHours(formData.start_time, formData.end_time, formData.break_duration);
    
    setShifts(shifts.map(s => 
      s.id === id 
        ? { ...s, ...formData, total_hours: totalHours }
        : s
    ));
    setEditingId(null);
    setFormData({ name: '', start_time: '', end_time: '', break_duration: 60 });
    toast({ title: 'Shift template updated', variant: 'success' });
  };

  const handleDelete = (id: string) => {
    if (confirm('Are you sure you want to delete this shift template?')) {
      setShifts(shifts.filter(s => s.id !== id));
      toast({ title: 'Shift template deleted', variant: 'success' });
    }
  };

  const handleToggleActive = (id: string) => {
    setShifts(shifts.map(s => 
      s.id === id ? { ...s, is_active: !s.is_active } : s
    ));
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Shift Times</h1>
          <p className="text-gray-500">Configure shift templates for rosters</p>
        </div>
        <Button onClick={() => setShowAddForm(true)}>
          <Plus className="w-4 h-4 mr-2" />
          Add Shift Template
        </Button>
      </div>

      {/* Add Form */}
      {showAddForm && (
        <Card>
          <CardHeader>
            <CardTitle>Add New Shift Template</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="text-sm text-gray-500">Shift Name *</label>
                <Input
                  value={formData.name}
                  onChange={(e) => setFormData({...formData, name: e.target.value})}
                  placeholder="e.g., Morning Shift"
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Break Duration (minutes)</label>
                <Input
                  type="number"
                  value={formData.break_duration}
                  onChange={(e) => setFormData({...formData, break_duration: Number(e.target.value)})}
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">Start Time *</label>
                <Input
                  type="time"
                  value={formData.start_time}
                  onChange={(e) => setFormData({...formData, start_time: e.target.value})}
                  className="mt-1"
                />
              </div>
              <div>
                <label className="text-sm text-gray-500">End Time *</label>
                <Input
                  type="time"
                  value={formData.end_time}
                  onChange={(e) => setFormData({...formData, end_time: e.target.value})}
                  className="mt-1"
                />
              </div>
            </div>
            {formData.start_time && formData.end_time && (
              <p className="text-sm text-gray-500">
                Total Hours: {calculateTotalHours(formData.start_time, formData.end_time, formData.break_duration)} hours (excluding break)
              </p>
            )}
            <div className="flex gap-3">
              <Button onClick={handleAdd}>
                <Save className="w-4 h-4 mr-2" />
                Save Template
              </Button>
              <Button variant="outline" onClick={() => {
                setShowAddForm(false);
                setFormData({ name: '', start_time: '', end_time: '', break_duration: 60 });
              }}>
                Cancel
              </Button>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Shift Templates List */}
      <div className="grid gap-4">
        {shifts.map((shift) => (
          <Card key={shift.id} className={!shift.is_active ? 'opacity-50' : ''}>
            <CardContent className="pt-6">
              {editingId === shift.id ? (
                <div className="space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="text-sm text-gray-500">Shift Name</label>
                      <Input
                        value={formData.name}
                        onChange={(e) => setFormData({...formData, name: e.target.value})}
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <label className="text-sm text-gray-500">Break (minutes)</label>
                      <Input
                        type="number"
                        value={formData.break_duration}
                        onChange={(e) => setFormData({...formData, break_duration: Number(e.target.value)})}
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <label className="text-sm text-gray-500">Start Time</label>
                      <Input
                        type="time"
                        value={formData.start_time}
                        onChange={(e) => setFormData({...formData, start_time: e.target.value})}
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <label className="text-sm text-gray-500">End Time</label>
                      <Input
                        type="time"
                        value={formData.end_time}
                        onChange={(e) => setFormData({...formData, end_time: e.target.value})}
                        className="mt-1"
                      />
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <Button size="sm" onClick={() => handleUpdate(shift.id)}>
                      <Save className="w-4 h-4 mr-1" /> Save
                    </Button>
                    <Button size="sm" variant="outline" onClick={() => {
                      setEditingId(null);
                      setFormData({ name: '', start_time: '', end_time: '', break_duration: 60 });
                    }}>
                      Cancel
                    </Button>
                  </div>
                </div>
              ) : (
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className={`p-3 rounded-xl ${getShiftColor(shift.name)}`}>
                      {getShiftIcon(shift.name)}
                    </div>
                    <div>
                      <h3 className="font-semibold text-gray-900">{shift.name}</h3>
                      <p className="text-sm text-gray-500">
                        {shift.start_time} - {shift.end_time} • {shift.total_hours} hours
                      </p>
                      <p className="text-xs text-gray-400">
                        <Coffee className="w-3 h-3 inline mr-1" />
                        {shift.break_duration} min break
                      </p>
                    </div>
                  </div>
                  
                  <div className="flex items-center gap-2">
                    <label className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={shift.is_active}
                        onChange={() => handleToggleActive(shift.id)}
                        className="w-4 h-4 rounded border-gray-300"
                      />
                      <span className="text-sm text-gray-500">Active</span>
                    </label>
                    <Button variant="ghost" size="sm" onClick={() => handleEdit(shift)}>
                      <Edit2 className="w-4 h-4" />
                    </Button>
                    <Button variant="ghost" size="sm" onClick={() => handleDelete(shift.id)} className="text-red-500 hover:text-red-700">
                      <Trash2 className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
              )}
            </CardContent>
          </Card>
        ))}
      </div>

      {shifts.length === 0 && (
        <Card>
          <CardContent className="py-12 text-center">
            <Clock className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No shift templates</h3>
            <p className="text-gray-500">Add shift templates to use in rosters</p>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
