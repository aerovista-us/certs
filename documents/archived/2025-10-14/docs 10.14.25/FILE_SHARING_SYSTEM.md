# AeroVista File Sharing System

## Overview

The AeroVista File Sharing System provides a modern, drag-and-drop file upload interface with comprehensive file management capabilities. It's designed for easy "drop and go" workflows and seamless file sharing across the AeroVista infrastructure.

## Architecture

### Components

1. **Nginx Web Server** (`nxcore-fileshare-nginx`)
   - Serves static HTML/CSS/JS files
   - Handles file upload requests
   - Routes PHP requests to PHP-FPM

2. **PHP-FPM Backend** (`nxcore-fileshare-php`)
   - Processes file uploads
   - Handles file management operations
   - Provides REST API for file operations

3. **File Storage**
   - Upload directory: `/srv/core/fileshare/uploads/`
   - Web files: `/srv/core/fileshare/www/`
   - Configuration: `/srv/core/config/fileshare/`

## Features

### Drop & Go Interface
- **Drag & Drop Upload**: Modern HTML5 drag-and-drop interface
- **Progress Tracking**: Real-time upload progress with visual feedback
- **Chunked Uploads**: Large file support with automatic chunking
- **Multiple Files**: Batch upload support
- **File Validation**: Size limits and type checking

### File Manager
- **Browse Files**: Grid view with file icons and metadata
- **Download Files**: Direct download links
- **Delete Files**: Secure file deletion with confirmation
- **Share Links**: Generate shareable URLs
- **File Metadata**: Size, date, type information

### Workflow Integration
- **Webhook Support**: Automatic processing triggers
- **AI Integration**: Ready for AI-powered file processing
- **Automation**: N8N workflow integration
- **Notifications**: Upload completion alerts

## Access URLs

| Service | Direct IP | Tailscale URL | Description |
|---------|-----------|---------------|-------------|
| **Drop & Go** | `http://100.115.9.61:8082/` | `http://share.nxcore.tail79107c.ts.net/` | Main upload interface |
| **File Manager** | `http://100.115.9.61:8082/files.html` | `http://share.nxcore.tail79107c.ts.net/files.html` | File management interface |

## File Structure

```
/srv/core/fileshare/
├── www/                    # Web interface files
│   ├── index.html         # Drop & Go interface
│   ├── files.html         # File manager
│   ├── upload.php         # Upload handler
│   ├── list-files.php     # File listing API
│   ├── download.php       # Download handler
│   └── delete.php         # Delete handler
├── uploads/               # Uploaded files storage
└── config/
    └── nginx.conf         # Nginx configuration
```

## Configuration

### Nginx Configuration
- **Upload Limit**: 2GB maximum file size
- **PHP Processing**: FastCGI to PHP-FPM
- **Security**: Deny access to sensitive files
- **Performance**: Optimized for large file uploads

### PHP Configuration
- **Memory Limit**: 512MB for large file processing
- **Upload Timeout**: 300 seconds for large files
- **File Validation**: Size and type checking
- **Error Handling**: Comprehensive error reporting

## API Endpoints

### File Operations

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/upload.php` | POST | Upload files via form or AJAX |
| `/list-files.php` | GET | Get list of uploaded files |
| `/download.php?file=<name>` | GET | Download specific file |
| `/delete.php` | POST | Delete file (JSON payload) |

### Example API Usage

```javascript
// Upload file
const formData = new FormData();
formData.append('file', fileInput.files[0]);

fetch('/upload.php', {
    method: 'POST',
    body: formData
})
.then(response => response.json())
.then(data => console.log('Upload complete:', data));

// List files
fetch('/list-files.php')
.then(response => response.json())
.then(files => console.log('Files:', files));

// Delete file
fetch('/delete.php', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ filename: 'example.txt' })
})
.then(response => response.json())
.then(data => console.log('Delete result:', data));
```

## Security Features

### File Upload Security
- **File Type Validation**: Whitelist of allowed file types
- **Size Limits**: Configurable maximum file size
- **Path Traversal Protection**: Prevents directory traversal attacks
- **Virus Scanning**: Ready for integration with ClamAV

### Access Control
- **Network Isolation**: Backend services on private network
- **Authentication Ready**: Prepared for Authelia integration
- **HTTPS Support**: SSL/TLS encryption via Traefik
- **Rate Limiting**: Protection against abuse

## Integration Points

### Workflow Automation (N8N)
- **Webhook Triggers**: Automatic processing on file upload
- **File Processing**: Image resizing, document conversion
- **Notification System**: Email/Slack alerts on uploads
- **Data Extraction**: Text extraction from documents

### AI Services (Ollama/OpenWebUI)
- **Document Analysis**: AI-powered content analysis
- **Image Processing**: Automatic image enhancement
- **Content Generation**: AI-assisted file processing
- **Smart Organization**: AI-powered file categorization

### Monitoring Integration
- **Prometheus Metrics**: Upload statistics and performance
- **Grafana Dashboards**: File sharing analytics
- **Uptime Monitoring**: Service health checks
- **Log Aggregation**: Centralized logging

## Deployment

### Docker Compose
```yaml
version: "3.8"
services:
  fileshare-nginx:
    image: nginx:alpine
    container_name: nxcore-fileshare-nginx
    networks:
      - gateway
      - backend
    ports:
      - "8082:80"
    volumes:
      - /srv/core/fileshare/www:/var/www/html:ro
      - /srv/core/config/fileshare/nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - /srv/core/fileshare/uploads:/var/www/html/uploads:rw
    labels:
      - traefik.enable=true
      - traefik.http.routers.fileshare.rule=Host(`share.nxcore.tail79107c.ts.net`)
      - traefik.http.services.fileshare.loadbalancer.server.port=80
    restart: unless-stopped
    depends_on:
      - fileshare-php

  fileshare-php:
    image: php:8.2-fpm-alpine
    container_name: nxcore-fileshare-php
    networks:
      - backend
    volumes:
      - /srv/core/fileshare/www:/var/www/html:rw
      - /srv/core/fileshare/uploads:/var/www/html/uploads:rw
    restart: unless-stopped
```

### Deployment Commands
```bash
# Deploy file sharing system
cd /srv/core
sudo docker compose -f compose-fileshare.yml up -d

# Verify deployment
sudo docker ps | grep fileshare
curl -I http://localhost:8082/
```

## Troubleshooting

### Common Issues

1. **Upload Fails**
   - Check file size limits in nginx.conf
   - Verify PHP memory_limit and upload_max_filesize
   - Check disk space in /srv/core/fileshare/uploads/

2. **Files Not Appearing**
   - Verify file permissions on upload directory
   - Check PHP error logs: `sudo docker logs nxcore-fileshare-php`
   - Ensure uploads directory is writable

3. **Download Issues**
   - Check file exists in uploads directory
   - Verify nginx configuration for download.php
   - Check browser console for JavaScript errors

### Logs and Debugging
```bash
# View nginx logs
sudo docker logs nxcore-fileshare-nginx

# View PHP logs
sudo docker logs nxcore-fileshare-php

# Check file permissions
ls -la /srv/core/fileshare/uploads/

# Test upload directory
sudo docker exec nxcore-fileshare-php touch /var/www/html/uploads/test.txt
```

## Future Enhancements

### Planned Features
- **User Authentication**: Individual user accounts and quotas
- **File Versioning**: Version control for uploaded files
- **Advanced Search**: Full-text search across files
- **Collaboration**: Real-time file sharing and comments
- **Mobile App**: Native mobile interface
- **Cloud Sync**: Integration with cloud storage providers

### Performance Optimizations
- **CDN Integration**: Global file distribution
- **Image Optimization**: Automatic image compression
- **Caching**: Redis-based file metadata caching
- **Load Balancing**: Multi-instance deployment

## Support

For issues or questions about the File Sharing System:
1. Check the troubleshooting section above
2. Review container logs for error messages
3. Verify network connectivity and DNS resolution
4. Check file permissions and disk space

The system is designed to be robust and self-healing, with automatic restarts and comprehensive error handling.
