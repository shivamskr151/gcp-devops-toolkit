# GCP DevOps Toolkit

> **Comprehensive Google Cloud Platform infrastructure automation toolkit with Terraform, IAM management, and DevOps automation scripts.**

[![Terraform](https://img.shields.io/badge/terraform-1.0+-blue.svg)](https://www.terraform.io/)
[![GCP](https://img.shields.io/badge/GCP-Google%20Cloud-orange.svg)](https://cloud.google.com/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A complete DevOps toolkit for managing GCP infrastructure, IAM permissions, service accounts, and Kubernetes clusters. This repository provides Infrastructure as Code (IaC) with Terraform, automated IAM role management, and utility scripts for common DevOps tasks.

## 📋 Table of Contents

- [Features](#-features)
- [Architecture](#-architecture)
- [Quick Start](#-quick-start)
- [Components](#-components)
  - [Infrastructure (Terraform)](#infrastructure-terraform)
  - [IAM Management](#iam-management)
  - [Service Account Creation](#service-account-creation)
  - [Node Management](#node-management)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Usage](#-usage)
- [Documentation](#-documentation)
- [Project Structure](#-project-structure)
- [Security](#-security)
- [Contributing](#-contributing)

## ✨ Features

### Infrastructure as Code
- **VPC Networks** with multi-subnet architecture (Public, Private, DB, Shared)
- **GKE Clusters** (Production & Staging) with configurable node pools
- **Google Artifact Registry** for container images
- **Cloud NAT** and routing configuration
- **Multi-region support** (Mumbai/Delhi - India regions)
- **Modular Terraform** architecture for maintainability

### IAM & Access Management
- **Automated IAM role assignment** for DevOps/Infrastructure Architect roles
- **Organization policy management** for domain restrictions
- **Service account creation** with 76+ predefined roles
- **Bulk permission management** scripts

### DevOps Automation
- **Node pool management** (start/stop GKE nodes)
- **Infrastructure lifecycle** scripts (apply/destroy)
- **Region switching** utilities
- **Service account key** generation and management

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    GCP Infrastructure                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  VPC Network (main-vpc)                                     │
│  ├── Public Subnet (10.0.1.0/24)                           │
│  │   └── Frontend Node Pool                                 │
│  │                                                           │
│  ├── Private Subnet (10.0.2.0/24)                           │
│  │   ├── Backend Node Pool                                  │
│  │   └── GKE Clusters                                       │
│  │       ├── Pods: 10.1.0.0/16                             │
│  │       └── Services: 10.2.0.0/20                         │
│  │                                                           │
│  ├── DB Subnet (10.0.3.0/24)                                │
│  │   └── CloudSQL / MongoDB / Redis                         │
│  │                                                           │
│  └── Shared Subnet (10.0.4.0/24)                            │
│      └── Monitoring / Logging / CI/CD Agents                │
│                                                             │
│  GKE Clusters:                                              │
│  ├── gke-prod (Production)                                  │
│  └── gke-staging (Staging)                                  │
│                                                             │
│  Artifact Registry:                                          │
│  ├── microservices                                          │
│  ├── microfrontend                                          │
│  └── cicd                                                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### 1. Prerequisites

- **GCP CLI (gcloud)** installed and authenticated
- **Terraform** >= 1.0
- **Python** 3.6+ (for Python scripts)
- **GCP Project** with billing enabled
- **Required GCP APIs** enabled (see below)

### 2. Initial Setup

```bash
# Clone the repository
git clone https://github.com/shivamskr151/gcp-devops-toolkit.git
cd gcp-devops-toolkit

# Authenticate with GCP
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  artifactregistry.googleapis.com \
  servicenetworking.googleapis.com \
  cloudresourcemanager.googleapis.com
```

### 3. Infrastructure Deployment

```bash
# Navigate to terraform directory
cd terraform

# Configure your settings
cp config.yaml config.yaml.backup
# Edit config.yaml with your project details

# Apply infrastructure
./apply.sh
```

### 4. IAM Setup (First Time)

```bash
# Grant DevOps permissions to a developer
cd scripts
./setup-org-policy.sh developer@example.com
```

## 📦 Components

### Infrastructure (Terraform)

Complete Infrastructure as Code setup for GCP resources.

**Location:** `terraform/`

**Features:**
- Modular Terraform architecture
- Multi-region support (Mumbai/Delhi)
- Production and Staging environments
- Automated resource lifecycle management

**Quick Commands:**
```bash
cd terraform

# Apply infrastructure
./apply.sh

# Destroy infrastructure
./destroy.sh

# Switch regions
./switch-region.sh mumbai  # or delhi
```

**Documentation:** See [terraform/README.md](terraform/README.md) for detailed documentation.

### IAM Management

Automated scripts for managing IAM permissions and organization policies.

**Location:** `scripts/`

#### Available Scripts:

1. **`setup-org-policy.sh`** - Complete setup (policy + permissions)
   ```bash
   ./scripts/setup-org-policy.sh developer@example.com
   ```

2. **`grant-devops-role.sh`** - Grant DevOps roles only
   ```bash
   ./scripts/grant-devops-role.sh developer@example.com
   ```

3. **`grant-devops-role.py`** - Python alternative
   ```bash
   python3 scripts/grant-devops-role.py developer@example.com
   ```

**Roles Granted:**
- `roles/editor` - Broad infrastructure management
- `roles/compute.admin` - Compute resources
- `roles/container.admin` - GKE/Kubernetes clusters
- `roles/iam.serviceAccountUser` - Service account usage
- `roles/storage.admin` - Cloud Storage
- `roles/cloudsql.admin` - Cloud SQL databases
- `roles/iam.securityReviewer` - IAM policy review

### Service Account Creation

Interactive script to create service accounts with 76+ predefined roles.

**Location:** `scripts/create-service-account.sh`

**Features:**
- 76+ predefined roles organized by category
- Quick presets (1-11) for common use cases
- Browse mode to explore all roles
- Direct role input support
- Automatic JSON key generation

**Usage:**
```bash
./scripts/create-service-account.sh
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

**Documentation:** See [scripts/SERVICE-ACCOUNT-README.md](scripts/SERVICE-ACCOUNT-README.md) for detailed guide.

### Node Management

Scripts for managing GKE node pools.

**Location:** `scripts/`

**Available Scripts:**
- `start-nodes.sh` - Start GKE node pools
- `stop-nodes.sh` - Stop GKE node pools

**Documentation:** See [scripts/NODE-MANAGEMENT.md](scripts/NODE-MANAGEMENT.md) for usage.

## 📋 Prerequisites

### Required Tools

- **gcloud CLI**: [Installation Guide](https://cloud.google.com/sdk/docs/install)
- **Terraform**: [Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- **Python 3.6+**: [Installation Guide](https://www.python.org/downloads/)

### Required GCP Permissions

For initial setup, you need:
- **Organization Administrator** (`roles/resourcemanager.organizationAdmin`) OR
- **Organization Policy Administrator** (`roles/orgpolicy.policyAdmin`)
- **Project Owner** (`roles/owner`) for the project

### Required GCP APIs

```bash
gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  artifactregistry.googleapis.com \
  servicenetworking.googleapis.com \
  cloudresourcemanager.googleapis.com \
  iam.googleapis.com
```

## 🔧 Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/shivamskr151/gcp-devops-toolkit.git
   cd gcp-devops-toolkit
   ```

2. **Make scripts executable:**
   ```bash
   chmod +x scripts/*.sh
   chmod +x terraform/*.sh
   ```

3. **Configure Terraform:**
   ```bash
   cd terraform
   # Edit config.yaml with your project details
   ```

4. **Set up service account (for Terraform):**
   ```bash
   # Create service account key and save as terraform-sa-key.json
   # Place it in the root directory
   ```

## 💻 Usage

### Infrastructure Management

```bash
# Apply all infrastructure
cd terraform
./apply.sh

# Apply specific components
terraform apply -target=module.vpc
terraform apply -target=module.gke_prod

# Destroy infrastructure
./destroy.sh
```

### IAM Management

```bash
# First time setup (fixes policy + grants roles)
./scripts/setup-org-policy.sh developer@example.com

# Grant roles only (policy already configured)
./scripts/grant-devops-role.sh developer@example.com
```

### Service Account Creation

```bash
# Interactive service account creation
./scripts/create-service-account.sh

# Follow prompts to select roles and create account
```

### Node Management

```bash
# Start GKE nodes
./scripts/start-nodes.sh

# Stop GKE nodes
./scripts/stop-nodes.sh
```

## 📚 Documentation

### Main Documentation
- **[README.md](README.md)** - This file (project overview)
- **[terraform/README.md](terraform/README.md)** - Infrastructure documentation
- **[scripts/SERVICE-ACCOUNT-README.md](scripts/SERVICE-ACCOUNT-README.md)** - Service account guide
- **[scripts/NODE-MANAGEMENT.md](scripts/NODE-MANAGEMENT.md)** - Node management guide

### Terraform Documentation
- **[terraform/STEP-BY-STEP-APPLY.md](terraform/STEP-BY-STEP-APPLY.md)** - Detailed apply guide
- **[terraform/REGIONS.md](terraform/REGIONS.md)** - Region configuration
- **[terraform/CIDR-ALLOCATION.md](terraform/CIDR-ALLOCATION.md)** - Network planning
- **[terraform/DESTRUCTION-GUIDE.md](terraform/DESTRUCTION-GUIDE.md)** - Safe destruction guide

### Scripts Documentation
- **[scripts/QUICK-START.md](scripts/QUICK-START.md)** - Quick start guide
- **[scripts/SERVICE-ACCOUNT-README.md](scripts/SERVICE-ACCOUNT-README.md)** - Service account details

## 📁 Project Structure

```
gcp-devops-toolkit/
├── README.md                          # Main project documentation
├── .gitignore                         # Git ignore rules
│
├── scripts/                            # Automation scripts
│   ├── create-service-account.sh      # Service account creation (76+ roles)
│   ├── setup-org-policy.sh            # Complete IAM setup
│   ├── grant-devops-role.sh           # Grant DevOps roles
│   ├── grant-devops-role.py           # Python alternative
│   ├── start-nodes.sh                 # Start GKE nodes
│   ├── stop-nodes.sh                  # Stop GKE nodes
│   ├── delete-vpc.sh                  # VPC deletion utility
│   ├── fix-service-account-key-policy.sh
│   ├── SERVICE-ACCOUNT-README.md      # Service account documentation
│   ├── NODE-MANAGEMENT.md             # Node management guide
│   └── QUICK-START.md                 # Quick start guide
│
├── terraform/                          # Infrastructure as Code
│   ├── config.yaml                     # Main configuration
│   ├── config-mumbai.yaml              # Mumbai region config
│   ├── config-delhi.yaml               # Delhi region config
│   ├── 01-vpc.tf                       # VPC configuration
│   ├── 02-gke.tf                       # GKE clusters
│   ├── 03-artifact-registry.tf         # Artifact Registry
│   ├── provider.tf                     # GCP provider config
│   ├── variables.tf                    # Terraform variables
│   ├── outputs.tf                      # Output values
│   ├── versions.tf                     # Version constraints
│   ├── apply.sh                        # Apply script
│   ├── destroy.sh                      # Destroy script
│   ├── switch-region.sh                # Region switcher
│   ├── README.md                       # Terraform documentation
│   ├── STEP-BY-STEP-APPLY.md          # Detailed guide
│   ├── REGIONS.md                      # Region documentation
│   ├── CIDR-ALLOCATION.md              # Network planning
│   ├── DESTRUCTION-GUIDE.md            # Destruction guide
│   └── modules/                        # Terraform modules
│       ├── vpc/                        # VPC module
│       ├── gke/                        # GKE module
│       ├── artifact-registry/          # Artifact Registry module
│       └── firewall/                   # Firewall rules module
│
└── results/                            # Documentation assets
    ├── organisation-roles.png
    ├── organisation.png
    └── project-roles.png
```

## 🔒 Security

### Important Security Notes

1. **Service Account Keys**: Never commit service account JSON keys to the repository. They are automatically excluded via `.gitignore`.

2. **Terraform State**: State files may contain sensitive information and are excluded from version control.

3. **Organization Policies**: The `setup-org-policy.sh` script sets `allValues: ALLOW` which removes domain restrictions. Consider more restrictive policies for production.

4. **IAM Permissions**: Regularly audit IAM permissions and follow the principle of least privilege.

5. **Secrets Management**: Use Google Secret Manager or similar services for sensitive configuration.

### Best Practices

- ✅ Use service accounts for applications instead of user accounts
- ✅ Regularly rotate service account keys
- ✅ Enable audit logging for IAM changes
- ✅ Use Terraform workspaces for environment separation
- ✅ Review and test changes in staging before production

## 🐛 Troubleshooting

### Common Issues

**Error: "User is not in permitted organization"**
- **Solution:** Run `./scripts/setup-org-policy.sh <email>` to fix organization policy

**Error: "Permission denied"**
- **Solution:** Verify you have required roles (Organization Admin or Policy Admin)

**Error: "API not enabled"**
- **Solution:** Enable required APIs using `gcloud services enable <api-name>`

**Terraform: "Resource already exists"**
- **Solution:** Use `terraform import` or destroy and recreate

**GKE: "Cluster creation timeout"**
- **Solution:** GKE clusters take 10-15 minutes. Check status with `gcloud container clusters describe`

For more troubleshooting, see:
- [terraform/README.md](terraform/README.md#troubleshooting)
- [scripts/QUICK-START.md](scripts/QUICK-START.md)

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This repository contains utility scripts and Terraform configurations for GCP infrastructure management. Use at your own discretion and ensure compliance with your organization's security policies.

## 🔗 Links

- **Repository:** https://github.com/shivamskr151/gcp-devops-toolkit
- **GCP Documentation:** https://cloud.google.com/docs
- **Terraform GCP Provider:** https://registry.terraform.io/providers/hashicorp/google/latest/docs

## 📧 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the detailed documentation in subdirectories
3. Verify GCP APIs are enabled
4. Check service account permissions
5. Review script error messages for specific guidance

---

**Made with ❤️ for GCP DevOps teams**
