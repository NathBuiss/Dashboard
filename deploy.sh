#!/bin/bash

# Deployment script for the Tools Dashboard

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
NAMESPACE="tools"
RELEASE_NAME="tools-dashboard"
CHART_PATH="$(dirname "$0")"
VALUES_FILE=""

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Deploy the Tools Dashboard to Kubernetes"
    echo ""
    echo "Options:"
    echo "  -n, --namespace NAMESPACE    Kubernetes namespace (default: $NAMESPACE)"
    echo "  -r, --release NAME           Helm release name (default: $RELEASE_NAME)"
    echo "  -f, --values FILE            YAML values file for Helm"
    echo "  -c, --chart PATH             Path to Helm chart (default: $CHART_PATH)"
    echo "  -h, --help                   Show this help message"
}

log()     { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
error()   { printf "${RED}[ERROR]${NC} %s\n" "$1" >&2; }
success() { printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"; }

while [ "$#" -gt 0 ]; do
    case $1 in
        -n|--namespace) NAMESPACE="$2";   shift 2 ;;
        -r|--release)   RELEASE_NAME="$2"; shift 2 ;;
        -f|--values)    VALUES_FILE="$2"; shift 2 ;;
        -c|--chart)     CHART_PATH="$2";  shift 2 ;;
        -h|--help)      usage; exit 0 ;;
        *) error "Unknown option: $1"; usage; exit 1 ;;
    esac
done

# Validate chart path
if [ ! -d "$CHART_PATH" ] || [ ! -f "$CHART_PATH/Chart.yaml" ]; then
    error "Helm chart not found at: $CHART_PATH"
    exit 1
fi

# Ensure namespace exists
log "Ensuring namespace '$NAMESPACE' exists..."
if ! kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then
    if kubectl create namespace "$NAMESPACE"; then
        success "Namespace '$NAMESPACE' created"
    else
        error "Failed to create namespace '$NAMESPACE'"
        exit 1
    fi
else
    log "Namespace '$NAMESPACE' already exists"
fi

# Validate values file if specified
if [ -n "$VALUES_FILE" ] && [ ! -f "$VALUES_FILE" ]; then
    error "Values file not found: $VALUES_FILE"
    exit 1
fi

# Build helm command
log "Deploying Helm chart to namespace '$NAMESPACE'..."
HELM_CMD="helm upgrade --install $RELEASE_NAME $CHART_PATH --namespace $NAMESPACE --create-namespace"
if [ -n "$VALUES_FILE" ]; then
    HELM_CMD="$HELM_CMD --values $VALUES_FILE"
fi

printf "${YELLOW}Executing:${NC} %s\n" "$HELM_CMD"
eval "$HELM_CMD"

if [ $? -eq 0 ]; then
    success "Helm chart deployed successfully!"
    echo ""
    echo "=================================================="
    echo "Access your dashboard at:"
    echo "https://dashboard.tools.example.com"
    echo ""
    echo "To customize, edit values.yaml or use --set flags."
    echo "=================================================="
else
    error "Helm chart deployment failed!"
    exit 1
fi

log "Showing deployment status..."
kubectl get all -n "$NAMESPACE" | grep -E "(tools-dashboard|dashboard)"
success "Done!"
