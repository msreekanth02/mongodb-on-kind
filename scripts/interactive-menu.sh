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
    echo -e "${BOLD} 3)${NC} Cluster Management - Start, stop, status, destroy cluster"
    echo -e "${BOLD} 4)${NC} Management Tools - Manage existing deployment"
    echo -e "${BOLD} 5)${NC} Monitoring & Logs - View cluster status and logs"
    echo -e "${BOLD} 6)${NC} Security Lab - Learn credential management"
    echo -e "${BOLD} 7)${NC} Kubernetes Playground - Practice kubectl commands"
    echo -e "${BOLD} 8)${NC} Learning Resources - Tutorials and documentation"
    echo -e "${BOLD} 9)${NC} Cleanup - Remove deployment and cluster"
    echo -e "${BOLD}10)${NC} Help & Troubleshooting"
    echo -e "${BOLD}11)${NC} Exit"
    echo
    echo -e "${YELLOW}Choose an option [1-11]: ${NC}\c"
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

# Cluster Management Menu
cluster_management_menu() {
    while true; do
        print_header "CLUSTER MANAGEMENT"
        
        echo -e "${GREEN}Comprehensive Kind cluster management and control${NC}"
        echo
        
        # Show current cluster status
        local cluster_status=$(get_cluster_status)
        echo -e "${BOLD}Current Status:${NC} $cluster_status"
        echo
        
        echo -e "${BOLD}Cluster Management Options:${NC}"
        echo
        echo -e "${BOLD}1)${NC} Start Cluster - Create and start the MongoDB cluster"
        echo -e "${BOLD}2)${NC} Stop Cluster - Stop cluster containers (preserves data)"
        echo -e "${BOLD}3)${NC} Status Check - Detailed cluster and application status"
        echo -e "${BOLD}4)${NC} Restart Cluster - Stop and start cluster cleanly"
        echo -e "${BOLD}5)${NC} Destroy Cluster - Completely remove cluster and data"
        echo -e "${BOLD}6)${NC} Quick Deploy - Start cluster and deploy applications"
        echo -e "${BOLD}7)${NC} Cluster Info - Show detailed cluster information"
        echo -e "${BOLD}8)${NC} Back to Main Menu"
        echo
        echo -e "${YELLOW}Choose an option [1-8]: ${NC}\c"
        
        read -r choice
        case $choice in
            1) start_cluster ;;
            2) stop_cluster ;;
            3) cluster_status_check ;;
            4) restart_cluster ;;
            5) destroy_cluster ;;
            6) quick_deploy_cluster ;;
            7) cluster_info ;;
            8) break ;;
            *) print_error "Invalid option. Please choose 1-8." ;;
        esac
    done
}

# Helper function to get cluster status
get_cluster_status() {
    if ! command -v kind &> /dev/null; then
        echo -e "${RED}Kind not installed${NC}"
        return
    fi
    
    if ! docker info &> /dev/null 2>&1; then
        echo -e "${RED}Docker not running${NC}"
        return
    fi
    
    local clusters=$(kind get clusters 2>/dev/null)
    if echo "$clusters" | grep -q "mongodb-cluster"; then
        # Check if cluster is actually running
        if docker ps --format "table {{.Names}}" 2>/dev/null | grep -q "mongodb-cluster"; then
            # Check if applications are deployed
            if kubectl get pods -l app=mongodb &>/dev/null 2>&1; then
                echo -e "${GREEN}Running with applications${NC}"
            else
                echo -e "${YELLOW}Running (no applications)${NC}"
            fi
        else
            echo -e "${YELLOW}Created but stopped${NC}"
        fi
    else
        echo -e "${RED}Not created${NC}"
    fi
}

# Function to start cluster
start_cluster() {
    print_header "START CLUSTER"
    
    print_info "Starting Kind cluster for MongoDB deployment..."
    echo
    
    # Check prerequisites
    if ! check_prerequisites; then
        pause
        return 1
    fi
    
    # Check if cluster already exists
    local clusters=$(kind get clusters 2>/dev/null)
    if echo "$clusters" | grep -q "mongodb-cluster"; then
        # Check if it's running
        if docker ps --format "table {{.Names}}" 2>/dev/null | grep -q "mongodb-cluster"; then
            print_success "Cluster 'mongodb-cluster' is already running!"
            show_cluster_summary
            pause
            return 0
        else
            print_info "Cluster exists but is stopped. Starting containers..."
            if start_existing_cluster; then
                print_success "Cluster started successfully!"
                show_cluster_summary
            else
                print_error "Failed to start existing cluster"
            fi
            pause
            return
        fi
    fi
    
    print_step "Creating new Kind cluster..."
    echo
    echo -e "${BOLD}Cluster Configuration:${NC}"
    echo "• Name: mongodb-cluster"
    echo "• Nodes: 1 control-plane + 2 workers"
    echo "• Port mappings: 8081 (MongoDB Express), 27017 (MongoDB)"
    echo
    
    if ask_yes_no "Create cluster with this configuration"; then
        if kind create cluster --config "$PROJECT_DIR/kind/kind-config.yaml" --name mongodb-cluster; then
            print_success "Cluster created successfully!"
            echo
            print_step "Verifying cluster..."
            kubectl cluster-info --context kind-mongodb-cluster
            echo
            show_cluster_summary
            
            if ask_yes_no "Deploy MongoDB applications now"; then
                deploy_applications
            fi
        else
            print_error "Failed to create cluster"
        fi
    fi
    
    pause
}

# Function to stop cluster
stop_cluster() {
    print_header "STOP CLUSTER"
    
    print_info "This will stop the cluster containers but preserve all data and configuration"
    echo
    
    # Check if cluster exists
    local clusters=$(kind get clusters 2>/dev/null)
    if ! echo "$clusters" | grep -q "mongodb-cluster"; then
        print_warning "No cluster named 'mongodb-cluster' found"
        pause
        return 0
    fi
    
    # Check if cluster is running
    if ! docker ps --format "table {{.Names}}" 2>/dev/null | grep -q "mongodb-cluster"; then
        print_info "Cluster 'mongodb-cluster' is already stopped"
        pause
        return 0
    fi
    
    echo -e "${BOLD}Current cluster status:${NC}"
    kubectl get nodes --context kind-mongodb-cluster 2>/dev/null || echo "Unable to connect to cluster"
    echo
    
    print_warning "Stopping cluster will:"
    echo "• Stop all cluster containers"
    echo "• Preserve all data and configurations"
    echo "• Allow restart without data loss"
    echo "• Stop all running applications"
    echo
    
    if ask_yes_no "Stop the cluster"; then
        print_step "Stopping cluster containers..."
        
        # Get all cluster containers
        local containers=$(docker ps -q --filter "name=mongodb-cluster")
        if [ -n "$containers" ]; then
            if docker stop $containers; then
                print_success "Cluster stopped successfully!"
                echo
                print_info "Cluster can be restarted later with 'Start Cluster' option"
                print_info "All data and configurations are preserved"
            else
                print_error "Failed to stop some containers"
            fi
        else
            print_info "No running containers found for mongodb-cluster"
        fi
    fi
    
    pause
}

# Function for detailed cluster status check
cluster_status_check() {
    print_header "CLUSTER STATUS CHECK"
    
    print_step "Performing comprehensive status check..."
    echo
    
    # Check Docker
    echo -e "${BOLD}1. Docker Status:${NC}"
    if docker info &> /dev/null; then
        print_success "Docker is running"
        echo "   Version: $(docker --version | cut -d' ' -f3 | cut -d',' -f1)"
    else
        print_error "Docker is not running"
        echo
        pause
        return 1
    fi
    
    echo
    
    # Check Kind
    echo -e "${BOLD}2. Kind Status:${NC}"
    if command -v kind &> /dev/null; then
        print_success "Kind is installed"
        echo "   Version: $(kind version | grep kind | cut -d' ' -f2)"
        
        local clusters=$(kind get clusters 2>/dev/null)
        echo "   Available clusters: ${clusters:-"None"}"
    else
        print_error "Kind is not installed"
    fi
    
    echo
    
    # Check specific cluster
    echo -e "${BOLD}3. MongoDB Cluster Status:${NC}"
    local clusters=$(kind get clusters 2>/dev/null)
    if echo "$clusters" | grep -q "mongodb-cluster"; then
        print_success "Cluster 'mongodb-cluster' exists"
        
        # Check if running
        if docker ps --format "table {{.Names}}" 2>/dev/null | grep -q "mongodb-cluster"; then
            print_success "Cluster containers are running"
            
            # Check nodes
            echo
            echo -e "${BOLD}   Cluster Nodes:${NC}"
            kubectl get nodes --context kind-mongodb-cluster 2>/dev/null || print_error "   Cannot connect to cluster API"
            
            # Check system pods
            echo
            echo -e "${BOLD}   System Pods:${NC}"
            kubectl get pods -n kube-system --context kind-mongodb-cluster 2>/dev/null | head -5 || print_error "   Cannot get system pods"
            
        else
            print_warning "Cluster exists but containers are stopped"
        fi
    else
        print_warning "Cluster 'mongodb-cluster' does not exist"
    fi
    
    echo
    
    # Check applications if cluster is running
    if kubectl get nodes --context kind-mongodb-cluster &>/dev/null; then
        echo -e "${BOLD}4. Application Status:${NC}"
        
        # Check MongoDB
        if kubectl get pods -l app=mongodb --context kind-mongodb-cluster &>/dev/null; then
            local mongo_status=$(kubectl get pods -l app=mongodb --context kind-mongodb-cluster -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
            if [ "$mongo_status" = "Running" ]; then
                print_success "MongoDB is running"
            else
                print_warning "MongoDB pod status: ${mongo_status:-"Unknown"}"
            fi
        else
            print_info "MongoDB is not deployed"
        fi
        
        # Check MongoDB Express
        if kubectl get pods -l app=mongodb-express --context kind-mongodb-cluster &>/dev/null; then
            local express_status=$(kubectl get pods -l app=mongodb-express --context kind-mongodb-cluster -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
            if [ "$express_status" = "Running" ]; then
                print_success "MongoDB Express is running"
                echo "   Web UI: http://localhost:8081"
            else
                print_warning "MongoDB Express pod status: ${express_status:-"Unknown"}"
            fi
        else
            print_info "MongoDB Express is not deployed"
        fi
        
        # Check services
        echo
        echo -e "${BOLD}5. Service Status:${NC}"
        kubectl get services --context kind-mongodb-cluster 2>/dev/null | grep -E "(mongodb|NAME)" || print_info "No MongoDB services found"
        
        # Connectivity test
        echo
        echo -e "${BOLD}6. Connectivity Test:${NC}"
        if curl -s --connect-timeout 5 http://localhost:8081 >/dev/null 2>&1; then
            print_success "MongoDB Express web interface is accessible"
        else
            print_warning "MongoDB Express web interface is not accessible"
        fi
        
        if nc -z localhost 27017 2>/dev/null; then
            print_success "MongoDB port is accessible"
        else
            print_warning "MongoDB port is not accessible"
        fi
        
    fi
    
    echo
    show_cluster_summary
    pause
}

# Function to restart cluster
restart_cluster() {
    print_header "RESTART CLUSTER"
    
    print_info "This will cleanly restart the cluster and all applications"
    echo
    
    local clusters=$(kind get clusters 2>/dev/null)
    if ! echo "$clusters" | grep -q "mongodb-cluster"; then
        print_warning "No cluster named 'mongodb-cluster' found"
        print_info "Use 'Start Cluster' to create a new cluster"
        pause
        return 0
    fi
    
    print_warning "Restart process:"
    echo "• Stop all cluster containers"
    echo "• Start cluster containers"
    echo "• Wait for cluster to be ready"
    echo "• Verify applications are running"
    echo
    
    if ask_yes_no "Restart the cluster"; then
        print_step "Step 1/4: Stopping cluster..."
        local containers=$(docker ps -q --filter "name=mongodb-cluster")
        if [ -n "$containers" ]; then
            docker stop $containers >/dev/null 2>&1
            print_success "Cluster stopped"
        else
            print_info "Cluster was already stopped"
        fi
        
        print_step "Step 2/4: Starting cluster containers..."
        if start_existing_cluster; then
            print_success "Cluster containers started"
        else
            print_error "Failed to start cluster containers"
            pause
            return 1
        fi
        
        print_step "Step 3/4: Waiting for cluster to be ready..."
        sleep 5
        local attempts=0
        while [ $attempts -lt 30 ]; do
            if kubectl get nodes --context kind-mongodb-cluster &>/dev/null; then
                print_success "Cluster API is ready"
                break
            fi
            echo -n "."
            sleep 2
            attempts=$((attempts + 1))
        done
        
        if [ $attempts -eq 30 ]; then
            print_error "Cluster did not become ready in time"
            pause
            return 1
        fi
        
        print_step "Step 4/4: Verifying applications..."
        sleep 3
        if kubectl get pods --context kind-mongodb-cluster &>/dev/null; then
            kubectl get pods --context kind-mongodb-cluster
            print_success "Cluster restart completed successfully!"
        else
            print_warning "Cluster restarted but applications may need time to start"
        fi
        
        echo
        show_cluster_summary
    fi
    
    pause
}

# Function to destroy cluster
destroy_cluster() {
    print_header "DESTROY CLUSTER"
    
    print_warning "DESTRUCTIVE OPERATION!"
    echo
    print_error "This will PERMANENTLY DELETE:"
    echo "• The entire Kind cluster"
    echo "• All MongoDB data and databases"
    echo "• All configurations and secrets"
    echo "• All persistent volumes and claims"
    echo "• All applications and services"
    echo
    print_warning "This action CANNOT be undone!"
    echo
    
    local clusters=$(kind get clusters 2>/dev/null)
    if ! echo "$clusters" | grep -q "mongodb-cluster"; then
        print_info "No cluster named 'mongodb-cluster' found to destroy"
        pause
        return 0
    fi
    
    # Show what will be destroyed
    echo -e "${BOLD}Current cluster contents:${NC}"
    if kubectl get all --context kind-mongodb-cluster &>/dev/null; then
        kubectl get all --context kind-mongodb-cluster 2>/dev/null | head -10
        echo "..."
    else
        echo "Unable to connect to cluster (may already be stopped)"
    fi
    echo
    
    echo -e "${RED}${BOLD}Are you absolutely sure you want to destroy everything?${NC}"
    if ask_yes_no "Type 'yes' to confirm destruction" "n"; then
        echo
        print_warning "Last chance! This will delete ALL data permanently."
        read -p "Type 'DESTROY' in capital letters to confirm: " confirm
        
        if [ "$confirm" = "DESTROY" ]; then
            print_step "Destroying cluster 'mongodb-cluster'..."
            
            if kind delete cluster --name mongodb-cluster; then
                print_success "Cluster destroyed successfully"
                echo
                print_info "All data, configurations, and applications have been permanently deleted"
                print_info "You can create a fresh cluster using 'Start Cluster' option"
            else
                print_error "Failed to destroy cluster completely"
                print_info "You may need to manually clean up with: docker system prune"
            fi
        else
            print_info "Destruction cancelled - cluster is safe"
        fi
    else
        print_info "Destruction cancelled - cluster is safe"
    fi
    
    pause
}

# Function for quick deploy
quick_deploy_cluster() {
    print_header "QUICK DEPLOY - CLUSTER + APPLICATIONS"
    
    print_info "This will create the cluster and deploy all MongoDB applications automatically"
    echo
    
    echo -e "${BOLD}Quick Deploy Process:${NC}"
    echo "1. Check prerequisites"
    echo "2. Create/start Kind cluster"
    echo "3. Initialize secure credentials"
    echo "4. Deploy MongoDB with persistent storage"
    echo "5. Deploy MongoDB Express web interface"
    echo "6. Verify all components are running"
    echo
    
    if ask_yes_no "Start quick deployment"; then
        # Check prerequisites first
        if ! check_prerequisites; then
            pause
            return 1
        fi
        
        # Start or create cluster
        print_step "Step 1: Ensuring cluster is running..."
        local clusters=$(kind get clusters 2>/dev/null)
        if ! echo "$clusters" | grep -q "mongodb-cluster"; then
            print_info "Creating new cluster..."
            if ! kind create cluster --config "$PROJECT_DIR/kind/kind-config.yaml" --name mongodb-cluster; then
                print_error "Failed to create cluster"
                pause
                return 1
            fi
        elif ! docker ps --format "table {{.Names}}" 2>/dev/null | grep -q "mongodb-cluster"; then
            print_info "Starting existing cluster..."
            if ! start_existing_cluster; then
                print_error "Failed to start cluster"
                pause
                return 1
            fi
        fi
        print_success "Cluster is ready"
        
        # Deploy applications
        print_step "Step 2: Deploying applications..."
        if deploy_applications; then
            print_success "Quick deployment completed successfully!"
            echo
            show_cluster_summary
            show_access_info
        else
            print_error "Deployment failed"
        fi
    fi
    
    pause
}

# Function to show cluster info
cluster_info() {
    print_header "DETAILED CLUSTER INFORMATION"
    
    if ! check_cluster_exists; then
        print_warning "No MongoDB cluster found"
        pause
        return 0
    fi
    
    echo -e "${BOLD}Cluster Configuration:${NC}"
    echo "• Name: mongodb-cluster"
    echo "• Type: Kind (Kubernetes in Docker)"
    echo "• Config: $(realpath "$PROJECT_DIR/kind/kind-config.yaml")"
    echo
    
    if kubectl get nodes --context kind-mongodb-cluster &>/dev/null; then
        echo -e "${BOLD}Nodes:${NC}"
        kubectl get nodes --context kind-mongodb-cluster -o wide
        echo
        
        echo -e "${BOLD}Cluster Info:${NC}"
        kubectl cluster-info --context kind-mongodb-cluster
        echo
        
        echo -e "${BOLD}System Resources:${NC}"
        echo "Namespaces:"
        kubectl get namespaces --context kind-mongodb-cluster
        echo
        
        echo -e "${BOLD}Storage:${NC}"
        kubectl get pv,pvc --context kind-mongodb-cluster 2>/dev/null || echo "No persistent volumes found"
        echo
        
        echo -e "${BOLD}Network:${NC}"
        kubectl get services --context kind-mongodb-cluster
        echo
        
        if kubectl get pods --context kind-mongodb-cluster &>/dev/null; then
            echo -e "${BOLD}Applications:${NC}"
            kubectl get pods -o wide --context kind-mongodb-cluster
        fi
    else
        print_warning "Cannot connect to cluster API"
    fi
    
    pause
}

# Helper function to check prerequisites
check_prerequisites() {
    local all_good=true
    
    print_step "Checking prerequisites..."
    
    # Check Docker
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker Desktop"
        all_good=false
    else
        print_success "Docker is running"
    fi
    
    # Check Kind
    if ! command -v kind &> /dev/null; then
        print_error "Kind is not installed. Install with: brew install kind"
        all_good=false
    else
        print_success "Kind is available"
    fi
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Install with: brew install kubectl"
        all_good=false
    else
        print_success "kubectl is available"
    fi
    
    if [ "$all_good" = false ]; then
        echo
        print_error "Please install missing prerequisites and try again"
        return 1
    fi
    
    return 0
}

# Helper function to check if cluster exists
check_cluster_exists() {
    local clusters=$(kind get clusters 2>/dev/null)
    echo "$clusters" | grep -q "mongodb-cluster"
}

# Helper function to start existing cluster
start_existing_cluster() {
    local containers=$(docker ps -a -q --filter "name=mongodb-cluster")
    if [ -n "$containers" ]; then
        docker start $containers >/dev/null 2>&1
        sleep 3
        return 0
    else
        return 1
    fi
}

# Helper function to deploy applications
deploy_applications() {
    # Initialize credentials if not exists
    if [ ! -f "$PROJECT_DIR/.credentials/encrypted_creds.enc" ]; then
        print_step "Initializing secure credentials..."
        "$SCRIPT_DIR/manage-credentials.sh" --init
    fi
    
    # Deploy using the existing deploy script
    print_step "Deploying MongoDB applications..."
    if "$SCRIPT_DIR/deploy.sh"; then
        return 0
    else
        return 1
    fi
}

# Helper function to show cluster summary
show_cluster_summary() {
    echo -e "${BOLD}Cluster Summary:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Cluster status
    local status=$(get_cluster_status)
    echo "Status: $status"
    
    # Node count if running
    if kubectl get nodes --context kind-mongodb-cluster &>/dev/null; then
        local node_count=$(kubectl get nodes --context kind-mongodb-cluster --no-headers 2>/dev/null | wc -l)
        echo "Nodes: $node_count"
        
        local pod_count=$(kubectl get pods --context kind-mongodb-cluster --no-headers 2>/dev/null | wc -l)
        echo "Pods: $pod_count"
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
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
            3) cluster_management_menu ;;
            4) management_menu ;;
            5) monitoring_menu ;;
            6) security_menu ;;
            7) playground_menu ;;
            8) learning_resources ;;
            9) 
                if ask_yes_no "Are you sure you want to cleanup everything"; then
                    "$SCRIPT_DIR/cleanup.sh"
                fi
                ;;
            10) show_help ;;
            11) 
                print_header "GOODBYE!"
                echo -e "${GREEN}Thank you for using the MongoDB on Kind Learning Lab!${NC}"
                echo "Keep exploring Kubernetes - you're doing great! "
                echo
                exit 0
                ;;
            *)
                print_error "Invalid option. Please choose 1-11."
                sleep 2
                ;;
        esac
    done
}

# Run the main function
main "$@"
