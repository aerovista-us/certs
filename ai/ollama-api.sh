#!/usr/bin/env bash
set -euo pipefail

# Ollama API Client for NXCore AI Services
# Provides easy access to Ollama models via command line

OLLAMA_HOST="${OLLAMA_HOST:-http://localhost:11434}"
DEFAULT_MODEL="llama3.2"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date -u +%Y-%m-%dT%H:%M:%SZ)]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if Ollama is running
check_ollama() {
    if ! curl -s "$OLLAMA_HOST/api/tags" >/dev/null 2>&1; then
        error "Ollama is not running at $OLLAMA_HOST"
        exit 1
    fi
}

# List available models
list_models() {
    log "Available models:"
    curl -s "$OLLAMA_HOST/api/tags" | jq -r '.models[] | "  - \(.name) (\(.size | . / 1024 / 1024 / 1024 | floor)GB)"'
}

# Generate text using Ollama
generate() {
    local model="${1:-$DEFAULT_MODEL}"
    local prompt="$2"
    local system_prompt="${3:-}"
    
    if [ -z "$prompt" ]; then
        error "Prompt is required"
        echo "Usage: $0 generate [model] \"prompt\" [system_prompt]"
        exit 1
    fi
    
    log "Generating with model: $model"
    
    local payload
    if [ -n "$system_prompt" ]; then
        payload=$(cat <<EOF
{
    "model": "$model",
    "prompt": "$prompt",
    "system": "$system_prompt",
    "stream": false
}
EOF
)
    else
        payload=$(cat <<EOF
{
    "model": "$model",
    "prompt": "$prompt",
    "stream": false
}
EOF
)
    fi
    
    curl -s -X POST "$OLLAMA_HOST/api/generate" \
        -H "Content-Type: application/json" \
        -d "$payload" | jq -r '.response'
}

# Process file content
process_file() {
    local model="${1:-$DEFAULT_MODEL}"
    local filepath="$2"
    local task="${3:-summarize}"
    
    if [ ! -f "$filepath" ]; then
        error "File not found: $filepath"
        exit 1
    fi
    
    local content=$(cat "$filepath")
    local prompt
    
    case "$task" in
        "summarize")
            prompt="Please provide a concise summary of the following content:\n\n$content"
            ;;
        "analyze")
            prompt="Please analyze the following content and provide insights:\n\n$content"
            ;;
        "extract")
            prompt="Please extract key information from the following content:\n\n$content"
            ;;
        *)
            prompt="$task\n\n$content"
            ;;
    esac
    
    generate "$model" "$prompt"
}

# Chat with model
chat() {
    local model="${1:-$DEFAULT_MODEL}"
    local message="$2"
    
    if [ -z "$message" ]; then
        error "Message is required"
        echo "Usage: $0 chat [model] \"message\""
        exit 1
    fi
    
    log "Chatting with model: $model"
    generate "$model" "$message"
}

# Process CSV data
process_csv() {
    local model="${1:-$DEFAULT_MODEL}"
    local csv_file="$2"
    
    if [ ! -f "$csv_file" ]; then
        error "CSV file not found: $csv_file"
        exit 1
    fi
    
    # Get first few lines for context
    local sample=$(head -5 "$csv_file")
    local prompt="Please analyze this CSV data and provide insights about its structure and content:\n\n$sample"
    
    generate "$model" "$prompt"
}

# Main function
main() {
    check_ollama
    
    case "${1:-help}" in
        "list")
            list_models
            ;;
        "generate")
            generate "$2" "$3" "$4"
            ;;
        "process")
            process_file "$2" "$3" "$4"
            ;;
        "chat")
            chat "$2" "$3"
            ;;
        "csv")
            process_csv "$2" "$3"
            ;;
        "help"|*)
            echo "NXCore Ollama API Client"
            echo ""
            echo "Usage: $0 <command> [options]"
            echo ""
            echo "Commands:"
            echo "  list                           - List available models"
            echo "  generate [model] \"prompt\"      - Generate text"
            echo "  process [model] file [task]    - Process file (summarize/analyze/extract)"
            echo "  chat [model] \"message\"         - Chat with model"
            echo "  csv [model] file.csv           - Process CSV data"
            echo "  help                           - Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 list"
            echo "  $0 generate llama3.2 \"Explain Docker containers\""
            echo "  $0 process llama3.2 document.txt summarize"
            echo "  $0 chat mistral \"Hello, how are you?\""
            echo "  $0 csv llama3.2 data.csv"
            echo ""
            echo "Environment:"
            echo "  OLLAMA_HOST - Ollama server URL (default: http://localhost:11434)"
            ;;
    esac
}

main "$@"
