# 🚀 NXCore-Control

**AeroVista Infrastructure Control Panel** - Windows-based containerized infrastructure management solution.

## 📋 Overview

NXCore-Control provides a complete infrastructure stack with:

- **🔒 Secure Access** - Self-signed certificate management with auto-download
- **🐳 Container Orchestration** - Docker Compose-based deployment
- **🌐 Path-Based Routing** - Single domain access via Traefik
- **📊 Monitoring** - Grafana, Prometheus, Uptime Kuma
- **🤖 AI Services** - Open WebUI + Ollama local LLM
- **📁 File Management** - FileBrowser integration
- **🔐 Authentication** - Authelia SSO/MFA gateway

## 🏗️ Core Services

| Service | Purpose |
|---------|---------|
| **Traefik** | Reverse proxy & load balancer |
| **Landing Dashboard** | Main control panel with live monitoring |
| **PostgreSQL** | Primary database |
| **Redis** | Caching & session storage |
| **Grafana** | Metrics visualization |
| **Prometheus** | Metrics collection |
| **Portainer** | Container management |
| **Open WebUI** | AI chat interface |
| **FileBrowser** | File sharing |
| **Authelia** | SSO/MFA gateway |

## 🚀 Quick Start

### Prerequisites
- Windows 10/11 + PowerShell
- Docker Desktop
- SSH access + Tailscale VPN

### Deployment
```powershell
# Clone & deploy
git clone https://github.com/yourusername/NXCore-Control.git
cd NXCore-Control
.\scripts\ps\deploy-containers.ps1

# Generate certificates
.\scripts\ps\generate-selfsigned-certs.ps1
.\scripts\ps\deploy-selfsigned-certs.ps1

# Access dashboard
# https://nxcore.tail79107c.ts.net/
```

## 🔗 Service Access

All services via path-based routing: `https://nxcore.tail79107c.ts.net/`

| Service | Path | Description |
|---------|------|-------------|
| **Dashboard** | `/` | Main control panel |
| **Grafana** | `/grafana/` | Metrics visualization |
| **Prometheus** | `/prometheus/` | Metrics collection |
| **Portainer** | `/portainer/` | Container management |
| **AI Service** | `/ai/` | Open WebUI chat |
| **FileBrowser** | `/files/` | File sharing |
| **Uptime Kuma** | `/status/` | Service monitoring |
| **AeroCaller** | `/aerocaller/` | Custom app |
| **Authelia** | `/auth/` | SSO/MFA gateway |

## 🔒 Certificate Management

- **Auto-download**: Landing page detects untrusted certificates
- **Download URL**: `/certs/download/nxcore-certificate.crt`
- **Installation**: Browser-specific guides provided
- **Manual**: Use `certlm.msc` for Chrome/Edge

## 📁 Project Structure

```
NXCore-Control/
├── docker/           # Docker Compose files
├── configs/          # Service configurations
├── scripts/          # Deployment scripts (PS/Bash)
├── certs/            # Certificate management
├── tests/            # Playwright E2E tests
└── docs/             # Documentation
```

## 🛠️ Development

```bash
# Development environment
docker-compose -f docker/compose-dev.yml up -d

# Testing
npx playwright test
```

## 📊 Monitoring

- **Health Checks**: All services with endpoints
- **Real-time Status**: Landing page monitoring
- **Grafana**: Pre-configured dashboards
- **Prometheus**: Metrics collection
- **Uptime Kuma**: Service availability

## 🚨 Troubleshooting

| Issue | Solution |
|-------|----------|
| Certificate warnings | Download & install certificate |
| Service 404s | Check Traefik routing |
| Container issues | Verify Docker status |

```bash
# Debug commands
docker ps
docker logs <service-name>
curl -k https://nxcore.tail79107c.ts.net/<service>/
```

## 📚 Documentation

- [Certificate Installation Guide](CERTIFICATE_INSTALLATION_GUIDE.md)
- [Service Access Guide](docs/SERVICE_ACCESS_GUIDE.md)
- [Deployment Verification](DEPLOYMENT_VERIFICATION_REPORT.md)
- [Certificate Download System](CERTIFICATE_DOWNLOAD_SYSTEM.md)

## 🤝 Contributing

1. Fork → Feature branch → Changes → Tests → PR

## 📄 License

MIT License - see [LICENSE](LICENSE)

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/NXCore-Control/issues)
- **Docs**: Check `docs/` directory

---

**NXCore-Control** - *Infrastructure Made Simple* 🚀
