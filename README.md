# 🚀 NXCore-Control

**AeroVista Infrastructure Control Panel** - A comprehensive Windows operator pack for deploying and managing containerized infrastructure services.

## 📋 Overview

NXCore-Control is a complete infrastructure management solution that provides:

- **🔒 Secure Access** - Self-signed certificate management with automatic download system
- **🐳 Container Orchestration** - Docker Compose-based service deployment
- **🌐 Path-Based Routing** - Single domain access to all services via Traefik
- **📊 Monitoring Stack** - Grafana, Prometheus, Uptime Kuma integration
- **🤖 AI Services** - Local LLM with Open WebUI and Ollama
- **📁 File Management** - FileBrowser for file sharing and management
- **🔐 Authentication** - Authelia SSO/MFA gateway
- **📈 Observability** - Comprehensive logging and monitoring

## 🏗️ Architecture

### **Core Services**
- **Traefik** - Reverse proxy and load balancer
- **Landing Dashboard** - Main control panel with live status monitoring
- **PostgreSQL** - Primary database
- **Redis** - Caching and session storage

### **Observability Stack**
- **Grafana** - Metrics visualization and dashboards
- **Prometheus** - Metrics collection and alerting
- **Uptime Kuma** - Service uptime monitoring
- **cAdvisor** - Container metrics
- **Dozzle** - Container log viewer

### **AI Services**
- **Open WebUI** - AI chat interface
- **Ollama** - Local LLM inference engine

### **Management Tools**
- **Portainer** - Docker container management
- **FileBrowser** - File sharing and management
- **Authelia** - SSO/MFA authentication gateway

## 🚀 Quick Start

### **Prerequisites**
- Windows 10/11 with PowerShell
- Docker Desktop
- SSH access to target server
- Tailscale VPN (for network access)

### **Deployment**
1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/NXCore-Control.git
   cd NXCore-Control
   ```

2. **Deploy core infrastructure**
   ```powershell
   .\scripts\ps\deploy-containers.ps1
   ```

3. **Generate and deploy certificates**
   ```powershell
   .\scripts\ps\generate-selfsigned-certs.ps1
   .\scripts\ps\deploy-selfsigned-certs.ps1
   ```

4. **Access the dashboard**
   - Visit: `https://nxcore.tail79107c.ts.net/`
   - Download and install the certificate for secure access

## 🔗 Service Access

All services are accessible via path-based routing under the single domain:

| Service | URL | Description |
|---------|-----|-------------|
| **Dashboard** | `/` | Main control panel |
| **Grafana** | `/grafana/` | Metrics visualization |
| **Prometheus** | `/prometheus/` | Metrics collection |
| **Portainer** | `/portainer/` | Container management |
| **AI Service** | `/ai/` | Open WebUI chat interface |
| **FileBrowser** | `/files/` | File sharing |
| **Uptime Kuma** | `/status/` | Service monitoring |
| **Traefik** | `/traefik/` | Reverse proxy dashboard |
| **AeroCaller** | `/aerocaller/` | Custom application |
| **Authelia** | `/auth/` | SSO/MFA gateway |

## 🔒 Certificate Management

### **Automatic Certificate Download**
- The landing page automatically detects when certificates are not trusted
- Users can download certificates via the prominent download section
- Browser-specific installation guides are provided

### **Manual Certificate Installation**
1. **Chrome/Edge**: Use Windows Certificate Manager (`certlm.msc`)
2. **Firefox**: Import through Firefox settings
3. **Safari**: Use macOS Keychain

### **Certificate Files**
- **Download**: `/certs/download/nxcore-certificate.crt`
- **Installation Guides**: Browser-specific instructions included

## 📁 Project Structure

```
NXCore-Control/
├── docker/                 # Docker Compose files
│   ├── compose-*.yml      # Service definitions
│   ├── traefik-*.yml      # Traefik configuration
│   └── tailnet-*.yml      # Path-based routing
├── configs/               # Service configurations
│   ├── authelia/          # Authelia configuration
│   ├── grafana/           # Grafana dashboards
│   └── landing/           # Landing page assets
├── scripts/               # Deployment scripts
│   ├── ps/                # PowerShell scripts
│   └── bash/              # Bash scripts
├── certs/                 # Certificate management
│   └── selfsigned/        # Self-signed certificates
├── tests/                 # Testing framework
│   └── playwright/        # End-to-end tests
└── docs/                  # Documentation
```

## 🛠️ Development

### **Local Development**
```bash
# Start development environment
docker-compose -f docker/compose-dev.yml up -d

# Run tests
npm test
# or
npx playwright test
```

### **Testing**
- **Playwright Tests**: End-to-end service testing
- **Service Verification**: Automated health checks
- **Certificate Testing**: SSL/TLS validation

## 📊 Monitoring

### **Health Checks**
- All services include health check endpoints
- Real-time status monitoring on landing page
- Automated service discovery and routing

### **Metrics**
- **Grafana Dashboards**: Pre-configured monitoring
- **Prometheus Targets**: Comprehensive metrics collection
- **Uptime Monitoring**: Service availability tracking

## 🔧 Configuration

### **Environment Variables**
- Domain configuration: `nxcore.tail79107c.ts.net`
- Service ports and networking
- Certificate paths and settings

### **Traefik Configuration**
- Path-based routing for all services
- SSL/TLS termination
- Load balancing and health checks

## 🚨 Troubleshooting

### **Common Issues**
1. **Certificate Warnings**: Download and install the provided certificate
2. **Service 404s**: Check Traefik routing configuration
3. **Container Issues**: Verify Docker service status

### **Debug Commands**
```bash
# Check service status
docker ps

# View service logs
docker logs <service-name>

# Test service connectivity
curl -k https://nxcore.tail79107c.ts.net/<service>/
```

## 📚 Documentation

- **[Certificate Installation Guide](CERTIFICATE_INSTALLATION_GUIDE.md)**
- **[Service Access Guide](docs/SERVICE_ACCESS_GUIDE.md)**
- **[Deployment Verification](DEPLOYMENT_VERIFICATION_REPORT.md)**
- **[Certificate Download System](CERTIFICATE_DOWNLOAD_SYSTEM.md)**

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/NXCore-Control/issues)
- **Documentation**: Check the `docs/` directory
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/NXCore-Control/discussions)

## 🎯 Roadmap

- [ ] Enhanced monitoring dashboards
- [ ] Automated backup systems
- [ ] Multi-environment support
- [ ] Kubernetes migration path
- [ ] Advanced security features

---

**NXCore-Control** - *Infrastructure Made Simple* 🚀
