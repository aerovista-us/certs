import { test, expect, Page } from '@playwright/test';

interface ServiceCheck {
  name: string;
  url: string;
  expectedStatus: number;
  expectedContent?: string[];
  shouldRedirect?: boolean;
  redirectUrl?: string;
}

const services: ServiceCheck[] = [
  {
    name: 'Landing Page',
    url: 'https://nxcore.tail79107c.ts.net/',
    expectedStatus: 200,
    expectedContent: ['AeroVista', 'NXCore', 'Infrastructure']
  },
  {
    name: 'Traefik API',
    url: 'https://nxcore.tail79107c.ts.net/api/http/routers',
    expectedStatus: 200,
    expectedContent: ['rule', 'service']
  },
  {
    name: 'Traefik Dashboard',
    url: 'https://nxcore.tail79107c.ts.net/dash',
    expectedStatus: 200,
    expectedContent: ['Traefik', 'dashboard']
  },
  {
    name: 'Grafana',
    url: 'https://nxcore.tail79107c.ts.net/grafana/',
    expectedStatus: 200,
    expectedContent: ['Grafana', 'login']
  },
  {
    name: 'Prometheus',
    url: 'https://nxcore.tail79107c.ts.net/prometheus/',
    expectedStatus: 200,
    expectedContent: ['Prometheus', 'targets']
  },
  {
    name: 'Portainer',
    url: 'https://nxcore.tail79107c.ts.net/portainer/',
    expectedStatus: 200,
    expectedContent: ['Portainer', 'login']
  },
  {
    name: 'AI Service (OpenWebUI)',
    url: 'https://nxcore.tail79107c.ts.net/ai/',
    expectedStatus: 200,
    expectedContent: ['Open WebUI', 'chat', 'AI']
  },
  {
    name: 'FileBrowser',
    url: 'https://nxcore.tail79107c.ts.net/files/',
    expectedStatus: 200,
    expectedContent: ['FileBrowser', 'files']
  },
  {
    name: 'Uptime Kuma',
    url: 'https://nxcore.tail79107c.ts.net/status/',
    expectedStatus: 200,
    expectedContent: ['Uptime Kuma', 'monitoring']
  },
  {
    name: 'Authelia',
    url: 'https://nxcore.tail79107c.ts.net/auth/',
    expectedStatus: 200,
    expectedContent: ['Authelia', 'login', 'authentication']
  },
  {
    name: 'n8n',
    url: 'https://nxcore.tail79107c.ts.net/n8n/',
    expectedStatus: 200,
    expectedContent: ['n8n', 'workflow', 'automation']
  },
  {
    name: 'AeroCaller',
    url: 'https://nxcore.tail79107c.ts.net/aerocaller/',
    expectedStatus: 200,
    expectedContent: ['AeroCaller', 'calling']
  }
];

interface IssueReport {
  service: string;
  url: string;
  status: number;
  issues: string[];
  consoleErrors: string[];
  networkErrors: string[];
  recommendations: string[];
}

test.describe('NXCore Landing Page Service Audit', () => {
  let issues: IssueReport[] = [];

  test.beforeEach(async ({ page }) => {
    // Listen for console errors
    page.on('console', msg => {
      if (msg.type() === 'error') {
        console.log(`Console Error: ${msg.text()}`);
      }
    });

    // Listen for network errors
    page.on('response', response => {
      if (response.status() >= 400) {
        console.log(`Network Error: ${response.url()} - ${response.status()}`);
      }
    });
  });

  test('Audit all service links', async ({ page }) => {
    console.log('🔍 Starting comprehensive service audit...\n');

    for (const service of services) {
      console.log(`\n📋 Testing ${service.name}...`);
      console.log(`   URL: ${service.url}`);

      const report: IssueReport = {
        service: service.name,
        url: service.url,
        status: 0,
        issues: [],
        consoleErrors: [],
        networkErrors: [],
        recommendations: []
      };

      try {
        // Navigate to the service
        const response = await page.goto(service.url, { 
          waitUntil: 'networkidle',
          timeout: 30000 
        });

        report.status = response?.status() || 0;

        // Check status code
        if (report.status !== service.expectedStatus) {
          report.issues.push(`Expected status ${service.expectedStatus}, got ${report.status}`);
        }

        // Check for expected content
        if (service.expectedContent) {
          const content = await page.content();
          for (const expectedText of service.expectedContent) {
            if (!content.toLowerCase().includes(expectedText.toLowerCase())) {
              report.issues.push(`Missing expected content: "${expectedText}"`);
            }
          }
        }

        // Check for console errors
        const consoleMessages = await page.evaluate(() => {
          return window.console._logs || [];
        });

        // Check for JavaScript errors
        const jsErrors = await page.evaluate(() => {
          const errors: string[] = [];
          window.addEventListener('error', (e) => {
            errors.push(e.message);
          });
          return errors;
        });

        // Check for 404s or broken links
        const brokenLinks = await page.$$eval('a[href]', links => 
          links.filter(link => {
            const href = link.getAttribute('href');
            return href && (href.includes('404') || href.includes('error'));
          }).map(link => link.getAttribute('href'))
        );

        if (brokenLinks.length > 0) {
          report.issues.push(`Found broken links: ${brokenLinks.join(', ')}`);
        }

        // Check for SSL/TLS issues
        const securityIssues = await page.evaluate(() => {
          const issues: string[] = [];
          if (location.protocol !== 'https:') {
            issues.push('Not using HTTPS');
          }
          return issues;
        });

        if (securityIssues.length > 0) {
          report.issues.push(...securityIssues);
        }

        // Check for loading issues
        const loadingIssues = await page.evaluate(() => {
          const issues: string[] = [];
          const images = document.querySelectorAll('img');
          const brokenImages = Array.from(images).filter(img => !img.complete || img.naturalHeight === 0);
          if (brokenImages.length > 0) {
            issues.push(`${brokenImages.length} broken images`);
          }
          return issues;
        });

        if (loadingIssues.length > 0) {
          report.issues.push(...loadingIssues);
        }

        // Generate recommendations
        if (report.status === 502) {
          report.recommendations.push('Check if service container is running');
          report.recommendations.push('Verify Traefik routing configuration');
          report.recommendations.push('Check network connectivity');
        } else if (report.status === 404) {
          report.recommendations.push('Verify service is deployed');
          report.recommendations.push('Check Traefik path-based routing');
        } else if (report.status === 503) {
          report.recommendations.push('Service may be starting up');
          report.recommendations.push('Check container health status');
        }

        // Check for authentication issues
        if (service.name.includes('Auth') || service.name.includes('Login')) {
          const authContent = await page.content();
          if (authContent.includes('502') || authContent.includes('Bad Gateway')) {
            report.issues.push('Authentication service not accessible');
            report.recommendations.push('Deploy Authelia with proper routing');
          }
        }

        console.log(`   Status: ${report.status}`);
        console.log(`   Issues: ${report.issues.length}`);
        if (report.issues.length > 0) {
          console.log(`   Problems: ${report.issues.join(', ')}`);
        }

      } catch (error) {
        report.issues.push(`Navigation failed: ${error}`);
        report.recommendations.push('Check if service is accessible');
        console.log(`   ❌ Failed: ${error}`);
      }

      issues.push(report);

      // Wait between requests to avoid overwhelming the server
      await page.waitForTimeout(2000);
    }

    // Generate comprehensive report
    console.log('\n📊 AUDIT SUMMARY');
    console.log('================\n');

    const totalServices = services.length;
    const workingServices = issues.filter(i => i.issues.length === 0).length;
    const brokenServices = issues.filter(i => i.issues.length > 0);

    console.log(`Total Services: ${totalServices}`);
    console.log(`Working: ${workingServices}`);
    console.log(`Issues: ${brokenServices.length}\n`);

    if (brokenServices.length > 0) {
      console.log('🚨 SERVICES WITH ISSUES:');
      console.log('========================\n');

      for (const broken of brokenServices) {
        console.log(`❌ ${broken.service}`);
        console.log(`   URL: ${broken.url}`);
        console.log(`   Status: ${broken.status}`);
        console.log(`   Issues: ${broken.issues.join(', ')}`);
        if (broken.recommendations.length > 0) {
          console.log(`   Recommendations: ${broken.recommendations.join(', ')}`);
        }
        console.log('');
      }
    }

    // Generate fix plan
    console.log('🔧 RECOMMENDED FIXES:');
    console.log('====================\n');

    const fixPlan = generateFixPlan(issues);
    for (const fix of fixPlan) {
      console.log(`1. ${fix.action}`);
      console.log(`   Services affected: ${fix.services.join(', ')}`);
      console.log(`   Command: ${fix.command}\n`);
    }
  });

  test('Generate detailed report', async ({ page }) => {
    // This test will generate a detailed HTML report
    const reportHtml = generateHTMLReport(issues);
    
    // Save report to file
    const fs = require('fs');
    const path = require('path');
    const reportPath = path.join(__dirname, '..', 'test-results', 'landing-page-audit-report.html');
    
    fs.mkdirSync(path.dirname(reportPath), { recursive: true });
    fs.writeFileSync(reportPath, reportHtml);
    
    console.log(`\n📄 Detailed report saved to: ${reportPath}`);
  });
});

function generateFixPlan(issues: IssueReport[]): Array<{action: string, services: string[], command: string}> {
  const fixes = [];

  // Group issues by type
  const routingIssues = issues.filter(i => i.status === 502 || i.status === 404);
  const authIssues = issues.filter(i => i.service.includes('Auth') && i.issues.length > 0);
  const sslIssues = issues.filter(i => i.issues.some(issue => issue.includes('HTTPS')));

  if (routingIssues.length > 0) {
    fixes.push({
      action: 'Fix Traefik routing configuration',
      services: routingIssues.map(i => i.service),
      command: 'sudo /srv/core/fix-traefik-routing.sh'
    });
  }

  if (authIssues.length > 0) {
    fixes.push({
      action: 'Deploy Authelia with proper routing',
      services: authIssues.map(i => i.service),
      command: 'sudo /srv/core/fix-authelia-routing.sh'
    });
  }

  if (sslIssues.length > 0) {
    fixes.push({
      action: 'Update SSL/TLS configuration',
      services: sslIssues.map(i => i.service),
      command: 'sudo /srv/core/scripts/update-ssl-config.sh'
    });
  }

  return fixes;
}

function generateHTMLReport(issues: IssueReport[]): string {
  const workingServices = issues.filter(i => i.issues.length === 0);
  const brokenServices = issues.filter(i => i.issues.length > 0);

  return `
<!DOCTYPE html>
<html>
<head>
    <title>NXCore Service Audit Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #1e40af; color: white; padding: 20px; border-radius: 8px; }
        .summary { background: #f3f4f6; padding: 15px; border-radius: 8px; margin: 20px 0; }
        .service { border: 1px solid #e5e7eb; margin: 10px 0; padding: 15px; border-radius: 8px; }
        .working { border-left: 4px solid #10b981; }
        .broken { border-left: 4px solid #ef4444; }
        .issues { color: #dc2626; }
        .recommendations { color: #059669; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🔍 NXCore Service Audit Report</h1>
        <p>Generated: ${new Date().toLocaleString()}</p>
    </div>

    <div class="summary">
        <h2>📊 Summary</h2>
        <p><strong>Total Services:</strong> ${issues.length}</p>
        <p><strong>Working:</strong> ${workingServices.length}</p>
        <p><strong>Issues:</strong> ${brokenServices.length}</p>
    </div>

    <h2>✅ Working Services</h2>
    ${workingServices.map(service => `
        <div class="service working">
            <h3>${service.service}</h3>
            <p><strong>URL:</strong> ${service.url}</p>
            <p><strong>Status:</strong> ${service.status}</p>
        </div>
    `).join('')}

    <h2>❌ Services with Issues</h2>
    ${brokenServices.map(service => `
        <div class="service broken">
            <h3>${service.service}</h3>
            <p><strong>URL:</strong> ${service.url}</p>
            <p><strong>Status:</strong> ${service.status}</p>
            <div class="issues">
                <h4>Issues:</h4>
                <ul>
                    ${service.issues.map(issue => `<li>${issue}</li>`).join('')}
                </ul>
            </div>
            ${service.recommendations.length > 0 ? `
                <div class="recommendations">
                    <h4>Recommendations:</h4>
                    <ul>
                        ${service.recommendations.map(rec => `<li>${rec}</li>`).join('')}
                    </ul>
                </div>
            ` : ''}
        </div>
    `).join('')}
</body>
</html>`;
}
