#!/usr/bin/env bash
echo "📥 Pulling AI models for NXCore..."
ollama pull llama3.2
ollama pull mistral
ollama pull codellama
echo "✅ Models ready for NXCore AI services"
