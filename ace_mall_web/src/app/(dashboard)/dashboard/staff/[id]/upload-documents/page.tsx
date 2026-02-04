'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import api from '@/lib/api';
import { User } from '@/types';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { LoadingSpinner } from '@/components/shared/LoadingSpinner';
import { ArrowLeft, Upload, FileText, Check, X } from 'lucide-react';
import { toast } from 'react-toastify';

const CLOUDINARY_UPLOAD_PRESET = 'flutter_uploads';
const CLOUDINARY_CLOUD_NAME = 'desk7uuna';

interface DocumentField {
  key: string;
  label: string;
  category: 'staff' | 'guarantor1' | 'guarantor2';
}

const DOCUMENT_FIELDS: DocumentField[] = [
  // Staff Documents
  { key: 'passport_url', label: 'Passport', category: 'staff' },
  { key: 'national_id_url', label: 'National ID', category: 'staff' },
  { key: 'birth_certificate_url', label: 'Birth Certificate', category: 'staff' },
  { key: 'waec_certificate_url', label: 'WAEC Certificate', category: 'staff' },
  { key: 'neco_certificate_url', label: 'NECO Certificate', category: 'staff' },
  { key: 'jamb_result_url', label: 'JAMB Result', category: 'staff' },
  { key: 'degree_certificate_url', label: 'Degree Certificate', category: 'staff' },
  { key: 'diploma_certificate_url', label: 'Diploma Certificate', category: 'staff' },
  { key: 'nysc_certificate_url', label: 'NYSC Certificate', category: 'staff' },
  { key: 'state_of_origin_cert_url', label: 'State of Origin Certificate', category: 'staff' },
  { key: 'lga_certificate_url', label: 'LGA Certificate', category: 'staff' },
  { key: 'drivers_license_url', label: "Driver's License", category: 'staff' },
  { key: 'voters_card_url', label: "Voter's Card", category: 'staff' },
  { key: 'resume_url', label: 'Resume/CV', category: 'staff' },
  { key: 'cover_letter_url', label: 'Cover Letter', category: 'staff' },
  // Guarantor 1 Documents
  { key: 'g1_passport', label: 'Guarantor 1 Passport', category: 'guarantor1' },
  { key: 'g1_national_id', label: 'Guarantor 1 National ID', category: 'guarantor1' },
  { key: 'g1_work_id', label: 'Guarantor 1 Work ID', category: 'guarantor1' },
  // Guarantor 2 Documents
  { key: 'g2_passport', label: 'Guarantor 2 Passport', category: 'guarantor2' },
  { key: 'g2_national_id', label: 'Guarantor 2 National ID', category: 'guarantor2' },
  { key: 'g2_work_id', label: 'Guarantor 2 Work ID', category: 'guarantor2' },
];

export default function UploadDocumentsPage() {
  const params = useParams();
  const router = useRouter();
  const staffId = params.id as string;

  const [staff, setStaff] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [uploadingDoc, setUploadingDoc] = useState<string | null>(null);

  useEffect(() => {
    const fetchStaff = async () => {
      try {
        const response = await api.getStaffById(staffId);
        setStaff(response.user);
      } catch (error) {
        console.error('Failed to fetch staff:', error);
        toast.error('Failed to load staff details');
      } finally {
        setIsLoading(false);
      }
    };

    fetchStaff();
  }, [staffId]);

  const uploadToCloudinary = async (file: File, folder: string): Promise<string> => {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('upload_preset', CLOUDINARY_UPLOAD_PRESET);
    formData.append('folder', folder);

    const response = await fetch(
      `https://api.cloudinary.com/v1_1/${CLOUDINARY_CLOUD_NAME}/auto/upload`,
      {
        method: 'POST',
        body: formData,
      }
    );

    if (!response.ok) {
      throw new Error('Failed to upload to Cloudinary');
    }

    const data = await response.json();
    return data.secure_url;
  };

  const handleFileSelect = async (docField: DocumentField, event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    setUploadingDoc(docField.key);

    try {
      // Determine folder based on category
      let folder = 'ace_mall_staff/documents';
      if (docField.category === 'guarantor1' || docField.category === 'guarantor2') {
        folder = 'ace_mall_staff/guarantors';
      }

      // Upload to Cloudinary
      const documentUrl = await uploadToCloudinary(file, folder);

      // Update backend based on document type
      if (docField.category === 'staff') {
        // Update staff document
        const updateData: any = {};
        updateData[docField.key] = documentUrl;
        await api.updateStaffProfile(staffId, updateData);
      } else {
        // Upload guarantor document
        const guarantorNumber = docField.category === 'guarantor1' ? 1 : 2;
        // Extract document type: g1_passport -> passport, g2_national_id -> national_id, g2_work_id -> work_id
        const documentType = docField.key.substring(3); // Remove 'g1_' or 'g2_' prefix
        
        await api.uploadGuarantorDocument(staffId, guarantorNumber, documentType, documentUrl);
      }

      toast.success(`${docField.label} uploaded successfully!`);

      // Refresh staff data
      const response = await api.getStaffById(staffId);
      setStaff(response.user);
    } catch (error) {
      console.error('Upload error:', error);
      toast.error(`Failed to upload ${docField.label}`);
    } finally {
      setUploadingDoc(null);
    }
  };

  const getDocumentUrl = (docField: DocumentField): string | null => {
    if (!staff) return null;

    if (docField.category === 'staff') {
      return (staff as any)[docField.key] || null;
    } else if (docField.category === 'guarantor1') {
      const field = docField.key.replace('g1_', 'guarantor1_');
      return (staff as any)[field] || null;
    } else {
      const field = docField.key.replace('g2_', 'guarantor2_');
      return (staff as any)[field] || null;
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (!staff) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-500">Staff member not found</p>
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-4xl mx-auto">
      {/* Back Button */}
      <button
        onClick={() => router.back()}
        className="flex items-center gap-2 text-gray-500 hover:text-gray-700"
      >
        <ArrowLeft className="w-4 h-4" />
        Back to Profile
      </button>

      {/* Header */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <FileText className="w-6 h-6 text-primary" />
            Upload Documents for {staff.full_name}
          </CardTitle>
        </CardHeader>
      </Card>

      {/* Staff Documents */}
      <Card>
        <CardHeader>
          <CardTitle>Staff Documents</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {DOCUMENT_FIELDS.filter(doc => doc.category === 'staff').map(docField => {
              const existingUrl = getDocumentUrl(docField);
              const isUploading = uploadingDoc === docField.key;

              return (
                <div key={docField.key} className="border rounded-lg p-4">
                  <div className="flex items-center justify-between mb-2">
                    <label className="text-sm font-medium">{docField.label}</label>
                    {existingUrl && <Check className="w-5 h-5 text-green-600" />}
                  </div>
                  
                  <div className="flex gap-2">
                    <input
                      id={`file-staff-${docField.key}`}
                      type="file"
                      accept="image/*,application/pdf"
                      onChange={(e) => handleFileSelect(docField, e)}
                      disabled={isUploading}
                      className="hidden"
                    />
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      className="flex-1"
                      disabled={isUploading}
                      onClick={() => document.getElementById(`file-staff-${docField.key}`)?.click()}
                    >
                      {isUploading ? (
                        <>
                          <LoadingSpinner size="sm" />
                          <span className="ml-2">Uploading...</span>
                        </>
                      ) : (
                        <>
                          <Upload className="w-4 h-4 mr-2" />
                          {existingUrl ? 'Replace' : 'Upload'}
                        </>
                      )}
                    </Button>
                    
                    {existingUrl && (
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        onClick={() => window.open(existingUrl, '_blank')}
                      >
                        View
                      </Button>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>

      {/* Guarantor 1 Documents */}
      <Card>
        <CardHeader>
          <CardTitle>Guarantor 1 Documents</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {DOCUMENT_FIELDS.filter(doc => doc.category === 'guarantor1').map(docField => {
              const existingUrl = getDocumentUrl(docField);
              const isUploading = uploadingDoc === docField.key;

              return (
                <div key={docField.key} className="border rounded-lg p-4">
                  <div className="flex items-center justify-between mb-2">
                    <label className="text-sm font-medium">{docField.label.replace('Guarantor 1 ', '')}</label>
                    {existingUrl && <Check className="w-5 h-5 text-green-600" />}
                  </div>
                  
                  <div className="flex gap-2">
                    <input
                      id={`file-g1-${docField.key}`}
                      type="file"
                      accept="image/*,application/pdf"
                      onChange={(e) => handleFileSelect(docField, e)}
                      disabled={isUploading}
                      className="hidden"
                    />
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      className="flex-1"
                      disabled={isUploading}
                      onClick={() => document.getElementById(`file-g1-${docField.key}`)?.click()}
                    >
                      {isUploading ? (
                        <>
                          <LoadingSpinner size="sm" />
                          <span className="ml-2">Uploading...</span>
                        </>
                      ) : (
                        <>
                          <Upload className="w-4 h-4 mr-2" />
                          {existingUrl ? 'Replace' : 'Upload'}
                        </>
                      )}
                    </Button>
                    
                    {existingUrl && (
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        onClick={() => window.open(existingUrl, '_blank')}
                      >
                        View
                      </Button>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>

      {/* Guarantor 2 Documents */}
      <Card>
        <CardHeader>
          <CardTitle>Guarantor 2 Documents</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {DOCUMENT_FIELDS.filter(doc => doc.category === 'guarantor2').map(docField => {
              const existingUrl = getDocumentUrl(docField);
              const isUploading = uploadingDoc === docField.key;

              return (
                <div key={docField.key} className="border rounded-lg p-4">
                  <div className="flex items-center justify-between mb-2">
                    <label className="text-sm font-medium">{docField.label.replace('Guarantor 2 ', '')}</label>
                    {existingUrl && <Check className="w-5 h-5 text-green-600" />}
                  </div>
                  
                  <div className="flex gap-2">
                    <input
                      id={`file-g2-${docField.key}`}
                      type="file"
                      accept="image/*,application/pdf"
                      onChange={(e) => handleFileSelect(docField, e)}
                      disabled={isUploading}
                      className="hidden"
                    />
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      className="flex-1"
                      disabled={isUploading}
                      onClick={() => document.getElementById(`file-g2-${docField.key}`)?.click()}
                    >
                      {isUploading ? (
                        <>
                          <LoadingSpinner size="sm" />
                          <span className="ml-2">Uploading...</span>
                        </>
                      ) : (
                        <>
                          <Upload className="w-4 h-4 mr-2" />
                          {existingUrl ? 'Replace' : 'Upload'}
                        </>
                      )}
                    </Button>
                    
                    {existingUrl && (
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        onClick={() => window.open(existingUrl, '_blank')}
                      >
                        View
                      </Button>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
