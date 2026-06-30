#!/bin/bash
# Jarvis SaaS Setup & Validation Script
# This script checks prerequisites and guides you through initial setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Utility functions
print_header() {
    echo -e "\n${BLUE}=================================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=================================================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_header "CHECKING PREREQUISITES"
    
    local missing=0
    
    # Check Docker
    if command -v docker &> /dev/null; then
        print_success "Docker is installed ($(docker --version | awk '{print $3}'))"
    else
        print_error "Docker is not installed. Install from: https://docs.docker.com/get-docker/"
        missing=$((missing + 1))
    fi
    
    # Check Docker Compose
    if docker compose version &> /dev/null; then
        print_success "Docker Compose is installed"
    else
        print_error "Docker Compose is not installed. Install from: https://docs.docker.com/compose/install/"
        missing=$((missing + 1))
    fi
    
    # Check git
    if command -v git &> /dev/null; then
        print_success "Git is installed"
    else
        print_warning "Git is not installed (optional, but recommended for version control)"
    fi
    
    # Check curl
    if command -v curl &> /dev/null; then
        print_success "curl is installed"
    else
        print_error "curl is not installed. Install with: apt-get install curl"
        missing=$((missing + 1))
    fi
    
    # Check openssl
    if command -v openssl &> /dev/null; then
        print_success "openssl is installed"
    else
        print_error "openssl is not installed. Install with: apt-get install openssl"
        missing=$((missing + 1))
    fi
    
    if [ $missing -gt 0 ]; then
        print_error "$missing prerequisite(s) missing. Please install before continuing."
        exit 1
    fi
    
    print_success "All prerequisites met!"
}

# Generate secrets
generate_secrets() {
    print_header "GENERATING SECRETS"
    
    local n8n_key=$(openssl rand -hex 24)
    local onyx_secret=$(openssl rand -base64 32)
    local inbox_secret=$(openssl rand -base64 32)
    
    print_success "Generated N8N_ENCRYPTION_KEY (24 hex chars)"
    print_success "Generated ONYX_SECRET (32 base64 chars)"
    print_success "Generated INBOX_SECRET (32 base64 chars)"
    
    # Save to temporary file for user to review
    echo "# Generated Secrets ($(date))" > /tmp/jarvis-secrets.txt
    echo "N8N_ENCRYPTION_KEY=$n8n_key" >> /tmp/jarvis-secrets.txt
    echo "ONYX_SECRET=$onyx_secret" >> /tmp/jarvis-secrets.txt
    echo "INBOX_SECRET=$inbox_secret" >> /tmp/jarvis-secrets.txt
    
    echo -e "\n${YELLOW}Secrets saved to /tmp/jarvis-secrets.txt${NC}"
    echo "You'll need these values to fill in deployment/.env"
}

# Validate .env file
validate_env() {
    print_header "VALIDATING CONFIGURATION"
    
    if [ ! -f "deployment/.env" ]; then
        print_error "deployment/.env not found!"
        print_info "Create it by running: cp deployment/.env.example deployment/.env"
        return 1
    fi
    
    # Source the .env but don't export (to avoid interfering with system)
    local env_file="deployment/.env"
    local errors=0
    
    # Check required fields
    for field in ONYX_DOMAIN N8N_DOMAIN INBOX_DOMAIN N8N_ENCRYPTION_KEY ONYX_SECRET INBOX_SECRET SMTP_SERVER SMTP_PORT SMTP_USERNAME SMTP_PASSWORD SMTP_FROM_EMAIL TIMEZONE; do
        if ! grep -q "^$field=" "$env_file"; then
            print_error "Missing required field: $field"
            errors=$((errors + 1))
        elif grep -q "^$field=replace_with" "$env_file" || grep -q "^$field=$" "$env_file" || grep -q "^$field=.*_or_leave_empty" "$env_file"; then
            print_warning "Field not filled in: $field"
            errors=$((errors + 1))
        else
            print_success "✓ $field is configured"
        fi
    done
    
    if [ $errors -gt 0 ]; then
        print_error "$errors configuration issue(s) found. Edit deployment/.env to fix."
        return 1
    fi
    
    print_success "All required fields configured!"
}

# Test DNS resolution
test_dns() {
    print_header "TESTING DNS RESOLUTION"
    
    source deployment/.env
    
    for domain in "$ONYX_DOMAIN" "$N8N_DOMAIN" "$INBOX_DOMAIN"; do
        if nslookup "$domain" &>/dev/null; then
            local ip=$(nslookup "$domain" 2>/dev/null | grep "Address:" | tail -1 | awk '{print $2}')
            print_success "$domain resolves to $ip"
        else
            print_warning "$domain does not resolve yet (DNS may take a few minutes to propagate)"
        fi
    done
}

# Pull Docker images
pull_images() {
    print_header "PULLING DOCKER IMAGES"
    
    print_info "This may take a few minutes on first run..."
    
    docker compose -f deployment/docker-compose.yml pull
    
    print_success "All images pulled successfully!"
}

# Start services
start_services() {
    print_header "STARTING SERVICES"
    
    docker compose -f deployment/docker-compose.yml up -d
    
    print_success "Services started in background"
    print_info "Waiting for services to be ready..."
    
    sleep 10
    
    if docker compose -f deployment/docker-compose.yml ps | grep -q "Up"; then
        print_success "Services are running!"
    else
        print_error "Some services failed to start. Run: docker compose -f deployment/docker-compose.yml logs"
        return 1
    fi
}

# Show access URLs
show_urls() {
    print_header "ACCESS YOUR SERVICES"
    
    source deployment/.env
    
    echo "Open these URLs in your browser (wait 30-60 seconds for HTTPS cert issuance):"
    echo ""
    echo "  Onyx Chat:     https://$ONYX_DOMAIN"
    echo "  n8n:           https://$N8N_DOMAIN"
    echo "  Inbox Zero:    https://$INBOX_DOMAIN"
    echo ""
    echo "Default accounts:"
    echo "  Email:    $(grep ADMIN_EMAIL deployment/.env | cut -d= -f2)"
    echo "  Password: Set on first login"
    echo ""
}

# Main menu
show_menu() {
    print_header "JARVIS SAAS SETUP"
    
    echo "What would you like to do?"
    echo ""
    echo "  1) Check prerequisites (Docker, curl, openssl, etc.)"
    echo "  2) Generate secrets for deployment/.env"
    echo "  3) Validate deployment/.env configuration"
    echo "  4) Test DNS resolution"
    echo "  5) Pull Docker images (first time setup)"
    echo "  6) Start all services"
    echo "  7) Show access URLs and next steps"
    echo "  8) Run full setup (1-7 in sequence)"
    echo "  9) Stop all services"
    echo "  0) Exit"
    echo ""
    read -p "Choose an option [0-9]: " choice
}

# Stop services
stop_services() {
    print_header "STOPPING SERVICES"
    docker compose -f deployment/docker-compose.yml down
    print_success "Services stopped"
}

# Main loop
main() {
    # Change to script directory
    cd "$(dirname "$0")"
    
    while true; do
        show_menu
        
        case $choice in
            1) check_prerequisites ;;
            2) generate_secrets ;;
            3) validate_env ;;
            4) test_dns ;;
            5) pull_images ;;
            6) start_services ;;
            7) show_urls ;;
            8)
                check_prerequisites
                generate_secrets
                echo -e "\n${YELLOW}Next: Edit deployment/.env and add the generated secrets${NC}"
                read -p "Press Enter to continue after editing .env..."
                validate_env
                test_dns
                pull_images
                start_services
                show_urls
                ;;
            9) stop_services ;;
            0) 
                echo "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
