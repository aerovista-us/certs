# NXCore Multi-PC Deployment Checklist

## Pre-Deployment
- [ ] Copy deployment package to target PC
- [ ] Ensure Administrator privileges
- [ ] Verify network connectivity to server
- [ ] Confirm SSH access to 100.115.9.61

## Installation
- [ ] Run `install-openssl-and-setup.ps1` as Administrator
- [ ] Verify OpenSSL installation
- [ ] Check OpenSSL is in system PATH
- [ ] Test OpenSSL command: `openssl version`

## Certificate Generation
- [ ] Run `generate-and-deploy-bundles-fixed.ps1`
- [ ] Verify certificate generation for all services
- [ ] Check server deployment success
- [ ] Confirm Traefik restart
- [ ] Validate SSL configuration

## Post-Deployment
- [ ] Test all services for green lock icons
- [ ] Verify client installation packages
- [ ] Check server certificate permissions
- [ ] Review Traefik logs for errors
- [ ] Test certificate connectivity

## Services to Verify
- [ ] https://nxcore.tail79107c.ts.net/ (Landing)
- [ ] https://nxcore.tail79107c.ts.net/grafana/
- [ ] https://nxcore.tail79107c.ts.net/prometheus/
- [ ] https://nxcore.tail79107c.ts.net/portainer/
- [ ] https://nxcore.tail79107c.ts.net/ai/
- [ ] https://nxcore.tail79107c.ts.net/files/
- [ ] https://nxcore.tail79107c.ts.net/status/
- [ ] https://nxcore.tail79107c.ts.net/traefik/
- [ ] https://nxcore.tail79107c.ts.net/aerocaller/
- [ ] https://nxcore.tail79107c.ts.net/auth/

## Success Criteria
- [ ] All services show green lock icons
- [ ] No certificate errors in browser
- [ ] Traefik logs show no SSL errors
- [ ] Client installation packages ready
- [ ] Server certificates properly deployed

---
**Checklist Version**: 1.0
**Last Updated**: $(Get-Date)
