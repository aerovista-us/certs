#!/usr/bin/env python3
"""
NXCore Enhanced Service Monitor
Comprehensive testing and monitoring for NXCore infrastructure
"""

import asyncio
import aiohttp
import json
import logging
import time
from datetime import datetime
from typing import Dict, List, Optional
from dataclasses import dataclass
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/srv/core/logs/enhanced-service-monitor.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

@dataclass
class ServiceResult:
    name: str
    url: str
    status_code: int
    response_time: float
    content_length: int
    working: bool
    issues: List[str]
    content_validation: bool
    timestamp: datetime

class NXCoreServiceMonitor:
    def __init__(self):
        self.services = [
            {
                'name': 'Landing Page',
                'url': 'https://nxcore.tail79107c.ts.net/',
                'expected_content': ['AeroVista', 'NXCore', 'Infrastructure'],
                'expected_status': 200
            },
            {
                'name': 'cAdvisor',
                'url': 'https://nxcore.tail79107c.ts.net/metrics/',
                'expected_content': ['containers', 'docker'],
                'expected_status': 200
            },
            {
                'name': 'Prometheus',
                'url': 'https://nxcore.tail79107c.ts.net/prometheus/',
                'expected_content': ['prometheus', 'query', 'graph'],
                'expected_status': 200
            },
            {
                'name': 'Grafana',
                'url': 'https://nxcore.tail79107c.ts.net/grafana/',
                'expected_content': ['grafana', 'login', 'dashboard'],
                'expected_status': 200
            },
            {
                'name': 'n8n',
                'url': 'https://nxcore.tail79107c.ts.net/n8n/',
                'expected_content': ['n8n', 'workflow', 'automation'],
                'expected_status': 200
            },
            {
                'name': 'OpenWebUI',
                'url': 'https://nxcore.tail79107c.ts.net/ai/',
                'expected_content': ['openwebui', 'chat', 'ai'],
                'expected_status': 200
            },
            {
                'name': 'Authelia',
                'url': 'https://nxcore.tail79107c.ts.net/auth/',
                'expected_content': ['authelia', 'login', 'authentication'],
                'expected_status': 200
            },
            {
                'name': 'Uptime Kuma',
                'url': 'https://nxcore.tail79107c.ts.net/status/',
                'expected_content': ['uptime', 'kuma', 'monitoring'],
                'expected_status': 200
            },
            {
                'name': 'Traefik Dashboard',
                'url': 'https://nxcore.tail79107c.ts.net/traefik/',
                'expected_content': ['traefik', 'dashboard', 'router'],
                'expected_status': 200
            },
            {
                'name': 'Portainer',
                'url': 'https://nxcore.tail79107c.ts.net/portainer/',
                'expected_content': ['portainer', 'docker', 'containers'],
                'expected_status': 200
            },
            {
                'name': 'File Browser',
                'url': 'https://nxcore.tail79107c.ts.net/files/',
                'expected_content': ['filebrowser', 'files', 'browser'],
                'expected_status': 200
            },
            {
                'name': 'AeroCaller',
                'url': 'https://nxcore.tail79107c.ts.net/aerocaller/',
                'expected_content': ['aerocaller', 'webrtc', 'calling'],
                'expected_status': 200
            }
        ]
        
        self.session = None
        self.results = []

    async def create_session(self):
        """Create aiohttp session with SSL context"""
        import ssl
        
        # Disable SSL verification for self-signed certificates
        ssl_context = ssl.create_default_context()
        ssl_context.check_hostname = False
        ssl_context.verify_mode = ssl.CERT_NONE
        
        connector = aiohttp.TCPConnector(ssl=ssl_context)
        timeout = aiohttp.ClientTimeout(total=15)
        
        self.session = aiohttp.ClientSession(
            connector=connector,
            timeout=timeout,
            headers={'User-Agent': 'NXCore-Monitor/1.0'}
        )

    async def test_service(self, service: Dict) -> ServiceResult:
        """Test a single service"""
        start_time = time.time()
        issues = []
        content_validation = False
        
        try:
            async with self.session.get(service['url']) as response:
                response_time = (time.time() - start_time) * 1000  # Convert to ms
                content = await response.text()
                
                # Check status code
                if response.status != service['expected_status']:
                    if response.status in [302, 307]:
                        issues.append(f"Redirect ({response.status})")
                    elif response.status == 502:
                        issues.append("502 Bad Gateway")
                    elif response.status == 500:
                        issues.append("500 Internal Server Error")
                    else:
                        issues.append(f"HTTP {response.status}")
                
                # Check content validation
                content_lower = content.lower()
                expected_content = [item.lower() for item in service['expected_content']]
                
                if any(keyword in content_lower for keyword in expected_content):
                    content_validation = True
                else:
                    issues.append(f"Expected content not found: {service['expected_content']}")
                
                # Determine if service is working
                working = (response.status == service['expected_status'] and 
                          content_validation and 
                          len(issues) == 0)
                
                return ServiceResult(
                    name=service['name'],
                    url=service['url'],
                    status_code=response.status,
                    response_time=response_time,
                    content_length=len(content),
                    working=working,
                    issues=issues,
                    content_validation=content_validation,
                    timestamp=datetime.now()
                )
                
        except asyncio.TimeoutError:
            issues.append("Request Timeout (>15s)")
        except Exception as e:
            issues.append(f"Connection Error: {str(e)}")
        
        response_time = (time.time() - start_time) * 1000
        
        return ServiceResult(
            name=service['name'],
            url=service['url'],
            status_code=0,
            response_time=response_time,
            content_length=0,
            working=False,
            issues=issues,
            content_validation=False,
            timestamp=datetime.now()
        )

    async def run_comprehensive_test(self) -> Dict:
        """Run comprehensive test on all services"""
        logger.info("🔍 NXCore Enhanced Service Monitor - Starting comprehensive test")
        
        await self.create_session()
        
        try:
            # Test all services concurrently
            tasks = [self.test_service(service) for service in self.services]
            results = await asyncio.gather(*tasks, return_exceptions=True)
            
            # Filter out exceptions and process results
            self.results = [r for r in results if isinstance(r, ServiceResult)]
            
            # Calculate metrics
            working_services = [r for r in self.results if r.working]
            broken_services = [r for r in self.results if not r.working]
            
            success_rate = len(working_services) / len(self.results) * 100
            avg_response_time = sum(r.response_time for r in self.results) / len(self.results)
            
            # Generate report
            report = {
                'timestamp': datetime.now().isoformat(),
                'success_rate': success_rate,
                'working_services': len(working_services),
                'broken_services': len(broken_services),
                'total_services': len(self.results),
                'average_response_time': avg_response_time,
                'results': [
                    {
                        'name': r.name,
                        'url': r.url,
                        'status_code': r.status_code,
                        'response_time': r.response_time,
                        'working': r.working,
                        'issues': r.issues,
                        'content_validation': r.content_validation
                    }
                    for r in self.results
                ]
            }
            
            # Log results
            self.log_results(working_services, broken_services, success_rate, avg_response_time)
            
            return report
            
        finally:
            if self.session:
                await self.session.close()

    def log_results(self, working_services: List[ServiceResult], 
                   broken_services: List[ServiceResult], 
                   success_rate: float, 
                   avg_response_time: float):
        """Log test results"""
        logger.info("📊 ENHANCED TEST RESULTS")
        logger.info("=" * 50)
        
        logger.info(f"✅ Working Services: {len(working_services)}/{len(self.results)} ({success_rate:.1f}%)")
        for service in working_services:
            logger.info(f"   - {service.name}: {service.status_code} ({service.response_time:.1f}ms)")
        
        logger.info(f"\n❌ Broken Services: {len(broken_services)}/{len(self.results)} ({100-success_rate:.1f}%)")
        for service in broken_services:
            issues_str = ', '.join(service.issues) if service.issues else 'Unknown'
            logger.info(f"   - {service.name}: {service.status_code} ({issues_str})")
        
        logger.info(f"\n📈 Performance Summary:")
        logger.info(f"   Average Response Time: {avg_response_time:.1f}ms")
        
        # Categorize issues
        redirect_issues = [s for s in broken_services if any('Redirect' in issue for issue in s.issues)]
        gateway_issues = [s for s in broken_services if any('502' in issue for issue in s.issues)]
        content_issues = [s for s in self.results if not s.content_validation and s.status_code == 200]
        
        if redirect_issues:
            logger.info(f"   Redirect Issues: {len(redirect_issues)} services")
        if gateway_issues:
            logger.info(f"   Gateway Issues: {len(gateway_issues)} services")
        if content_issues:
            logger.info(f"   Content Issues: {len(content_issues)} services")
        
        logger.info(f"\n🎯 OVERALL SUCCESS RATE: {success_rate:.1f}%")
        
        if success_rate >= 90:
            logger.info("🏆 EXCELLENT! System is highly functional")
        elif success_rate >= 75:
            logger.info("✅ GOOD! System is mostly functional")
        elif success_rate >= 50:
            logger.info("⚠️ FAIR! System needs improvement")
        else:
            logger.info("❌ POOR! System needs major fixes")

    def generate_recommendations(self) -> List[str]:
        """Generate improvement recommendations based on results"""
        recommendations = []
        
        # Categorize issues
        redirect_issues = [s for s in self.results if any('Redirect' in issue for issue in s.issues)]
        gateway_issues = [s for s in self.results if any('502' in issue for issue in s.issues)]
        content_issues = [s for s in self.results if not s.content_validation and s.status_code == 200]
        
        if redirect_issues:
            recommendations.append(f"🔧 Fix Traefik routing issues ({len(redirect_issues)} services)")
            recommendations.append("   - Check Traefik configuration files")
            recommendations.append("   - Verify path-based routing rules")
            recommendations.append("   - Fix StripPrefix middleware")
        
        if gateway_issues:
            recommendations.append(f"🔧 Fix service configuration issues ({len(gateway_issues)} services)")
            recommendations.append("   - Check container health")
            recommendations.append("   - Review service logs")
            recommendations.append("   - Restart failed services")
        
        if content_issues:
            recommendations.append(f"🔧 Fix content validation issues ({len(content_issues)} services)")
            recommendations.append("   - Complete service setup")
            recommendations.append("   - Configure authentication")
            recommendations.append("   - Verify service functionality")
        
        recommendations.extend([
            "🔒 Implement security hardening",
            "   - Change default credentials",
            "   - Generate secure secrets",
            "   - Update SSL certificates",
            "📊 Enhance monitoring and alerting",
            "   - Set up Grafana dashboards",
            "   - Configure Prometheus alerts",
            "   - Implement automated testing"
        ])
        
        return recommendations

async def main():
    """Main function"""
    monitor = NXCoreServiceMonitor()
    
    try:
        # Run comprehensive test
        report = await monitor.run_comprehensive_test()
        
        # Generate recommendations
        recommendations = monitor.generate_recommendations()
        
        logger.info("\n🔧 RECOMMENDATIONS:")
        for rec in recommendations:
            logger.info(rec)
        
        # Save report to file
        report_file = Path('/srv/core/logs/enhanced-service-report.json')
        report_file.parent.mkdir(parents=True, exist_ok=True)
        
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        logger.info(f"\n📋 Report saved to: {report_file}")
        logger.info("✅ Enhanced service monitoring completed successfully!")
        
    except Exception as e:
        logger.error(f"❌ Enhanced service monitoring failed: {e}")
        raise

if __name__ == "__main__":
    asyncio.run(main())
