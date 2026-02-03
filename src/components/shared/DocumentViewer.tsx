'use client';

import { useState } from 'react';
import { X, Download, ZoomIn, ZoomOut } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface DocumentViewerProps {
  url: string;
  title: string;
  onClose: () => void;
}

export function DocumentViewer({ url, title, onClose }: DocumentViewerProps) {
  const [zoom, setZoom] = useState(100);
  const isPDF = url.toLowerCase().endsWith('.pdf');

  const handleDownload = () => {
    window.open(url, '_blank');
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/80 flex items-center justify-center p-4">
      <div className="bg-white rounded-lg w-full max-w-4xl h-[90vh] flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b">
          <h2 className="text-lg font-semibold">{title}</h2>
          <div className="flex items-center gap-2">
            {!isPDF && (
              <>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setZoom(Math.max(50, zoom - 25))}
                  disabled={zoom <= 50}
                >
                  <ZoomOut className="w-4 h-4" />
                </Button>
                <span className="text-sm text-gray-600 min-w-[60px] text-center">
                  {zoom}%
                </span>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setZoom(Math.min(200, zoom + 25))}
                  disabled={zoom >= 200}
                >
                  <ZoomIn className="w-4 h-4" />
                </Button>
              </>
            )}
            <Button variant="outline" size="sm" onClick={handleDownload}>
              <Download className="w-4 h-4 mr-2" />
              Download
            </Button>
            <Button variant="ghost" size="sm" onClick={onClose}>
              <X className="w-4 h-4" />
            </Button>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-auto bg-gray-100 flex items-center justify-center p-4">
          {isPDF ? (
            <iframe
              src={url}
              className="w-full h-full bg-white rounded"
              title={title}
            />
          ) : (
            <img
              src={url}
              alt={title}
              className="max-w-full max-h-full object-contain rounded"
              style={{ transform: `scale(${zoom / 100})` }}
            />
          )}
        </div>
      </div>
    </div>
  );
}
