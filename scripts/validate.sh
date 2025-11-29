#!/bin/bash

# MongoDB on Kind - Validation Script
# This script validates the deployment and tests connectivity

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

# Function to get dynamic host IP
get_host_ip() {
    HOST_IP=$(ifconfig | grep -A 1 'en0' | grep 'inet ' | awk '{print $2}' | head -n 1)
    
    if [ -z "$HOST_IP" ]; then
        # Try alternative interface names
        HOST_IP=$(ifconfig | grep -E 'inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | grep -v '127.0.0.1' | awk '{print $2}' | head -n 1)
    fi
    
    if [ -z "$HOST_IP" ]; then
        HOST_IP="localhost"
    fi
    
    echo $HOST_IP
}

main() {
    print_status "Starting validation of MongoDB on Kind deployment..."
    
    CLUSTER_NAME="mongodb-cluster"
    
    # Check if cluster exists
    if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
        print_error "Kind cluster '$CLUSTER_NAME' not found. Please run deploy.sh first."
        exit 1
    fi
    
    print_success "Kind cluster found!"
    
    # Set kubectl context
    kubectl cluster-info --context kind-$CLUSTER_NAME > /dev/null 2>&1
    
    print_status "Checking pod status..."
    
    # Check MongoDB pod
    MONGODB_STATUS=$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NotFound")
    if [ "$MONGODB_STATUS" == "Running" ]; then
        print_success "MongoDB pod is running"
    else
        print_error "MongoDB pod status: $MONGODB_STATUS"
    fi
    
    # Check MongoDB Express pod
    MONGOEXPRESS_STATUS=$(kubectl get pods -l app=mongodb-express -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NotFound")
    if [ "$MONGOEXPRESS_STATUS" == "Running" ]; then
        print_success "MongoDB Express pod is running"
    else
        print_error "MongoDB Express pod status: $MONGOEXPRESS_STATUS"
    fi
    
    # Check services
    print_status "Checking services..."
    
    # MongoDB services
    if kubectl get service mongodb-service > /dev/null 2>&1; then
        print_success "MongoDB internal service exists"
    else
        print_error "MongoDB internal service not found"
    fi
    
    if kubectl get service mongodb-nodeport > /dev/null 2>&1; then
        print_success "MongoDB external service exists"
    else
        print_error "MongoDB external service not found"
    fi
    
    # MongoDB Express services
    if kubectl get service mongodb-express-service > /dev/null 2>&1; then
        print_success "MongoDB Express internal service exists"
    else
        print_error "MongoDB Express internal service not found"
    fi
    
    if kubectl get service mongodb-express-nodeport > /dev/null 2>&1; then
        print_success "MongoDB Express external service exists"
    else
        print_error "MongoDB Express external service not found"
    fi
    
    # Get service ports
    HOST_IP=$(get_host_ip)
    
    if kubectl get service mongodb-nodeport > /dev/null 2>&1; then
        MONGODB_NODEPORT=$(kubectl get service mongodb-nodeport -o jsonpath='{.spec.ports[0].nodePort}')
        print_status "MongoDB external port: $MONGODB_NODEPORT"
    fi
    
    if kubectl get service mongodb-express-nodeport > /dev/null 2>&1; then
        MONGOEXPRESS_NODEPORT=$(kubectl get service mongodb-express-nodeport -o jsonpath='{.spec.ports[0].nodePort}')
        print_status "MongoDB Express external port: $MONGOEXPRESS_NODEPORT"
    fi
    
    # Test MongoDB connectivity from within cluster
    print_status "Testing MongoDB connectivity from within cluster..."
    
    MONGO_POD=$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    if [ -n "$MONGO_POD" ]; then
        if kubectl exec $MONGO_POD -- mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
            print_success "MongoDB is responding to ping commands"
        else
            print_warning "MongoDB ping test failed (this might be normal if auth is required)"
        fi
    fi
    
    # Test MongoDB Express connectivity
    if [ -n "$MONGOEXPRESS_NODEPORT" ]; then
        print_status "Testing MongoDB Express web interface..."
        
        # Get WebUI password from encrypted credentials
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        if [ -f "$SCRIPT_DIR/manage-credentials.sh" ]; then
            WEBUI_PASSWORD=$("$SCRIPT_DIR/manage-credentials.sh" --get webui_password 2>/dev/null || echo "")
            
            if [ -n "$WEBUI_PASSWORD" ]; then
                # Try to curl the MongoDB Express interface with encrypted credentials
                if command -v curl > /dev/null 2>&1; then
                    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -u admin:"$WEBUI_PASSWORD" http://localhost:8081 --connect-timeout 5 || echo "000")
                    if [ "$HTTP_STATUS" == "200" ]; then
                        print_success "MongoDB Express web interface is accessible"
                    else
                        print_warning "MongoDB Express web interface returned HTTP $HTTP_STATUS"
                    fi
                else
                    print_warning "curl not available for web interface testing"
                fi
            else
                print_warning "Could not retrieve WebUI password for testing"
            fi
        else
            print_warning "Credential management script not found"
        fi
    fi
    
    # Check persistent volume
    print_status "Checking persistent storage..."
    
    PVC_STATUS=$(kubectl get pvc mongodb-pvc -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotFound")
    if [ "$PVC_STATUS" == "Bound" ]; then
        print_success "Persistent volume claim is bound"
    else
        print_error "Persistent volume claim status: $PVC_STATUS"
    fi
    
    # Check ConfigMap and Secret
    print_status "Checking configuration resources..."
    
    if kubectl get configmap mongodb-configmap > /dev/null 2>&1; then
        print_success "MongoDB ConfigMap exists"
    else
        print_error "MongoDB ConfigMap not found"
    fi
    
    if kubectl get secret mongodb-secret > /dev/null 2>&1; then
        print_success "MongoDB Secret exists"
    else
        print_error "MongoDB Secret not found"
    fi
    
    # Resource usage
    print_status "Resource usage:"
    kubectl top pods 2>/dev/null || print_warning "Metrics server not available for resource usage"
    
    # Summary
    echo
    print_status "Validation Summary:"
    echo "  Cluster: $CLUSTER_NAME"
    echo "  Host IP: $HOST_IP"
    echo "  MongoDB external: $HOST_IP:${MONGODB_NODEPORT:-'N/A'}"
    echo "  MongoDB Express UI: http://$HOST_IP:${MONGOEXPRESS_NODEPORT:-'N/A'}"
    echo
    
    # Display current status
    echo "Current Pod Status:"
    kubectl get pods -o wide
    echo
    echo "Current Service Status:"
    kubectl get services
    echo
    
    print_success "Validation completed!"
}

# Help function
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "MongoDB on Kind Validation Script"
    echo
    echo "Usage:"
    echo "  $0              Run validation tests"
    echo "  $0 --help       Show this help message"
    echo
    exit 0
fi

main
