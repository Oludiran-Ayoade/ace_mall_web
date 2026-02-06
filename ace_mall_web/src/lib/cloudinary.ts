// Cloudinary optimization utilities
export const CLOUDINARY_CONFIG = {
  cloud_name: 'desk7uuna',
  upload_preset: 'flutter_uploads',
};

/**
 * Optimizes Cloudinary image URL with automatic format and quality settings
 * This reduces a 3MB image to typically 300-500KB
 * @param url - Original Cloudinary URL
 * @param options - Optional transformation parameters
 */
export function optimizeCloudinaryUrl(
  url: string,
  options: {
    width?: number;
    height?: number;
    crop?: 'fill' | 'fit' | 'scale' | 'thumb';
  } = {}
): string {
  if (!url || !url.includes('cloudinary.com')) {
    return url;
  }

  // Extract the base URL and path
  const urlParts = url.split('/upload/');
  if (urlParts.length !== 2) {
    return url;
  }

  const [baseUrl, imagePath] = urlParts;

  // Build transformation string
  const transformations: string[] = [
    'f_auto', // Auto format (WebP for browsers that support it, otherwise JPEG/PNG)
    'q_auto', // Auto quality (reduces file size while maintaining visual quality)
  ];

  // Add optional transformations
  if (options.width) {
    transformations.push(`w_${options.width}`);
  }
  if (options.height) {
    transformations.push(`h_${options.height}`);
  }
  if (options.crop) {
    transformations.push(`c_${options.crop}`);
  }

  // Reconstruct URL with optimizations
  return `${baseUrl}/upload/${transformations.join(',')}/${imagePath}`;
}

/**
 * Upload file to Cloudinary with optimization
 */
export async function uploadToCloudinary(
  file: File,
  folder: string
): Promise<{ url: string; publicId: string }> {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('upload_preset', CLOUDINARY_CONFIG.upload_preset);
  formData.append('folder', folder);

  const response = await fetch(
    `https://api.cloudinary.com/v1_1/${CLOUDINARY_CONFIG.cloud_name}/auto/upload`,
    {
      method: 'POST',
      body: formData,
    }
  );

  if (!response.ok) {
    throw new Error('Failed to upload to Cloudinary');
  }

  const data = await response.json();
  
  // Return optimized URL automatically
  return {
    url: optimizeCloudinaryUrl(data.secure_url),
    publicId: data.public_id,
  };
}
