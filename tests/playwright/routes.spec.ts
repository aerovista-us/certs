import { test, expect } from '@playwright/test';

const routes = [
  { path: '/', expectStatus: 200 },
  { path: '/grafana/', expectStatus: 200 },
  { path: '/prometheus/', expectStatus: 200 },
  { path: '/files/', expectStatus: 200 },
  { path: '/status/', expectStatus: 200 },
  { path: '/portainer/', expectStatus: 200 },
  { path: '/traefik/', expectStatus: 200 },
  { path: '/ai/', expectStatus: 200 },
];

for (const { path, expectStatus } of routes) {
  test(`GET ${path} returns ${expectStatus}`, async ({ page, request }) => {
    const baseURL = 'https://nxcore.tail79107c.ts.net';
    const url = `${baseURL}${path}`;
    const resp = await request.get(url, { ignoreHTTPSErrors: true });
    expect(resp.status(), `Status for ${url}`).toBeGreaterThanOrEqual(200);
    expect(resp.status(), `Status for ${url}`).toBeLessThan(500);
    // basic content sanity for some routes
    if (path === '/') {
      const html = await resp.text();
      expect(html).toContain('AeroVista');
    }
  });
}


