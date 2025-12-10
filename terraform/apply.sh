#!/bin/bash

# Terraform Apply Script for GCP Infrastructure
# This script applies Terraform configuration in the correct order

set -e

echo "=========================================="
echo "GCP Infrastructure Terraform Apply"
echo "=========================================="
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

# Check if service account key exists
if [ ! -f "../terraform-sa-key.json" ]; then
    echo "Error: terraform-sa-key.json not found in parent directory"
    exit 1
fi

echo "Step 1: Initializing Terraform..."
terraform init

echo ""
echo "Step 2: Validating configuration..."
terraform validate

echo ""
read -p "Do you want to apply Step 1 (VPC)? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Applying Step 1: VPC Infrastructure..."
    terraform apply -target=module.vpc -target=module.firewall
    echo "✓ VPC infrastructure created"
else
    echo "Skipping Step 1"
fi

echo ""
read -p "Do you want to apply Step 2 (GKE Clusters)? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Applying Step 2: GKE Clusters..."
    terraform apply -target=module.gke_prod -target=module.gke_staging
    echo "✓ GKE clusters created"
else
    echo "Skipping Step 2"
fi

echo ""
read -p "Do you want to apply Step 3 (Artifact Registry)? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Applying Step 3: Artifact Registry..."
    terraform apply -target=module.artifact_registry
    echo "✓ Artifact Registry created"
else
    echo "Skipping Step 3"
fi

echo ""
echo "=========================================="
echo "Infrastructure deployment complete!"
echo "=========================================="
echo ""
echo "To get cluster credentials:"
echo "  gcloud container clusters get-credentials gke-prod --region=asia-south2 --project=variphi"
echo "  gcloud container clusters get-credentials gke-staging --region=asia-south2 --project=variphi"
echo ""

