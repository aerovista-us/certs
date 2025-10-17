#!/usr/bin/env bash
set -euo pipefail

# Complete AI System Setup for NXCore
# Installs and configures Ollama, OpenWebUI, and AI monitoring

REPO_DIR="/srv/core/nxcore"

echo "🤖 Setting up NXCore AI System..."

# Make AI scripts executable
echo "🔧 Making AI scripts executable..."
chmod +x "$REPO_DIR/ai/ai-core.sh"
chmod +x "$REPO_DIR/ai/ollama/pull-models.sh"
chmod +x "$REPO_DIR/ai/ollama-api.sh"
chmod +x "$REPO_DIR/ai/ai-processor.sh"
chmod +x "$REPO_DIR/ai/ai-monitor.sh"

# Install systemd services for AI monitoring
echo "⚙️ Installing AI monitoring services..."
sudo cp "$REPO_DIR/systemd/ai-monitor.service" /etc/systemd/system/
sudo cp "$REPO_DIR/systemd/ai-monitor.timer" /etc/systemd/system/

# Reload systemd and enable AI monitoring
echo "🔄 Enabling AI monitoring..."
sudo systemctl daemon-reload
sudo systemctl enable ai-monitor.timer
sudo systemctl start ai-monitor.timer

# Check if Ollama is running
echo "🔍 Checking Ollama status..."
if docker ps | grep -q ollama; then
    echo "✅ Ollama container is running"
else
    echo "⚠️ Ollama container not found - please start with:"
    echo "   docker-compose -f docker/compose-ollama.yml up -d"
fi

# Check if OpenWebUI is running
echo "🔍 Checking OpenWebUI status..."
if docker ps | grep -q openwebui; then
    echo "✅ OpenWebUI container is running"
else
    echo "⚠️ OpenWebUI container not found - please start with:"
    echo "   docker-compose -f docker/compose-openwebui.yml up -d"
fi

# Test AI system
echo "🧪 Testing AI system..."
if "$REPO_DIR/ai/ai-monitor.sh" check; then
    echo "✅ AI system is healthy"
else
    echo "⚠️ AI system has issues - check logs:"
    echo "   journalctl -u ai-monitor.service -f"
fi

# Pull models if Ollama is available
echo "📥 Checking for AI models..."
if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
    echo "✅ Ollama is accessible - checking models..."
    "$REPO_DIR/ai/ollama/pull-models.sh"
else
    echo "⚠️ Ollama not accessible - models will be pulled when service starts"
fi

echo "🎉 NXCore AI System setup complete!"
echo ""
echo "📋 System Status:"
echo "  Ollama: $(docker ps | grep -q ollama && echo "✅ Running" || echo "❌ Not running")"
echo "  OpenWebUI: $(docker ps | grep -q openwebui && echo "✅ Running" || echo "❌ Not running")"
echo "  AI Monitor: $(systemctl is-active ai-monitor.timer && echo "✅ Active" || echo "❌ Inactive")"
echo ""
echo "🌐 Access Points:"
echo "  Web Interface: https://nxcore.tail79107c.ts.net/ai/"
echo "  Ollama API: http://localhost:11434"
echo ""
echo "📝 Quick Commands:"
echo "  Test AI: $REPO_DIR/ai/ollama-api.sh generate llama3.2 \"Hello\""
echo "  Monitor: $REPO_DIR/ai/ai-monitor.sh monitor"
echo "  Process file: $REPO_DIR/ai/ai-processor.sh process file.txt /tmp/output"
echo ""
echo "📚 Documentation: docs/AI_SYSTEM_OVERVIEW.md"
