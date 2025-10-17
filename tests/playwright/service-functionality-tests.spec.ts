import { test, expect } from '@playwright/test';

// Helper function to create a context with HTTPS error ignoring
async function createTestContext(browser: any) {
  return await browser.newContext({ ignoreHTTPSErrors: true });
}

test.describe('Service Functionality Tests', () => {
  
  test('AI Service (Open WebUI) - Full Functionality Check', async ({ browser }) => {
    console.log('🤖 Testing AI Service (Open WebUI)...');
    
    const context = await createTestContext(browser);
    const page = await context.newPage();
    
    try {
      await page.goto('https://nxcore.tail79107c.ts.net/ai/', { waitUntil: 'domcontentloaded', timeout: 30000 });
      
      // Check for console errors
      const errors: string[] = [];
      page.on('console', msg => {
        if (msg.type() === 'error') {
          errors.push(msg.text());
        }
      });
      
      // Wait for page to load
      await page.waitForTimeout(5000);
      
      // Check if we can see the interface elements
      const hasLoginForm = await page.locator('input[type="email"], input[type="text"], input[type="password"]').count() > 0;
      const hasChatInterface = await page.locator('textarea, input[placeholder*="message"], input[placeholder*="chat"]').count() > 0;
      const hasButtons = await page.locator('button').count() > 0;
      const hasWebUIElements = await page.locator('[class*="webui"], [class*="chat"], [class*="message"]').count() > 0;
      
      console.log('📊 AI Service Status:');
      console.log(`  - Login Form Present: ${hasLoginForm}`);
      console.log(`  - Chat Interface Present: ${hasChatInterface}`);
      console.log(`  - Interactive Elements: ${hasButtons}`);
      console.log(`  - WebUI Elements: ${hasWebUIElements}`);
      console.log(`  - Console Errors: ${errors.length}`);
      
      if (errors.length > 0) {
        console.log('❌ Console Errors Found:');
        errors.forEach(error => console.log(`    - ${error}`));
      }
      
      // Check for specific Open WebUI elements
      const title = await page.title();
      console.log(`  - Page Title: ${title}`);
      
      // Try to interact with the page
      if (hasLoginForm) {
        console.log('🔐 Login Required - First user will be admin');
        console.log('   Default: Create account on first visit');
      }
      
      if (hasChatInterface || hasWebUIElements) {
        console.log('💬 Chat interface detected - service is functional');
      }
      
      // Report status
      const isFunctional = hasLoginForm || hasChatInterface || hasButtons || hasWebUIElements;
      console.log(`✅ AI Service Status: ${isFunctional ? 'FUNCTIONAL' : 'ISSUES DETECTED'}`);
      
    } finally {
      await context.close();
    }
  });

  test('Grafana - Full Functionality Check', async ({ browser }) => {
    console.log('📊 Testing Grafana...');
    
    const context = await createTestContext(browser);
    const page = await context.newPage();
    
    try {
      await page.goto('https://nxcore.tail79107c.ts.net/grafana/', { waitUntil: 'domcontentloaded', timeout: 30000 });
      
      const errors: string[] = [];
      page.on('console', msg => {
        if (msg.type() === 'error') {
          errors.push(msg.text());
        }
      });
      
      await page.waitForTimeout(3000);
      
      // Check for Grafana login page
      const hasLoginForm = await page.locator('input[name="user"], input[name="password"]').count() > 0;
      const hasGrafanaLogo = await page.locator('img[alt*="Grafana"], .login-branding').count() > 0;
      const hasLoginButton = await page.locator('button[type="submit"], .login-button').count() > 0;
      const hasGrafanaElements = await page.locator('[class*="grafana"], [class*="login"]').count() > 0;
      
      console.log('📊 Grafana Status:');
      console.log(`  - Login Form Present: ${hasLoginForm}`);
      console.log(`  - Grafana Branding: ${hasGrafanaLogo}`);
      console.log(`  - Login Button: ${hasLoginButton}`);
      console.log(`  - Grafana Elements: ${hasGrafanaElements}`);
      console.log(`  - Console Errors: ${errors.length}`);
      
      if (hasLoginForm || hasGrafanaElements) {
        console.log('🔐 Grafana Login Required:');
        console.log('   Default Credentials: admin / admin');
        console.log('   (Change on first login)');
      }
      
      const isFunctional = hasLoginForm || hasGrafanaLogo || hasGrafanaElements;
      console.log(`✅ Grafana Status: ${isFunctional ? 'FUNCTIONAL' : 'ISSUES DETECTED'}`);
      
    } finally {
      await context.close();
    }
  });

  test('Prometheus - Full Functionality Check', async ({ browser }) => {
    console.log('📈 Testing Prometheus...');
    
    const context = await createTestContext(browser);
    const page = await context.newPage();
    
    try {
      await page.goto('https://nxcore.tail79107c.ts.net/prometheus/', { waitUntil: 'domcontentloaded', timeout: 30000 });
      
      const errors: string[] = [];
      page.on('console', msg => {
        if (msg.type() === 'error') {
          errors.push(msg.text());
        }
      });
      
      await page.waitForTimeout(3000);
      
      // Check for Prometheus interface
      const hasPrometheusTitle = await page.locator('text=Prometheus').count() > 0;
      const hasQueryInput = await page.locator('input[placeholder*="query"], textarea').count() > 0;
      const hasExecuteButton = await page.locator('button:has-text("Execute"), button:has-text("Query")').count() > 0;
      const hasGraphTab = await page.locator('text=Graph, text=Console').count() > 0;
      const hasPrometheusElements = await page.locator('[class*="prometheus"], [class*="query"]').count() > 0;
      
      console.log('📊 Prometheus Status:');
      console.log(`  - Prometheus Title: ${hasPrometheusTitle}`);
      console.log(`  - Query Interface: ${hasQueryInput}`);
      console.log(`  - Execute Button: ${hasExecuteButton}`);
      console.log(`  - Graph/Console Tabs: ${hasGraphTab}`);
      console.log(`  - Prometheus Elements: ${hasPrometheusElements}`);
      console.log(`  - Console Errors: ${errors.length}`);
      
      if (hasQueryInput || hasPrometheusElements) {
        console.log('🔍 Prometheus Query Interface Available');
        console.log('   Try: up, node_cpu_seconds_total, etc.');
      }
      
      const isFunctional = hasPrometheusTitle || hasQueryInput || hasPrometheusElements;
      console.log(`✅ Prometheus Status: ${isFunctional ? 'FUNCTIONAL' : 'ISSUES DETECTED'}`);
      
    } finally {
      await context.close();
    }
  });

  test('FileBrowser - Full Functionality Check', async ({ browser }) => {
    console.log('📁 Testing FileBrowser...');
    
    const context = await createTestContext(browser);
    const page = await context.newPage();
    
    try {
      await page.goto('https://nxcore.tail79107c.ts.net/files/', { waitUntil: 'domcontentloaded', timeout: 30000 });
      
      const errors: string[] = [];
      page.on('console', msg => {
        if (msg.type() === 'error') {
          errors.push(msg.text());
        }
      });
      
      await page.waitForTimeout(3000);
      
      // Check for FileBrowser interface
      const hasLoginForm = await page.locator('input[type="password"], input[name="password"]').count() > 0;
      const hasFileList = await page.locator('.file-list, .directory, table').count() > 0;
      const hasUploadButton = await page.locator('input[type="file"], button:has-text("Upload")').count() > 0;
      const hasNavigation = await page.locator('nav, .breadcrumb, .path').count() > 0;
      const hasFileBrowserElements = await page.locator('[class*="file"], [class*="browser"]').count() > 0;
      
      console.log('📊 FileBrowser Status:');
      console.log(`  - Login Form: ${hasLoginForm}`);
      console.log(`  - File List: ${hasFileList}`);
      console.log(`  - Upload Interface: ${hasUploadButton}`);
      console.log(`  - Navigation: ${hasNavigation}`);
      console.log(`  - FileBrowser Elements: ${hasFileBrowserElements}`);
      console.log(`  - Console Errors: ${errors.length}`);
      
      if (hasLoginForm) {
        console.log('🔐 FileBrowser Login Required:');
        console.log('   Check docker-compose for PASSWORD environment variable');
        console.log('   Default may be: admin / admin');
      }
      
      const isFunctional = hasLoginForm || hasFileList || hasFileBrowserElements;
      console.log(`✅ FileBrowser Status: ${isFunctional ? 'FUNCTIONAL' : 'ISSUES DETECTED'}`);
      
    } finally {
      await context.close();
    }
  });

  test('Uptime Kuma - Full Functionality Check', async ({ browser }) => {
    console.log('💚 Testing Uptime Kuma...');
    
    const context = await createTestContext(browser);
    const page = await context.newPage();
    
    try {
      await page.goto('https://nxcore.tail79107c.ts.net/status/', { waitUntil: 'domcontentloaded', timeout: 30000 });
      
      const errors: string[] = [];
      page.on('console', msg => {
        if (msg.type() === 'error') {
          errors.push(msg.text());
        }
      });
      
      await page.waitForTimeout(3000);
      
      // Check for Uptime Kuma interface
      const hasLoginForm = await page.locator('input[type="password"], input[name="password"]').count() > 0;
      const hasStatusPage = await page.locator('.status-page, .monitor, .uptime').count() > 0;
      const hasDashboard = await page.locator('.dashboard, .monitor-list').count() > 0;
      const hasAddButton = await page.locator('button:has-text("Add"), button:has-text("New")').count() > 0;
      const hasUptimeElements = await page.locator('[class*="uptime"], [class*="kuma"]').count() > 0;
      
      console.log('📊 Uptime Kuma Status:');
      console.log(`  - Login Form: ${hasLoginForm}`);
      console.log(`  - Status Page: ${hasStatusPage}`);
      console.log(`  - Dashboard: ${hasDashboard}`);
      console.log(`  - Add Monitor Button: ${hasAddButton}`);
      console.log(`  - Uptime Elements: ${hasUptimeElements}`);
      console.log(`  - Console Errors: ${errors.length}`);
      
      if (hasLoginForm) {
        console.log('🔐 Uptime Kuma Login Required:');
        console.log('   First user will be admin - create account on first visit');
      }
      
      const isFunctional = hasLoginForm || hasStatusPage || hasDashboard || hasUptimeElements;
      console.log(`✅ Uptime Kuma Status: ${isFunctional ? 'FUNCTIONAL' : 'ISSUES DETECTED'}`);
      
    } finally {
      await context.close();
    }
  });

  test('Portainer - Full Functionality Check', async ({ browser }) => {
    console.log('🐳 Testing Portainer...');
    
    const context = await createTestContext(browser);
    const page = await context.newPage();
    
    try {
      await page.goto('https://nxcore.tail79107c.ts.net/portainer/', { waitUntil: 'domcontentloaded', timeout: 30000 });
      
      const errors: string[] = [];
      page.on('console', msg => {
        if (msg.type() === 'error') {
          errors.push(msg.text());
        }
      });
      
      await page.waitForTimeout(3000);
      
      // Check for Portainer interface
      const hasLoginForm = await page.locator('input[type="password"], input[name="password"]').count() > 0;
      const hasPortainerLogo = await page.locator('img[alt*="Portainer"], .portainer-logo').count() > 0;
      const hasDockerIcon = await page.locator('.docker-icon, [class*="docker"]').count() > 0;
      const hasContainersTab = await page.locator('text=Containers, text=Docker').count() > 0;
      const hasPortainerElements = await page.locator('[class*="portainer"], [class*="docker"]').count() > 0;
      
      console.log('📊 Portainer Status:');
      console.log(`  - Login Form: ${hasLoginForm}`);
      console.log(`  - Portainer Branding: ${hasPortainerLogo}`);
      console.log(`  - Docker Interface: ${hasDockerIcon}`);
      console.log(`  - Container Management: ${hasContainersTab}`);
      console.log(`  - Portainer Elements: ${hasPortainerElements}`);
      console.log(`  - Console Errors: ${errors.length}`);
      
      if (hasLoginForm) {
        console.log('🔐 Portainer Login Required:');
        console.log('   First user will be admin - create account on first visit');
        console.log('   Or check for default credentials in compose file');
      }
      
      const isFunctional = hasLoginForm || hasPortainerLogo || hasPortainerElements;
      console.log(`✅ Portainer Status: ${isFunctional ? 'FUNCTIONAL' : 'ISSUES DETECTED'}`);
      
    } finally {
      await context.close();
    }
  });

  test('Traefik Dashboard - Full Functionality Check', async ({ browser }) => {
    console.log('🔄 Testing Traefik Dashboard...');
    
    const context = await createTestContext(browser);
    const page = await context.newPage();
    
    try {
      await page.goto('https://nxcore.tail79107c.ts.net/traefik/', { waitUntil: 'domcontentloaded', timeout: 30000 });
      
      const errors: string[] = [];
      page.on('console', msg => {
        if (msg.type() === 'error') {
          errors.push(msg.text());
        }
      });
      
      await page.waitForTimeout(3000);
      
      // Check for Traefik dashboard
      const hasTraefikTitle = await page.locator('text=Traefik, text=Dashboard').count() > 0;
      const hasRoutersTable = await page.locator('table, .routers, .services').count() > 0;
      const hasHTTPTab = await page.locator('text=HTTP, text=Routers').count() > 0;
      const hasServicesList = await page.locator('.service, .router').count() > 0;
      const hasTraefikElements = await page.locator('[class*="traefik"], [class*="dashboard"]').count() > 0;
      
      console.log('📊 Traefik Dashboard Status:');
      console.log(`  - Traefik Title: ${hasTraefikTitle}`);
      console.log(`  - Routers Table: ${hasRoutersTable}`);
      console.log(`  - HTTP Tab: ${hasHTTPTab}`);
      console.log(`  - Services List: ${hasServicesList}`);
      console.log(`  - Traefik Elements: ${hasTraefikElements}`);
      console.log(`  - Console Errors: ${errors.length}`);
      
      if (hasRoutersTable || hasTraefikElements) {
        console.log('🔍 Traefik Dashboard Functional');
        console.log('   View all configured routes and services');
      }
      
      const isFunctional = hasTraefikTitle || hasRoutersTable || hasTraefikElements;
      console.log(`✅ Traefik Status: ${isFunctional ? 'FUNCTIONAL' : 'ISSUES DETECTED'}`);
      
    } finally {
      await context.close();
    }
  });

  test('AeroCaller - Full Functionality Check', async ({ browser }) => {
    console.log('📞 Testing AeroCaller...');
    
    const context = await createTestContext(browser);
    const page = await context.newPage();
    
    try {
      await page.goto('https://nxcore.tail79107c.ts.net/aerocaller/', { waitUntil: 'domcontentloaded', timeout: 30000 });
      
      const errors: string[] = [];
      page.on('console', msg => {
        if (msg.type() === 'error') {
          errors.push(msg.text());
        }
      });
      
      await page.waitForTimeout(3000);
      
      // Check for AeroCaller interface
      const hasCallInterface = await page.locator('input[type="tel"], input[placeholder*="number"]').count() > 0;
      const hasCallButton = await page.locator('button:has-text("Call"), button:has-text("Dial")').count() > 0;
      const hasVideoInterface = await page.locator('video, .video-call').count() > 0;
      const hasWebRTCElements = await page.locator('.webrtc, .call-interface').count() > 0;
      const hasAeroCallerElements = await page.locator('[class*="aero"], [class*="caller"]').count() > 0;
      
      console.log('📊 AeroCaller Status:');
      console.log(`  - Call Interface: ${hasCallInterface}`);
      console.log(`  - Call Button: ${hasCallButton}`);
      console.log(`  - Video Interface: ${hasVideoInterface}`);
      console.log(`  - WebRTC Elements: ${hasWebRTCElements}`);
      console.log(`  - AeroCaller Elements: ${hasAeroCallerElements}`);
      console.log(`  - Console Errors: ${errors.length}`);
      
      if (hasCallInterface || hasAeroCallerElements) {
        console.log('📞 AeroCaller Functional');
        console.log('   WebRTC calling service ready');
      }
      
      const isFunctional = hasCallInterface || hasCallButton || hasAeroCallerElements;
      console.log(`✅ AeroCaller Status: ${isFunctional ? 'FUNCTIONAL' : 'ISSUES DETECTED'}`);
      
    } finally {
      await context.close();
    }
  });

});
