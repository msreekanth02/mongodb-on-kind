#!/bin/bash

# MongoDB on Kind - Interactive Menu System
# User-friendly interface for Kubernetes learners

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Function to print styled headers
print_header() {
    echo
    echo -e "${CYAN}${BOLD}================================================================${NC}"
    echo -e "${CYAN}${BOLD}$1${NC}"
    echo -e "${CYAN}${BOLD}================================================================${NC}"
    echo
}

print_subheader() {
    echo -e "${BLUE}${BOLD}>>> $1${NC}"
    echo
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓ SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠ WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗ ERROR]${NC} $1"
}

print_step() {
    echo -e "${MAGENTA}[STEP]${NC} $1"
}

# Function to pause and wait for user input
pause() {
    echo
    echo -e "${YELLOW}Press [Enter] to continue...${NC}"
    read -r
}

# Function to ask yes/no questions
ask_yes_no() {
    local question="$1"
    local default="${2:-n}"
    
    while true; do
        if [ "$default" = "y" ]; then
            echo -e "${YELLOW}$question [Y/n]: ${NC}\c"
        else
            echo -e "${YELLOW}$question [y/N]: ${NC}\c"
        fi
        
        read -r answer
        answer=${answer:-$default}
        
        case $answer in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo -e "${RED}Please answer yes (y) or no (n).${NC}";;
        esac
    done
}

# Function to display main menu
show_main_menu() {
    clear
    print_header "MONGODB ON KIND - KUBERNETES LEARNING LAB"
    
    echo -e "${GREEN}Welcome to the MongoDB on Kind Interactive Learning Environment!${NC}"
    echo
    echo -e "${BLUE}This tool helps Kubernetes beginners learn by doing:${NC}"
    echo "• Deploy a real MongoDB cluster on Kubernetes"
    echo "• Learn about pods, services, secrets, and storage"
    echo "• Practice kubectl commands in a safe environment"
    echo "• Understand container orchestration concepts"
    echo
    echo -e "${CYAN}${BOLD}MAIN MENU:${NC}"
    echo
    echo -e "${BOLD} 1)${NC} Quick Start - Deploy Everything (Recommended for beginners)"
    echo -e "${BOLD} 2)${NC} Learning Mode - Step-by-step guided deployment"
    echo -e "${BOLD} 3)${NC} Management Tools - Manage existing deployment"
    echo -e "${BOLD} 4)${NC} Monitoring & Logs - View cluster status and logs"
    echo -e "${BOLD} 5)${NC} Security Lab - Learn credential management"
    echo -e "${BOLD} 6)${NC} Kubernetes Playground - Practice kubectl commands"
    echo -e "${BOLD} 7)${NC} Learning Resources - Tutorials and documentation"
    echo -e "${BOLD} 8)${NC} Cleanup - Remove deployment and cluster"
    echo -e "${BOLD} 9)${NC} Help & Troubleshooting"
    echo -e "${BOLD}10)${NC} Exit"
    echo
    echo -e "${YELLOW}Choose an option [1-10]: ${NC}\c"
}

# Function for Quick Start
quick_start() {
    print_header "QUICK START - AUTOMATED DEPLOYMENT"
    
    print_info "This will automatically deploy a complete MongoDB cluster for you!"
    echo
    echo "What you'll get:"
    echo "• Kind Kubernetes cluster (3 nodes)"
    echo "• MongoDB database with persistent storage"
    echo "• MongoDB Express web interface"
    echo "• Secure encrypted credentials"
    echo "• All services configured and ready to use"
    echo
    
    if ask_yes_no "Ready to deploy? This will take 2-3 minutes"; then
        print_step "Starting automated deployment..."
        
        # Check prerequisites
        print_step "Checking prerequisites..."
        if ! command -v kind &> /dev/null; then
            print_error "Kind not found! Please install it: brew install kind"
            pause
            return 1
        fi
        
        if ! command -v kubectl &> /dev/null; then
            print_error "kubectl not found! Please install it: brew install kubectl"
            pause
            return 1
        fi
        
        if ! docker info &> /dev/null; then
            print_error "Docker is not running! Please start Docker Desktop"
            pause
            return 1
        fi
        
        # Initialize credentials if not exists
        if [ ! -f "$PROJECT_DIR/.credentials/encrypted_creds.enc" ]; then
            print_step "Initializing secure credentials..."
            "$SCRIPT_DIR/manage-credentials.sh" --init
        fi
        
        # Deploy the cluster
        print_step "Deploying Kubernetes cluster..."
        if "$SCRIPT_DIR/deploy.sh"; then
            print_success "Deployment completed successfully!"
            echo
            show_access_info
        else
            print_error "Deployment failed! Check the logs above."
        fi
    fi
    
    pause
}

# Function for Learning Mode
learning_mode() {
    print_header "LEARNING MODE - STEP-BY-STEP DEPLOYMENT"
    
    echo -e "${GREEN}Welcome to Learning Mode!${NC}"
    echo
    echo "In this mode, you'll learn Kubernetes concepts step by step:"
    echo
    echo -e "${BOLD}Learning Path:${NC}"
    echo "1. Understanding Kubernetes Architecture"
    echo "2. Creating a Kind Cluster" 
    echo "3. Setting up Storage"
    echo "4. Managing Secrets and ConfigMaps"
    echo "5. Deploying Applications"
    echo "6. Exposing Services"
    echo "7. Monitoring and Troubleshooting"
    echo
    
    if ask_yes_no "Start the learning journey"; then
        learning_step_1_architecture
    fi
}

# Learning Steps
learning_step_1_architecture() {
    print_header "STEP 1: KUBERNETES ARCHITECTURE"
    
    echo -e "${GREEN}Let's understand what Kubernetes is and how it works:${NC}"
    echo
    echo -e "${BOLD}Kubernetes Components:${NC}"
    echo "• •  Control Plane: The brain that manages the cluster"
    echo "• • Worker Nodes: Machines that run your applications"
    echo "• • Pods: Smallest deployable units (containers)"
    echo "• • Services: Expose applications to network traffic"
    echo "• • Volumes: Persistent storage for data"
    echo "• • Secrets: Secure storage for sensitive information"
    echo
    echo -e "${BOLD}• What is Kind?${NC}"
    echo "Kind (Kubernetes in Docker) runs a Kubernetes cluster inside Docker containers."
    echo "Perfect for learning and testing without complex setup!"
    echo
    echo -e "${BOLD}• Our Architecture:${NC}"
    echo "┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐"
    echo "│  Control Plane  │  │   Worker Node   │  │   Worker Node   │"
    echo "│   (Manager)     │  │  (Database)     │  │   (Frontend)    │"
    echo "└─────────────────┘  └─────────────────┘  └─────────────────┘"
    echo
    
    pause
    
    if ask_yes_no "Ready to create your cluster"; then
        learning_step_2_cluster
    fi
}

learning_step_2_cluster() {
    print_header "STEP 2: CREATING A KIND CLUSTER"
    
    echo -e "${GREEN}Now let's create your Kubernetes cluster!${NC}"
    echo
    echo -e "${BOLD}Learning Objectives:${NC}"
    echo "• Understand cluster configuration"
    echo "• Learn about node roles and labels"
    echo "• See how port mapping works"
    echo
    echo -e "${BOLD}Cluster Configuration:${NC}"
    echo "We'll create:"
    echo "• 1 Control Plane node (manages the cluster)"
    echo "• 2 Worker nodes (run applications)"
    echo "• Port mappings (access services from your computer)"
    echo
    
    if ask_yes_no "View the cluster configuration file"; then
        print_step "Showing cluster configuration..."
        echo
        echo -e "${CYAN}File: kind/kind-config.yaml${NC}"
        echo "----------------------------------------"
        cat "$PROJECT_DIR/kind/kind-config.yaml"
        echo "----------------------------------------"
        echo
        pause
    fi
    
    print_step "Creating the Kubernetes cluster..."
    echo
    if kind create cluster --config "$PROJECT_DIR/kind/kind-config.yaml" --name mongodb-cluster; then
        print_success "Cluster created successfully!"
        echo
        print_step "Let's explore what was created..."
        echo
        echo -e "${BOLD}Try these commands:${NC}"
        echo "kubectl get nodes         # See all nodes in cluster"
        echo "kubectl cluster-info      # Get cluster information"
        echo
        kubectl get nodes
        echo
        pause
        
        if ask_yes_no "Continue to storage setup"; then
            learning_step_3_storage
        fi
    else
        print_error "Failed to create cluster!"
        pause
    fi
}

learning_step_3_storage() {
    print_header "STEP 3: SETTING UP PERSISTENT STORAGE"
    
    echo -e "${GREEN}Databases need persistent storage to keep data safe!${NC}"
    echo
    echo -e "${BOLD}Learning Objectives:${NC}"
    echo "• Understand persistent volumes"
    echo "• Learn about storage classes"
    echo "• See how claims work"
    echo
    echo -e "${BOLD}Storage Concepts:${NC}"
    echo "• • PersistentVolume (PV): Actual storage space"
    echo "• • PersistentVolumeClaim (PVC): Request for storage"
    echo "•   StorageClass: Type/quality of storage"
    echo
    
    if ask_yes_no "View the storage configuration"; then
        print_step "Showing storage configuration..."
        echo
        echo -e "${CYAN}File: resource/storage/mongodb-storage.yaml${NC}"
        echo "----------------------------------------"
        cat "$PROJECT_DIR/resource/storage/mongodb-storage.yaml"
        echo "----------------------------------------"
        echo
        pause
    fi
    
    print_step "Applying storage configuration..."
    if kubectl apply -f "$PROJECT_DIR/resource/storage/"; then
        print_success "Storage configured!"
        echo
        print_step "Let's see what was created..."
        echo
        kubectl get storageclass
        kubectl get pvc
        echo
        pause
        
        if ask_yes_no "Continue to secrets and configuration"; then
            learning_step_4_secrets
        fi
    fi
}

learning_step_4_secrets() {
    print_header "STEP 4: MANAGING SECRETS AND CONFIGURATION"
    
    echo -e "${GREEN}Applications need configuration and secure credentials!${NC}"
    echo
    echo -e "${BOLD}Learning Objectives:${NC}"
    echo "• Understand Kubernetes secrets"
    echo "• Learn about ConfigMaps"
    echo "• See base64 encoding"
    echo
    echo -e "${BOLD}Security Concepts:${NC}"
    echo "• • Secrets: Store sensitive data (passwords, tokens)"
    echo "• • ConfigMaps: Store configuration data"
    echo "• Base64: Encoding (not encryption!) for secrets"
    echo
    
    if ask_yes_no "Initialize encrypted credentials"; then
        print_step "Setting up encrypted credentials..."
        if [ ! -f "$PROJECT_DIR/.credentials/encrypted_creds.enc" ]; then
            "$SCRIPT_DIR/manage-credentials.sh" --init
            print_success "Secure credentials initialized!"
        else
            print_info "Credentials already exist"
        fi
        
        echo
        print_step "Creating Kubernetes secrets..."
        kubectl apply -f "$PROJECT_DIR/resource/secrets/"
        kubectl apply -f "$PROJECT_DIR/resource/configmaps/"
        
        print_success "Secrets and ConfigMaps created!"
        echo
        print_step "Let's explore what was created..."
        echo
        echo -e "${BOLD}Secrets:${NC}"
        kubectl get secrets
        echo
        echo -e "${BOLD}ConfigMaps:${NC}"
        kubectl get configmaps
        echo
        
        if ask_yes_no "View a secret (base64 encoded)"; then
            echo
            kubectl get secret mongodb-secret -o yaml
        fi
        
        pause
        
        if ask_yes_no "Continue to application deployment"; then
            learning_step_5_deployment
        fi
    fi
}

learning_step_5_deployment() {
    print_header "STEP 5: DEPLOYING APPLICATIONS"
    
    echo -e "${GREEN}Now let's deploy MongoDB and MongoDB Express!${NC}"
    echo
    echo -e "${BOLD}Learning Objectives:${NC}"
    echo "• Understand Deployments"
    echo "• Learn about pods and containers"
    echo "• See health checks and init containers"
    echo
    echo -e "${BOLD}Deployment Concepts:${NC}"
    echo "• Deployment: Manages application replicas"
    echo "• • Pod: Runs one or more containers"
    echo "•   Health Checks: Monitor application health"
    echo "• Init Containers: Setup before main container"
    echo
    
    print_step "Deploying MongoDB..."
    kubectl apply -f "$PROJECT_DIR/resource/deployments/mongodb-deployment.yaml"
    
    print_step "Waiting for MongoDB to be ready..."
    kubectl wait --for=condition=available --timeout=120s deployment/mongodb-deployment
    
    print_success "MongoDB deployed successfully!"
    echo
    print_step "Now deploying MongoDB Express..."
    kubectl apply -f "$PROJECT_DIR/resource/deployments/mongodb-express-deployment.yaml"
    
    print_step "Waiting for MongoDB Express to be ready..."
    kubectl wait --for=condition=available --timeout=120s deployment/mongodb-express-deployment
    
    print_success "MongoDB Express deployed successfully!"
    echo
    print_step "Let's see your running applications..."
    echo
    kubectl get deployments
    echo
    kubectl get pods -o wide
    echo
    
    pause
    
    if ask_yes_no "Continue to service setup"; then
        learning_step_6_services
    fi
}

learning_step_6_services() {
    print_header "STEP 6: EXPOSING SERVICES"
    
    echo -e "${GREEN}Applications need to be accessible over the network!${NC}"
    echo
    echo -e "${BOLD}Learning Objectives:${NC}"
    echo "• Understand Kubernetes services"
    echo "• Learn about service types"
    echo "• See load balancing in action"
    echo
    echo -e "${BOLD}Service Concepts:${NC}"
    echo "•  ClusterIP: Internal cluster communication"
    echo "• • NodePort: External access via node ports"
    echo "•   LoadBalancer: Cloud load balancer"
    echo "•  Ingress: HTTP/HTTPS routing"
    echo
    
    print_step "Creating services..."
    kubectl apply -f "$PROJECT_DIR/resource/services/"
    
    print_success "Services created!"
    echo
    print_step "Let's see your services..."
    echo
    kubectl get services -o wide
    echo
    
    print_step "Getting access information..."
    MONGODB_PORT=$(kubectl get service mongodb-nodeport -o jsonpath='{.spec.ports[0].nodePort}')
    MONGOEXPRESS_PORT=$(kubectl get service mongodb-express-nodeport -o jsonpath='{.spec.ports[0].nodePort}')
    
    echo
    print_success " Deployment Complete! Your services are ready:"
    echo
    echo -e "${BOLD} MongoDB Express Web UI:${NC}"
    echo "   URL: http://localhost:8081"
    echo "   Username: admin"
    echo "   Password: Run './scripts/manage-credentials.sh --get webui_password'"
    echo
    echo -e "${BOLD} MongoDB Database:${NC}"
    echo "   Host: localhost:27017"
    echo "   Username: admin"
    echo "   Password: Run './scripts/manage-credentials.sh --get mongodb_root_password'"
    echo
    
    pause
    
    if ask_yes_no "Continue to monitoring"; then
        learning_step_7_monitoring
    fi
}

learning_step_7_monitoring() {
    print_header "STEP 7: MONITORING AND TROUBLESHOOTING"
    
    echo -e "${GREEN}Let's learn how to monitor and debug Kubernetes applications!${NC}"
    echo
    echo -e "${BOLD}Learning Objectives:${NC}"
    echo "• Monitor pod and service status"
    echo "• View application logs"
    echo "• Debug common issues"
    echo
    echo -e "${BOLD}Monitoring Commands:${NC}"
    echo "• kubectl get pods      # See pod status"
    echo "• kubectl describe pod  # Detailed pod info"
    echo "• kubectl logs         # View container logs"
    echo "• kubectl exec         # Run commands in containers"
    echo
    
    print_step "Current cluster status:"
    echo
    kubectl get all
    echo
    
    if ask_yes_no "View MongoDB logs"; then
        echo
        print_step "MongoDB logs (last 20 lines):"
        echo "----------------------------------------"
        kubectl logs -l app=mongodb --tail=20
        echo "----------------------------------------"
        echo
    fi
    
    if ask_yes_no "View MongoDB Express logs"; then
        echo
        print_step "MongoDB Express logs (last 20 lines):"
        echo "----------------------------------------"
        kubectl logs -l app=mongodb-express --tail=20
        echo "----------------------------------------"
        echo
    fi
    
    if ask_yes_no "Try connecting to MongoDB shell"; then
        echo
        print_step "Connecting to MongoDB..."
        MONGO_POD=$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}')
        echo "Pod name: $MONGO_POD"
        echo
        print_info "Running: kubectl exec -it $MONGO_POD -- mongosh --eval \"db.runCommand({ping: 1})\""
        kubectl exec -it $MONGO_POD -- mongosh --eval "db.runCommand({ping: 1})"
    fi
    
    print_success "Congratulations! You've completed the Kubernetes learning journey!"
    echo
    echo -e "${BOLD}What you've learned:${NC}"
    echo "Kubernetes architecture and components"
    echo "Creating and managing clusters with Kind"
    echo "Persistent storage with PVs and PVCs"
    echo "Secrets and configuration management"
    echo "Application deployment with pods and services"
    echo "Network exposure and service types"
    echo "Monitoring and troubleshooting techniques"
    echo
    pause
}

# Management Tools Menu
management_menu() {
    while true; do
        print_header "MANAGEMENT TOOLS"
        
        echo -e "${BOLD}Management Options:${NC}"
        echo
        echo -e "${BOLD}1)${NC} View Cluster Status"
        echo -e "${BOLD}2)${NC} Scale Applications"
        echo -e "${BOLD}3)${NC} Restart Services"
        echo -e "${BOLD}4)${NC} • Backup Data"
        echo -e "${BOLD}5)${NC} Update Configuration"
        echo -e "${BOLD}6)${NC} Back to Main Menu"
        echo
        echo -e "${YELLOW}Choose an option [1-6]: ${NC}\c"
        
        read -r choice
        case $choice in
            1) view_status ;;
            2) scale_applications ;;
            3) restart_services ;;
            4) backup_data ;;
            5) update_configuration ;;
            6) break ;;
            *) print_error "Invalid option. Please choose 1-6." ;;
        esac
    done
}

# Monitoring Menu
monitoring_menu() {
    while true; do
        print_header "MONITORING & LOGS"
        
        echo -e "${BOLD}Monitoring Options:${NC}"
        echo
        echo -e "${BOLD}1)${NC} Cluster Overview"
        echo -e "${BOLD}2)${NC} • Pod Status & Details"
        echo -e "${BOLD}3)${NC} View Application Logs"
        echo -e "${BOLD}4)${NC} • Service Status"
        echo -e "${BOLD}5)${NC} • Storage Information"
        echo -e "${BOLD}6)${NC} Real-time Monitoring"
        echo -e "${BOLD}7)${NC} Back to Main Menu"
        echo
        echo -e "${YELLOW}Choose an option [1-7]: ${NC}\c"
        
        read -r choice
        case $choice in
            1) cluster_overview ;;
            2) pod_details ;;
            3) view_logs ;;
            4) service_status ;;
            5) storage_info ;;
            6) realtime_monitoring ;;
            7) break ;;
            *) print_error "Invalid option. Please choose 1-7." ;;
        esac
    done
}

# Security Lab Menu  
security_menu() {
    while true; do
        print_header "• SECURITY LAB"
        
        echo -e "${BOLD}Security Learning Options:${NC}"
        echo
        echo -e "${BOLD}1)${NC} View Encrypted Credentials"
        echo -e "${BOLD}2)${NC} Rotate Passwords"
        echo -e "${BOLD}3)${NC} • Backup Credentials"
        echo -e "${BOLD}4)${NC} Security Best Practices"
        echo -e "${BOLD}5)${NC} Test Authentication"
        echo -e "${BOLD}6)${NC} Learn About Kubernetes Security"
        echo -e "${BOLD}7)${NC} Back to Main Menu"
        echo
        echo -e "${YELLOW}Choose an option [1-7]: ${NC}\c"
        
        read -r choice
        case $choice in
            1) view_credentials ;;
            2) rotate_passwords ;;
            3) backup_credentials ;;
            4) security_best_practices ;;
            5) test_authentication ;;
            6) security_education ;;
            7) break ;;
            *) print_error "Invalid option. Please choose 1-7." ;;
        esac
    done
}

# Playground Menu
playground_menu() {
    while true; do
        print_header "KUBERNETES PLAYGROUND"
        
        echo -e "${BOLD}Practice kubectl Commands:${NC}"
        echo
        echo -e "${BOLD}1)${NC} • Basic kubectl Commands"
        echo -e "${BOLD}2)${NC} Exploring Resources"
        echo -e "${BOLD}3)${NC} Deployment Operations"
        echo -e "${BOLD}4)${NC} • Service Management"
        echo -e "${BOLD}5)${NC}  Debugging Techniques"
        echo -e "${BOLD}6)${NC} Advanced Operations"
        echo -e "${BOLD}7)${NC} Practice Scenarios"
        echo -e "${BOLD}8)${NC} Back to Main Menu"
        echo
        echo -e "${YELLOW}Choose an option [1-8]: ${NC}\c"
        
        read -r choice
        case $choice in
            1) basic_kubectl ;;
            2) explore_resources ;;
            3) deployment_operations ;;
            4) service_management ;;
            5) debugging_techniques ;;
            6) advanced_operations ;;
            7) practice_scenarios ;;
            8) break ;;
            *) print_error "Invalid option. Please choose 1-8." ;;
        esac
    done
}

# Show access information
show_access_info() {
    echo -e "${BOLD}• Access Your Applications:${NC}"
    echo
    echo -e "${GREEN}MongoDB Express Web UI:${NC}"
    echo "  URL: http://localhost:8081"
    echo "  Username: admin"
    echo "  Password: (Run: ./scripts/manage-credentials.sh --get webui_password)"
    echo
    echo -e "${GREEN}MongoDB Database:${NC}"
    echo "  Host: localhost:27017"  
    echo "  Username: admin"
    echo "  Password: (Run: ./scripts/manage-credentials.sh --get mongodb_root_password)"
    echo
}

# Implementation stubs for menu functions (to be expanded)
view_status() {
    print_subheader "CLUSTER STATUS"
    "$SCRIPT_DIR/status.sh"
    pause
}

scale_applications() {
    print_subheader "SCALE APPLICATIONS"
    echo "Current deployments:"
    kubectl get deployments
    echo
    echo "Available scaling options:"
    echo "1) Scale MongoDB Express replicas"
    echo "2) View current resource usage"
    echo
    echo -e "${YELLOW}Enter number of replicas for MongoDB Express [1-5]: ${NC}\c"
    read -r replicas
    if [[ "$replicas" =~ ^[1-5]$ ]]; then
        print_step "Scaling MongoDB Express to $replicas replicas..."
        kubectl scale deployment mongodb-express-deployment --replicas=$replicas
        print_success "Scaled successfully!"
        kubectl get pods -l app=mongodb-express
    else
        print_error "Invalid number. Please enter 1-5."
    fi
    pause
}

restart_services() {
    print_subheader "RESTART SERVICES"
    echo "Available restart options:"
    echo "1) Restart MongoDB Express"
    echo "2) Restart MongoDB (careful - may cause downtime)"
    echo
    echo -e "${YELLOW}Choose service to restart [1-2]: ${NC}\c"
    read -r choice
    
    case $choice in
        1)
            print_step "Restarting MongoDB Express..."
            kubectl rollout restart deployment/mongodb-express-deployment
            kubectl rollout status deployment/mongodb-express-deployment
            print_success "MongoDB Express restarted!"
            ;;
        2)
            if ask_yes_no "Are you sure? This will cause temporary downtime"; then
                print_step "Restarting MongoDB..."
                kubectl rollout restart deployment/mongodb-deployment
                kubectl rollout status deployment/mongodb-deployment
                print_success "MongoDB restarted!"
            fi
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
    pause
}

backup_data() {
    print_subheader "• BACKUP DATA"
    if ask_yes_no "Create MongoDB backup"; then
        print_step "Creating MongoDB backup..."
        MONGO_POD=$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}')
        BACKUP_DIR="/tmp/mongodb-backup-$(date +%Y%m%d-%H%M%S)"
        
        print_info "Creating backup in pod..."
        kubectl exec $MONGO_POD -- mongodump --out /tmp/backup
        
        print_info "Copying backup to local machine..."
        kubectl cp $MONGO_POD:/tmp/backup "$BACKUP_DIR"
        
        if [ -d "$BACKUP_DIR" ]; then
            print_success "Backup created: $BACKUP_DIR"
        else
            print_error "Backup may have failed"
        fi
    fi
    pause
}

update_configuration() {
    print_subheader "UPDATE CONFIGURATION"
    echo "Configuration update options:"
    echo "1) Update MongoDB ConfigMap"
    echo "2) Regenerate credentials" 
    echo "3) Update resource limits"
    echo
    echo -e "${YELLOW}Choose option [1-3]: ${NC}\c"
    read -r choice
    
    case $choice in
        1)
            print_info "Current ConfigMap:"
            kubectl get configmap mongodb-configmap -o yaml
            ;;
        2)
            if ask_yes_no "Regenerate all credentials? This will require pod restarts"; then
                "$SCRIPT_DIR/manage-credentials.sh" --init
                print_success "Credentials regenerated!"
            fi
            ;;
        3)
            print_info "Current resource limits:"
            kubectl describe deployment mongodb-deployment | grep -A 10 "Limits:"
            ;;
    esac
    pause
}

cluster_overview() {
    print_subheader "CLUSTER OVERVIEW"
    echo "Nodes:"
    kubectl get nodes -o wide
    echo
    echo "All resources:"
    kubectl get all
    echo
    echo "Storage:"
    kubectl get pv,pvc
    pause
}

pod_details() {
    print_subheader "• POD DETAILS"
    kubectl get pods -o wide
    echo
    echo -e "${YELLOW}Enter pod name to describe (or press Enter for all): ${NC}\c"
    read -r pod_name
    
    if [ -n "$pod_name" ]; then
        kubectl describe pod "$pod_name"
    else
        print_info "Describing all MongoDB-related pods:"
        kubectl describe pods -l 'app in (mongodb,mongodb-express)'
    fi
    pause
}

view_logs() {
    print_subheader "APPLICATION LOGS"
    echo "Available log options:"
    echo "1) MongoDB logs"
    echo "2) MongoDB Express logs" 
    echo "3) All application logs"
    echo "4) Follow logs in real-time"
    echo
    echo -e "${YELLOW}Choose option [1-4]: ${NC}\c"
    read -r choice
    
    case $choice in
        1)
            print_info "MongoDB logs (last 50 lines):"
            kubectl logs -l app=mongodb --tail=50
            ;;
        2)
            print_info "MongoDB Express logs (last 50 lines):"
            kubectl logs -l app=mongodb-express --tail=50
            ;;
        3)
            print_info "All application logs:"
            kubectl logs -l 'app in (mongodb,mongodb-express)' --tail=30
            ;;
        4)
            print_info "Following logs in real-time (Ctrl+C to stop):"
            kubectl logs -l 'app in (mongodb,mongodb-express)' -f
            ;;
    esac
    pause
}

service_status() {
    print_subheader "• SERVICE STATUS"
    echo "Services:"
    kubectl get services -o wide
    echo
    echo "Endpoints:"
    kubectl get endpoints
    echo
    echo "Service connectivity test:"
    if nc -z localhost 8081 2>/dev/null; then
        print_success "MongoDB Express accessible on localhost:8081"
    else
        print_warning "MongoDB Express not accessible"
    fi
    
    if nc -z localhost 27017 2>/dev/null; then
        print_success "MongoDB accessible on localhost:27017"
    else
        print_warning "MongoDB not accessible"
    fi
    pause
}

storage_info() {
    print_subheader "• STORAGE INFORMATION"
    echo "Persistent Volumes:"
    kubectl get pv
    echo
    echo "Persistent Volume Claims:"
    kubectl get pvc
    echo
    echo "Storage Classes:"
    kubectl get storageclass
    echo
    if kubectl get pvc | grep -q mongodb-pvc; then
        print_info "MongoDB PVC details:"
        kubectl describe pvc mongodb-pvc
    fi
    pause
}

realtime_monitoring() {
    print_subheader "REAL-TIME MONITORING"
    echo "Real-time monitoring options:"
    echo "1) Watch pod status"
    echo "2) Watch service status"
    echo "3) Watch all resources"
    echo "4) Monitor events"
    echo
    echo -e "${YELLOW}Choose option [1-4]: ${NC}\c"
    read -r choice
    
    print_info "Press Ctrl+C to stop monitoring"
    echo
    
    case $choice in
        1) kubectl get pods -w ;;
        2) kubectl get services -w ;;
        3) kubectl get all -w ;;
        4) kubectl get events -w ;;
    esac
    pause
}

view_credentials() {
    print_subheader "ENCRYPTED CREDENTIALS"
    if ask_yes_no "Show decrypted credentials? (Use carefully!)"; then
        "$SCRIPT_DIR/manage-credentials.sh" --show
    fi
    
    echo
    print_info "Credential commands:"
    echo "Get WebUI password:    ./scripts/manage-credentials.sh --get webui_password"
    echo "Get MongoDB password:  ./scripts/manage-credentials.sh --get mongodb_root_password"
    echo "Backup credentials:    ./scripts/manage-credentials.sh --backup"
    pause
}

rotate_passwords() {
    print_subheader "ROTATE PASSWORDS"
    if ask_yes_no "This will generate new passwords and restart services. Continue"; then
        print_step "Generating new credentials..."
        "$SCRIPT_DIR/manage-credentials.sh" --init
        
        print_step "Updating Kubernetes resources..."
        "$SCRIPT_DIR/manage-credentials.sh" --update-k8s
        "$SCRIPT_DIR/manage-credentials.sh" --update-deployments
        
        print_step "Restarting services..."
        kubectl rollout restart deployment/mongodb-deployment
        kubectl rollout restart deployment/mongodb-express-deployment
        
        print_success "Password rotation completed!"
    fi
    pause
}

backup_credentials() {
    print_subheader "• BACKUP CREDENTIALS"
    echo -e "${YELLOW}Enter backup directory (or press Enter for default): ${NC}\c"
    read -r backup_dir
    
    if [ -n "$backup_dir" ]; then
        "$SCRIPT_DIR/manage-credentials.sh" --backup "$backup_dir"
    else
        "$SCRIPT_DIR/manage-credentials.sh" --backup
    fi
    pause
}

security_best_practices() {
    print_subheader "SECURITY BEST PRACTICES"
    echo -e "${BOLD}Kubernetes Security Best Practices:${NC}"
    echo
    echo "1. • Use secrets for sensitive data (passwords, tokens)"
    echo "2. Never hardcode credentials in images or configs"
    echo "3. Enable RBAC (Role-Based Access Control)"
    echo "4. • Use network policies to restrict traffic"
    echo "5. Regularly rotate credentials"
    echo "6. Monitor and audit cluster activities"
    echo "7.  Keep Kubernetes and containers updated"
    echo "8. Use admission controllers for policy enforcement"
    echo
    echo -e "${BOLD}This Project's Security Features:${NC}"
    echo "Encrypted credential storage"
    echo "No hardcoded passwords"
    echo "Kubernetes secrets for runtime credentials"
    echo "Base64 encoding for Kubernetes secrets"
    echo "Separate encryption keys"
    echo ".gitignore protection"
    pause
}

test_authentication() {
    print_subheader "TEST AUTHENTICATION"
    print_step "Testing MongoDB authentication..."
    
    ROOT_PASSWORD=$("$SCRIPT_DIR/manage-credentials.sh" --get mongodb_root_password)
    MONGO_POD=$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}')
    
    echo "Testing MongoDB connection..."
    if kubectl exec $MONGO_POD -- mongosh -u admin -p "$ROOT_PASSWORD" --authenticationDatabase admin --eval "db.runCommand({ping: 1})" > /dev/null 2>&1; then
        print_success "MongoDB authentication successful!"
    else
        print_error "MongoDB authentication failed!"
    fi
    
    print_step "Testing MongoDB Express web interface..."
    WEBUI_PASSWORD=$("$SCRIPT_DIR/manage-credentials.sh" --get webui_password)
    
    if curl -u admin:"$WEBUI_PASSWORD" http://localhost:8081 --connect-timeout 5 -s > /dev/null 2>&1; then
        print_success "MongoDB Express authentication successful!"
    else
        print_error "MongoDB Express authentication failed!"
    fi
    pause
}

security_education() {
    print_subheader "KUBERNETES SECURITY EDUCATION"
    echo -e "${BOLD}Understanding Kubernetes Security:${NC}"
    echo
    echo -e "${BOLD}1. Secrets vs ConfigMaps:${NC}"
    echo "   • Secrets: Base64 encoded (not encrypted!), for sensitive data"
    echo "   • ConfigMaps: Plain text, for non-sensitive configuration"
    echo
    echo -e "${BOLD}2. Service Accounts:${NC}"
    echo "   • Identity for pods to interact with Kubernetes API"
    echo "   • Can be restricted with RBAC"
    echo
    echo -e "${BOLD}3. Network Policies:${NC}"
    echo "   • Control traffic flow between pods"
    echo "   • Default: all traffic allowed"
    echo
    echo -e "${BOLD}4. Pod Security:${NC}"
    echo "   • Run as non-root user when possible"
    echo "   • Use read-only root filesystem"
    echo "   • Drop unnecessary capabilities"
    echo
    echo -e "${BOLD}5. Image Security:${NC}"
    echo "   • Use official images when possible"
    echo "   • Scan images for vulnerabilities"
    echo "   • Keep images updated"
    pause
}

# Playground functions
basic_kubectl() {
    print_subheader "• BASIC KUBECTL COMMANDS"
    "$SCRIPT_DIR/playground-helpers.sh" basic_kubectl
    pause
}

explore_resources() {
    print_subheader "EXPLORING RESOURCES"
    "$SCRIPT_DIR/playground-helpers.sh" explore
    pause
}

deployment_operations() {
    print_subheader "DEPLOYMENT OPERATIONS"
    "$SCRIPT_DIR/playground-helpers.sh" deployments
    pause
}

service_management() {
    print_subheader "• SERVICE MANAGEMENT"
    "$SCRIPT_DIR/playground-helpers.sh" services
    pause
}

debugging_techniques() {
    print_subheader " DEBUGGING TECHNIQUES"
    "$SCRIPT_DIR/playground-helpers.sh" debugging
    pause
}

advanced_operations() {
    print_subheader "ADVANCED OPERATIONS"
    echo -e "${BOLD}Advanced Kubernetes Operations:${NC}"
    echo
    echo "1. Rolling Updates and Rollbacks"
    echo "2. Resource Limits and Requests"
    echo "3. Health Checks and Probes"
    echo "4. Init Containers"
    echo "5. Jobs and CronJobs"
    echo "6. StatefulSets vs Deployments"
    echo
    echo "Let's explore some of these with your current deployment..."
    echo
    
    if ask_yes_no "Explore rolling updates"; then
        print_info "Current deployment status:"
        kubectl rollout status deployment/mongodb-express-deployment
        echo
        print_info "Deployment history:"
        kubectl rollout history deployment/mongodb-express-deployment
    fi
    pause
}

practice_scenarios() {
    print_subheader "PRACTICE SCENARIOS"
    "$SCRIPT_DIR/playground-helpers.sh" scenarios
    pause
}

# Help and documentation
show_help() {
    print_header "HELP & TROUBLESHOOTING"
    
    echo -e "${BOLD}Common Issues:${NC}"
    echo
    echo -e "${BOLD}1. Docker not running:${NC}"
    echo "   Solution: Start Docker Desktop"
    echo
    echo -e "${BOLD}2. Kind cluster creation fails:${NC}"
    echo "   Solution: Check port conflicts (8081, 27017)"
    echo "   Command: lsof -i :8081"
    echo
    echo -e "${BOLD}3. Pods stuck in Pending:${NC}"
    echo "   Solution: Check resources and storage"
    echo "   Command: kubectl describe pod <pod-name>"
    echo
    echo -e "${BOLD}4. Cannot access web interface:${NC}"
    echo "   Solution: Verify port forwarding and credentials"
    echo "   Command: curl -u admin:\$(./scripts/manage-credentials.sh --get webui_password) http://localhost:8081"
    echo
    echo -e "${BOLD}Useful Commands:${NC}"
    echo "kubectl get all                    # See all resources"
    echo "kubectl describe <resource>       # Detailed information"
    echo "kubectl logs <pod-name>          # View logs"
    echo "kubectl exec -it <pod> -- sh     # Connect to container"
    echo
    pause
}

# Learning resources
learning_resources() {
    print_header "LEARNING RESOURCES"
    
    echo -e "${BOLD}Kubernetes Learning Path:${NC}"
    echo
    echo -e "${BOLD}Beginner:${NC}"
    echo "• Official Kubernetes Tutorial: https://kubernetes.io/docs/tutorials/"
    echo "• Kubernetes Basics: https://kubernetes.io/docs/concepts/"
    echo "• Kind Documentation: https://kind.sigs.k8s.io/"
    echo
    echo -e "${BOLD}Intermediate:${NC}"
    echo "• kubectl Cheat Sheet: https://kubernetes.io/docs/reference/kubectl/cheatsheet/"
    echo "• Kubernetes Patterns: https://kubernetes.io/docs/concepts/cluster-administration/"
    echo "• Security Best Practices: https://kubernetes.io/docs/concepts/security/"
    echo
    echo -e "${BOLD}Advanced:${NC}"
    echo "• Operators and CRDs"
    echo "• Service Mesh (Istio)"
    echo "• GitOps with ArgoCD"
    echo
    echo -e "${BOLD}This Project's Documentation:${NC}"
    echo "• README.md - Complete setup guide"
    echo "• SECURITY.md - Security implementation details"
    echo "• scripts/ - All automation tools"
    echo
    pause
}

# Main execution function
main() {
    # Check if we're in the right directory
    if [ ! -f "$PROJECT_DIR/README.md" ]; then
        print_error "Please run this script from the MongoDB on Kind project directory"
        exit 1
    fi
    
    while true; do
        show_main_menu
        read -r choice
        
        case $choice in
            1) quick_start ;;
            2) learning_mode ;;
            3) management_menu ;;
            4) monitoring_menu ;;
            5) security_menu ;;
            6) playground_menu ;;
            7) learning_resources ;;
            8) 
                if ask_yes_no "Are you sure you want to cleanup everything"; then
                    "$SCRIPT_DIR/cleanup.sh"
                fi
                ;;
            9) show_help ;;
            10) 
                print_header "GOODBYE!"
                echo -e "${GREEN}Thank you for using the MongoDB on Kind Learning Lab!${NC}"
                echo "Keep exploring Kubernetes - you're doing great! "
                echo
                exit 0
                ;;
            *)
                print_error "Invalid option. Please choose 1-10."
                sleep 2
                ;;
        esac
    done
}

# Run the main function
main "$@"
