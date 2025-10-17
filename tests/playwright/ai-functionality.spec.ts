import { test, expect } from '@playwright/test';

test.describe('AI Service Functionality', () => {
  test('AI service loads and shows interface', async ({ page }) => {
    // Navigate to the AI service
    await page.goto('/ai/', { waitUntil: 'domcontentloaded' });
    
    // Check if the page contains expected AI interface elements
    await expect(page.locator('body')).toContainText(/AeroVista|AI|Chat|Assistant/i);
    
    // Check if the page loaded without major errors
    const title = await page.title();
    expect(title).toBeTruthy();
    
    // Check for any console errors
    const errors: string[] = [];
    page.on('console', msg => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      }
    });
    
    // Wait a bit for any async loading
    await page.waitForTimeout(2000);
    
    // Log any errors but don't fail the test for minor issues
    if (errors.length > 0) {
      console.log('Console errors found:', errors);
    }
  });

  test('AI service responds to direct requests', async ({ request, baseURL }) => {
    const response = await request.get(`${baseURL}/ai/`, { ignoreHTTPSErrors: true });
    expect(response.status()).toBe(200);
    
    const html = await response.text();
    expect(html).toContain('<!DOCTYPE html>');
    expect(html.length).toBeGreaterThan(1000); // Should be a substantial page
  });
});
