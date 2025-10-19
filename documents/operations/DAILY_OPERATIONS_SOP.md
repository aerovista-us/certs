# NXCore Infrastructure - Daily Operations SOP

## 🎯 **Daily Operations Overview**

**Purpose**: Standard Operating Procedures for daily NXCore infrastructure operations  
**Audience**: System administrators and operations staff  
**Frequency**: Daily, weekly, monthly tasks  
**Last Updated**: October 18, 2025

---

## 📋 **Daily Operations Checklist**

### **Morning Routine (5 minutes)**

#### **1. System Health Check**
```bash
# Check all containers are running
ssh glyph@100.115.9.61 "sudo docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

# Expected: 24 containers in "Up" status
# No containers should be "unhealthy" or "restarting"
```

#### **2. Service Availability Check**
```bash
# Test critical services
curl -k -s -o /dev/null -w 'HTTP %{http_code} - %{time_total}s' https://nxcore.tail79107c.ts.net/grafana/
curl -k -s -o /dev/null -w 'HTTP %{http_code} - %{time_total}s' https://nxcore.tail79107c.ts.net/prometheus/
curl -k -s -o /dev/null -w 'HTTP %{http_code} - %{time_total}s' https://nxcore.tail79107c.ts.net/ai/

# Expected: HTTP 200-302 responses, <2s response time
```

#### **3. Resource Usage Check**
```bash
# Check system resources
ssh glyph@100.115.9.61 "free -h && df -h"

# Check container resource usage
ssh glyph@100.115.9.61 "sudo docker stats --no-stream --format 'table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}'"
```

---

## 🔧 **Weekly Operations (30 minutes)**

### **Monday: System Maintenance**

#### **Container Updates**
```bash
# Check for container updates
ssh glyph@100.115.9.61 "sudo docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.CreatedAt}}'"

# Update containers (if needed)
ssh glyph@100.115.9.61 "cd /srv/core && sudo docker-compose pull && sudo docker-compose up -d"
```

#### **Log Review**
```bash
# Check for errors in the last 7 days
ssh glyph@100.115.9.61 "sudo journalctl --since '7 days ago' --priority=err"

# Check container logs for issues
ssh glyph@100.115.9.61 "sudo docker logs traefik --since 7d | grep -i error"
```

### **Wednesday: Security Review**

#### **Certificate Check**
```bash
# Check certificate expiration
ssh glyph@100.115.9.61 "openssl x509 -in /opt/nexus/traefik/certs/fullchain.pem -text -noout | grep -E 'Not Before|Not After'"

# Expected: Certificate valid for 365 days from creation
```

#### **Security Updates**
```bash
# Check for system updates
ssh glyph@100.115.9.61 "sudo apt list --upgradable"

# Apply security updates (if any)
ssh glyph@100.115.9.61 "sudo apt update && sudo apt upgrade -y"
```

### **Friday: Performance Review**

#### **Performance Metrics**
```bash
# Check system performance
ssh glyph@100.115.9.61 "htop -n 1"

# Check disk usage
ssh glyph@100.115.9.61 "df -h && du -sh /srv/core/*"
```

#### **Backup Verification**
```bash
# Check backup status
ssh glyph@100.115.9.61 "ls -la /srv/backups/"

# Verify backup integrity (if automated backups exist)
ssh glyph@100.115.9.61 "sudo docker exec postgres pg_dump -U n8n n8n | head -10"
```

---

## 📊 **Monthly Operations (2 hours)**

### **First Monday: Comprehensive Review**

#### **System Health Report**
```bash
# Generate comprehensive system report
ssh glyph@100.115.9.61 "sudo docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' > /tmp/system_status.txt"
ssh glyph@100.115.9.61 "sudo docker stats --no-stream --format 'table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}' >> /tmp/system_status.txt"
ssh glyph@100.115.9.61 "free -h >> /tmp/system_status.txt"
ssh glyph@100.115.9.61 "df -h >> /tmp/system_status.txt"
```

#### **Service Performance Analysis**
```bash
# Test all service endpoints
curl -k -s -o /dev/null -w 'Landing: HTTP %{http_code} - %{time_total}s\n' https://nxcore.tail79107c.ts.net/
curl -k -s -o /dev/null -w 'Grafana: HTTP %{http_code} - %{time_total}s\n' https://nxcore.tail79107c.ts.net/grafana/
curl -k -s -o /dev/null -w 'Prometheus: HTTP %{http_code} - %{time_total}s\n' https://nxcore.tail79107c.ts.net/prometheus/
curl -k -s -o /dev/null -w 'AI: HTTP %{http_code} - %{time_total}s\n' https://nxcore.tail79107c.ts.net/ai/
curl -k -s -o /dev/null -w 'Files: HTTP %{http_code} - %{time_total}s\n' https://nxcore.tail79107c.ts.net/files/
curl -k -s -o /dev/null -w 'Status: HTTP %{http_code} - %{time_total}s\n' https://nxcore.tail79107c.ts.net/status/
```

### **Third Monday: Security Hardening**

#### **Security Audit**
```bash
# Check for failed login attempts
ssh glyph@100.115.9.61 "sudo grep 'Failed password' /var/log/auth.log | tail -20"

# Check for suspicious activity
ssh glyph@100.115.9.61 "sudo netstat -tulpn | grep LISTEN"
```

#### **Certificate Renewal Check**
```bash
# Check certificate expiration date
ssh glyph@100.115.9.61 "openssl x509 -in /opt/nexus/traefik/certs/fullchain.pem -noout -dates"

# If certificate expires within 30 days, renew it
```

---

## 🚨 **Emergency Procedures**

### **Service Down Response**

#### **Step 1: Identify the Issue**
```bash
# Check which services are down
ssh glyph@100.115.9.61 "sudo docker ps --filter status=exited"

# Check service logs
ssh glyph@100.115.9.61 "sudo docker logs <service-name> --tail 50"
```

#### **Step 2: Restart Service**
```bash
# Restart specific service
ssh glyph@100.115.9.61 "sudo docker restart <service-name>"

# If that fails, recreate the service
ssh glyph@100.115.9.61 "cd /srv/core && sudo docker-compose -f compose-<service>.yml down && sudo docker-compose -f compose-<service>.yml up -d"
```

#### **Step 3: Verify Recovery**
```bash
# Test service is responding
curl -k https://nxcore.tail79107c.ts.net/<service>/

# Check service is healthy
ssh glyph@100.115.9.61 "sudo docker ps --filter name=<service>"
```

### **Complete System Failure**

#### **Step 1: Assess Damage**
```bash
# Check if server is accessible
ping nxcore.tail79107c.ts.net

# Check if SSH is accessible
ssh glyph@100.115.9.61 "echo 'Server is accessible'"
```

#### **Step 2: Restart All Services**
```bash
# Restart all containers
ssh glyph@100.115.9.61 "cd /srv/core && sudo docker-compose down && sudo docker-compose up -d"
```

#### **Step 3: Verify All Services**
```bash
# Check all containers are running
ssh glyph@100.115.9.61 "sudo docker ps --format 'table {{.Names}}\t{{.Status}}'"

# Test all service endpoints
curl -k https://nxcore.tail79107c.ts.net/
curl -k https://nxcore.tail79107c.ts.net/grafana/
curl -k https://nxcore.tail79107c.ts.net/prometheus/
```

---

## 📈 **Performance Monitoring**

### **Key Metrics to Track**

#### **System Metrics**
- **CPU Usage**: <80% average
- **Memory Usage**: <80% of available RAM
- **Disk Usage**: <80% of available space
- **Network Latency**: <100ms to services

#### **Service Metrics**
- **Response Time**: <2 seconds for all services
- **Availability**: 99.9% uptime target
- **Error Rate**: <1% of requests
- **Container Health**: All containers "healthy"

### **Monitoring Commands**
```bash
# Real-time system monitoring
ssh glyph@100.115.9.61 "htop"

# Container resource usage
ssh glyph@100.115.9.61 "sudo docker stats --no-stream"

# Network connectivity
ping nxcore.tail79107c.ts.net
```

---

## 🔐 **Security Operations**

### **Daily Security Checks**

#### **Access Logs**
```bash
# Check for unauthorized access attempts
ssh glyph@100.115.9.61 "sudo grep 'Failed password' /var/log/auth.log | tail -10"

# Check for suspicious network activity
ssh glyph@100.115.9.61 "sudo netstat -tulpn | grep -E ':(80|443|8080|9443)'"
```

#### **Certificate Status**
```bash
# Check certificate validity
ssh glyph@100.115.9.61 "openssl x509 -in /opt/nexus/traefik/certs/fullchain.pem -text -noout | grep -E 'Not Before|Not After'"
```

### **Weekly Security Tasks**

#### **Update Review**
```bash
# Check for available updates
ssh glyph@100.115.9.61 "sudo apt list --upgradable"

# Apply security updates
ssh glyph@100.115.9.61 "sudo apt update && sudo apt upgrade -y"
```

#### **Backup Verification**
```bash
# Verify backups are working
ssh glyph@100.115.9.61 "ls -la /srv/backups/"

# Test backup restoration (if needed)
```

---

## 📞 **Support Procedures**

### **Level 1: Self-Service**
- Check this SOP for common procedures
- Review system logs for obvious issues
- Restart services using provided commands
- Check network connectivity

### **Level 2: Technical Support**
- Contact system administrator
- Provide diagnostic output from commands
- Describe steps already taken
- Include relevant log entries

### **Level 3: Emergency Support**
- 24/7 emergency hotline for critical issues
- System down situations
- Security incidents
- Data loss prevention

---

## 📚 **Related Documentation**

- **[SYSTEM_STATUS_CONSOLIDATED.md](../consolidated/SYSTEM_STATUS_CONSOLIDATED.md)** - Current system status
- **[TROUBLESHOOTING_GUIDE_CONSOLIDATED.md](../development/TROUBLESHOOTING_GUIDE_CONSOLIDATED.md)** - Detailed troubleshooting
- **[ARCHITECTURE_CONSOLIDATED.md](../development/ARCHITECTURE_CONSOLIDATED.md)** - System architecture

---

## 🎯 **Success Criteria**

### **Daily Operations Success**
✅ **All containers running** (24/24)  
✅ **All services accessible** (11/12 - 92%)  
✅ **Response times <2s** for all services  
✅ **No critical errors** in logs  
✅ **System resources <80%** utilization  

### **Weekly Operations Success**
✅ **Security updates applied** (if available)  
✅ **Performance metrics reviewed**  
✅ **Backup verification completed**  
✅ **Log analysis completed**  

### **Monthly Operations Success**
✅ **Comprehensive health report** generated  
✅ **Security audit completed**  
✅ **Performance analysis completed**  
✅ **Documentation updated**  

---

**This SOP provides comprehensive daily, weekly, and monthly operational procedures for maintaining the NXCore infrastructure at peak performance.**
