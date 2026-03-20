#!/bin/zsh

# Deployment script for the Enhanced Tools Dashboard

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
NAMESPACE="tools"
RELEASE_NAME="tools-dashboard"
CHART_PATH="$(dirname "$0")"
VALUES_FILE=""

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Deploy the Enhanced Tools Dashboard to Kubernetes"
    echo ""
    echo "Options:"
    echo "  -n, --namespace NAMESPACE    Kubernetes namespace (default: $NAMESPACE)"
    echo "  -r, --release NAME           Helm release name (default: $RELEASE_NAME)"
    echo "  -f, --values FILE            YAML values file for Helm"
    echo "  -c, --chart PATH             Path to Helm chart (default: $CHART_PATH)"
    echo "  -h, --help                   Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 
  Deploy with default settings"
    echo "  $0 -n tools -r my-dashboard 
  Deploy to 'tools' namespace with release name 'my-dashboard'"
    echo "  $0 -f custom-values.yaml 
  Deploy with custom values file"
}

# Function to log messages
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -r|--release)
            RELEASE_NAME="$2"
            shift 2
            ;;
        -f|--values)
            VALUES_FILE="$2"
            shift 2
            ;;
        -c|--chart)
            CHART_PATH="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate chart path
if [ ! -d "$CHART_PATH" ]; then
    error "Helm chart not found at path: $CHART_PATH"
    exit 1
fi

if [ ! -f "$CHART_PATH/Chart.yaml" ]; then
    error "Invalid Helm chart: Chart.yaml not found at $CHART_PATH"
    exit 1
fi

# Create namespace if it doesn't exist
log "Ensuring namespace '$NAMESPACE' exists..."
kubectl get namespace "$NAMESPACE" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    kubectl create namespace "$NAMESPACE"
    if [ $? -eq 0 ]; then
        success "Namespace '$NAMESPACE' created successfully"
    else
        error "Failed to create namespace '$NAMESPACE'"
        exit 1
    fi
else
    log "Namespace '$NAMESPACE' already exists"
fi

# Validate values file if specified
if [ ! -z "$VALUES_FILE" ] && [ ! -f "$VALUES_FILE" ]; then
    error "Values file not found: $VALUES_FILE"
    exit 1
fi

# Install or upgrade the Helm chart
log "Deploying Helm chart to namespace '$NAMESPACE'..."

HELM_CMD="helm upgrade --install $RELEASE_NAME $CHART_PATH \
  --namespace $NAMESPACE \
  --create-namespace"

# Add values file if specified
if [ ! -z "$VALUES_FILE" ]; then
    HELM_CMD="$HELM_CMD --values $VALUES_FILE"
fi

# Execute the command
echo -e "${YELLOW}Executing:${NC} $HELM_CMD"
eval $HELM_CMD

if [ $? -eq 0 ]; then
    success "Helm chart deployed successfully!"
    
    # Show instructions
    echo ""
    echo "=================================================="
    echo "${GREEN}Deployment successful!${NC}"
    echo ""
    echo "Access your dashboard at:"
    echo "https://dashboard.tools.example.com"
    echo ""
    echo "To customize the host, edit the values.yaml file"
    echo "or use the --set flag during installation."
    echo "=================================================="
else
    error "Helm chart deployment failed!"
    exit 1
fi

# Show status
log "Showing deployment status..."
kubectl get all -n "$NAMESPACE" | grep -E "(tools-dashboard|dashboard)"

success "Deployment script completed!"