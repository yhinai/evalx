#!/bin/bash

# =============================================================================
# UNIFIED AI CLIENT - ONE-COMMAND DEPLOYMENT
# Deploys the complete application from GitHub repository
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${CYAN}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Banner
display_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
    ╔══════════════════════════════════════════════════════════════════╗
    ║                   🤖 UNIFIED AI CLIENT 🤖                        ║
    ║                                                                  ║
    ║            One-Command Deployment from GitHub                    ║
    ║        OpenAI • Claude • Gemini • DeepSeek • All-in-One          ║
    ║                                                                  ║
    ╚══════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_header "🔍 Checking Prerequisites"
    
    local missing_deps=()
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        missing_deps+=("docker")
    else
        print_success "Docker found"
    fi
    
    # Check Docker Compose
    if ! docker compose version &> /dev/null; then
        missing_deps+=("docker-compose")
    else
        print_success "Docker Compose found"
    fi
    
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running"
        echo "Please start Docker and try again"
        exit 1
    else
        print_success "Docker daemon is running"
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        echo ""
        echo "Please install the missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            case $dep in
                docker)
                    echo "  • Docker: https://docs.docker.com/get-docker/"
                    ;;
                docker-compose)
                    echo "  • Docker Compose: https://docs.docker.com/compose/install/"
                    ;;
            esac
        done
        exit 1
    fi
}

# Setup environment
setup_environment() {
    print_header "⚙️ Setting Up Environment"
    
    # Create .env file if it doesn't exist
    if [ ! -f .env ]; then
        print_info "Creating .env file from example..."
        cp .env.example .env
        print_success "Environment file created (.env)"
        print_warning "Please edit .env file and add your API keys!"
    else
        print_success "Environment file already exists"
    fi
    
    # Check if API keys are configured
    if grep -q "your_.*_api_key_here" .env 2>/dev/null; then
        print_warning "API keys not configured yet"
        
        echo ""
        read -p "Would you like to configure API keys now? (y/N): " configure_keys
        
        if [[ $configure_keys =~ ^[Yy]$ ]]; then
            configure_api_keys
        else
            print_info "You can configure API keys later by editing .env"
        fi
    else
        print_success "API keys appear to be configured"
    fi
}

# Configure API keys
configure_api_keys() {
    print_header "🔑 API Keys Configuration"
    
    echo "Enter your API keys (press Enter to skip):"
    echo ""
    
    # OpenAI
    read -p "OpenAI API Key (sk-proj-...): " openai_key
    if [ ! -z "$openai_key" ]; then
        sed -i.bak "s|OPENAI_API_KEY=.*|OPENAI_API_KEY=$openai_key|" .env
        print_success "OpenAI API key configured"
    fi
    
    # Claude
    read -p "Claude API Key (sk-ant-...): " claude_key
    if [ ! -z "$claude_key" ]; then
        sed -i.bak "s|CLAUDE_API_KEY=.*|CLAUDE_API_KEY=$claude_key|" .env
        print_success "Claude API key configured"
    fi
    
    # Gemini
    read -p "Gemini API Key: " gemini_key
    if [ ! -z "$gemini_key" ]; then
        sed -i.bak "s|GEMINI_API_KEY=.*|GEMINI_API_KEY=$gemini_key|" .env
        print_success "Gemini API key configured"
    fi
    
    # DeepSeek
    read -p "DeepSeek API Key: " deepseek_key
    if [ ! -z "$deepseek_key" ]; then
        sed -i.bak "s|DEEPSEEK_API_KEY=.*|DEEPSEEK_API_KEY=$deepseek_key|" .env
        print_success "DeepSeek API key configured"
    fi
    
    # Clean up backup files
    rm -f .env.bak
    
    print_success "API keys configuration complete!"
}

# Deploy application
deploy_application() {
    print_header "🚀 Deploying Application"
    
    # Stop any existing containers
    print_info "Stopping any existing containers..."
    docker compose down --remove-orphans 2>/dev/null || true
    
    # Build and start services
    print_info "Building and starting services..."
    if docker compose up --build -d; then
        print_success "Services started successfully"
    else
        print_error "Failed to start services"
        exit 1
    fi
    
    # Wait for services to be ready
    print_info "Waiting for services to be ready..."
    sleep 15
    
    # Health check
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -f http://localhost:8000/health &>/dev/null; then
            print_success "Backend is healthy"
            break
        else
            ((attempt++))
            if [ $attempt -eq $max_attempts ]; then
                print_error "Backend health check failed"
                print_info "Check logs with: docker compose logs backend"
                exit 1
            fi
            sleep 2
        fi
    done
    
    # Check frontend
    if curl -f http://localhost:3000 &>/dev/null; then
        print_success "Frontend is accessible"
    else
        print_warning "Frontend may not be ready yet"
    fi
}

# Display completion info
display_completion() {
    print_header "🎉 Deployment Complete!"
    
    echo ""
    echo -e "${GREEN}🚀 Your Unified AI Client is now running! 🚀${NC}"
    echo ""
    echo -e "${CYAN}Access your application:${NC}"
    echo -e "  ${BLUE}🌐 Frontend:${NC} http://localhost:3000"
    echo -e "  ${BLUE}🔧 Backend API:${NC} http://localhost:8000"
    echo -e "  ${BLUE}📖 API Documentation:${NC} http://localhost:8000/docs"
    echo -e "  ${BLUE}❤️ Health Check:${NC} http://localhost:8000/health"
    echo ""
    echo -e "${CYAN}Useful commands:${NC}"
    echo -e "  ${BLUE}📋 View logs:${NC} docker compose logs -f"
    echo -e "  ${BLUE}🔄 Restart:${NC} docker compose restart"
    echo -e "  ${BLUE}⏹️  Stop:${NC} docker compose down"
    echo -e "  ${BLUE}🗑️  Clean up:${NC} docker compose down -v"
    echo ""
    
    # Show configured providers
    local configured_providers=()
    if [ -f .env ]; then
        grep -v "your_.*_key_here" .env | grep "_API_KEY=" | while read line; do
            if [[ $line =~ ^([A-Z_]+)_API_KEY=.+ ]]; then
                provider=$(echo "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]')
                echo -e "${GREEN}$(echo $provider | tr '[:lower:]' '[:upper:]') API key configured${NC}"
            fi
        done
    fi
    
    echo ""
    echo -e "${YELLOW}💡 Next steps:${NC}"
    echo -e "  1. Open http://localhost:3000 in your browser"
    echo -e "  2. Select an AI provider (OpenAI, Claude, Gemini, or DeepSeek)"
    echo -e "  3. Start chatting!"
    echo ""
    echo -e "${GREEN}✨ Happy chatting with multiple AI models! ✨${NC}"
}

# Error handling
cleanup_on_error() {
    print_error "Deployment failed! Cleaning up..."
    docker compose down --remove-orphans 2>/dev/null || true
    exit 1
}

# Main execution
main() {
    display_banner
    check_prerequisites
    setup_environment
    deploy_application
    display_completion
}

# Set up error handling
trap cleanup_on_error ERR

# Run main function
main "$@"
