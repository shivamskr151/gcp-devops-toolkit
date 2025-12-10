# Step-by-Step Terraform Apply Guide

This guide walks you through applying the Terraform configuration in the correct order for GCP infrastructure setup in India region.

## Prerequisites

1. **GCP Project**: Ensure you have a GCP project (`variphi` in this case)
2. **Terraform**: Install Terraform >= 1.0
   ```bash
   terraform version
   ```
3. **Service Account Key**: Ensure `terraform-sa-key.json` is in the parent directory
4. **GCP APIs**: Enable required APIs (see below)

## Step 0: Enable Required GCP APIs

Before running Terraform, enable the required APIs:

```bash
# Set your project
gcloud config set project variphi

# Enable required APIs
gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  artifactregistry.googleapis.com \
  servicenetworking.googleapis.com \
  cloudresourcemanager.googleapis.com
```

## Step 1: Initialize Terraform

Navigate to the terraform directory and initialize:

```bash
cd terraform
terraform init
```

This will:
- Download the Google provider plugin
- Download the yamldecode provider plugin
- Set up the backend (if configured)

## Step 2: Review Configuration

Review the `config.yaml` file to ensure all settings are correct:

```bash
cat config.yaml
```

Key things to verify:
- Project ID: `variphi`
- Region: `asia-south1` (Mumbai, India)
- VPC CIDR ranges don't overlap
- GKE cluster configurations

## Step 3: Validate Configuration

Validate the Terraform configuration:

```bash
terraform validate
```

## Step 4: Plan Step 1 - VPC Infrastructure

Plan the VPC creation first:

```bash
terraform plan -target=module.vpc -out=tfplan-vpc
```

Review the plan to ensure:
- VPC will be created
- 4 subnets (public, private, db, shared) will be created
- Cloud Router and NAT will be created
- Firewall rules will be created

## Step 5: Apply Step 1 - VPC Infrastructure

Apply the VPC infrastructure:

```bash
terraform apply tfplan-vpc
```

Or apply directly:

```bash
terraform apply -target=module.vpc -target=module.firewall
```

**Expected Output:**
- VPC: `main-vpc`
- Subnets: `public-subnet`, `private-subnet`, `db-subnet`, `shared-subnet`
- Cloud Router: `main-router`
- Cloud NAT: `main-nat`
- Firewall rules

**Wait Time:** ~2-5 minutes

## Step 6: Plan Step 2 - GKE Clusters

Plan the GKE clusters:

```bash
terraform plan -target=module.gke_prod -target=module.gke_staging -out=tfplan-gke
```

Review the plan to ensure:
- Two GKE clusters will be created (prod and staging)
- Node pools will be created
- Clusters will use the private subnet

## Step 7: Apply Step 2 - GKE Clusters

Apply the GKE clusters:

```bash
terraform apply tfplan-gke
```

Or apply directly:

```bash
terraform apply -target=module.gke_prod -target=module.gke_staging
```

**Expected Output:**
- GKE Cluster: `gke-prod` (3 nodes initially)
- GKE Cluster: `gke-staging` (2 nodes initially)
- Node pools for each cluster

**Wait Time:** ~10-15 minutes per cluster

**Note:** GKE cluster creation can take 10-15 minutes. Be patient!

## Step 8: Plan Step 3 - Artifact Registry

Plan the Artifact Registry:

```bash
terraform plan -target=module.artifact_registry -out=tfplan-gar
```

Review the plan to ensure:
- 3 repositories will be created (microservices, microfrontend, cicd)

## Step 9: Apply Step 3 - Artifact Registry

Apply the Artifact Registry:

```bash
terraform apply tfplan-gar
```

Or apply directly:

```bash
terraform apply -target=module.artifact_registry
```

**Expected Output:**
- Artifact Registry repositories:
  - `microservices`
  - `microfrontend`
  - `cicd`

**Wait Time:** ~1-2 minutes

## Step 10: Verify Complete Infrastructure

Verify all resources were created:

```bash
# Check VPC
gcloud compute networks list

# Check Subnets
gcloud compute networks subnets list --network=main-vpc

# Check GKE Clusters
gcloud container clusters list

# Check Artifact Registry
gcloud artifacts repositories list
```

## Step 11: Get Cluster Credentials

Get credentials for the GKE clusters:

```bash
# Production cluster
gcloud container clusters get-credentials gke-prod \
  --region=asia-south1 \
  --project=variphi

# Staging cluster
gcloud container clusters get-credentials gke-staging \
  --region=asia-south1 \
  --project=variphi
```

## Alternative: Apply Everything at Once

If you prefer to apply everything in one go (not recommended for first-time setup):

```bash
terraform plan -out=tfplan-all
terraform apply tfplan-all
```

**Note:** This will take ~20-30 minutes total.

## Troubleshooting

### Error: API not enabled
```bash
# Enable the specific API
gcloud services enable <api-name>.googleapis.com
```

### Error: Insufficient permissions
- Ensure the service account has the required roles
- Check `terraform-sa-key.json` is valid

### Error: Resource already exists
- Check if resources were partially created
- Use `terraform import` if needed
- Or destroy and recreate

### GKE cluster creation timeout
- GKE clusters can take 15-20 minutes
- Check cluster status: `gcloud container clusters describe gke-prod --region=asia-south1`
- Wait and retry if needed

## Destroying Infrastructure

All resources are configured with proper lifecycle rules to ensure clean destruction without manual intervention. Terraform will automatically handle the correct deletion order based on dependencies.

### Option 1: Using the Destroy Script (Recommended)

```bash
./destroy.sh
```

This script will:
- Prompt for confirmation
- Show the destruction plan
- Destroy all resources in the correct order automatically

### Option 2: Manual Destruction

You can destroy everything at once - Terraform handles the order:

```bash
terraform destroy
```

**Deletion Order (handled automatically):**
1. Artifact Registry repositories (lifecycle rules allow deletion even with images)
2. GKE Node Pools (automatically deleted before clusters via lifecycle rules)
3. GKE Clusters (deletion_protection = false, node pools deleted first)
4. Firewall Rules
5. NAT Gateway (automatically deleted before Router via lifecycle rules)
6. Cloud Router
7. Subnets
8. VPC

**Note:** All resources have been configured with:
- `deletion_protection = false` for GKE clusters
- Lifecycle rules to ensure proper deletion order
- Dependencies that ensure resources are deleted in the correct sequence

**No manual deletion is required** - Terraform will handle everything automatically.

## Next Steps

After infrastructure is created:

1. **Configure kubectl** for both clusters
2. **Set up CI/CD** pipelines to use Artifact Registry
3. **Deploy applications** to GKE clusters
4. **Configure monitoring** and logging
5. **Set up database** connections (CloudSQL, MongoDB, Redis)

## Configuration Files

- `config.yaml` - Main configuration file (modify this to change infrastructure)
- `01-vpc.tf` - VPC and networking resources
- `02-gke.tf` - GKE clusters
- `03-artifact-registry.tf` - Artifact Registry repositories

## Cost Estimation

Approximate monthly costs (India region):
- VPC: Free
- NAT Gateway: ~$45/month (per GB egress)
- GKE Prod (3 nodes, e2-standard-4): ~$150/month
- GKE Staging (2 nodes, e2-standard-2): ~$50/month
- Artifact Registry: ~$0.10/GB storage + egress

**Total estimated:** ~$250-300/month (excluding data transfer)

