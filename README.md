# MongoDB on Kind Kubernetes Cluster - Comprehensive Learning Lab

This project creates a complete MongoDB deployment on a Kind (Kubernetes in Docker) cluster with MongoDB Express as a web interface. The setup includes persistent storage, enterprise-grade security configurations, interactive learning tools, and comprehensive automation scripts for educational purposes.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Interactive Learning Mode](#interactive-learning-mode)
- [Manual Operations](#manual-operations)
- [Security Implementation](#security-implementation)
- [Storage and Persistence](#storage-and-persistence)
- [Network Configuration](#network-configuration)
- [Monitoring and Operations](#monitoring-and-operations)
- [Learning Objectives](#learning-objectives)
- [Practice Scenarios](#practice-scenarios)
- [Troubleshooting](#troubleshooting)
- [File Reference Guide](#file-reference-guide)
- [Script Reference Guide](#script-reference-guide)
- [Command Reference](#command-reference)
- [Advanced Usage](#advanced-usage)
- [Contributing](#contributing)

## Overview

This is a comprehensive Kubernetes learning environment that provides hands-on experience with container orchestration, local development with Kind, database deployment, security best practices, and interactive learning through guided tutorials.

The project transforms a complex Kubernetes MongoDB deployment into an accessible educational tool suitable for beginners while maintaining production-ready patterns and enterprise-grade security.

## Architecture

### Cluster Configuration
- **1 Control Plane Node**: Manages the Kubernetes cluster
- **2 Worker Nodes**: Run the application workloads
  - `mongodb-worker`: Hosts database tier (labeled with `tier=database`)
  - `mongodb-express-worker`: Hosts frontend tier (labeled with `tier=frontend`)

### Components
- **MongoDB**: NoSQL database with persistent storage (5GB)
- **MongoDB Express**: Web-based MongoDB administration interface
- **Persistent Storage**: StorageClass and PVC for MongoDB data persistence
- **Services**: Both internal (ClusterIP) and external (NodePort) access
- **Security**: Kubernetes secrets with encrypted credential management
- **Configuration**: ConfigMap for database connection settings
- **Health Monitoring**: Comprehensive liveness and readiness probes
- **Node Affinity**: Workload distribution based on tier labels

## Prerequisites

Before running this project, ensure you have the following installed:

- **Docker**: Container runtime (Docker Desktop must be running)
- **Kind**: Kubernetes in Docker
- **kubectl**: Kubernetes command-line tool
- **jq**: JSON processor (for credential management)
- **openssl**: For encryption operations
- **macOS/Linux**: This project is designed for Unix-like systems

### Installation Commands

```bash
# Install Kind
brew install kind

# Install kubectl
brew install kubectl

# Install jq (JSON processor)
brew install jq

# Verify Docker is running
docker --version

# Verify all tools
kind --version
kubectl version --client
jq --version
openssl version
```

## Project Structure

```
mongodb-on-kind/
├── resource/                          # Kubernetes manifests
│   ├── configmaps/
│   │   └── mongodb-configmap.yaml     # MongoDB connection configuration
│   ├── deployments/
│   │   ├── mongodb-deployment.yaml    # MongoDB deployment with persistence
│   │   └── mongodb-express-deployment.yaml  # MongoDB Express with init container
│   ├── secrets/
│   │   └── mongodb-secret.yaml        # Base64-encoded database credentials
│   ├── services/
│   │   ├── mongodb-service.yaml       # MongoDB internal/external services
│   │   └── mongodb-express-service.yaml    # MongoDB Express services
│   └── storage/
│       └── mongodb-storage.yaml       # StorageClass and PVC for MongoDB
├── kind/
│   └── kind-config.yaml              # Kind cluster configuration
├── scripts/                          # Automation and management scripts
│   ├── cleanup.sh                    # Safe teardown with backup options
│   ├── deploy.sh                     # Main deployment script
│   ├── interactive-menu.sh           # Main learning interface
│   ├── manage-credentials.sh         # Encrypted credential management
│   ├── playground-helpers.sh         # Educational kubectl tutorials
│   ├── status.sh                     # Real-time cluster status monitoring
│   └── validate.sh                   # Health checks and connectivity testing
├── start.sh                          # Single entry point for learning environment
└── README.md                         # This comprehensive guide
```

## Quick Start

### Option 1: Interactive Learning Mode (Recommended for Beginners)

```bash
cd mongodb-on-kind
./start.sh
```

This launches an interactive menu system designed for Kubernetes learners with the following options:

- **Learning Mode**: Step-by-step guided deployment with explanations
- **Quick Start**: Automated deployment for experienced users
- **Management Tools**: Manage existing deployments
- **Kubernetes Playground**: Practice kubectl commands safely
- **Security Lab**: Learn about credential management
- **Help & Troubleshooting**: Context-sensitive assistance

### Option 2: Direct Deployment

```bash
cd mongodb-on-kind

# Initialize secure credentials (first time only)
./scripts/manage-credentials.sh --init

# Deploy the cluster
./scripts/deploy.sh

# Validate the deployment
./scripts/validate.sh
```

### Option 3: Manual Step-by-Step

```bash
# 1. Create encrypted credentials
./scripts/manage-credentials.sh --init

# 2. Create the Kind cluster
kind create cluster --config=kind/kind-config.yaml

# 3. Set kubectl context
kubectl config use-context kind-mongodb-cluster

# 4. Apply Kubernetes manifests in order
kubectl apply -f resource/storage/
kubectl apply -f resource/secrets/
kubectl apply -f resource/configmaps/
kubectl apply -f resource/deployments/
kubectl apply -f resource/services/

# 5. Wait for all pods to be ready
kubectl wait --for=condition=ready pod --all --timeout=300s

# 6. Verify deployment
./scripts/validate.sh
```

## Interactive Learning Mode

This project includes a comprehensive interactive menu system designed specifically for Kubernetes learners. The menu provides guided learning experiences with step-by-step explanations.

### Features

**Learning Mode**
- Step-by-step guided deployment with detailed explanations
- Learn Kubernetes concepts as you build
- Understand pods, services, secrets, storage, and networking
- Hands-on experience with real applications

**Kubernetes Playground**
- Practice kubectl commands safely
- Interactive tutorials for common operations
- Debugging and troubleshooting exercises
- Real-world scenarios and challenges

**Security Lab**
- Learn about Kubernetes security concepts
- Practice with encrypted credential management
- Understand secrets, ConfigMaps, and RBAC
- Security best practices demonstrations

**Management Tools**
- Monitor cluster status and resources
- Scale applications interactively
- View logs and debug issues
- Backup and restore procedures

### Usage

```bash
# Start the interactive learning environment
./start.sh

# Or directly launch the menu
./scripts/interactive-menu.sh
```

The interactive system is perfect for:
- Kubernetes beginners learning core concepts
- Students practicing kubectl commands
- Developers exploring container orchestration
- Anyone wanting hands-on Kubernetes experience

## Manual Operations

### View Cluster Status

```bash
# Set kubectl context
kubectl config use-context kind-mongodb-cluster

# View all pods with detailed information
kubectl get pods -o wide

# View all services
kubectl get services

# View persistent volumes and claims
kubectl get pv,pvc

# Check node status and labels
kubectl get nodes --show-labels

# View all resources in default namespace
kubectl get all

# Check cluster information
kubectl cluster-info
```

### Monitor Applications

```bash
# MongoDB logs
kubectl logs -l app=mongodb

# MongoDB Express logs
kubectl logs -l app=mongodb-express

# Follow logs in real-time
kubectl logs -f deployment/mongodb

# View events
kubectl get events --sort-by=.metadata.creationTimestamp

# Check resource usage (if metrics-server available)
kubectl top pods
kubectl top nodes
```

### Scale Applications

```bash
# Scale MongoDB (note: only scale to 1 for data consistency)
kubectl scale deployment mongodb --replicas=1

# Scale MongoDB Express
kubectl scale deployment mongodb-express --replicas=2

# Watch scaling in action
kubectl get pods -w
```

### Access MongoDB Directly

```bash
# Get MongoDB pod name
MONGO_POD=$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}')

# Connect to MongoDB shell
kubectl exec -it $MONGO_POD -- mongosh

# Connect with authentication
ROOT_PASSWORD=$(./scripts/manage-credentials.sh --get mongodb_root_password)
kubectl exec -it $MONGO_POD -- mongosh -u admin -p $ROOT_PASSWORD

# Run MongoDB commands
kubectl exec -it $MONGO_POD -- mongosh --eval "show dbs"
kubectl exec -it $MONGO_POD -- mongosh --eval "db.runCommand({ping: 1})"
```

## Security Implementation

### Overview
All plain-text passwords have been successfully removed from the MongoDB on Kind deployment and replaced with a comprehensive encrypted credential management system using AES-256-CBC encryption.

### Security Features

**Encrypted Credential Management**
- AES-256-CBC encryption for all sensitive data
- Cryptographically secure password generation
- Separate encryption key storage
- Automatic credential rotation capabilities
- Secure backup and recovery procedures

**File Security**
- No plain-text passwords in any configuration files
- Proper file permissions (600) for sensitive files
- Version control protection via .gitignore
- Audit trail with generation timestamps

### Credential Management Commands

```bash
# Initialize secure credentials (first time setup)
./scripts/manage-credentials.sh --init

# View all credentials (use carefully)
./scripts/manage-credentials.sh --show

# Get specific credential
./scripts/manage-credentials.sh --get webui_password
./scripts/manage-credentials.sh --get mongodb_root_password

# Backup credentials securely
./scripts/manage-credentials.sh --backup

# Update Kubernetes secrets with new credentials
./scripts/manage-credentials.sh --update-k8s

# Rotate all passwords
./scripts/manage-credentials.sh --init
```

### Current Credential Types
- **MongoDB Admin Password**: 24-character secure random string
- **MongoDB Root Password**: 32-character secure random string
- **WebUI Password**: 16-character secure random string

### Security Best Practices Implemented
- **Encryption at Rest**: All credentials encrypted using AES-256-CBC
- **No Plain-Text Storage**: Zero plain-text passwords in any files
- **Credential Rotation**: Easy re-initialization of all passwords
- **Secure Backups**: Encrypted backup functionality
- **Audit Trail**: Credential generation timestamps
- **Access Control**: Restricted file permissions

### Access Information

After deployment, you can access services using:

**MongoDB Express Web Interface**
- URL: http://localhost:8081
- Username: `admin`
- Password: `./scripts/manage-credentials.sh --get webui_password`

**MongoDB Database**
- Host: localhost:27017
- Username: `admin`
- Password: `./scripts/manage-credentials.sh --get mongodb_root_password`

## Storage and Persistence

MongoDB data is persisted using Kubernetes storage resources:

### Storage Components
- **StorageClass**: `mongodb-storage` (hostPath-based for local development)
- **PersistentVolume**: Automatically provisioned
- **PersistentVolumeClaim**: `mongodb-pvc` (5GB capacity)
- **Mount Point**: `/data/db` in the MongoDB container

### Storage Operations

```bash
# View storage resources
kubectl get storageclass,pv,pvc

# Check storage usage
kubectl describe pvc mongodb-pvc

# View mounted storage in pod
MONGO_POD=$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}')
kubectl exec $MONGO_POD -- df -h /data/db
```

### Backup and Restore

```bash
# Create a backup using MongoDB tools
kubectl exec -it $MONGO_POD -- mongodump --out /data/backup

# Copy backup to local machine
kubectl cp $MONGO_POD:/data/backup ./mongodb-backup

# Restore from backup
kubectl exec -it $MONGO_POD -- mongorestore /data/backup

# Create backup using script
./scripts/interactive-menu.sh
# Choose Management Tools > Backup Data
```

## Network Configuration

### Port Mappings
- **MongoDB**: Port 27017 (mapped to host port 30017)
- **MongoDB Express**: Port 8081 (mapped to host port 30081)

### Service Types
- **ClusterIP**: Internal cluster communication
- **NodePort**: External access from host machine

### Network Testing

```bash
# Test external connectivity
curl -u admin:$(./scripts/manage-credentials.sh --get webui_password) http://localhost:8081

# Test internal service discovery
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup mongodb-service

# Check service endpoints
kubectl get endpoints

# Test port accessibility
nc -z localhost 8081
nc -z localhost 27017

# Test from one pod to another
EXPRESS_POD=$(kubectl get pods -l app=mongodb-express -o jsonpath='{.items[0].metadata.name}')
kubectl exec $EXPRESS_POD -- nc -z mongodb-service 27017
```

## Monitoring and Operations

### Health Checks and Monitoring

```bash
# Check overall cluster status
./scripts/status.sh

# View pod health and readiness
kubectl get pods -o wide

# Check deployment status
kubectl get deployments

# View resource usage
kubectl describe nodes

# Check pod events and conditions
kubectl describe pod <pod-name>

# Monitor resource usage (if metrics-server available)
kubectl top pods
kubectl top nodes
```

### Application Management

```bash
# Restart deployments
kubectl rollout restart deployment/mongodb
kubectl rollout restart deployment/mongodb-express

# Check rollout status
kubectl rollout status deployment/mongodb

# View deployment history
kubectl rollout history deployment/mongodb

# Scale applications
kubectl scale deployment mongodb-express --replicas=2

# Update application configuration
kubectl edit configmap mongodb-configmap
kubectl rollout restart deployment/mongodb-express
```

## Learning Objectives

By completing this lab, you will understand:

### Kubernetes Fundamentals
- **Cluster Architecture**: Control plane, worker nodes, and networking
- **Core Resources**: Pods, Deployments, Services, ConfigMaps, Secrets
- **Storage**: Persistent Volumes, Persistent Volume Claims, Storage Classes
- **Networking**: ClusterIP, NodePort services, and service discovery

### Real-World Application Deployment
- **Multi-tier Applications**: Database and frontend tiers
- **Health Checks**: Liveness and readiness probes
- **Init Containers**: Dependency management and setup
- **Resource Management**: CPU and memory limits/requests

### Security and Configuration Management
- **Encrypted Credentials**: AES-256-CBC encryption for sensitive data
- **Kubernetes Secrets**: Base64 encoding and environment injection
- **Configuration Management**: Separating config from code
- **Security Best Practices**: No hardcoded credentials, proper file permissions

### Operations and Troubleshooting
- **Monitoring**: Viewing logs, status, and resource usage
- **Scaling**: Horizontal pod autoscaling concepts
- **Debugging**: Common issues and resolution techniques
- **Backup and Recovery**: Data persistence and backup strategies

## Practice Scenarios

### Scenario 1: Database Exploration
**Objective**: Discover what databases exist in your MongoDB instance

```bash
# Connect to MongoDB and list databases
MONGO_POD=$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $MONGO_POD -- mongosh --eval "show dbs"

# Create a test database
kubectl exec -it $MONGO_POD -- mongosh --eval "use testdb; db.test.insertOne({name: 'test'}); show dbs"
```

### Scenario 2: Scaling Exercise
**Objective**: Scale MongoDB Express and observe the behavior

```bash
# Scale up
kubectl scale deployment mongodb-express-deployment --replicas=3

# Watch pods being created
kubectl get pods -w

# Check load balancing
for i in {1..10}; do curl -s http://localhost:8081 | grep -o '<title>.*</title>'; done

# Scale back down
kubectl scale deployment mongodb-express-deployment --replicas=1
```

### Scenario 3: Service Discovery Test
**Objective**: Test inter-pod communication

```bash
# Test DNS resolution
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup mongodb-service

# Test connectivity
EXPRESS_POD=$(kubectl get pods -l app=mongodb-express -o jsonpath='{.items[0].metadata.name}')
kubectl exec $EXPRESS_POD -- nc -z mongodb-service 27017

# Check service endpoints
kubectl get endpoints mongodb-service -o wide
```

### Scenario 4: Security Deep Dive
**Objective**: Explore credential management

```bash
# View encrypted credentials
./scripts/manage-credentials.sh --show

# Decode Kubernetes secret manually
kubectl get secret mongodb-secret -o jsonpath='{.data.mongodb-root-password}' | base64 --decode

# Test authentication
ROOT_PASSWORD=$(./scripts/manage-credentials.sh --get mongodb_root_password)
kubectl exec $(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}') -- mongosh -u admin -p $ROOT_PASSWORD --eval "db.runCommand({ping: 1})"
```

### Scenario 5: Log Analysis
**Objective**: Find specific information in application logs

```bash
# Find MongoDB version
kubectl logs -l app=mongodb | grep -i version

# Monitor MongoDB Express startup
kubectl logs -l app=mongodb-express -f

# Search for specific events
kubectl logs -l app=mongodb | grep -i "connection"
kubectl logs -l app=mongodb-express | grep -i "error"
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Pods Stuck in Pending State

```bash
# Check what's preventing scheduling
kubectl describe pod <pod-name>

# Common causes and solutions:
# - Insufficient resources: Check node capacity
kubectl describe nodes

# - Storage mounting issues: Check PVC status
kubectl get pvc
kubectl describe pvc mongodb-pvc

# - Node selector constraints: Verify node labels
kubectl get nodes --show-labels
```

#### 2. Services Not Accessible

```bash
# Check service configuration
kubectl get services -o wide

# Verify endpoints exist
kubectl get endpoints

# Test port accessibility
nc -z localhost 8081
nc -z localhost 27017

# Check Kind port mapping
docker ps | grep mongodb-cluster
```

#### 3. Authentication Failures

```bash
# Check if credentials are properly initialized
./scripts/manage-credentials.sh --show

# Verify secret exists and is properly encoded
kubectl get secret mongodb-secret -o yaml

# Test database connectivity
./scripts/validate.sh

# Manual connection test
ROOT_PASSWORD=$(./scripts/manage-credentials.sh --get mongodb_root_password)
kubectl exec $(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}') -- mongosh -u admin -p $ROOT_PASSWORD --eval "db.runCommand({ping: 1})"
```

#### 4. Container Crashes or Restart Loops

```bash
# Check pod events
kubectl describe pod <pod-name>

# View container logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous  # For previous container instance

# Check resource limits
kubectl describe deployment <deployment-name>

# Verify liveness and readiness probes
kubectl get pod <pod-name> -o yaml | grep -A 10 "livenessProbe\|readinessProbe"
```

#### 5. Storage Issues

```bash
# Check PVC status
kubectl get pvc mongodb-pvc
kubectl describe pvc mongodb-pvc

# Verify storage class
kubectl get storageclass mongodb-storage

# Check if volume is mounted correctly
MONGO_POD=$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}')
kubectl exec $MONGO_POD -- df -h /data/db
kubectl exec $MONGO_POD -- ls -la /data/db
```

#### 6. Network Connectivity Issues

```bash
# Test service resolution
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup mongodb-service

# Check service endpoints
kubectl get endpoints

# Verify pod-to-pod communication
kubectl exec <source-pod> -- nc -z <target-service> <port>

# Check iptables rules (advanced)
kubectl exec <pod> -- iptables -L
```

### Reset and Recovery

```bash
# Complete cluster reset
kind delete cluster --name mongodb-cluster

# Redeploy from scratch
./scripts/deploy.sh

# Reset credentials only
./scripts/manage-credentials.sh --init

# Clean deployment and redeploy
kubectl delete -f resource/
kubectl apply -f resource/
```

## File Reference Guide

### Kubernetes Manifests

#### resource/storage/mongodb-storage.yaml
- **Purpose**: Defines storage resources for MongoDB data persistence
- **Components**:
  - StorageClass: `mongodb-storage` using hostPath provisioner
  - PersistentVolume: 5GB capacity for MongoDB data
  - PersistentVolumeClaim: Binds to PV for use by MongoDB pods
- **Key Features**: Local storage suitable for development environments

#### resource/secrets/mongodb-secret.yaml
- **Purpose**: Stores encrypted database credentials as Kubernetes secrets
- **Components**:
  - `mongodb-root-password`: Base64-encoded MongoDB admin password
  - `mongodb-password`: Base64-encoded MongoDB user password
- **Security**: Works with encrypted credential management system

#### resource/configmaps/mongodb-configmap.yaml
- **Purpose**: Provides non-sensitive configuration data
- **Components**:
  - Database connection strings
  - Service discovery information
  - Application configuration parameters
- **Usage**: Referenced by MongoDB Express deployment

#### resource/deployments/mongodb-deployment.yaml
- **Purpose**: Defines MongoDB database deployment
- **Key Features**:
  - Single replica for data consistency
  - Persistent volume mounting
  - Node selector for database tier
  - Liveness and readiness probes
  - Resource limits and requests
  - Security context for proper permissions

#### resource/deployments/mongodb-express-deployment.yaml
- **Purpose**: Defines MongoDB Express web interface deployment
- **Key Features**:
  - Init container for dependency checking
  - Environment variable injection from secrets/configmaps
  - Node selector for frontend tier
  - Health checks for web interface
  - Scalable deployment design

#### resource/services/mongodb-service.yaml
- **Purpose**: Exposes MongoDB database service
- **Service Types**:
  - ClusterIP: Internal cluster communication
  - NodePort: External access for development
- **Port Configuration**: 27017 (MongoDB default port)

#### resource/services/mongodb-express-service.yaml
- **Purpose**: Exposes MongoDB Express web interface
- **Service Types**:
  - ClusterIP: Internal cluster communication
  - NodePort: External web access
- **Port Configuration**: 8081 (web interface port)

#### kind/kind-config.yaml
- **Purpose**: Defines Kind cluster configuration
- **Cluster Topology**:
  - 1 control-plane node
  - 2 worker nodes with custom labels
- **Port Mappings**:
  - 27017: MongoDB database access
  - 8081: MongoDB Express web interface
- **Node Configuration**: Custom labels for workload placement

### Documentation Files

#### README.md
- **Purpose**: Comprehensive project documentation and user guide
- **Content**: Complete setup instructions, usage examples, troubleshooting, security implementation, learning guides, and project summary
- **Audience**: All users from beginners to advanced - serves as the single source of truth for the entire project

## Script Reference Guide

### start.sh
- **Purpose**: Single entry point for the learning environment
- **Function**: Launches the interactive menu system
- **Usage**: `./start.sh`
- **Features**: Beginner-friendly interface to all project functionality

### scripts/deploy.sh
- **Purpose**: Main deployment automation script
- **Functions**:
  - Detects host IP automatically
  - Creates Kind cluster with specified configuration
  - Deploys all Kubernetes resources in correct order
  - Waits for all pods to be ready
  - Displays connection information
- **Usage**: `./scripts/deploy.sh [--cleanup]`
- **Features**: Comprehensive error handling and validation

### scripts/validate.sh
- **Purpose**: Deployment validation and testing script
- **Functions**:
  - Checks status of all pods and services
  - Tests connectivity to MongoDB
  - Verifies MongoDB Express web interface
  - Displays resource usage and summary
- **Usage**: `./scripts/validate.sh`
- **Features**: Comprehensive health checks and connectivity tests

### scripts/status.sh
- **Purpose**: Real-time cluster status monitoring
- **Functions**:
  - Provides comprehensive cluster overview
  - Shows pod, service, and storage status
  - Displays quick connectivity tests
  - Lists useful management commands
- **Usage**: `./scripts/status.sh`
- **Features**: User-friendly status dashboard

### scripts/manage-credentials.sh
- **Purpose**: Encrypted credential management system
- **Functions**:
  - Initialize secure credentials with AES-256-CBC encryption
  - Retrieve specific credentials safely
  - Create secure backups
  - Update Kubernetes secrets
  - Rotate passwords
- **Usage**: 
  ```bash
  ./scripts/manage-credentials.sh --init
  ./scripts/manage-credentials.sh --get <credential_name>
  ./scripts/manage-credentials.sh --show
  ./scripts/manage-credentials.sh --backup
  ```
- **Security**: All passwords encrypted at rest, never stored in plain text

### scripts/cleanup.sh
- **Purpose**: Safe teardown with backup options
- **Functions**:
  - Offers backup before deletion
  - Safely removes Kind cluster
  - Cleans up Docker containers and networks
  - Preserves encrypted credentials (optional)
- **Usage**: `./scripts/cleanup.sh [--preserve-creds]`
- **Features**: Data protection and recovery options

### scripts/interactive-menu.sh
- **Purpose**: Main learning interface with menu-driven navigation
- **Functions**:
  - Learning Mode: Step-by-step guided deployment
  - Quick Start: Automated deployment
  - Management Tools: Interactive cluster management
  - Security Lab: Credential management training
  - Kubernetes Playground: Safe kubectl practice environment
  - Help & Troubleshooting: Context-sensitive assistance
- **Usage**: `./scripts/interactive-menu.sh`
- **Features**: Beginner-friendly, educational, comprehensive

### scripts/playground-helpers.sh
- **Purpose**: Educational kubectl tutorials and helpers
- **Functions**:
  - Interactive kubectl command tutorials
  - Safe practice environment for experimentation
  - Guided exercises for common operations
  - Troubleshooting scenarios
- **Usage**: Called by interactive menu system
- **Features**: Hands-on learning with real cluster

## Command Reference

### Essential kubectl Commands

#### Cluster and Context Management
```bash
# List all contexts
kubectl config get-contexts

# Switch to project context
kubectl config use-context kind-mongodb-cluster

# Get cluster information
kubectl cluster-info

# View cluster nodes
kubectl get nodes --show-labels
```

#### Pod Management
```bash
# List all pods
kubectl get pods

# List pods with detailed information
kubectl get pods -o wide

# Describe a specific pod
kubectl describe pod <pod-name>

# View pod logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # Follow logs
kubectl logs <pod-name> --previous  # Previous container instance

# Execute commands in pod
kubectl exec -it <pod-name> -- /bin/bash
kubectl exec <pod-name> -- <command>

# Port forward to pod
kubectl port-forward pod/<pod-name> 8080:80
```

#### Deployment Management
```bash
# List deployments
kubectl get deployments

# Describe deployment
kubectl describe deployment <deployment-name>

# Scale deployment
kubectl scale deployment <deployment-name> --replicas=3

# Update deployment
kubectl set image deployment/<deployment-name> <container-name>=<new-image>

# Rollout management
kubectl rollout status deployment/<deployment-name>
kubectl rollout history deployment/<deployment-name>
kubectl rollout restart deployment/<deployment-name>
kubectl rollout undo deployment/<deployment-name>
```

#### Service Management
```bash
# List services
kubectl get services

# Describe service
kubectl describe service <service-name>

# View service endpoints
kubectl get endpoints

# Test service connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nc -z <service-name> <port>
```

#### Storage Management
```bash
# View storage resources
kubectl get storageclass,pv,pvc

# Describe persistent volume claim
kubectl describe pvc <pvc-name>

# Check storage usage in pod
kubectl exec <pod-name> -- df -h <mount-path>
```

#### Secret and ConfigMap Management
```bash
# List secrets and configmaps
kubectl get secrets,configmaps

# View secret contents (base64 decoded)
kubectl get secret <secret-name> -o jsonpath='{.data.<key>}' | base64 --decode

# Edit configmap
kubectl edit configmap <configmap-name>

# Create secret from command line
kubectl create secret generic <secret-name> --from-literal=<key>=<value>
```

#### Debugging Commands
```bash
# View events
kubectl get events --sort-by=.metadata.creationTimestamp

# Debug pod issues
kubectl describe pod <pod-name>
kubectl logs <pod-name>

# Check resource usage
kubectl top pods
kubectl top nodes

# Run debugging pod
kubectl run debug-pod --image=busybox --rm -it --restart=Never -- /bin/sh
```

### Project-Specific Commands

#### MongoDB Operations
```bash
# Get MongoDB pod name
MONGO_POD=$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}')

# Connect to MongoDB shell
kubectl exec -it $MONGO_POD -- mongosh

# Connect with authentication
ROOT_PASSWORD=$(./scripts/manage-credentials.sh --get mongodb_root_password)
kubectl exec -it $MONGO_POD -- mongosh -u admin -p $ROOT_PASSWORD

# MongoDB commands
kubectl exec -it $MONGO_POD -- mongosh --eval "show dbs"
kubectl exec -it $MONGO_POD -- mongosh --eval "db.runCommand({ping: 1})"
kubectl exec -it $MONGO_POD -- mongosh --eval "use testdb; db.test.insertOne({name: 'test'})"
```

#### Credential Management
```bash
# Initialize credentials
./scripts/manage-credentials.sh --init

# Get specific credential
./scripts/manage-credentials.sh --get webui_password
./scripts/manage-credentials.sh --get mongodb_root_password

# View all credentials
./scripts/manage-credentials.sh --show

# Backup credentials
./scripts/manage-credentials.sh --backup
```

#### Monitoring and Status
```bash
# Check overall status
./scripts/status.sh

# Validate deployment
./scripts/validate.sh

# Monitor logs
kubectl logs -f -l app=mongodb
kubectl logs -f -l app=mongodb-express
```

### Advanced Operations

#### Resource Management
```bash
# Apply all manifests
kubectl apply -f resource/

# Apply specific directory
kubectl apply -f resource/deployments/

# Delete resources
kubectl delete -f resource/deployments/
kubectl delete deployment,service,pod --all

# View resource definitions
kubectl get deployment mongodb-deployment -o yaml
kubectl get service mongodb-service -o yaml
```

#### Troubleshooting Commands
```bash
# Check pod readiness
kubectl get pods -o custom-columns=NAME:.metadata.name,READY:.status.containerStatuses[0].ready,STATUS:.status.phase

# View detailed pod status
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName,IP:.status.podIP

# Network debugging
kubectl exec -it <pod-name> -- nslookup kubernetes.default
kubectl exec -it <pod-name> -- nc -z <service-name> <port>

# Resource usage debugging
kubectl describe nodes
kubectl describe pod <pod-name> | grep -A 5 "Resource\|Limit"
```

## Advanced Usage

### Environment Customization

#### Custom Node Configuration
To modify the cluster topology, edit `kind/kind-config.yaml`:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30017
    hostPort: 27017
  - containerPort: 30081
    hostPort: 8081
- role: worker
  labels:
    tier: database
    environment: development
- role: worker
  labels:
    tier: frontend
    environment: development
- role: worker  # Add additional worker node
  labels:
    tier: compute
```

#### Storage Configuration
To use different storage types, modify `resource/storage/mongodb-storage.yaml`:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: mongodb-storage
provisioner: kubernetes.io/no-provisioner  # For static provisioning
# provisioner: rancher.io/local-path       # For dynamic local-path
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

#### Resource Limits
Update deployments with custom resource limits:

```bash
# Edit deployment
kubectl edit deployment mongodb-deployment

# Or apply patch
kubectl patch deployment mongodb-deployment -p '{"spec":{"template":{"spec":{"containers":[{"name":"mongodb","resources":{"limits":{"memory":"2Gi","cpu":"1000m"}}}]}}}}'
```

### Production Considerations

#### High Availability Setup
For production-like environments:

```bash
# Scale MongoDB Express for load balancing
kubectl scale deployment mongodb-express-deployment --replicas=3

# Add multiple worker nodes to kind configuration
# Update node selectors and anti-affinity rules
```

#### Monitoring Integration
Add monitoring stack:

```bash
# Example: Deploy Prometheus and Grafana
kubectl create namespace monitoring
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/master/bundle.yaml
```

#### Backup Strategies
Implement automated backups:

```bash
# Create backup CronJob
kubectl create cronjob mongodb-backup --image=mongo:6.0 --schedule="0 2 * * *" -- mongodump --uri="mongodb://admin:password@mongodb-service:27017" --out /backup
```

### Development Workflows

#### Configuration Updates
```bash
# Update ConfigMap and restart affected deployments
kubectl patch configmap mongodb-configmap -p '{"data":{"MONGO_INITDB_ROOT_USERNAME":"newadmin"}}'
kubectl rollout restart deployment/mongodb-express-deployment
```

#### Secret Rotation
```bash
# Generate new credentials
./scripts/manage-credentials.sh --init

# Update Kubernetes secrets
./scripts/manage-credentials.sh --update-k8s

# Restart deployments to pick up new secrets
kubectl rollout restart deployment/mongodb-deployment
kubectl rollout restart deployment/mongodb-express-deployment
```

#### Testing Different Versions
```bash
# Update MongoDB version
kubectl set image deployment/mongodb-deployment mongodb=mongo:7.0

# Monitor rollout
kubectl rollout status deployment/mongodb-deployment
```

## Contributing

### Adding New Features

1. **New Services**: Add service definitions to `resource/services/`
2. **Additional Deployments**: Create manifests in `resource/deployments/`
3. **Custom Scripts**: Add automation scripts to `scripts/` directory
4. **Documentation**: Update relevant documentation files

### Development Guidelines

#### Script Development
- Follow existing script patterns and error handling
- Add comprehensive logging and user feedback
- Include help text and usage examples
- Test thoroughly with various scenarios

#### Kubernetes Manifest Standards
- Use consistent labels and selectors
- Include resource limits and health checks
- Follow security best practices
- Document configuration options

#### Documentation Standards
- Keep instructions clear and beginner-friendly
- Include command examples with expected output
- Provide troubleshooting guidance
- Update all relevant documentation files

### Testing

#### Comprehensive Testing Checklist
- [ ] Fresh deployment on clean system
- [ ] Credential management functionality
- [ ] Service accessibility and connectivity
- [ ] Storage persistence after pod restart
- [ ] Scaling operations
- [ ] Cleanup and restoration procedures
- [ ] Interactive menu system functionality
- [ ] Documentation accuracy

#### Test Scenarios
```bash
# Test fresh deployment
kind delete cluster --name mongodb-cluster
./scripts/deploy.sh

# Test credential rotation
./scripts/manage-credentials.sh --init
./scripts/validate.sh

# Test scaling
kubectl scale deployment mongodb-express-deployment --replicas=3
kubectl get pods -w

# Test backup/restore
./scripts/interactive-menu.sh  # Management Tools > Backup Data
```

This comprehensive README provides complete documentation for the MongoDB on Kind Kubernetes Learning Lab, covering all aspects from basic setup to advanced operations, troubleshooting, and contributions. The project serves as both a functional MongoDB deployment and an educational platform for learning Kubernetes concepts through hands-on experience.
