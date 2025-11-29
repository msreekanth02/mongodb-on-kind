#!/bin/bash

# MongoDB on Kind - Cleanup Script
# This script safely removes the Kind cluster and cleans up resources

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

main() {
    CLUSTER_NAME="mongodb-cluster"
    
    echo "=================================================================="
    echo "                MongoDB on Kind - Cleanup"
    echo "=================================================================="
    echo
    
    # Check if cluster exists
    if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
        print_warning "Kind cluster '$CLUSTER_NAME' not found."
        exit 0
    fi
    
    print_warning "This will permanently delete the following:"
    echo "  - Kind cluster: $CLUSTER_NAME"
    echo "  - All MongoDB data (unless backed up)"
    echo "  - All Kubernetes resources in the cluster"
    echo
    
    # Confirmation prompt
    read -p "Are you sure you want to proceed? (type 'yes' to confirm): " -r
    echo
    
    if [[ ! $REPLY == "yes" ]]; then
        print_status "Cleanup cancelled."
        exit 0
    fi
    
    # Show current cluster status before deletion
    print_status "Current cluster status:"
    kubectl config use-context kind-$CLUSTER_NAME 2>/dev/null || true
    
    echo "Pods:"
    kubectl get pods 2>/dev/null || print_warning "Could not retrieve pods"
    echo
    
    echo "Services:"
    kubectl get services 2>/dev/null || print_warning "Could not retrieve services"
    echo
    
    echo "Persistent Volumes:"
    kubectl get pv,pvc 2>/dev/null || print_warning "Could not retrieve storage"
    echo
    
    # Optional: Create a final backup
    read -p "Do you want to create a final MongoDB backup before deletion? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Creating MongoDB backup..."
        
        MONGO_POD=$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
        if [ -n "$MONGO_POD" ]; then
            BACKUP_DIR="/tmp/mongodb-backup-$(date +%Y%m%d-%H%M%S)"
            print_status "Backing up to: $BACKUP_DIR"
            
            # Create backup directory on local machine
            mkdir -p "$BACKUP_DIR"
            
            # Run mongodump in the pod and copy to local machine
            kubectl exec $MONGO_POD -- mongodump --out /tmp/backup 2>/dev/null || print_warning "Backup may have failed"
            kubectl cp $MONGO_POD:/tmp/backup "$BACKUP_DIR" 2>/dev/null || print_warning "Could not copy backup"
            
            if [ -d "$BACKUP_DIR" ] && [ "$(ls -A $BACKUP_DIR)" ]; then
                print_success "Backup created at: $BACKUP_DIR"
            else
                print_warning "Backup may not have completed successfully"
            fi
        else
            print_warning "MongoDB pod not found, skipping backup"
        fi
    fi
    
    # Delete the Kind cluster
    print_status "Deleting Kind cluster: $CLUSTER_NAME"
    
    if kind delete cluster --name $CLUSTER_NAME; then
        print_success "Kind cluster deleted successfully!"
    else
        print_error "Failed to delete Kind cluster"
        exit 1
    fi
    
    # Clean up kubectl contexts
    print_status "Cleaning up kubectl context..."
    kubectl config delete-context kind-$CLUSTER_NAME 2>/dev/null || print_warning "Context may have already been removed"
    
    # Optional: Clean up Docker volumes (Kind creates volumes for persistence)
    read -p "Do you want to clean up related Docker volumes? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Cleaning up Docker volumes..."
        
        # List and remove Kind-related volumes
        VOLUMES=$(docker volume ls -q | grep -E "(${CLUSTER_NAME}|kind)" || true)
        if [ -n "$VOLUMES" ]; then
            echo "$VOLUMES" | xargs docker volume rm 2>/dev/null || print_warning "Some volumes may not have been removed"
            print_success "Docker volumes cleaned up"
        else
            print_status "No related Docker volumes found"
        fi
    fi
    
    # Final cleanup verification
    print_status "Verifying cleanup..."
    
    if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
        print_error "Cluster still exists after deletion attempt"
    else
        print_success "Cluster successfully removed"
    fi
    
    echo
    print_success "Cleanup completed!"
    echo
    print_status "To redeploy, run: ./scripts/deploy.sh"
    echo
}

# Help function
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "MongoDB on Kind Cleanup Script"
    echo
    echo "This script safely removes the Kind cluster and offers to:"
    echo "  - Create a final backup of MongoDB data"
    echo "  - Delete the Kind cluster"
    echo "  - Clean up kubectl contexts"
    echo "  - Remove related Docker volumes"
    echo
    echo "Usage:"
    echo "  $0              Run interactive cleanup"
    echo "  $0 --help       Show this help message"
    echo
    exit 0
fi

main
