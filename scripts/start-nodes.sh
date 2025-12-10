#!/bin/bash

# Script to start all GKE nodes (scale node pools back to minimum)
# This will restore nodes in both production and staging clusters

set -e

PROJECT_ID="variphi"
REGION="asia-south2"

# Node counts (minimum for cost savings)
PROD_BACKEND_NODES=1
PROD_FRONTEND_NODES=1
STAGING_BACKEND_NODES=1
STAGING_FRONTEND_NODES=1

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Starting All GKE Nodes ===${NC}"
echo ""
echo "This will scale all node pools back to minimum node count (1 node per pool)."
echo ""

# Confirm before proceeding
read -p "Are you sure you want to start all nodes? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Operation cancelled."
    exit 0
fi

echo ""
echo -e "${YELLOW}Starting PRODUCTION cluster nodes...${NC}"

# Production Backend Pool - Restore min_nodes to 1, then scale up
echo "  - Restoring autoscaling for gke-prod-backend-pool (min_nodes=1)..."
gcloud container node-pools update gke-prod-backend-pool \
    --cluster=gke-prod \
    --region=$REGION \
    --project=$PROJECT_ID \
    --min-nodes=1 \
    --quiet || echo "  ⚠️  Failed to update autoscaling"

echo "  - Scaling gke-prod-backend-pool to $PROD_BACKEND_NODES node(s)..."
gcloud container clusters resize gke-prod \
    --node-pool=gke-prod-backend-pool \
    --num-nodes=$PROD_BACKEND_NODES \
    --region=$REGION \
    --project=$PROJECT_ID \
    --quiet || echo "  ⚠️  Failed to scale backend pool"

# Production Frontend Pool - Restore min_nodes to 1, then scale up
echo "  - Restoring autoscaling for gke-prod-frontend-pool (min_nodes=1)..."
gcloud container node-pools update gke-prod-frontend-pool \
    --cluster=gke-prod \
    --region=$REGION \
    --project=$PROJECT_ID \
    --min-nodes=1 \
    --quiet || echo "  ⚠️  Failed to update autoscaling"

echo "  - Scaling gke-prod-frontend-pool to $PROD_FRONTEND_NODES node(s)..."
gcloud container clusters resize gke-prod \
    --node-pool=gke-prod-frontend-pool \
    --num-nodes=$PROD_FRONTEND_NODES \
    --region=$REGION \
    --project=$PROJECT_ID \
    --quiet || echo "  ⚠️  Failed to scale frontend pool"

echo ""
echo -e "${YELLOW}Starting STAGING cluster nodes...${NC}"

# Staging Backend Pool - Restore min_nodes to 1, then scale up
echo "  - Restoring autoscaling for gke-staging-backend-pool (min_nodes=1)..."
gcloud container node-pools update gke-staging-backend-pool \
    --cluster=gke-staging \
    --region=$REGION \
    --project=$PROJECT_ID \
    --min-nodes=1 \
    --quiet || echo "  ⚠️  Failed to update autoscaling"

echo "  - Scaling gke-staging-backend-pool to $STAGING_BACKEND_NODES node(s)..."
gcloud container clusters resize gke-staging \
    --node-pool=gke-staging-backend-pool \
    --num-nodes=$STAGING_BACKEND_NODES \
    --region=$REGION \
    --project=$PROJECT_ID \
    --quiet || echo "  ⚠️  Failed to scale backend pool"

# Staging Frontend Pool - Restore min_nodes to 1, then scale up
echo "  - Restoring autoscaling for gke-staging-frontend-pool (min_nodes=1)..."
gcloud container node-pools update gke-staging-frontend-pool \
    --cluster=gke-staging \
    --region=$REGION \
    --project=$PROJECT_ID \
    --min-nodes=1 \
    --quiet || echo "  ⚠️  Failed to update autoscaling"

echo "  - Scaling gke-staging-frontend-pool to $STAGING_FRONTEND_NODES node(s)..."
gcloud container clusters resize gke-staging \
    --node-pool=gke-staging-frontend-pool \
    --num-nodes=$STAGING_FRONTEND_NODES \
    --region=$REGION \
    --project=$PROJECT_ID \
    --quiet || echo "  ⚠️  Failed to scale frontend pool"

echo ""
echo -e "${GREEN}✓ All node pools scaling up${NC}"
echo ""
echo "Waiting 30 seconds for nodes to start..."
sleep 30

echo ""
echo -e "${GREEN}=== Node Status ===${NC}"
echo ""
echo "PRODUCTION:"
PROD_BACKEND_COUNT=$(gcloud compute instances list --project=$PROJECT_ID --filter="labels.goog-k8s-node-pool-name=gke-prod-backend-pool AND status:RUNNING" --format="value(name)" 2>/dev/null | wc -l | tr -d ' ')
PROD_FRONTEND_COUNT=$(gcloud compute instances list --project=$PROJECT_ID --filter="labels.goog-k8s-node-pool-name=gke-prod-frontend-pool AND status:RUNNING" --format="value(name)" 2>/dev/null | wc -l | tr -d ' ')
echo "  Backend Pool: $PROD_BACKEND_COUNT nodes running"
echo "  Frontend Pool: $PROD_FRONTEND_COUNT nodes running"
echo ""
echo "STAGING:"
STAGING_BACKEND_COUNT=$(gcloud compute instances list --project=$PROJECT_ID --filter="labels.goog-k8s-node-pool-name=gke-staging-backend-pool AND status:RUNNING" --format="value(name)" 2>/dev/null | wc -l | tr -d ' ')
STAGING_FRONTEND_COUNT=$(gcloud compute instances list --project=$PROJECT_ID --filter="labels.goog-k8s-node-pool-name=gke-staging-frontend-pool AND status:RUNNING" --format="value(name)" 2>/dev/null | wc -l | tr -d ' ')
echo "  Backend Pool: $STAGING_BACKEND_COUNT nodes running"
echo "  Frontend Pool: $STAGING_FRONTEND_COUNT nodes running"
echo ""
TOTAL_NODES=$((PROD_BACKEND_COUNT + PROD_FRONTEND_COUNT + STAGING_BACKEND_COUNT + STAGING_FRONTEND_COUNT))
echo -e "${GREEN}Total nodes running: $TOTAL_NODES${NC}"
echo ""
echo "Note: Nodes may take a few minutes to fully start and become ready."
echo "Check status with: kubectl get nodes"

