#!/bin/bash

# MongoDB on Kind - Credential Management Script
# This script manages encrypted credentials for the deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Default credentials directory
CREDS_DIR="$(dirname "$0")/../.credentials"
ENCRYPTED_FILE="$CREDS_DIR/encrypted_creds.enc"
KEY_FILE="$CREDS_DIR/encryption.key"

# Ensure credentials directory exists
mkdir -p "$CREDS_DIR"

# Function to generate a random encryption key
generate_key() {
    if [ ! -f "$KEY_FILE" ]; then
        print_status "Generating encryption key..."
        openssl rand -base64 32 > "$KEY_FILE"
        chmod 600 "$KEY_FILE"
        print_success "Encryption key generated"
    else
        print_status "Using existing encryption key"
    fi
}

# Function to encrypt credentials
encrypt_credentials() {
    local mongodb_admin_password="$1"
    local mongodb_root_password="$2"
    local webui_password="$3"
    
    generate_key
    
    # Create credentials JSON
    cat > "/tmp/creds.json" << EOF
{
  "mongodb_admin_password": "$mongodb_admin_password",
  "mongodb_root_password": "$mongodb_root_password",
  "webui_password": "$webui_password",
  "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

    # Encrypt the credentials
    openssl enc -aes-256-cbc -salt -in "/tmp/creds.json" -out "$ENCRYPTED_FILE" -pass file:"$KEY_FILE"
    rm "/tmp/creds.json"
    chmod 600 "$ENCRYPTED_FILE"
    
    print_success "Credentials encrypted and stored securely"
}

# Function to decrypt credentials
decrypt_credentials() {
    if [ ! -f "$ENCRYPTED_FILE" ] || [ ! -f "$KEY_FILE" ]; then
        print_error "Encrypted credentials or key file not found"
        return 1
    fi
    
    openssl enc -aes-256-cbc -d -in "$ENCRYPTED_FILE" -pass file:"$KEY_FILE" 2>/dev/null
}

# Function to get a specific credential
get_credential() {
    local key="$1"
    
    if ! command -v jq &> /dev/null; then
        print_error "jq is required for credential extraction. Please install it: brew install jq"
        return 1
    fi
    
    local creds_json=$(decrypt_credentials)
    if [ $? -ne 0 ]; then
        print_error "Failed to decrypt credentials"
        return 1
    fi
    
    echo "$creds_json" | jq -r ".$key"
}

# Function to generate secure random passwords
generate_secure_password() {
    local length=${1:-24}
    openssl rand -base64 $length | tr -d "=+/" | cut -c1-$length
}

# Function to initialize with secure random passwords
initialize_secure_credentials() {
    print_status "Generating secure random passwords..."
    
    local mongodb_admin_password=$(generate_secure_password 24)
    local mongodb_root_password=$(generate_secure_password 32)
    local webui_password=$(generate_secure_password 16)
    
    encrypt_credentials "$mongodb_admin_password" "$mongodb_root_password" "$webui_password"
    
    echo
    print_success "Secure credentials initialized!"
    print_warning "IMPORTANT: The encryption key is stored in $KEY_FILE"
    print_warning "Keep this file secure and backed up. Without it, credentials cannot be recovered."
}

# Function to show credentials (for authorized use)
show_credentials() {
    if [ ! -f "$ENCRYPTED_FILE" ]; then
        print_error "No encrypted credentials found. Run with --init first."
        return 1
    fi
    
    print_status "Decrypting credentials..."
    local creds_json=$(decrypt_credentials)
    if [ $? -ne 0 ]; then
        print_error "Failed to decrypt credentials"
        return 1
    fi
    
    echo
    print_status "MongoDB Credentials:"
    echo "  Admin Password: $(echo "$creds_json" | jq -r '.mongodb_admin_password')"
    echo "  Root Password:  $(echo "$creds_json" | jq -r '.mongodb_root_password')"
    echo "  WebUI Password: $(echo "$creds_json" | jq -r '.webui_password')"
    echo "  Generated At:   $(echo "$creds_json" | jq -r '.generated_at')"
}

# Function to update Kubernetes secrets with encrypted credentials
update_k8s_secrets() {
    if [ ! -f "$ENCRYPTED_FILE" ]; then
        print_error "No encrypted credentials found. Run with --init first."
        return 1
    fi
    
    print_status "Updating Kubernetes secrets with encrypted credentials..."
    
    local mongodb_admin_password=$(get_credential "mongodb_admin_password")
    local mongodb_root_password=$(get_credential "mongodb_root_password")
    
    if [ -z "$mongodb_admin_password" ] || [ -z "$mongodb_root_password" ]; then
        print_error "Failed to retrieve credentials"
        return 1
    fi
    
    # Base64 encode the credentials
    local admin_b64=$(echo -n "$mongodb_admin_password" | base64)
    local root_b64=$(echo -n "$mongodb_root_password" | base64)
    local username_b64=$(echo -n "admin" | base64)
    
    # Update the secret file
    local secret_file="$(dirname "$0")/../resource/secrets/mongodb-secret.yaml"
    
    cat > "$secret_file" << EOF
apiVersion: v1
kind: Secret
metadata:
  name: mongodb-secret
  namespace: default
type: Opaque
data:
  # Note: These are encrypted credentials, managed by scripts/manage-credentials.sh
  # To view credentials: ./scripts/manage-credentials.sh --show
  mongodb-username: $username_b64
  mongodb-password: $admin_b64
  mongodb-root-password: $root_b64
EOF

    print_success "Kubernetes secret file updated"
}

# Function to update deployment files
update_deployment_files() {
    if [ ! -f "$ENCRYPTED_FILE" ]; then
        print_error "No encrypted credentials found. Run with --init first."
        return 1
    fi
    
    print_status "Updating deployment files with encrypted credentials..."
    
    local webui_password=$(get_credential "webui_password")
    
    if [ -z "$webui_password" ]; then
        print_error "Failed to retrieve WebUI password"
        return 1
    fi
    
    # Update MongoDB Express deployment
    local express_deployment="$(dirname "$0")/../resource/deployments/mongodb-express-deployment.yaml"
    
    # Replace the hardcoded password with a reference to get it from credentials
    sed -i.bak "s/value: \"webadmin123\"/value: \"$webui_password\"/" "$express_deployment"
    rm -f "${express_deployment}.bak"
    
    print_success "Deployment files updated with secure credentials"
}

# Function to backup credentials
backup_credentials() {
    if [ ! -f "$ENCRYPTED_FILE" ] || [ ! -f "$KEY_FILE" ]; then
        print_error "No credentials to backup"
        return 1
    fi
    
    local backup_dir="${1:-./credentials_backup_$(date +%Y%m%d_%H%M%S)}"
    mkdir -p "$backup_dir"
    
    cp "$ENCRYPTED_FILE" "$backup_dir/"
    cp "$KEY_FILE" "$backup_dir/"
    
    print_success "Credentials backed up to: $backup_dir"
    print_warning "Store this backup in a secure location!"
}

# Main function
main() {
    case "$1" in
        "--init")
            initialize_secure_credentials
            update_k8s_secrets
            update_deployment_files
            ;;
        "--show")
            show_credentials
            ;;
        "--get")
            if [ -z "$2" ]; then
                print_error "Usage: $0 --get <credential_name>"
                print_error "Available credentials: mongodb_admin_password, mongodb_root_password, webui_password"
                exit 1
            fi
            get_credential "$2"
            ;;
        "--update-k8s")
            update_k8s_secrets
            ;;
        "--update-deployments")
            update_deployment_files
            ;;
        "--backup")
            backup_credentials "$2"
            ;;
        "--help" | "-h" | *)
            echo "MongoDB on Kind - Credential Management"
            echo
            echo "This script securely manages encrypted credentials for the MongoDB deployment."
            echo
            echo "Usage:"
            echo "  $0 --init                    Initialize with secure random passwords"
            echo "  $0 --show                    Show decrypted credentials (use carefully)"
            echo "  $0 --get <credential>        Get specific credential"
            echo "  $0 --update-k8s             Update Kubernetes secrets"
            echo "  $0 --update-deployments     Update deployment files"
            echo "  $0 --backup [directory]     Backup encrypted credentials"
            echo "  $0 --help                   Show this help message"
            echo
            echo "Available credentials:"
            echo "  mongodb_admin_password, mongodb_root_password, webui_password"
            echo
            echo "Security Notes:"
            echo "  - Credentials are encrypted using AES-256-CBC"
            echo "  - Encryption key is stored separately in .credentials/encryption.key"
            echo "  - Keep the encryption key secure and backed up"
            echo "  - Never commit the .credentials directory to version control"
            echo
            ;;
    esac
}

main "$@"
