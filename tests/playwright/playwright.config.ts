import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  timeout: 30000,
  retries: 0,
  use: {
    baseURL: 'https://nxcore.tail79107c.ts.net',
    ignoreHTTPSErrors: true,
    actionTimeout: 10000,
    navigationTimeout: 15000,
    trace: 'off',
    acceptDownloads: true,
    bypassCSP: true,
  },
  projects: [
    {
      name: 'chromium',
      use: { 
        ...devices['Desktop Chrome'],
        baseURL: 'https://nxcore.tail79107c.ts.net',
        ignoreHTTPSErrors: true,
        acceptDownloads: true,
        bypassCSP: true,
      },
    },
  ],
});


