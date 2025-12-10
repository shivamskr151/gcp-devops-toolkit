# Service Account Creation Script

Unified script to create GCP service accounts with specific roles and generate JSON key files.

## Quick Start

```bash
./create-service-account.sh
```

Interactive script with **76+ roles** available through multiple selection methods.

## Features

- ✅ Interactive role selection
- ✅ Predefined role sets (GCS, Compute, GKE, etc.)
- ✅ Custom role selection
- ✅ Automatic service account creation
- ✅ JSON key file generation
- ✅ Security warnings and best practices

## Quick Presets (1-11)

1. **Storage Admin** - `roles/storage.admin`
2. **Compute Admin** - `roles/compute.admin`
3. **Container Admin (GKE)** - `roles/container.admin`
4. **Cloud SQL Admin** - `roles/cloudsql.admin`
5. **BigQuery Admin** - `roles/bigquery.admin`
6. **Pub/Sub Admin** - `roles/pubsub.admin`
7. **Cloud Functions Admin** - `roles/cloudfunctions.admin`
8. **Cloud Run Admin** - `roles/run.admin`
9. **Service Account User** - `roles/iam.serviceAccountUser`
10. **Editor** - `roles/editor` (Broad permissions)
11. **Viewer** - `roles/viewer` (Read only)

## Browse All Roles

Type `browse` when prompted to see all **76+ roles** organized by category:

- **Storage** (5 roles)
- **Compute** (5 roles)
- **Kubernetes/GKE** (3 roles)
- **Database** (4 roles)
- **BigQuery** (5 roles)
- **Pub/Sub** (4 roles)
- **Cloud Functions** (3 roles)
- **Cloud Run** (3 roles)
- **IAM** (5 roles)
- **Monitoring & Logging** (5 roles)
- **Security** (3 roles)
- **Artifact Registry** (3 roles)
- **Cloud Build** (2 roles)
- **General** (3 roles)

## Usage Examples

### Example 1: Create Service Account for GCS Access

```bash
./create-service-account.sh
# Enter name: gcs-service-account
# Select: 1 (Storage Admin)
```

### Example 2: Create Service Account with Multiple Roles

```bash
./create-service-account.sh
# Enter name: devops-sa
# Select: 1,2,3 (Storage, Compute, Container Admin)
```

### Example 3: Browse All Roles

```bash
./create-service-account.sh
# Enter name: custom-sa
# Select: browse
# Choose from 76+ roles organized by category
```

### Example 4: Direct Role Names

```bash
./create-service-account.sh
# Enter name: custom-sa
# Select: roles/storage.admin,roles/bigquery.admin
# Or: storage-admin,bigquery-admin
```

## Advanced Script Features

The advanced script includes:

- **Comprehensive Role Catalog**: 30+ roles organized by category
- **Numbered Selection**: Select by number or role name
- **Custom Display Name**: Set custom display name
- **Description**: Add description to service account
- **Better Organization**: Roles grouped by service

### Role Categories (Advanced)

- **Storage**: Admin, Object Admin, Creator, Viewer
- **Compute**: Admin, Instance Admin, Network Admin
- **Kubernetes/GKE**: Admin, Cluster Admin, Developer
- **Database**: Cloud SQL Admin, Client
- **BigQuery**: Admin, Data Editor, Data Viewer
- **Pub/Sub**: Admin, Publisher, Subscriber
- **Cloud Functions**: Admin, Developer, Invoker
- **Cloud Run**: Admin, Invoker
- **IAM**: Service Account User, Service Account Admin
- **Monitoring & Logging**: Admin, Writer
- **Security**: Secret Manager Admin, Secret Accessor
- **General**: Editor, Viewer

## Output

Both scripts generate:

1. **Service Account** in GCP
2. **JSON Key File** (`<name>-key.json`)
3. **IAM Role Bindings** for selected roles

## Using the JSON Key

### Environment Variable
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
```

### gcloud CLI
```bash
gcloud auth activate-service-account --key-file="service-account-key.json"
```

### Terraform
```bash
export GOOGLE_APPLICATION_CREDENTIALS="service-account-key.json"
terraform plan
```

### Python
```python
from google.oauth2 import service_account
import google.auth

credentials = service_account.Credentials.from_service_account_file(
    'service-account-key.json'
)
```

## Security Best Practices

⚠️ **IMPORTANT:**

1. **Never commit JSON keys to version control**
   - Add `*-key.json` to `.gitignore`
   - Use secret management (Secret Manager, Vault, etc.)

2. **Store keys securely**
   - Use GCP Secret Manager
   - Encrypt at rest
   - Limit access

3. **Rotate keys regularly**
   - Delete old keys
   - Generate new ones
   - Update applications

4. **Use least privilege**
   - Grant only necessary roles
   - Review permissions regularly

5. **Monitor key usage**
   - Enable audit logs
   - Set up alerts

## Troubleshooting

### Error: "Service account already exists"
- The script will continue and grant roles to existing account
- Or delete the existing account first:
  ```bash
  gcloud iam service-accounts delete <email> --project=variphi
  ```

### Error: "Permission denied"
- Ensure you have `roles/iam.serviceAccountAdmin` or `roles/owner`
- Check project permissions

### Error: "Invalid role"
- Verify role name format: `roles/<service>.<permission>`
- Check role exists in GCP

## Selection Methods

The script supports **three ways** to select roles:

1. **Quick Presets** (1-11) - Common roles for quick selection
2. **Browse All** - Type `browse` to see all 76+ roles organized by category
3. **Direct Input** - Enter role names or keys directly

## Features

| Feature | Status |
|---------|--------|
| Total Roles Available | ✅ 76+ roles |
| Quick Presets | ✅ 11 common roles |
| Browse Mode | ✅ All roles by category |
| Custom Roles | ✅ Direct role name input |
| Display Name | ✅ Customizable |
| Description | ✅ Customizable |
| Role Categories | ✅ Organized by service |
| Ease of Use | ⭐⭐⭐⭐⭐ |

## Project Configuration

- **Project ID**: `variphi`
- **Organization ID**: `454153135806`

To change project, edit the `PROJECT_ID` variable in the script.

## Related Scripts

- `setup-org-policy.sh` - Fix organization policy
- `grant-devops-role.sh` - Grant roles to users

## Examples

### Create GCS Service Account
```bash
$ ./create-service-account.sh
Enter service account name: gcs-uploader
Select role(s): 1
# Creates: gcs-uploader-key.json
```

### Create Multi-Purpose Service Account
```bash
$ ./create-service-account.sh
Enter service account name: devops-automation
Select role(s): 1,2,3,4
# Grants: Storage, Compute, Container, Cloud SQL Admin
```

### Create Read-Only Service Account
```bash
$ ./create-service-account.sh
Enter service account name: monitoring-reader
Select role(s): 11
# Grants: Viewer role (read-only)
```

---

For more information, see [README.md](README.md)

