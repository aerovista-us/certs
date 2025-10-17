import { test, expect } from '@playwright/test';

test.describe('Static Assets Loading', () => {
  test('AI service loads static assets correctly', async ({ page }) => {
    // Navigate to the AI service
    await page.goto('/ai/', { waitUntil: 'networkidle' });
    
    // Check if the page loads without 404 errors for static assets
    const response = await page.waitForResponse(response => 
      response.url().includes('/static/') || response.url().includes('/_app/')
    );
    
    expect(response.status()).toBeLessThan(400);
  });

  test('Grafana loads without asset errors', async ({ page }) => {
    await page.goto('/grafana/', { waitUntil: 'networkidle' });
    
    // Check for common Grafana static assets
    const response = await page.waitForResponse(response => 
      response.url().includes('/public/') || response.url().includes('/static/')
    );
    
    expect(response.status()).toBeLessThan(400);
  });

  test('Prometheus loads without asset errors', async ({ page }) => {
    await page.goto('/prometheus/', { waitUntil: 'networkidle' });
    
    // Prometheus should load its static assets
    const response = await page.waitForResponse(response => 
      response.url().includes('/static/') || response.url().includes('/web/')
    );
    
    expect(response.status()).toBeLessThan(400);
  });
});
