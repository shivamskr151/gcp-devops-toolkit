# Region Configuration Guide

This Terraform setup supports two India regions:
- **Mumbai** (asia-south1) - Default
- **Delhi** (asia-south2)

## Quick Switch Between Regions

### Using the Script (Recommended)

```bash
# Switch to Mumbai
./switch-region.sh mumbai

# Switch to Delhi
./switch-region.sh delhi
```

### Manual Switch

```bash
# Switch to Mumbai
cp config-mumbai.yaml config.yaml

# Switch to Delhi
cp config-delhi.yaml config.yaml
```

## Region Details

### Mumbai (asia-south1)
- **Zones:**
  - asia-south1-a
  - asia-south1-b
  - asia-south1-c
- **Default Config:** `config-mumbai.yaml`

### Delhi (asia-south2)
- **Zones:**
  - asia-south2-a
  - asia-south2-b
  - asia-south2-c
- **Default Config:** `config-delhi.yaml`

## Configuration Files

- `config.yaml` - Active configuration (symlinked or copied from region-specific file)
- `config-mumbai.yaml` - Mumbai region configuration
- `config-delhi.yaml` - Delhi region configuration

## Verify Current Region

```bash
# Check current region
grep "region:" config.yaml

# Or use the switch script
./switch-region.sh
```

## Multi-Region Deployment

To deploy in both regions:

1. **Deploy to Mumbai:**
   ```bash
   ./switch-region.sh mumbai
   terraform workspace new mumbai
   terraform apply
   ```

2. **Deploy to Delhi:**
   ```bash
   ./switch-region.sh delhi
   terraform workspace new delhi
   terraform apply
   ```

## Region-Specific Considerations

### CIDR Ranges
Both regions use the same CIDR ranges (10.0.x.0/24). If deploying to both regions in the same project, you may want to adjust CIDR ranges to avoid conflicts if using VPC peering.

### Artifact Registry
Artifact Registry repositories are region-specific. Each region will have its own set of repositories.

### GKE Clusters
GKE clusters are region-specific. You'll have separate clusters in each region.

## Switching After Initial Deployment

⚠️ **Warning:** Switching regions after deployment will cause Terraform to try to recreate resources. Use Terraform workspaces for multi-region deployments instead.

```bash
# Use workspaces for multi-region
terraform workspace new mumbai
terraform apply

terraform workspace new delhi
terraform apply
```

