#!/bin/bash

# MongoDB on Kind - Status Display Script
# Shows the current status and access information for the deployment

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
    echo -e "${CYAN}${BOLD}$1${NC}"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

echo
print_header "================================================================"
print_header "         MongoDB on Kind Kubernetes Cluster Status"
print_header "================================================================"
echo

# Check if cluster exists
if ! kind get clusters | grep -q "^mongodb-cluster$"; then
    print_warning "Kind cluster 'mongodb-cluster' not found!"
    echo
    echo "To deploy the cluster, run: ./scripts/deploy.sh"
    exit 1
fi

print_success "Kind cluster 'mongodb-cluster' is running"

# Set kubectl context
kubectl config use-context kind-mongodb-cluster > /dev/null 2>&1

# Check pod status
echo
print_header "Pod Status:"
kubectl get pods -l 'app in (mongodb,mongodb-express)' -o wide

# Check service status
echo
print_header "Service Status:"
kubectl get services -l 'app in (mongodb,mongodb-express)' -o wide

# Get access information
echo
print_header "Access Information:"

# Check if MongoDB Express is accessible
if nc -z localhost 8081 2>/dev/null; then
    print_success "MongoDB Express Web UI: http://localhost:8081"
    echo "  Username: admin"
    echo "  Password: (encrypted - use ./scripts/manage-credentials.sh --get webui_password)"
else
    print_warning "MongoDB Express not accessible on localhost:8081"
fi

# Check if MongoDB is accessible
if nc -z localhost 27017 2>/dev/null; then
    print_success "MongoDB Database: localhost:27017"
    echo "  Username: admin"
    echo "  Password: (encrypted - use ./scripts/manage-credentials.sh --get mongodb_root_password)"
else
    print_warning "MongoDB not accessible on localhost:27017"
fi

echo
print_header "Useful Commands:"
echo
echo "  # View MongoDB logs"
echo "  kubectl logs -l app=mongodb"
echo
echo "  # View MongoDB Express logs"
echo "  kubectl logs -l app=mongodb-express"
echo
echo "  # Connect to MongoDB shell"
echo "  kubectl exec -it \$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}') -- mongosh"
echo
echo "  # Scale MongoDB Express"
echo "  kubectl scale deployment mongodb-express-deployment --replicas=2"
echo
echo "  # Get MongoDB credentials
  echo "  ./scripts/manage-credentials.sh --get mongodb_root_password"
  echo
  echo "  # Show all credentials (use carefully)"
  echo "  ./scripts/manage-credentials.sh --show"
echo
echo "  # Validate deployment"
echo "  ./scripts/validate.sh"
echo
echo "  # Clean up everything"
echo "  ./scripts/cleanup.sh"

echo
print_header "Storage Information:"
kubectl get pv,pvc | grep mongodb

echo
print_header "================================================================"

# Quick connectivity test
echo
# Quick connectivity test
echo
print_header "Quick Connectivity Test:"

# Get credentials for testing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/manage-credentials.sh" ]; then
    WEBUI_PASSWORD=$("$SCRIPT_DIR/manage-credentials.sh" --get webui_password 2>/dev/null || echo "")
    
    if [ -n "$WEBUI_PASSWORD" ] && curl -u admin:"$WEBUI_PASSWORD" http://localhost:8081 --connect-timeout 5 --max-time 10 -s > /dev/null 2>&1; then
        print_success "MongoDB Express web interface is responding"
    else
        print_warning "MongoDB Express web interface test failed"
    fi
else
    print_warning "Could not test MongoDB Express - credential script not found"
fi

if nc -z localhost 27017 2>/dev/null; then
    print_success "MongoDB database port is accessible"
else
    print_warning "MongoDB database port test failed"
fi

echo
print_header "================================================================"
echo
