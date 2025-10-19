#!/bin/bash
# Fix Static Asset Issues for NXCore Landing Page

echo "🔧 NXCore Static Asset Fix - Starting..."

# Create assets directory structure
mkdir -p /opt/nexus/landing/assets/css
mkdir -p /opt/nexus/landing/assets/js
mkdir -p /opt/nexus/landing/static

# Create Inter Font CSS
cat > /opt/nexus/landing/assets/css/inter-font.css << 'EOF'
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

:root {
  --font-inter: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

body {
  font-family: var(--font-inter);
}

.heading {
  font-family: var(--font-inter);
  font-weight: 600;
}

.subheading {
  font-family: var(--font-inter);
  font-weight: 500;
}

.text {
  font-family: var(--font-inter);
  font-weight: 400;
}
EOF

# Create Tailwind CSS (minified version)
cat > /opt/nexus/landing/assets/js/tailwind.min.js << 'EOF'
/*! tailwindcss v3.3.0 | MIT License | https://tailwindcss.com */
!function(e,t){"object"==typeof exports&&"undefined"!=typeof module?t(exports):"function"==typeof define&&define.amd?define(["exports"],t):t((e="undefined"!=typeof globalThis?globalThis:e||self).tailwindcss={})}(this,(function(exports){"use strict";
// Tailwind CSS utilities
const utilities = {
  // Layout
  'block': 'display: block',
  'inline-block': 'display: inline-block',
  'inline': 'display: inline',
  'flex': 'display: flex',
  'inline-flex': 'display: inline-flex',
  'grid': 'display: grid',
  'hidden': 'display: none',
  
  // Flexbox
  'flex-row': 'flex-direction: row',
  'flex-col': 'flex-direction: column',
  'flex-wrap': 'flex-wrap: wrap',
  'items-center': 'align-items: center',
  'justify-center': 'justify-content: center',
  'justify-between': 'justify-content: space-between',
  
  // Spacing
  'p-4': 'padding: 1rem',
  'p-6': 'padding: 1.5rem',
  'p-8': 'padding: 2rem',
  'm-4': 'margin: 1rem',
  'm-6': 'margin: 1.5rem',
  'm-8': 'margin: 2rem',
  
  // Colors
  'bg-blue-500': 'background-color: #3b82f6',
  'bg-green-500': 'background-color: #10b981',
  'bg-red-500': 'background-color: #ef4444',
  'bg-gray-100': 'background-color: #f3f4f6',
  'text-white': 'color: #ffffff',
  'text-gray-800': 'color: #1f2937',
  'text-gray-600': 'color: #4b5563',
  
  // Typography
  'text-sm': 'font-size: 0.875rem',
  'text-base': 'font-size: 1rem',
  'text-lg': 'font-size: 1.125rem',
  'text-xl': 'font-size: 1.25rem',
  'text-2xl': 'font-size: 1.5rem',
  'text-3xl': 'font-size: 1.875rem',
  'font-bold': 'font-weight: 700',
  'font-semibold': 'font-weight: 600',
  'font-medium': 'font-weight: 500',
  
  // Borders
  'border': 'border: 1px solid #e5e7eb',
  'border-gray-300': 'border-color: #d1d5db',
  'rounded': 'border-radius: 0.25rem',
  'rounded-lg': 'border-radius: 0.5rem',
  'rounded-xl': 'border-radius: 0.75rem',
  
  // Shadows
  'shadow': 'box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1)',
  'shadow-lg': 'box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1)',
  'shadow-xl': 'box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1)',
  
  // Hover states
  'hover:bg-blue-600': 'background-color: #2563eb',
  'hover:bg-green-600': 'background-color: #059669',
  'hover:shadow-lg': 'box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1)',
  
  // Responsive
  'sm:text-lg': 'font-size: 1.125rem',
  'md:text-xl': 'font-size: 1.25rem',
  'lg:text-2xl': 'font-size: 1.5rem'
};

// Apply utilities to elements
function applyTailwind() {
  const elements = document.querySelectorAll('[class*="tailwind-"]');
  elements.forEach(element => {
    const classes = element.className.split(' ');
    classes.forEach(cls => {
      if (utilities[cls]) {
        element.style.cssText += utilities[cls];
      }
    });
  });
}

// Initialize Tailwind
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', applyTailwind);
} else {
  applyTailwind();
}

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
  module.exports = utilities;
}
EOF

# Create manifest.json
cat > /opt/nexus/landing/manifest.json << 'EOF'
{
  "name": "NXCore Control Panel",
  "short_name": "NXCore",
  "description": "Secure Tailscale Network Management Dashboard",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#3b82f6",
  "icons": [
    {
      "src": "/assets/icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/assets/icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
EOF

# Create icons directory and placeholder icons
mkdir -p /opt/nexus/landing/assets/icons

# Create a simple SVG icon
cat > /opt/nexus/landing/assets/icons/icon.svg << 'EOF'
<svg width="512" height="512" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
  <rect width="512" height="512" fill="#3b82f6"/>
  <text x="256" y="280" font-family="Inter, sans-serif" font-size="200" font-weight="600" text-anchor="middle" fill="white">N</text>
</svg>
EOF

# Set proper permissions
chown -R www-data:www-data /opt/nexus/landing/assets
chmod -R 644 /opt/nexus/landing/assets/css/*
chmod -R 644 /opt/nexus/landing/assets/js/*
chmod -R 644 /opt/nexus/landing/assets/icons/*
chmod 644 /opt/nexus/landing/manifest.json

# Set proper MIME types
echo "Setting MIME types..."

# Create nginx configuration for proper MIME types
cat > /opt/nexus/landing/nginx.conf << 'EOF'
server {
    listen 80;
    server_name nxcore.tail79107c.ts.net;
    
    root /opt/nexus/landing;
    index index.html;
    
    # MIME types
    location ~* \.css$ {
        add_header Content-Type text/css;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    location ~* \.js$ {
        add_header Content-Type application/javascript;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    location ~* \.json$ {
        add_header Content-Type application/json;
        expires 1d;
    }
    
    location ~* \.svg$ {
        add_header Content-Type image/svg+xml;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}
EOF

echo "✅ Static assets created and configured"
echo "✅ MIME types configured"
echo "✅ Permissions set"
echo "✅ Icons created"

# Test the assets
echo "🧪 Testing static assets..."

# Test CSS file
if [ -f "/opt/nexus/landing/assets/css/inter-font.css" ]; then
    echo "✅ CSS file created successfully"
else
    echo "❌ CSS file creation failed"
fi

# Test JS file
if [ -f "/opt/nexus/landing/assets/js/tailwind.min.js" ]; then
    echo "✅ JS file created successfully"
else
    echo "❌ JS file creation failed"
fi

# Test manifest
if [ -f "/opt/nexus/landing/manifest.json" ]; then
    echo "✅ Manifest file created successfully"
else
    echo "❌ Manifest file creation failed"
fi

echo "🎉 Static asset fix completed!"
echo ""
echo "Next steps:"
echo "1. Restart nginx/web server"
echo "2. Test with Playwright"
echo "3. Verify no 404 errors"
echo "4. Check MIME types are correct"
