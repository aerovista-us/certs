# NXCore AI System Overview

## Architecture

The NXCore AI system provides local LLM capabilities through Ollama with OpenWebUI frontend, integrated with the Shipping & Receiving system for automated file processing.

### Core Components

| Component | Purpose | Port | URL |
|-----------|---------|------|-----|
| **Ollama** | LLM Backend | 11434 | `http://localhost:11434` |
| **OpenWebUI** | Web Interface | 8080 | `https://nxcore.tail79107c.ts.net/ai/` |
| **AI Processor** | File Analysis | - | CLI Tool |
| **AI Monitor** | Health Checks | - | Systemd Service |

## Models

### Primary Models
- **llama3.2** - General purpose, high performance
- **mistral** - Efficient, fast responses
- **codellama** - Code generation and analysis

### Model Management
```bash
# List available models
/srv/core/nxcore/ai/ollama-api.sh list

# Pull new models
/srv/core/nxcore/ai/ollama/pull-models.sh

# Test model
/srv/core/nxcore/ai/ollama-api.sh generate llama3.2 "Hello, world!"
```

## AI Integration

### Shipping & Receiving Integration

The AI system automatically processes files from the exchange system:

1. **File Detection** → Inbox watcher detects new files
2. **AI Processing** → Files sent to AI processor via n8n
3. **Analysis Generation** → AI creates summaries and insights
4. **Output** → Results saved to outbox for GitHub publishing

### Supported File Types

| Type | Processing | Output |
|------|------------|--------|
| **CSV** | Data analysis, insights | `*_analysis.md` |
| **TXT/MD** | Content summarization | `*_summary.md` |
| **JSON** | Structure analysis | `*_analysis.md` |
| **LOG** | Error detection, patterns | `*_analysis.md` |

### n8n Functions

- `n8n/functions/ai-csv-processor.js` - AI-enhanced CSV processing
- `n8n/functions/ai-text-processor.js` - AI-enhanced text processing

## Usage

### Command Line Interface

```bash
# AI API Client
/srv/core/nxcore/ai/ollama-api.sh generate llama3.2 "Explain Docker"
/srv/core/nxcore/ai/ollama-api.sh process llama3.2 document.txt summarize
/srv/core/nxcore/ai/ollama-api.sh csv llama3.2 data.csv

# AI Processor
/srv/core/nxcore/ai/ai-processor.sh process file.csv /tmp/output
/srv/core/nxcore/ai/ai-processor.sh exchange 2025-01-16

# AI Monitor
/srv/core/nxcore/ai/ai-monitor.sh monitor
/srv/core/nxcore/ai/ai-monitor.sh check
```

### Web Interface

Access the OpenWebUI interface at: `https://nxcore.tail79107c.ts.net/ai/`

Features:
- Chat with models
- File upload and analysis
- Model management
- Conversation history

## Monitoring

### Health Checks

The AI monitor runs every 30 minutes and checks:
- Ollama service availability
- OpenWebUI accessibility
- AI generation functionality
- System resources (disk, memory)
- Docker container status

### Alerts

Health reports and alerts are saved to:
- `/srv/core/nxcore/state/outbox/alerts/`

### Manual Monitoring

```bash
# Check service status
systemctl status ollama
systemctl status openwebui

# View logs
journalctl -u ollama -f
journalctl -u ai-monitor.service -f

# Run health check
/srv/core/nxcore/ai/ai-monitor.sh check
```

## Configuration

### Environment Variables

```bash
# Ollama configuration
OLLAMA_HOST=http://localhost:11434

# OpenWebUI configuration
OPENWEBUI_HOST=https://nxcore.tail79107c.ts.net/ai
OLLAMA_BASE_URL=http://ollama:11434
WEBUI_NAME=AeroVista AI Assistant
```

### Docker Services

- `docker/compose-ollama.yml` - Ollama backend
- `docker/compose-openwebui.yml` - OpenWebUI frontend

## Security

### Access Control
- Ollama: Internal access only (127.0.0.1:11434)
- OpenWebUI: HTTPS with authentication enabled
- AI processing: Restricted to exchange system

### Data Privacy
- All processing happens locally
- No data sent to external services
- Models run on local hardware

## Performance

### Resource Requirements
- **RAM**: 8GB+ recommended for llama3.2
- **Storage**: 10GB+ for models
- **CPU**: Multi-core recommended

### Optimization
- Models loaded on-demand
- Automatic cleanup of temporary files
- Resource monitoring and alerts

## Troubleshooting

### Common Issues

1. **Ollama not responding**
   ```bash
   systemctl restart ollama
   docker restart ollama
   ```

2. **Models not loading**
   ```bash
   ollama pull llama3.2
   ollama list
   ```

3. **OpenWebUI not accessible**
   ```bash
   docker logs openwebui
   systemctl status openwebui
   ```

4. **AI processing fails**
   ```bash
   /srv/core/nxcore/ai/ai-monitor.sh check
   journalctl -u ai-monitor.service -n 50
   ```

### Debug Commands

```bash
# Test Ollama API
curl -s http://localhost:11434/api/tags

# Test AI generation
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model": "llama3.2", "prompt": "Hello", "stream": false}'

# Check container logs
docker logs ollama
docker logs openwebui
```

## Integration Examples

### CSV Analysis
```bash
# Process CSV with AI
/srv/core/nxcore/ai/ai-processor.sh process data.csv /tmp/output

# Results in:
# - data.csv (original)
# - data_analysis.md (AI insights)
```

### Text Summarization
```bash
# Summarize document
/srv/core/nxcore/ai/ollama-api.sh process llama3.2 document.txt summarize
```

### Automated Processing
Files dropped in `/srv/exchange/inbox/` are automatically:
1. Detected by inbox watcher
2. Processed by AI via n8n
3. Analyzed and summarized
4. Saved to outbox for GitHub publishing

---

**NXCore AI System** - *Local Intelligence for Your Infrastructure* 🤖
