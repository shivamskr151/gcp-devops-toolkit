#!/bin/bash

# Terraform Destroy Script for GCP Infrastructure
# This script destroys Terraform resources in the correct order to avoid dependency issues
# All resources are configured with proper lifecycle rules to ensure clean destruction

set -e

echo "=========================================="
echo "GCP Infrastructure Terraform Destroy"
echo "=========================================="
echo ""
echo "⚠️  WARNING: This will delete ALL infrastructure resources!"
echo ""

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Error: Terraform is not installed"
    exit 1
fi

# Check if config.yaml exists
if [ ! -f "config.yaml" ]; then
    echo "Error: config.yaml not found"
    exit 1
fi

# Confirm destruction
read -p "Are you sure you want to destroy ALL infrastructure? (yes/no): " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Destruction cancelled."
    exit 0
fi

echo ""
echo "Step 1: Initializing Terraform..."
terraform init

echo ""
echo "Step 2: Planning destruction..."
terraform plan -destroy

echo ""
read -p "Review the plan above. Continue with destruction? (yes/no): " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Destruction cancelled."
    exit 0
fi

echo ""
echo "=========================================="
echo "Destroying Infrastructure"
echo "=========================================="
echo ""
echo "Note: Terraform will automatically handle the correct deletion order:"
echo "  1. Artifact Registry repositories"
echo "  2. GKE Node Pools (automatically deleted before clusters)"
echo "  3. GKE Clusters"
echo "  4. Firewall Rules"
echo "  5. NAT Gateway (automatically deleted before Router)"
echo "  6. Cloud Router"
echo "  7. Subnets"
echo "  8. VPC"
echo ""

# Destroy everything - Terraform handles the order based on dependencies
echo "Destroying all resources..."
terraform destroy -auto-approve

echo ""
echo "=========================================="
echo "Infrastructure destruction complete!"
echo "=========================================="
echo ""
echo "All resources have been deleted."
echo ""

