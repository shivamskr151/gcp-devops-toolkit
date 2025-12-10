# GCP Infrastructure Terraform Configuration

This directory contains Terraform configuration for setting up a complete GCP infrastructure in India region (asia-south1) including:

- **VPC** with 4 subnets (Public, Private, DB, Shared)
- **GKE Clusters** (Production and Staging)
- **Google Artifact Registry** (GAR)
- **Cloud NAT** and Routing

## Architecture

```
VPC (Single)
│
├── Public Subnet (10.0.1.0/24) - Frontend Node Pool
│
├── Private Subnet (10.0.2.0/24) - Backend Node Pool + GKE
│   ├── Pods Range: 10.1.0.0/16
│   └── Services Range: 10.2.0.0/20
│
├── Private DB Subnet (10.0.3.0/24) - CloudSQL / Mongo / Redis
│
└── Shared Subnet (10.0.4.0/24) - Monitoring, Logging, CI/CD Agents

GKE Clusters:
├── gke-prod (Production)
└── gke-staging (Staging)

Artifact Registry:
├── microservices
├── microfrontend
└── cicd
```

## Quick Start

### 1. Prerequisites

- Terraform >= 1.0
- GCP Project: `variphi`
- Service Account Key: `terraform-sa-key.json` in parent directory
- Required GCP APIs enabled (see below)

### 2. Enable GCP APIs

```bash
gcloud config set project variphi

gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  artifactregistry.googleapis.com \
  servicenetworking.googleapis.com \
  cloudresourcemanager.googleapis.com
```

### 3. Configure

Edit `config.yaml` to customize:
- Project ID
- Region/Zones
- CIDR ranges
- GKE cluster sizes
- Artifact Registry repositories

### 4. Apply Infrastructure

**Option A: Using the script (Recommended)**
```bash
cd terraform
./apply.sh
```

**Option B: Manual step-by-step**
```bash
cd terraform

# Initialize
terraform init

# Step 1: VPC
terraform apply -target=module.vpc -target=module.firewall

# Step 2: GKE Clusters
terraform apply -target=module.gke_prod -target=module.gke_staging

# Step 3: Artifact Registry
terraform apply -target=module.artifact_registry
```

**Option C: Apply everything at once**
```bash
terraform apply
```

## Directory Structure

```
terraform/
├── config.yaml                    # Main configuration (YAML)
├── versions.tf                     # Terraform version requirements
├── provider.tf                     # GCP provider configuration
├── 01-vpc.tf                       # VPC and networking
├── 02-gke.tf                       # GKE clusters
├── 03-artifact-registry.tf         # Artifact Registry
├── outputs.tf                      # Output values
├── apply.sh                        # Quick apply script
├── STEP-BY-STEP-APPLY.md          # Detailed guide
└── modules/
    ├── vpc/                        # VPC module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── gke/                        # GKE module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── artifact-registry/          # Artifact Registry module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── firewall/                   # Firewall rules module
        ├── main.tf
        └── variables.tf
```

## Region Selection

This setup supports two India regions:
- **Mumbai** (asia-south1) - Default
- **Delhi** (asia-south2)

### Switch Regions

```bash
# Switch to Mumbai
./switch-region.sh mumbai

# Switch to Delhi
./switch-region.sh delhi
```

See [REGIONS.md](REGIONS.md) for detailed region configuration guide.

## Configuration

All configuration is in `config.yaml`. Key sections:

### Project
```yaml
project:
  id: "variphi"
  region: "asia-south1"
```

### VPC
```yaml
vpc:
  name: "main-vpc"
  subnets:
    public: ...
    private: ...
    db: ...
    shared: ...
```

### GKE
```yaml
gke:
  clusters:
    prod: ...
    staging: ...
```

### Artifact Registry
```yaml
artifact_registry:
  repositories:
    - name: "microservices"
    - name: "microfrontend"
    - name: "cicd"
```

## Outputs

After applying, get outputs:

```bash
terraform output
```

Key outputs:
- `vpc_id` - VPC ID
- `gke_prod_cluster_name` - Production cluster name
- `gke_staging_cluster_name` - Staging cluster name
- `artifact_registry_repositories` - Repository URLs

## Get Cluster Credentials

```bash
# Production
gcloud container clusters get-credentials gke-prod \
  --region=asia-south1 \
  --project=variphi

# Staging
gcloud container clusters get-credentials gke-staging \
  --region=asia-south1 \
  --project=variphi
```

## Verify Infrastructure

```bash
# VPC
gcloud compute networks list

# Subnets
gcloud compute networks subnets list --network=main-vpc

# GKE Clusters
gcloud container clusters list

# Artifact Registry
gcloud artifacts repositories list
```

## Destroy Infrastructure

**Warning:** This will delete all resources!

All resources are configured with proper lifecycle rules to ensure clean destruction. Terraform will automatically handle the correct deletion order.

### Using the Destroy Script (Recommended)

```bash
./destroy.sh
```

### Manual Destruction

```bash
# Destroy everything - Terraform handles the order automatically
terraform destroy
```

**Deletion Order (automatic):**
1. Artifact Registry repositories
2. GKE Node Pools (deleted before clusters)
3. GKE Clusters
4. Firewall Rules
5. NAT Gateway (deleted before Router)
6. Cloud Router
7. Subnets
8. VPC

**All resources can be destroyed cleanly without manual intervention.**

## Destroy & Recreate

To destroy and recreate infrastructure in one workflow:

```bash
./destroy-and-recreate.sh
```

This will:
1. Destroy all resources
2. Wait for complete deletion
3. Recreate everything
4. Verify successful recreation

**See `DESTROY-AND-RECREATE.md` for complete workflow details.**

## Cost Estimation

Approximate monthly costs (India region):
- VPC: Free
- NAT Gateway: ~$45/month (per GB egress)
- GKE Prod (3 nodes, e2-standard-4): ~$150/month
- GKE Staging (2 nodes, e2-standard-2): ~$50/month
- Artifact Registry: ~$0.10/GB storage + egress

**Total estimated:** ~$250-300/month (excluding data transfer)

## Troubleshooting

### API Not Enabled
```bash
gcloud services enable <api-name>.googleapis.com
```

### Insufficient Permissions
- Verify service account has required roles
- Check `terraform-sa-key.json` is valid

### GKE Creation Timeout
- GKE clusters take 10-15 minutes to create
- Check status: `gcloud container clusters describe gke-prod --region=asia-south1`

### Resource Already Exists
- Use `terraform import` if needed
- Or destroy and recreate

## Next Steps

After infrastructure is created:

1. **Configure kubectl** for both clusters
2. **Set up CI/CD** pipelines to use Artifact Registry
3. **Deploy applications** to GKE clusters
4. **Configure monitoring** and logging
5. **Set up database** connections (CloudSQL, MongoDB, Redis)

## Documentation

- [STEP-BY-STEP-APPLY.md](STEP-BY-STEP-APPLY.md) - Detailed step-by-step guide
- [config.yaml](config.yaml) - Configuration reference

## Support

For issues:
1. Check the troubleshooting section
2. Verify GCP APIs are enabled
3. Check service account permissions
4. Review Terraform error messages

