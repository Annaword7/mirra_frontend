/**
 * Mirra Tailwind theme extension.
 * Derived from the Flutter implementation (mi_r_r_a_dev v2.4.0+102).
 * For any web surface (marketing site / web admin). The mobile app itself is Flutter —
 * the canonical binding there is `FFDesignTokens` in lib/flutter_flow/flutter_flow_theme.dart.
 *
 * Usage: const mirra = require('./design_system/tokens/tailwind.theme.js');
 *        module.exports = { theme: { extend: mirra } };
 */
module.exports = {
  colors: {
    primary: { DEFAULT: '#5C85D9', variant: '#3B6FCC' },
    secondary: '#F2EBB4',
    tertiary: '#F4CFBC',
    text: {
      primary: '#1A1A1A',
      secondary: '#6B6B6B', // darkened from #929292 for WCAG AA
      tertiary: '#555555',
      disabled: '#AFAFB0',
      'on-primary': '#FFFFFF',
    },
    surface: {
      DEFAULT: '#FFFFFF',
      muted: '#F3F4F6',
      background: '#EBF0FC',
      'background-raised': '#CBDDFE',
    },
    border: { DEFAULT: '#E0E0E0', divider: '#E6E6E6' },
    success: { DEFAULT: '#2E7D32', bg: '#E8F5E9' },
    warning: { DEFAULT: '#F9A825', bg: '#FFF3E0' },
    error:   { DEFAULT: '#E53935', bg: '#FFEBEE' },
    info: '#5C85D9',
  },
  fontFamily: {
    sans: ['Raleway', 'sans-serif'],
  },
  fontSize: {
    'display-lg':  ['57px', { lineHeight: '1.1' }],
    'display-md':  ['45px', { lineHeight: '1.1' }],
    'display-sm':  ['36px', { lineHeight: '1.1' }],
    'headline-lg': ['32px', { lineHeight: '1.15' }],
    'headline-md': ['24px', { lineHeight: '1.2' }],
    'headline-sm': ['22px', { lineHeight: '1.2' }],
    'title-lg':    ['20px', { lineHeight: '1.2' }],
    'title-md':    ['18px', { lineHeight: '1.3' }],
    'title-sm':    ['16px', { lineHeight: '1.3' }],
    'body-lg':     ['16px', { lineHeight: '1.5' }],
    'body-md':     ['14px', { lineHeight: '1.5' }],
    'body-sm':     ['12px', { lineHeight: '1.4' }],
    'label-lg':    ['16px', { lineHeight: '1.2' }],
    'label-md':    ['14px', { lineHeight: '1.2' }],
    'label-sm':    ['12px', { lineHeight: '1.2' }],
  },
  fontWeight: {
    regular: '400', medium: '500', semibold: '600', bold: '700',
  },
  spacing: {
    xxs: '2px', xs: '4px', sm: '8px', md: '12px', lg: '16px', xl: '20px',
    '2xl': '24px', '3xl': '32px', '4xl': '40px', '5xl': '48px', '6xl': '64px',
  },
  borderRadius: {
    xs: '4px', sm: '8px', md: '12px', lg: '16px', xl: '24px', '2xl': '32px', full: '9999px',
  },
  borderWidth: {
    hairline: '1px', thick: '2px',
  },
  boxShadow: {
    sm: '0 1px 3px rgba(0,0,0,0.10)',
    md: '0 3px 6px rgba(0,0,0,0.10)',
    lg: '0 8px 15px rgba(0,0,0,0.10)',
    xl: '0 16px 25px rgba(0,0,0,0.10)',
  },
  opacity: {
    4: '0.04', 8: '0.08', 12: '0.12', 16: '0.16', 24: '0.24',
    32: '0.32', 48: '0.48', 64: '0.64', 80: '0.80', 92: '0.92',
  },
  height: {
    'btn-sm': '36px', 'btn-md': '44px', 'btn-lg': '52px', input: '52px',
  },
  size: {
    'icon-xs': '16px', 'icon-sm': '20px', 'icon-md': '24px',
    'icon-lg': '28px', 'icon-xl': '32px', 'icon-2xl': '48px',
    'avatar-xs': '24px', 'avatar-sm': '32px', 'avatar-md': '40px',
    'avatar-lg': '56px', 'avatar-xl': '80px',
  },
  blur: { backdrop: '18px' },
};
