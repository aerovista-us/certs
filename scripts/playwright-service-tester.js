#!/usr/bin/env node
/**
 * NXCore Playwright Service Tester
 * Comprehensive browser-based testing for NXCore infrastructure
 */

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

// Configuration
const CONFIG = {
    baseUrl: 'https://nxcore.tail79107c.ts.net',
    timeout: 30000,
    headless: true,
    outputDir: '/srv/core/logs/playwright-tests',
    services: [
        {
            name: 'Landing Page',
            path: '/',
            expectedElements: ['AeroVista', 'NXCore', 'Infrastructure'],
            expectedStatus: 200
        },
        {
            name: 'Grafana',
            path: '/grafana/',
            expectedElements: ['grafana', 'login', 'dashboard'],
            expectedStatus: 200
        },
        {
            name: 'Prometheus',
            path: '/prometheus/',
            expectedElements: ['prometheus', 'query', 'graph'],
            expectedStatus: 200
        },
        {
            name: 'cAdvisor',
            path: '/metrics/',
            expectedElements: ['containers', 'docker', 'cadvisor'],
            expectedStatus: 200
        },
        {
            name: 'n8n',
            path: '/n8n/',
            expectedElements: ['n8n', 'workflow', 'automation'],
            expectedStatus: 200
        },
        {
            name: 'OpenWebUI',
            path: '/ai/',
            expectedElements: ['openwebui', 'chat', 'ai'],
            expectedStatus: 200
        },
        {
            name: 'Authelia',
            path: '/auth/',
            expectedElements: ['authelia', 'login', 'authentication'],
            expectedStatus: 200
        },
        {
            name: 'Uptime Kuma',
            path: '/status/',
            expectedElements: ['uptime', 'kuma', 'monitoring'],
            expectedStatus: 200
        },
        {
            name: 'Traefik Dashboard',
            path: '/traefik/',
            expectedElements: ['traefik', 'dashboard', 'router'],
            expectedStatus: 200
        },
        {
            name: 'Portainer',
            path: '/portainer/',
            expectedElements: ['portainer', 'docker', 'containers'],
            expectedStatus: 200
        },
        {
            name: 'File Browser',
            path: '/files/',
            expectedElements: ['filebrowser', 'files', 'browser'],
            expectedStatus: 200
        },
        {
            name: 'AeroCaller',
            path: '/aerocaller/',
            expectedElements: ['aerocaller', 'webrtc', 'calling'],
            expectedStatus: 200
        }
    ]
};

class NXCorePlaywrightTester {
    constructor() {
        this.browser = null;
        this.context = null;
        this.page = null;
        this.results = [];
        this.startTime = Date.now();
    }

    async initialize() {
        console.log('🚀 Initializing NXCore Playwright Tester...');
        
        // Create output directory
        if (!fs.existsSync(CONFIG.outputDir)) {
            fs.mkdirSync(CONFIG.outputDir, { recursive: true });
        }

        // Launch browser with SSL context
        this.browser = await chromium.launch({
            headless: CONFIG.headless,
            args: [
                '--ignore-certificate-errors',
                '--ignore-ssl-errors',
                '--ignore-certificate-errors-spki-list',
                '--disable-web-security',
                '--allow-running-insecure-content'
            ]
        });

        // Create context with SSL bypass
        this.context = await this.browser.newContext({
            ignoreHTTPSErrors: true,
            userAgent: 'NXCore-Playwright-Tester/1.0'
        });

        this.page = await this.context.newPage();
        
        // Set up error handling
        this.page.on('pageerror', error => {
            console.log(`Page error: ${error.message}`);
        });

        this.page.on('requestfailed', request => {
            console.log(`Request failed: ${request.url()} - ${request.failure().errorText}`);
        });

        console.log('✅ Browser initialized successfully');
    }

    async testService(service) {
        const testStartTime = Date.now();
        const result = {
            name: service.name,
            path: service.path,
            url: `${CONFIG.baseUrl}${service.path}`,
            status: 'unknown',
            responseTime: 0,
            working: false,
            issues: [],
            contentValidation: false,
            screenshot: null,
            timestamp: new Date().toISOString()
        };

        try {
            console.log(`🧪 Testing ${service.name}...`);
            
            // Navigate to service
            const response = await this.page.goto(result.url, {
                waitUntil: 'networkidle',
                timeout: CONFIG.timeout
            });

            result.responseTime = Date.now() - testStartTime;
            result.status = response.status();

            // Check status code
            if (result.status !== service.expectedStatus) {
                if (result.status === 302 || result.status === 307) {
                    result.issues.push(`Redirect (${result.status})`);
                } else if (result.status === 502) {
                    result.issues.push('502 Bad Gateway');
                } else if (result.status === 500) {
                    result.issues.push('500 Internal Server Error');
                } else {
                    result.issues.push(`HTTP ${result.status}`);
                }
            }

            // Get page content
            const content = await this.page.content();
            const textContent = await this.page.textContent('body');

            // Check for expected elements
            const foundElements = service.expectedElements.filter(element =>
                textContent.toLowerCase().includes(element.toLowerCase())
            );

            if (foundElements.length > 0) {
                result.contentValidation = true;
            } else {
                result.issues.push(`Expected content not found: ${service.expectedElements.join(', ')}`);
            }

            // Take screenshot
            const screenshotPath = path.join(CONFIG.outputDir, `${service.name.replace(/\s+/g, '-').toLowerCase()}.png`);
            await this.page.screenshot({ path: screenshotPath, fullPage: true });
            result.screenshot = screenshotPath;

            // Determine if service is working
            result.working = (result.status === service.expectedStatus && 
                            result.contentValidation && 
                            result.issues.length === 0);

            // Log result
            console.log(`   Status: ${result.status} (${result.responseTime}ms)`);
            console.log(`   Working: ${result.working ? '✅ YES' : '❌ NO'}`);
            
            if (result.issues.length > 0) {
                console.log(`   Issues: ${result.issues.join(', ')}`);
            } else {
                console.log('   ✅ No issues detected');
            }

        } catch (error) {
            result.issues.push(`Test Error: ${error.message}`);
            result.responseTime = Date.now() - testStartTime;
            console.log(`   ❌ Test failed: ${error.message}`);
        }

        return result;
    }

    async runComprehensiveTest() {
        console.log('🔍 NXCore Playwright Comprehensive Testing');
        console.log('==========================================');
        console.log(`Testing ${CONFIG.services.length} services...\n`);

        await this.initialize();

        try {
            // Test all services
            for (const service of CONFIG.services) {
                const result = await this.testService(service);
                this.results.push(result);
                console.log(''); // Empty line for readability
            }

            // Generate summary
            this.generateSummary();

        } finally {
            await this.cleanup();
        }
    }

    generateSummary() {
        console.log('📊 PLAYWRIGHT TEST RESULTS');
        console.log('==========================');

        const working = this.results.filter(r => r.working);
        const broken = this.results.filter(r => !r.working);

        console.log(`✅ Working Services: ${working.length}/${this.results.length} (${Math.round((working.length/this.results.length)*100)}%)`);
        working.forEach(r => console.log(`   - ${r.name}: ${r.status} (${r.responseTime}ms)`));

        console.log(`\n❌ Broken Services: ${broken.length}/${this.results.length} (${Math.round((broken.length/this.results.length)*100)}%)`);
        broken.forEach(r => {
            const issues = r.issues.length > 0 ? ` (${r.issues.join(', ')})` : '';
            console.log(`   - ${r.name}: ${r.status}${issues}`);
        });

        // Performance summary
        const avgResponseTime = this.results.reduce((sum, r) => sum + r.responseTime, 0) / this.results.length;
        console.log(`\n📈 Performance Summary:`);
        console.log(`   Average Response Time: ${Math.round(avgResponseTime)}ms`);

        const slowServices = this.results.filter(r => r.responseTime > 5000);
        if (slowServices.length > 0) {
            console.log(`   Slow Services (>5s): ${slowServices.map(s => s.name).join(', ')}`);
        }

        // Success rate calculation
        const successRate = Math.round((working.length/this.results.length)*100);
        console.log(`\n🎯 OVERALL SUCCESS RATE: ${successRate}%`);

        if (successRate >= 90) {
            console.log('🏆 EXCELLENT! System is highly functional');
        } else if (successRate >= 75) {
            console.log('✅ GOOD! System is mostly functional');
        } else if (successRate >= 50) {
            console.log('⚠️ FAIR! System needs improvement');
        } else {
            console.log('❌ POOR! System needs major fixes');
        }

        // Generate recommendations
        this.generateRecommendations(working, broken);

        // Save results to file
        this.saveResults();
    }

    generateRecommendations(working, broken) {
        console.log('\n🔧 RECOMMENDATIONS:');
        
        // Categorize issues
        const redirectIssues = broken.filter(r => r.issues.some(issue => issue.includes('Redirect')));
        const gatewayIssues = broken.filter(r => r.issues.some(issue => issue.includes('502')));
        const contentIssues = this.results.filter(r => !r.contentValidation && r.status === 200);

        if (redirectIssues.length > 0) {
            console.log(`1. Fix Traefik routing issues (${redirectIssues.length} services)`);
            console.log('   - Check Traefik configuration files');
            console.log('   - Verify path-based routing rules');
            console.log('   - Fix StripPrefix middleware');
        }

        if (gatewayIssues.length > 0) {
            console.log(`2. Fix service configuration issues (${gatewayIssues.length} services)`);
            console.log('   - Check container health');
            console.log('   - Review service logs');
            console.log('   - Restart failed services');
        }

        if (contentIssues.length > 0) {
            console.log(`3. Fix content validation issues (${contentIssues.length} services)`);
            console.log('   - Complete service setup');
            console.log('   - Configure authentication');
            console.log('   - Verify service functionality');
        }

        console.log('4. Implement security hardening');
        console.log('   - Change default credentials');
        console.log('   - Generate secure secrets');
        console.log('   - Update SSL certificates');
        console.log('5. Enhance monitoring and alerting');
        console.log('   - Set up Grafana dashboards');
        console.log('   - Configure Prometheus alerts');
        console.log('   - Implement automated testing');
    }

    saveResults() {
        const reportFile = path.join(CONFIG.outputDir, 'playwright-test-report.json');
        const summaryFile = path.join(CONFIG.outputDir, 'playwright-test-summary.md');

        // Save JSON report
        const report = {
            timestamp: new Date().toISOString(),
            totalServices: this.results.length,
            workingServices: this.results.filter(r => r.working).length,
            brokenServices: this.results.filter(r => !r.working).length,
            successRate: Math.round((this.results.filter(r => r.working).length / this.results.length) * 100),
            averageResponseTime: Math.round(this.results.reduce((sum, r) => sum + r.responseTime, 0) / this.results.length),
            results: this.results
        };

        fs.writeFileSync(reportFile, JSON.stringify(report, null, 2));

        // Save markdown summary
        const summary = `# NXCore Playwright Test Summary

**Date**: ${new Date().toISOString()}
**Total Services**: ${report.totalServices}
**Working Services**: ${report.workingServices}
**Broken Services**: ${report.brokenServices}
**Success Rate**: ${report.successRate}%
**Average Response Time**: ${report.averageResponseTime}ms

## Working Services
${this.results.filter(r => r.working).map(r => `- **${r.name}**: ${r.status} (${r.responseTime}ms)`).join('\n')}

## Broken Services
${this.results.filter(r => !r.working).map(r => `- **${r.name}**: ${r.status} - ${r.issues.join(', ')}`).join('\n')}

## Screenshots
${this.results.map(r => `- [${r.name}](${r.screenshot})`).join('\n')}
`;

        fs.writeFileSync(summaryFile, summary);

        console.log(`\n📋 Results saved:`);
        console.log(`   JSON Report: ${reportFile}`);
        console.log(`   Summary: ${summaryFile}`);
        console.log(`   Screenshots: ${CONFIG.outputDir}`);
    }

    async cleanup() {
        if (this.context) {
            await this.context.close();
        }
        if (this.browser) {
            await this.browser.close();
        }
        console.log('🧹 Browser cleanup completed');
    }
}

// Main execution
async function main() {
    const tester = new NXCorePlaywrightTester();
    
    try {
        await tester.runComprehensiveTest();
        console.log('\n✅ Playwright testing completed successfully!');
        process.exit(0);
    } catch (error) {
        console.error('❌ Playwright testing failed:', error);
        process.exit(1);
    }
}

// Run if called directly
if (require.main === module) {
    main();
}

module.exports = NXCorePlaywrightTester;
