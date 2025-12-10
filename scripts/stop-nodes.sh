#!/bin/bash

# Script to stop all GKE nodes (scale node pools to 0) to eliminate compute costs
# This will stop all nodes in both production and staging clusters

set -e

PROJECT_ID="variphi"
REGION="asia-south2"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Stopping All GKE Nodes ===${NC}"
echo ""
echo "This will scale all node pools to 0 nodes, eliminating compute costs."
echo "Cluster control planes will still incur minimal costs."
echo ""

# Confirm before proceeding
read -p "Are you sure you want to stop all nodes? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Operation cancelled."
    exit 0
fi

echo ""
echo -e "${YELLOW}Stopping PRODUCTION cluster nodes...${NC}"

# Production Backend Pool - Temporarily set min_nodes to 0, then scale to 0
echo "  - Updating autoscaling for gke-prod-backend-pool (min_nodes=0)..."
gcloud container node-pools update gke-prod-backend-pool \
    --cluster=gke-prod \
    --region=$REGION \
    --project=$PROJECT_ID \
    --min-nodes=0 \
    --quiet || echo "  ⚠️  Failed to update autoscaling"

echo "  - Scaling gke-prod-backend-pool to 0 nodes..."
gcloud container clusters resize gke-prod \
    --node-pool=gke-prod-backend-pool \
    --num-nodes=0 \
    --region=$REGION \
    --project=$PROJECT_ID \
    --quiet || echo "  ⚠️  Failed to scale backend pool"

# Production Frontend Pool - Temporarily set min_nodes to 0, then scale to 0
echo "  - Updating autoscaling for gke-prod-frontend-pool (min_nodes=0)..."
gcloud container node-pools update gke-prod-frontend-pool \
    --cluster=gke-prod \
    --region=$REGION \
    --project=$PROJECT_ID \
    --min-nodes=0 \
    --quiet || echo "  ⚠️  Failed to update autoscaling"

echo "  - Scaling gke-prod-frontend-pool to 0 nodes..."
gcloud container clusters resize gke-prod \
    --node-pool=gke-prod-frontend-pool \
    --num-nodes=0 \
    --region=$REGION \
    --project=$PROJECT_ID \
    --quiet || echo "  ⚠️  Failed to scale frontend pool"

echo ""
echo -e "${YELLOW}Stopping STAGING cluster nodes...${NC}"

# Staging Backend Pool - Temporarily set min_nodes to 0, then scale to 0
echo "  - Updating autoscaling for gke-staging-backend-pool (min_nodes=0)..."
gcloud container node-pools update gke-staging-backend-pool \
    --cluster=gke-staging \
    --region=$REGION \
    --project=$PROJECT_ID \
    --min-nodes=0 \
    --quiet || echo "  ⚠️  Failed to update autoscaling"

echo "  - Scaling gke-staging-backend-pool to 0 nodes..."
gcloud container clusters resize gke-staging \
    --node-pool=gke-staging-backend-pool \
    --num-nodes=0 \
    --region=$REGION \
    --project=$PROJECT_ID \
    --quiet || echo "  ⚠️  Failed to scale backend pool"

# Staging Frontend Pool - Temporarily set min_nodes to 0, then scale to 0
echo "  - Updating autoscaling for gke-staging-frontend-pool (min_nodes=0)..."
gcloud container node-pools update gke-staging-frontend-pool \
    --cluster=gke-staging \
    --region=$REGION \
    --project=$PROJECT_ID \
    --min-nodes=0 \
    --quiet || echo "  ⚠️  Failed to update autoscaling"

echo "  - Scaling gke-staging-frontend-pool to 0 nodes..."
gcloud container clusters resize gke-staging \
    --node-pool=gke-staging-frontend-pool \
    --num-nodes=0 \
    --region=$REGION \
    --project=$PROJECT_ID \
    --quiet || echo "  ⚠️  Failed to scale frontend pool"

echo ""
echo -e "${GREEN}✓ All node pools scaled to 0 nodes${NC}"
echo ""
echo "Waiting 10 seconds for nodes to stop..."
sleep 10

echo ""
echo -e "${GREEN}=== Node Status ===${NC}"
echo ""
echo "PRODUCTION:"
echo "  Backend Pool: $(gcloud compute instances list --project=$PROJECT_ID --filter="labels.goog-k8s-node-pool-name=gke-prod-backend-pool AND status:RUNNING" --format="value(name)" 2>/dev/null | wc -l | tr -d ' ') nodes running"
echo "  Frontend Pool: $(gcloud compute instances list --project=$PROJECT_ID --filter="labels.goog-k8s-node-pool-name=gke-prod-frontend-pool AND status:RUNNING" --format="value(name)" 2>/dev/null | wc -l | tr -d ' ') nodes running"
echo ""
echo "STAGING:"
echo "  Backend Pool: $(gcloud compute instances list --project=$PROJECT_ID --filter="labels.goog-k8s-node-pool-name=gke-staging-backend-pool AND status:RUNNING" --format="value(name)" 2>/dev/null | wc -l | tr -d ' ') nodes running"
echo "  Frontend Pool: $(gcloud compute instances list --project=$PROJECT_ID --filter="labels.goog-k8s-node-pool-name=gke-staging-frontend-pool AND status:RUNNING" --format="value(name)" 2>/dev/null | wc -l | tr -d ' ') nodes running"
echo ""
echo -e "${GREEN}All nodes stopped. Compute costs eliminated!${NC}"
echo ""
echo "Note: Cluster control planes are FREE, so total cost is now $0."
echo "To start nodes again, run: ./scripts/start-nodes.sh"

