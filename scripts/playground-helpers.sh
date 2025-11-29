#!/bin/bash

# MongoDB on Kind - Playground Helper Functions
# Extended functions for the interactive menu system

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

print_command() {
    echo -e "${BLUE}$ $1${NC}"
    echo -e "${YELLOW}Description: $2${NC}"
    echo
}

run_command_with_explanation() {
    local cmd="$1"
    local explanation="$2"
    
    echo -e "${BOLD}Command:${NC} $cmd"
    echo -e "${BOLD}Purpose:${NC} $explanation"
    echo
    echo -e "${YELLOW}Press Enter to run this command...${NC}"
    read -r
    
    echo -e "${BLUE}$ $cmd${NC}"
    eval "$cmd"
    echo
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read -r
}

# Basic kubectl commands tutorial
basic_kubectl_tutorial() {
    echo -e "${BOLD}📚 BASIC KUBECTL COMMANDS${NC}"
    echo
    echo "kubectl is the command-line tool for interacting with Kubernetes."
    echo "Let's practice the most important commands:"
    echo
    
    run_command_with_explanation "kubectl version" "Check kubectl and cluster version"
    run_command_with_explanation "kubectl cluster-info" "Get cluster information"
    run_command_with_explanation "kubectl get nodes" "List all nodes in the cluster"
    run_command_with_explanation "kubectl get pods" "List all pods in current namespace"
    run_command_with_explanation "kubectl get services" "List all services"
    run_command_with_explanation "kubectl get deployments" "List all deployments"
    run_command_with_explanation "kubectl get all" "List all resources"
    
    echo -e "${BOLD}🎯 Try these commands yourself:${NC}"
    echo "kubectl get pods -o wide          # More detailed pod info"
    echo "kubectl get pods --all-namespaces # Pods in all namespaces"
    echo "kubectl describe pod <pod-name>   # Detailed pod description"
}

# Resource exploration
explore_resources() {
    echo -e "${BOLD}🔍 EXPLORING KUBERNETES RESOURCES${NC}"
    echo
    echo "Let's explore different Kubernetes resources in detail:"
    echo
    
    # Pods
    echo -e "${BOLD}📦 PODS:${NC}"
    run_command_with_explanation "kubectl get pods -o wide" "See pods with additional details"
    
    if kubectl get pods | grep -q mongodb; then
        MONGO_POD=$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}')
        run_command_with_explanation "kubectl describe pod $MONGO_POD" "Detailed pod information"
    fi
    
    # Services
    echo -e "${BOLD}🌐 SERVICES:${NC}"
    run_command_with_explanation "kubectl get services -o wide" "See services with selectors"
    run_command_with_explanation "kubectl get endpoints" "See service endpoints"
    
    # Storage
    echo -e "${BOLD}💾 STORAGE:${NC}"
    run_command_with_explanation "kubectl get pv,pvc" "Persistent volumes and claims"
    run_command_with_explanation "kubectl get storageclass" "Available storage classes"
    
    # Secrets and ConfigMaps
    echo -e "${BOLD}🔐 CONFIGURATION:${NC}"
    run_command_with_explanation "kubectl get secrets" "List secrets"
    run_command_with_explanation "kubectl get configmaps" "List configuration maps"
}

# Deployment operations
deployment_operations() {
    echo -e "${BOLD}🚀 DEPLOYMENT OPERATIONS${NC}"
    echo
    echo "Learn how to manage application deployments:"
    echo
    
    run_command_with_explanation "kubectl get deployments" "List current deployments"
    run_command_with_explanation "kubectl describe deployment mongodb-deployment" "Detailed deployment info"
    
    echo -e "${BOLD}Scaling Operations:${NC}"
    echo "Current MongoDB Express replicas:"
    kubectl get deployment mongodb-express-deployment -o jsonpath='{.spec.replicas}'
    echo
    echo
    
    if [[ $(kubectl get deployment mongodb-express-deployment -o jsonpath='{.spec.replicas}') == "1" ]]; then
        echo "Let's scale MongoDB Express to 2 replicas:"
        run_command_with_explanation "kubectl scale deployment mongodb-express-deployment --replicas=2" "Scale up MongoDB Express"
        run_command_with_explanation "kubectl get pods -l app=mongodb-express" "See new pods being created"
        
        echo "Now let's scale back down:"
        run_command_with_explanation "kubectl scale deployment mongodb-express-deployment --replicas=1" "Scale down MongoDB Express"
    fi
    
    echo -e "${BOLD}Rollout Operations:${NC}"
    run_command_with_explanation "kubectl rollout status deployment/mongodb-express-deployment" "Check rollout status"
    run_command_with_explanation "kubectl rollout history deployment/mongodb-express-deployment" "See rollout history"
}

# Service management
service_management() {
    echo -e "${BOLD}🌐 SERVICE MANAGEMENT${NC}"
    echo
    echo "Learn about Kubernetes service networking:"
    echo
    
    run_command_with_explanation "kubectl get services" "List all services"
    run_command_with_explanation "kubectl describe service mongodb-service" "Internal service details"
    run_command_with_explanation "kubectl describe service mongodb-nodeport" "External service details"
    
    echo -e "${BOLD}Service Discovery:${NC}"
    if kubectl get pods -l app=mongodb-express | grep -q Running; then
        EXPRESS_POD=$(kubectl get pods -l app=mongodb-express -o jsonpath='{.items[0].metadata.name}')
        echo "Let's test service discovery from inside a pod:"
        run_command_with_explanation "kubectl exec $EXPRESS_POD -- nslookup mongodb-service" "DNS resolution test"
    fi
    
    echo -e "${BOLD}Port Forwarding (Alternative Access):${NC}"
    echo "You can also access services using port forwarding:"
    print_command "kubectl port-forward service/mongodb-express-service 8080:8081" "Forward local port 8080 to service port 8081"
    echo "This would make the service available at http://localhost:8080"
}

# Debugging techniques
debugging_techniques() {
    echo -e "${BOLD}🐛 DEBUGGING TECHNIQUES${NC}"
    echo
    echo "Learn how to troubleshoot Kubernetes issues:"
    echo
    
    echo -e "${BOLD}1. Check Pod Status:${NC}"
    run_command_with_explanation "kubectl get pods" "See pod status"
    
    echo -e "${BOLD}2. Get Detailed Information:${NC}"
    if kubectl get pods | grep -q mongodb; then
        MONGO_POD=$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}')
        run_command_with_explanation "kubectl describe pod $MONGO_POD" "Detailed pod information and events"
    fi
    
    echo -e "${BOLD}3. View Container Logs:${NC}"
    run_command_with_explanation "kubectl logs -l app=mongodb" "MongoDB container logs"
    run_command_with_explanation "kubectl logs -l app=mongodb-express" "MongoDB Express logs"
    
    echo -e "${BOLD}4. Execute Commands in Containers:${NC}"
    if kubectl get pods -l app=mongodb | grep -q Running; then
        MONGO_POD=$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}')
        echo "Let's connect to the MongoDB container:"
        print_command "kubectl exec -it $MONGO_POD -- bash" "Interactive shell in MongoDB container"
        print_command "kubectl exec $MONGO_POD -- ps aux" "List processes in container"
    fi
    
    echo -e "${BOLD}5. Resource Usage:${NC}"
    print_command "kubectl top pods" "Pod resource usage (requires metrics-server)"
    print_command "kubectl top nodes" "Node resource usage"
    
    echo -e "${BOLD}6. Events:${NC}"
    run_command_with_explanation "kubectl get events --sort-by=.metadata.creationTimestamp" "Cluster events timeline"
}

# Practice scenarios
practice_scenarios() {
    echo -e "${BOLD}🎯 PRACTICE SCENARIOS${NC}"
    echo
    echo "Try these hands-on scenarios to build your skills:"
    echo
    
    echo -e "${BOLD}Scenario 1: Investigate a 'Mysterious' Issue${NC}"
    echo "Task: Find out which MongoDB databases exist"
    echo "Hint: Use kubectl exec to run mongosh commands"
    echo
    
    echo -e "${BOLD}Scenario 2: Scale and Monitor${NC}"
    echo "Task: Scale MongoDB Express, watch the pods, then scale back"
    echo "Commands you'll need: scale, get pods -w, describe"
    echo
    
    echo -e "${BOLD}Scenario 3: Service Discovery Test${NC}"
    echo "Task: From MongoDB Express pod, test connectivity to MongoDB"
    echo "Hint: Use kubectl exec with ping or nc commands"
    echo
    
    echo -e "${BOLD}Scenario 4: Log Investigation${NC}"
    echo "Task: Find the MongoDB version from the logs"
    echo "Hint: Use kubectl logs and grep"
    echo
    
    echo -e "${BOLD}Scenario 5: Secret Exploration${NC}"
    echo "Task: Decode the MongoDB password from Kubernetes secret"
    echo "Hint: Use kubectl get secret with -o yaml and base64"
    echo
    
    echo "Try these scenarios on your own, then check the solutions!"
    echo
    echo -e "${YELLOW}Press Enter to see solution hints...${NC}"
    read -r
    
    echo -e "${BOLD}💡 SOLUTION HINTS:${NC}"
    echo
    echo "Scenario 1: kubectl exec \$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}') -- mongosh --eval 'show dbs'"
    echo
    echo "Scenario 2: kubectl scale deployment mongodb-express-deployment --replicas=3"
    echo "           kubectl get pods -w"
    echo "           kubectl scale deployment mongodb-express-deployment --replicas=1"
    echo
    echo "Scenario 3: kubectl exec \$(kubectl get pods -l app=mongodb-express -o jsonpath='{.items[0].metadata.name}') -- nc -z mongodb-service 27017"
    echo
    echo "Scenario 4: kubectl logs -l app=mongodb | grep -i version"
    echo
    echo "Scenario 5: kubectl get secret mongodb-secret -o jsonpath='{.data.mongodb-root-password}' | base64 --decode"
}

# Export functions for use in main menu
case "$1" in
    "basic_kubectl") basic_kubectl_tutorial ;;
    "explore") explore_resources ;;
    "deployments") deployment_operations ;;
    "services") service_management ;;
    "debugging") debugging_techniques ;;
    "scenarios") practice_scenarios ;;
esac
