/**
 * Simple URL-safe encoding/decoding for staff IDs
 * This provides basic obfuscation - not cryptographic security
 */

export function encodeStaffId(id: string): string {
  try {
    // Convert UUID to base64 and make it URL-safe
    const encoded = btoa(id)
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=/g, '');
    return encoded;
  } catch (error) {
    console.error('Failed to encode staff ID:', error);
    return id;
  }
}

export function decodeStaffId(encoded: string): string {
  try {
    // Reverse the URL-safe encoding
    const base64 = encoded
      .replace(/-/g, '+')
      .replace(/_/g, '/');
    
    // Add padding if needed
    const padded = base64 + '=='.substring(0, (4 - base64.length % 4) % 4);
    
    const decoded = atob(padded);
    return decoded;
  } catch (error) {
    console.error('Failed to decode staff ID:', error);
    return encoded;
  }
}

/**
 * Generate staff profile URL with encoded ID
 */
export function getStaffProfileUrl(staffId: string): string {
  const encoded = encodeStaffId(staffId);
  return `/dashboard/staff/${encoded}`;
}

/**
 * Check if a string looks like a valid UUID
 */
export function isValidUUID(str: string): boolean {
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  return uuidRegex.test(str);
}
