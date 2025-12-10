# Quick Start Guide

## 🚀 Fastest Way to Deploy

```bash
cd terraform

# 1. Enable APIs (one-time)
gcloud config set project variphi
gcloud services enable compute.googleapis.com container.googleapis.com artifactregistry.googleapis.com

# 2. Initialize Terraform
terraform init

# 3. Validate Terraform
terraform validate


# 3. Terraform plan
terraform plan

# 4. Apply everything
terraform apply
```

## 📋 Step-by-Step (Recommended for First Time)

### Step 1: VPC Infrastructure
```bash
terraform apply -target=module.vpc -target=module.firewall
```
**Creates:**
- VPC: `main-vpc`
- 4 Subnets: public, private, db, shared
- Cloud Router & NAT
- Firewall rules

### Step 2: GKE Clusters
```bash
terraform apply -target=module.gke_prod -target=module.gke_staging
```
**Creates:**
- `gke-prod` cluster (3 nodes)
- `gke-staging` cluster (2 nodes)

**⏱️ Takes 10-15 minutes per cluster**

### Step 3: Artifact Registry
```bash
terraform apply -target=module.artifact_registry
```
**Creates:**
- 3 repositories: microservices, microfrontend, cicd

## ✅ Verify

```bash
# Check everything
gcloud compute networks list
gcloud container clusters list
gcloud artifacts repositories list
```

## 🔑 Get Cluster Access

```bash
gcloud container clusters get-credentials gke-prod --region=asia-south1
gcloud container clusters get-credentials gke-staging --region=asia-south1
```

## 📝 Configuration

### Region Selection
```bash
# Switch to Mumbai (default)
./switch-region.sh mumbai

# Switch to Delhi
./switch-region.sh delhi
```

### Customize Settings
Edit `config.yaml` to customize:
- CIDR ranges
- Node counts
- Machine types
- Repository names

## 🗑️ Cleanup

All resources are configured for clean destruction. No manual deletion required.

### Option 1: Using the Destroy Script (Recommended)

```bash
./destroy.sh
```

### Option 2: Manual Destruction

```bash
terraform destroy
```



