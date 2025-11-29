#!/bin/bash

# MongoDB on Kind - Deployment Script
# This script creates a Kind cluster and deploys MongoDB and MongoDB Express

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to check if command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 is not installed. Please install it first."
        exit 1
    fi
}

# Function to wait for pods to be ready
wait_for_pods() {
    local namespace=$1
    local label_selector=$2
    local timeout=${3:-300}
    
    print_status "Waiting for pods with label $label_selector to be ready..."
    kubectl wait --for=condition=ready pod -l $label_selector -n $namespace --timeout=${timeout}s
}

# Function to get dynamic host IP
get_host_ip() {
    # Try different methods to get the host IP
    HOST_IP=$(ifconfig | grep -A 1 'en0' | grep 'inet ' | awk '{print $2}' | head -n 1)
    
    if [ -z "$HOST_IP" ]; then
        # Try alternative interface names
        HOST_IP=$(ifconfig | grep -E 'inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | grep -v '127.0.0.1' | awk '{print $2}' | head -n 1)
    fi
    
    if [ -z "$HOST_IP" ]; then
        # Try using route command
        HOST_IP=$(route get default | grep interface | awk '{print $2}' | xargs ifconfig | grep 'inet ' | awk '{print $2}' | head -n 1 2>/dev/null || echo "")
    fi
    
    if [ -z "$HOST_IP" ]; then
        print_warning "Could not detect host IP automatically. Using localhost."
        HOST_IP="localhost"
    fi
    
    echo $HOST_IP
}

# Main deployment function
main() {
    print_status "Starting MongoDB on Kind deployment..."
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    check_command "kind"
    check_command "kubectl"
    check_command "docker"
    check_command "jq"
    
    # Verify encrypted credentials exist
    if [ ! -f "$(dirname "$0")/../.credentials/encrypted_creds.enc" ]; then
        print_error "Encrypted credentials not found!"
        print_error "Please run: ./scripts/manage-credentials.sh --init"
        exit 1
    fi
    
    # Get current directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
    
    print_status "Project directory: $PROJECT_DIR"
    
    # Detect host IP
    HOST_IP=$(get_host_ip)
    print_status "Detected host IP: $HOST_IP"
    
    # Check if cluster already exists
    CLUSTER_NAME="mongodb-cluster"
    if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
        print_warning "Kind cluster '$CLUSTER_NAME' already exists."
        read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Deleting existing cluster..."
            kind delete cluster --name $CLUSTER_NAME
        else
            print_status "Using existing cluster..."
        fi
    fi
    
    # Create Kind cluster if it doesn't exist
    if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
        print_status "Creating Kind cluster..."
        kind create cluster --config "$PROJECT_DIR/kind/kind-config.yaml" --name $CLUSTER_NAME
        print_success "Kind cluster created successfully!"
    fi
    
    # Set kubectl context
    print_status "Setting kubectl context..."
    kubectl cluster-info --context kind-$CLUSTER_NAME
    
    # Apply Kubernetes manifests in correct order
    print_status "Deploying Kubernetes resources..."
    
    # 1. Storage Class and PVC
    print_status "Creating storage resources..."
    kubectl apply -f "$PROJECT_DIR/resource/storage/"
    
    # 2. ConfigMap
    print_status "Creating ConfigMap..."
    kubectl apply -f "$PROJECT_DIR/resource/configmaps/"
    
    # 3. Secret
    print_status "Creating Secret..."
    kubectl apply -f "$PROJECT_DIR/resource/secrets/"
    
    # 4. MongoDB Deployment
    print_status "Deploying MongoDB..."
    kubectl apply -f "$PROJECT_DIR/resource/deployments/mongodb-deployment.yaml"
    
    # 5. MongoDB Service
    print_status "Creating MongoDB services..."
    kubectl apply -f "$PROJECT_DIR/resource/services/mongodb-service.yaml"
    
    # Wait for MongoDB to be ready
    print_status "Waiting for MongoDB to be ready..."
    wait_for_pods "default" "app=mongodb" 120
    
    # 6. MongoDB Express Deployment
    print_status "Deploying MongoDB Express..."
    kubectl apply -f "$PROJECT_DIR/resource/deployments/mongodb-express-deployment.yaml"
    
    # 7. MongoDB Express Service
    print_status "Creating MongoDB Express services..."
    kubectl apply -f "$PROJECT_DIR/resource/services/mongodb-express-service.yaml"
    
    # Wait for MongoDB Express to be ready
    print_status "Waiting for MongoDB Express to be ready..."
    wait_for_pods "default" "app=mongodb-express" 120
    
    # Get service information
    print_status "Getting service information..."
    
    # MongoDB NodePort
    MONGODB_NODEPORT=$(kubectl get service mongodb-nodeport -o jsonpath='{.spec.ports[0].nodePort}')
    
    # MongoDB Express NodePort
    MONGOEXPRESS_NODEPORT=$(kubectl get service mongodb-express-nodeport -o jsonpath='{.spec.ports[0].nodePort}')
    
    # Display deployment information
    echo
    print_success "Deployment completed successfully!"
    echo
    echo "=================================================================="
    echo "                    DEPLOYMENT INFORMATION"
    echo "=================================================================="
    echo
    echo "Cluster Name: $CLUSTER_NAME"
    echo "Host IP: $HOST_IP"
    echo
    echo "Services:"
    echo "  MongoDB:"
    echo "    - Internal: mongodb-service.default.svc.cluster.local:27017"
    echo "    - External: $HOST_IP:$MONGODB_NODEPORT"
    echo
    echo "  MongoDB Express:"
    echo "    - Internal: mongodb-express-service.default.svc.cluster.local:8081"
    echo "    - External: http://$HOST_IP:$MONGOEXPRESS_NODEPORT"
    echo
    echo "Web Interface:"
    echo "  MongoDB Express UI: http://$HOST_IP:$MONGOEXPRESS_NODEPORT"
    echo
    echo "Database Credentials:"
    echo "  Username: admin"
    echo "  Password: (stored in kubernetes secret)"
    echo
    echo "=================================================================="
    echo
    
    # Show pod status
    print_status "Pod Status:"
    kubectl get pods -o wide
    echo
    
    # Show service status
    print_status "Service Status:"
    kubectl get services
    echo
    
    # Test connectivity
    print_status "Testing connectivity..."
    if kubectl get pods -l app=mongodb -o jsonpath='{.items[0].status.phase}' | grep -q "Running"; then
        print_success "MongoDB is running!"
    else
        print_warning "MongoDB may not be fully ready yet."
    fi
    
    if kubectl get pods -l app=mongodb-express -o jsonpath='{.items[0].status.phase}' | grep -q "Running"; then
        print_success "MongoDB Express is running!"
        echo
        print_status "You can access MongoDB Express at: http://$HOST_IP:$MONGOEXPRESS_NODEPORT"
    else
        print_warning "MongoDB Express may not be fully ready yet."
    fi
    
    echo
    print_status "Useful commands:"
    echo "  View logs: kubectl logs -l app=mongodb"
    echo "  View logs: kubectl logs -l app=mongodb-express"
    echo "  Scale: kubectl scale deployment mongodb --replicas=2"
    echo "  Delete cluster: kind delete cluster --name $CLUSTER_NAME"
    echo
}

# Cleanup function
cleanup() {
    if [ "$1" == "--cleanup" ]; then
        CLUSTER_NAME="mongodb-cluster"
        print_status "Cleaning up..."
        if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
            kind delete cluster --name $CLUSTER_NAME
            print_success "Cluster deleted successfully!"
        else
            print_warning "No cluster found to delete."
        fi
        exit 0
    fi
}

# Script options
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "MongoDB on Kind Deployment Script"
    echo
    echo "Usage:"
    echo "  $0              Deploy the complete stack"
    echo "  $0 --cleanup    Delete the Kind cluster"
    echo "  $0 --help       Show this help message"
    echo
    exit 0
fi

cleanup "$1"

# Run main deployment
main
