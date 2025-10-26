/**
 * Convert a number to its ordinal form (1st, 2nd, 3rd, 4th, etc.)
 */
export function toOrdinal(num: number | string): string {
  const n = typeof num === 'string' ? parseInt(num, 10) : num;
  
  if (isNaN(n)) return num.toString();
  
  const lastDigit = n % 10;
  const lastTwoDigits = n % 100;
  
  // Handle special cases for 11th, 12th, 13th
  if (lastTwoDigits >= 11 && lastTwoDigits <= 13) {
    return `${n}th`;
  }
  
  // Handle regular cases
  switch (lastDigit) {
    case 1:
      return `${n}st`;
    case 2:
      return `${n}nd`;
    case 3:
      return `${n}rd`;
    default:
      return `${n}th`;
  }
}

/**
 * Format a century number with proper ordinal suffix
 */
export function formatCentury(century: number | string): string {
  return `${toOrdinal(century)} century`;
}
