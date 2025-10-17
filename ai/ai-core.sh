#!/usr/bin/env bash
set -e
echo "🔧 Installing Ollama and pulling starter models..."
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl enable --now ollama
echo "📥 Pulling models (customize as needed)..."
ollama pull llama3.2
ollama pull mistral
ollama pull codellama
echo "✅ AI core ready."
