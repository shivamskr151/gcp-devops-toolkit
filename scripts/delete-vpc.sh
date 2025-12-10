#!/bin/bash

# Script to delete VPC and its dependencies in the correct order
# This handles the case where the router is blocking VPC deletion

set -e

PROJECT_ID="variphi"
REGION="asia-south2"
VPC_NAME="main-vpc"
ROUTER_NAME="main-router"
NAT_NAME="main-nat"

echo "=========================================="
echo "Deleting VPC: $VPC_NAME"
echo "=========================================="
echo ""
echo "⚠️  WARNING: This will delete the VPC and all its dependencies!"
echo ""

# Confirm deletion
read -p "Are you sure you want to delete $VPC_NAME? (yes/no): " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Deletion cancelled."
    exit 0
fi

echo ""
echo "Step 1: Deleting NAT Gateway ($NAT_NAME)..."
if gcloud compute routers nats describe "$NAT_NAME" --router="$ROUTER_NAME" --region="$REGION" --project="$PROJECT_ID" &>/dev/null; then
    gcloud compute routers nats delete "$NAT_NAME" \
        --router="$ROUTER_NAME" \
        --region="$REGION" \
        --project="$PROJECT_ID" \
        --quiet
    echo "✓ NAT Gateway deleted"
else
    echo "⚠ NAT Gateway not found (may already be deleted)"
fi

echo ""
echo "Step 2: Deleting Cloud Router ($ROUTER_NAME)..."
if gcloud compute routers describe "$ROUTER_NAME" --region="$REGION" --project="$PROJECT_ID" &>/dev/null; then
    gcloud compute routers delete "$ROUTER_NAME" \
        --region="$REGION" \
        --project="$PROJECT_ID" \
        --quiet
    echo "✓ Cloud Router deleted"
else
    echo "⚠ Cloud Router not found (may already be deleted)"
fi

echo ""
echo "Step 3: Checking for remaining dependencies..."
echo "Checking for firewall rules..."
FIREWALL_RULES=$(gcloud compute firewall-rules list --filter="network:${VPC_NAME}" --format="value(name)" --project="$PROJECT_ID" 2>/dev/null || echo "")

if [ -n "$FIREWALL_RULES" ]; then
    echo "Found firewall rules:"
    echo "$FIREWALL_RULES" | while read -r rule; do
        echo "  - $rule"
    done
    echo ""
    read -p "Delete these firewall rules? (yes/no): " -r
    echo
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "$FIREWALL_RULES" | while read -r rule; do
            echo "Deleting firewall rule: $rule"
            gcloud compute firewall-rules delete "$rule" --project="$PROJECT_ID" --quiet || true
        done
        echo "✓ Firewall rules deleted"
    fi
fi

echo ""
echo "Checking for subnets..."
SUBNETS=$(gcloud compute networks subnets list --network="$VPC_NAME" --format="value(name)" --project="$PROJECT_ID" 2>/dev/null || echo "")

if [ -n "$SUBNETS" ]; then
    echo "Found subnets:"
    echo "$SUBNETS" | while read -r subnet; do
        echo "  - $subnet"
    done
    echo ""
    read -p "Delete these subnets? (yes/no): " -r
    echo
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "$SUBNETS" | while read -r subnet; do
            REGION_FOR_SUBNET=$(gcloud compute networks subnets describe "$subnet" --format="value(region)" --project="$PROJECT_ID" 2>/dev/null || echo "$REGION")
            echo "Deleting subnet: $subnet (region: $REGION_FOR_SUBNET)"
            gcloud compute networks subnets delete "$subnet" --region="$REGION_FOR_SUBNET" --project="$PROJECT_ID" --quiet || true
        done
        echo "✓ Subnets deleted"
    fi
fi

echo ""
echo "Step 4: Deleting VPC ($VPC_NAME)..."
if gcloud compute networks describe "$VPC_NAME" --project="$PROJECT_ID" &>/dev/null; then
    gcloud compute networks delete "$VPC_NAME" \
        --project="$PROJECT_ID" \
        --quiet
    echo "✓ VPC deleted successfully"
else
    echo "⚠ VPC not found (may already be deleted)"
fi

echo ""
echo "=========================================="
echo "VPC deletion complete!"
echo "=========================================="


