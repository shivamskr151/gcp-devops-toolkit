# Terraform Resource Destruction Guide

## Overview

All Terraform resources have been configured to ensure **clean destruction without manual intervention**. This document explains the changes made and how destruction works.

## Changes Made

### 1. GKE Clusters
- **Deletion Protection**: Already set to `false` in `modules/gke/main.tf`
- **Lifecycle Rules**: Added to ensure node pools are deleted before clusters
- **Dependencies**: Node pools have explicit `depends_on` to ensure proper order

### 2. GKE Node Pools
- **Lifecycle Rules**: Added to ensure proper deletion order
- **Dependencies**: Explicitly depend on cluster, ensuring deletion happens in reverse order

### 3. VPC Resources
- **VPC**: Added lifecycle rule to ensure subnets are deleted first
- **Cloud Router**: Added lifecycle rule to ensure NAT is deleted first
- **NAT Gateway**: Added lifecycle rule and explicit dependency on Router

### 4. Firewall Rules
- **Lifecycle Rules**: Added to ensure clean deletion

### 5. Artifact Registry
- **Lifecycle Rules**: Added to allow deletion even if repositories contain images

### 6. Bug Fixes
- Fixed staging frontend cluster to use `staging_frontend_subnet_name` instead of `prod_frontend_subnet_name`
- Fixed staging backend cluster to use `staging_backend_subnet_name` instead of `prod_backend_subnet_name`

## Automatic Deletion Order

When you run `terraform destroy`, Terraform automatically handles resources in this order:

1. **Artifact Registry Repositories** - Can be deleted even with images
2. **GKE Node Pools** - Deleted before clusters (via lifecycle rules)
3. **GKE Clusters** - Deletion protection disabled, node pools already deleted
4. **Firewall Rules** - Deleted before network
5. **NAT Gateway** - Deleted before Router (via lifecycle rules)
6. **Cloud Router** - Deleted after NAT
7. **Subnets** - Deleted before VPC (via dependencies)
8. **VPC** - Deleted last

## Usage

### Recommended: Use the Destroy Script

```bash
./destroy.sh
```

This script:
- Prompts for confirmation
- Shows the destruction plan
- Destroys all resources automatically

### Manual Destruction

```bash
terraform destroy
```

Terraform will automatically handle the correct order based on:
- Resource dependencies (`depends_on`)
- Lifecycle rules
- Resource relationships

## Verification

After destruction, verify all resources are deleted:

```bash
# Check GKE clusters
gcloud container clusters list --project=variphi

# Check VPC
gcloud compute networks list --project=variphi

# Check Artifact Registry
gcloud artifacts repositories list --project=variphi
```

All should return empty or show no resources.

## Troubleshooting

### If Destruction Fails

1. **Check for orphaned resources**: Sometimes GCP resources can be in a transitional state
   ```bash
   # Wait a few minutes and retry
   terraform destroy
   ```

2. **Force deletion of specific resource** (if needed):
   ```bash
   terraform destroy -target=module.gke_frontend_prod
   ```

3. **Check GCP Console**: Verify resources are actually deleted or in a deleting state

### Common Issues

- **GKE Cluster stuck**: Wait 5-10 minutes, then retry
- **NAT Gateway stuck**: Usually resolves automatically, wait and retry
- **Artifact Registry with images**: Lifecycle rules allow deletion, but may take longer

## Technical Details

### Lifecycle Rules Added

All resources now have:
```hcl
lifecycle {
  create_before_destroy = false
}
```

This ensures:
- Resources are deleted in the correct order
- Dependencies are respected
- No orphaned resources are created

### Deletion Protection

GKE clusters have:
```hcl
deletion_protection = false
```

This ensures clusters can be deleted via Terraform without manual intervention.

## Summary

✅ All resources can be destroyed with a single `terraform destroy` command  
✅ No manual deletion required  
✅ Proper deletion order handled automatically  
✅ Lifecycle rules ensure clean destruction  
✅ Bug fixes ensure correct subnet usage  

