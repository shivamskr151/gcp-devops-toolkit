# GCP DevOps/Infrastructure Architect IAM Setup

This repository contains scripts to grant DevOps/Infrastructure Architect permissions to developers in the GCP project `variphi`.

## Quick Start

### For New Setup (First Time)

If you're setting up for the first time and need to allow external domains (like gmail.com):

```bash
./setup-org-policy.sh wr.akashkumar@gmail.com
```

This script will:
1. Grant Organization Policy Administrator role (if needed)
2. Update organization-level policy to allow all domains
3. Update project-level policy to allow all domains
4. Grant DevOps permissions to the developer

### For Existing Setup (Policy Already Configured)

If the organization policy is already configured to allow external domains:

```bash
./grant-devops-role.sh wr.akashkumar@gmail.com
```

## Prerequisites

1. **GCP CLI (gcloud)** installed and authenticated
   ```bash
   gcloud auth login
   gcloud config set project variphi
   ```

2. **Required Roles:**
   - Organization Administrator (`roles/resourcemanager.organizationAdmin`) OR
   - Organization Policy Administrator (`roles/orgpolicy.policyAdmin`)
   - Project Owner (`roles/owner`) for the project

3. **For Terraform**: Terraform installed (>= 1.0)
   ```bash
   terraform version
   ```

4. **For Python script**: Python 3.6+ installed

## Scripts

### Service Account Creation

#### `create-service-account.sh` - Create Service Account with JSON Key

**Purpose:** Unified script to create service account with **76+ roles** and generate JSON key file.

**Usage:**
```bash
./create-service-account.sh
```

**Features:**
- **76+ roles** available
- **Quick presets** (1-11) for common roles
- **Browse mode** - See all roles organized by category
- **Direct input** - Enter role names or keys
- Custom display name and description
- Automatic JSON key generation

**Selection Methods:**

1. **Quick Presets** (1-11):
   ```bash
   Select: 1,3,5  # Storage, Container, BigQuery Admin
   ```

2. **Browse All Roles**:
   ```bash
   Select: browse  # Shows all 76+ roles by category
   ```

3. **Direct Role Input**:
   ```bash
   Select: roles/storage.admin,roles/compute.admin
   # Or: storage-admin,compute-admin
   ```

**Example:**
```bash
$ ./create-service-account.sh
Enter service account name: gcs-service-account
Select role(s): 1  # Or: browse, or: roles/storage.admin
# Creates: gcs-service-account-key.json
```

**Available Categories:**
- Storage (5 roles)
- Compute (5 roles)
- Kubernetes/GKE (3 roles)
- Database (4 roles)
- BigQuery (5 roles)
- Pub/Sub (4 roles)
- Cloud Functions (3 roles)
- Cloud Run (3 roles)
- IAM (5 roles)
- Monitoring & Logging (5 roles)
- Security (3 roles)
- Artifact Registry (3 roles)
- Cloud Build (2 roles)
- General (3 roles)

**See:** [SERVICE-ACCOUNT-README.md](SERVICE-ACCOUNT-README.md) for detailed documentation.

### IAM Permission Management

#### 1. `setup-org-policy.sh` - Complete Setup Script

**Purpose:** Fixes organization policy and grants permissions in one command.

**Usage:**
```bash
./setup-org-policy.sh <developer-email>
```

**Example:**
```bash
./setup-org-policy.sh wr.akashkumar@gmail.com
```

**What it does:**
- Grants Organization Policy Administrator role (if needed)
- Updates organization-level policy to allow all domains
- Updates project-level policy to allow all domains
- Grants all DevOps/Infrastructure Architect roles to the developer

**When to use:**
- First time setup
- When organization policy is blocking external domains
- When you want to do everything in one command

### 2. `grant-devops-role.sh` - Grant Permissions Only

**Purpose:** Grants DevOps/Infrastructure Architect roles to a developer.

**Usage:**
```bash
./grant-devops-role.sh <developer-email>
```

**Example:**
```bash
./grant-devops-role.sh wr.akashkumar@gmail.com
```

**What it does:**
- Grants 7 IAM roles for DevOps/Infrastructure Architect
- Provides detailed error messages if something fails
- Detects organization policy constraint issues

**When to use:**
- Organization policy is already configured
- You only need to grant permissions (not fix policy)
- Quick permission updates

### 3. `grant-devops-role.py` - Python Alternative

**Purpose:** Same as `grant-devops-role.sh` but written in Python.

**Usage:**
```bash
python3 grant-devops-role.py <developer-email>
```

### 4. `fix-via-terraform.sh` - Terraform Method

**Purpose:** Uses Terraform to manage organization policy (Infrastructure as Code).

**Usage:**
```bash
./fix-via-terraform.sh
```

**Note:** Requires Terraform to be installed and initialized.

## Roles Granted

The following IAM roles are granted to developers:

| Role | Purpose |
|------|---------|
| **Editor** (`roles/editor`) | Broad permissions for infrastructure management |
| **Compute Admin** (`roles/compute.admin`) | Manage compute resources (VMs, instances) |
| **Container Admin** (`roles/container.admin`) | Manage GKE/Kubernetes clusters |
| **Service Account User** (`roles/iam.serviceAccountUser`) | Use service accounts |
| **Storage Admin** (`roles/storage.admin`) | Manage Cloud Storage buckets |
| **Cloud SQL Admin** (`roles/cloudsql.admin`) | Manage Cloud SQL databases |
| **IAM Security Reviewer** (`roles/iam.securityReviewer`) | View IAM policies and permissions |

## Project Configuration

- **Project ID:** `variphi`
- **Organization ID:** `454153135806`
- **Organization:** `variphi.com`

## Understanding Organization Policies

### The Problem

GCP has an organization policy called `iam.allowedPolicyMemberDomains` that restricts which domains can be added as IAM members. By default, it may only allow your organization's domain.

### The Solution

The `setup-org-policy.sh` script sets the policy to allow **all domains** by setting:
```yaml
constraint: constraints/iam.allowedPolicyMemberDomains
listPolicy:
  allValues: ALLOW
```

**Important Notes:**
- This removes domain restrictions entirely (allows any domain)
- The policy accepts **customer IDs** (like `C00t18jqd`), not domain names
- Setting `allValues: ALLOW` is the simplest solution for allowing external users

### Policy Levels

- **Organization Level:** Applies to all projects in the organization
- **Project Level:** Overrides organization policy for a specific project

The script updates both levels to ensure consistency.

## Verification

### Check Current Policy

```bash
# Organization level
gcloud resource-manager org-policies describe iam.allowedPolicyMemberDomains \
    --organization=454153135806

# Project level
gcloud resource-manager org-policies describe iam.allowedPolicyMemberDomains \
    --project=variphi
```

### Verify Granted Permissions

```bash
gcloud projects get-iam-policy variphi \
    --flatten="bindings[].members" \
    --filter="bindings.members:user:wr.akashkumar@gmail.com" \
    --format="table(bindings.role)"
```

## Troubleshooting

### Error: "User is not in permitted organization"

**Cause:** Organization policy is blocking the domain.

**Solution:**
```bash
./setup-org-policy.sh <developer-email>
```

### Error: "Permission denied"

**Cause:** Missing required roles.

**Solution:** Ensure you have:
- Organization Administrator (`roles/resourcemanager.organizationAdmin`) OR
- Organization Policy Administrator (`roles/orgpolicy.policyAdmin`)

The `setup-org-policy.sh` script will grant the Organization Policy Administrator role automatically if you have Organization Administrator role.

### Error: "Policy update failed"

**Possible causes:**
1. Role hasn't propagated yet (wait 10-30 seconds)
2. Insufficient permissions
3. Policy is locked by another process

**Solution:** Wait a few seconds and try again, or use Google Cloud Console.

## Terraform Usage

For Infrastructure as Code approach:

```bash
cd terraform

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with developer email
# developer_email = "wr.akashkumar@gmail.com"

# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply
```

## Removing Permissions

### Using gcloud:

```bash
gcloud projects remove-iam-policy-binding variphi \
    --member="user:wr.akashkumar@gmail.com" \
    --role="roles/editor"
```

Repeat for each role.

### Using Terraform:

```bash
cd terraform
terraform destroy
```

## Security Considerations

- The `allValues: ALLOW` setting removes domain restrictions entirely
- Consider using more restrictive policies in production
- Regularly audit IAM permissions
- Use service accounts for applications instead of user accounts when possible

## Files Structure

```
gcp/
├── README.md                           # This file
├── SERVICE-ACCOUNT-README.md           # Service account creation guide
│
├── setup-org-policy.sh                 # Complete setup script (fixes policy + grants roles)
│
├── create-service-account.sh           # Create service account (76+ roles, unified)
│
└── terraform/
    ├── main.tf                          # Terraform IAM configuration
    └── terraform.tfvars.example         # Example variables
```

## Examples

### Example 1: First Time Setup

```bash
# Fix policy and grant permissions in one command
./setup-org-policy.sh wr.akashkumar@gmail.com
```

### Example 2: Grant Permissions to Multiple Developers

```bash
# Policy is already configured, just grant permissions
./grant-devops-role.sh developer1@example.com
./grant-devops-role.sh developer2@example.com
./grant-devops-role.sh developer3@example.com
```

### Example 3: Verify Setup

```bash
# Check policy
gcloud resource-manager org-policies describe iam.allowedPolicyMemberDomains \
    --organization=454153135806

# Check permissions
gcloud projects get-iam-policy variphi \
    --flatten="bindings[].members" \
    --filter="bindings.members:user:wr.akashkumar@gmail.com" \
    --format="table(bindings.role)"
```

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Verify you have the required roles
3. Check GCP Console for policy status
4. Review script error messages for specific guidance

## License

This repository contains utility scripts for GCP IAM management. Use at your own discretion and ensure compliance with your organization's security policies.
