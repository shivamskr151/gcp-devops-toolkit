# Destroy and Recreate Guide

This guide explains how to safely destroy and recreate your entire infrastructure using Terraform.

## Overview

✅ **All resources are configured for clean destruction and recreation**  
✅ **No manual cleanup required**  
✅ **Idempotent configuration - can be applied multiple times**  
✅ **Proper resource ordering handled automatically**

## Complete Workflow: Destroy → Recreate

### Step 1: Destroy Infrastructure

```bash
cd terraform

# Option 1: Use the destroy script (recommended)
./destroy.sh

# Option 2: Manual destroy
terraform destroy
```

**What happens:**
- All resources are deleted in the correct order
- Terraform state is cleaned up
- No orphaned resources remain

**Verification after destroy:**
```bash
# Verify all resources are deleted
gcloud container clusters list --project=variphi
gcloud compute networks list --project=variphi
gcloud artifacts repositories list --project=variphi

# All should return empty or no resources
```

### Step 2: Wait for Complete Deletion (Important!)

Some GCP resources take time to fully delete:
- **GKE Clusters**: 5-10 minutes
- **NAT Gateway**: 2-5 minutes
- **VPC/Subnets**: Usually immediate, but wait 1-2 minutes to be safe

**Check deletion status:**
```bash
# Check if any resources are still deleting
gcloud container clusters list --project=variphi --filter="status:DEGRADED OR status:STOPPING"
gcloud compute operations list --project=variphi --filter="status:RUNNING"
```

### Step 3: Recreate Infrastructure

After destruction is complete, you can recreate everything:

```bash
# Option 1: Use the apply script (recommended)
./apply.sh

# Option 2: Apply everything at once
terraform init
terraform apply

# Option 3: Step-by-step apply
terraform apply -target=module.vpc -target=module.firewall
terraform apply -target=module.gke_prod -target=module.gke_staging
terraform apply -target=module.artifact_registry
```

**Recreation Order (automatic):**
1. VPC and Subnets
2. Cloud Router
3. NAT Gateway
4. Firewall Rules
5. GKE Clusters
6. GKE Node Pools
7. Artifact Registry Repositories

### Step 4: Verify Recreation

```bash
# Check VPC
gcloud compute networks list --project=variphi
gcloud compute networks subnets list --network=main-vpc --project=variphi

# Check GKE Clusters (wait for them to be RUNNING)
gcloud container clusters list --project=variphi

# Check Artifact Registry
gcloud artifacts repositories list --project=variphi

# Get cluster credentials
gcloud container clusters get-credentials gke-prod --region=asia-south2 --project=variphi
gcloud container clusters get-credentials gke-staging --region=asia-south2 --project=variphi
```

## Quick Destroy & Recreate Script

You can use this one-liner workflow:

```bash
cd terraform

# Destroy
terraform destroy -auto-approve

# Wait a few minutes for complete deletion
echo "Waiting 5 minutes for resources to fully delete..."
sleep 300

# Recreate
terraform init
terraform apply -auto-approve
```

## Important Notes

### 1. Terraform State

After `terraform destroy`, the Terraform state file (`.tfstate`) will be empty or removed. This is **normal and expected**. When you run `terraform apply` again, Terraform will:
- Initialize fresh state
- Create all resources from scratch
- Track them in the new state file

### 2. Resource Names

All resource names are defined in `config.yaml`:
- VPC: `main-vpc`
- Subnets: Defined in config (e.g., `prod-frontend-subnet`)
- GKE Clusters: Defined in config (e.g., `gke-prod`, `gke-staging`)
- Artifact Registry: Defined in config (e.g., `docker-images`)

**These names are consistent** - resources will be recreated with the same names.

### 3. Resource IDs

GCP assigns new resource IDs when recreating:
- VPC ID will be different (but name stays the same)
- Cluster endpoints will be different
- IP addresses may be different

This is **normal** - Terraform handles this automatically.

### 4. Data Loss

⚠️ **Warning**: Destroying infrastructure will delete:
- All data in GKE clusters (pods, services, deployments)
- All container images in Artifact Registry (if not backed up)
- All network configurations

**Backup important data before destroying!**

## Troubleshooting

### Issue: "Resource already exists" after destroy

**Cause**: Resource deletion is still in progress.

**Solution**:
```bash
# Wait a few more minutes
sleep 300

# Check deletion status
gcloud compute operations list --project=variphi --filter="status:RUNNING"

# Retry apply
terraform apply
```

### Issue: "API not enabled" during recreation

**Cause**: APIs might have been disabled or need re-enabling.

**Solution**:
```bash
gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  artifactregistry.googleapis.com \
  servicenetworking.googleapis.com \
  cloudresourcemanager.googleapis.com
```

### Issue: GKE cluster creation fails

**Cause**: Sometimes GKE needs the VPC to be fully ready.

**Solution**:
```bash
# Wait a bit longer, then retry
sleep 60
terraform apply -target=module.gke_frontend_prod
```

### Issue: NAT Gateway creation fails

**Cause**: Router might not be fully ready.

**Solution**:
```bash
# Apply VPC resources first, wait, then continue
terraform apply -target=module.vpc
sleep 30
terraform apply
```

## Best Practices

1. **Always verify destruction is complete** before recreating
2. **Use the scripts** (`destroy.sh` and `apply.sh`) for consistency
3. **Backup important data** before destroying
4. **Test in staging** before destroying production
5. **Monitor GCP Console** during destruction and recreation

## Example: Complete Destroy & Recreate

```bash
#!/bin/bash
set -e

cd terraform

echo "=== Step 1: Destroy Infrastructure ==="
terraform destroy -auto-approve

echo ""
echo "=== Step 2: Wait for Complete Deletion ==="
echo "Waiting 5 minutes for resources to fully delete..."
sleep 300

echo ""
echo "=== Step 3: Verify Deletion ==="
echo "Checking for remaining resources..."
gcloud container clusters list --project=variphi
gcloud compute networks list --project=variphi

echo ""
echo "=== Step 4: Recreate Infrastructure ==="
terraform init
terraform apply -auto-approve

echo ""
echo "=== Step 5: Verify Recreation ==="
echo "Checking created resources..."
gcloud container clusters list --project=variphi
gcloud compute networks list --project=variphi
gcloud artifacts repositories list --project=variphi

echo ""
echo "=== Complete! ==="
```

## Summary

✅ **Destroy**: `terraform destroy` or `./destroy.sh`  
✅ **Wait**: 5-10 minutes for complete deletion  
✅ **Recreate**: `terraform apply` or `./apply.sh`  
✅ **Verify**: Check resources are created successfully  

**The configuration is fully idempotent and can be destroyed and recreated as many times as needed.**

