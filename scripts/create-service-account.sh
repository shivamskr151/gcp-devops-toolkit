#!/bin/bash

# Unified script to create service account and generate JSON key file
# Compatible with bash 3.x (macOS default)
# Usage: ./create-service-account.sh

set -e

PROJECT_ID="variphi"
REGION="us-central1"

# Role mapping function (replaces associative arrays for bash 3.x compatibility)
get_role() {
    local key=$1
    case "$key" in
        # Quick presets
        "1"|"storage-admin") echo "roles/storage.admin" ;;
        "2"|"compute-admin") echo "roles/compute.admin" ;;
        "3"|"container-admin") echo "roles/container.admin" ;;
        "4"|"cloudsql-admin") echo "roles/cloudsql.admin" ;;
        "5"|"bigquery-admin") echo "roles/bigquery.admin" ;;
        "6"|"pubsub-admin") echo "roles/pubsub.admin" ;;
        "7"|"cloudfunctions-admin") echo "roles/cloudfunctions.admin" ;;
        "8"|"run-admin") echo "roles/run.admin" ;;
        "9"|"iam-service-account-user") echo "roles/iam.serviceAccountUser" ;;
        "10"|"editor") echo "roles/editor" ;;
        "11"|"viewer") echo "roles/viewer" ;;
        "12"|"artifactregistry-admin") echo "roles/artifactregistry.admin" ;;
        
        # Storage
        "storage-object-admin") echo "roles/storage.objectAdmin" ;;
        "storage-object-creator") echo "roles/storage.objectCreator" ;;
        "storage-object-viewer") echo "roles/storage.objectViewer" ;;
        "storage-bucket-admin") echo "roles/storage.buckets.admin" ;;
        
        # Compute
        "compute-instance-admin") echo "roles/compute.instanceAdmin" ;;
        "compute-instance-admin-v1") echo "roles/compute.instanceAdmin.v1" ;;
        "compute-network-admin") echo "roles/compute.networkAdmin" ;;
        "compute-security-admin") echo "roles/compute.securityAdmin" ;;
        "compute-storage-admin") echo "roles/compute.storageAdmin" ;;
        
        # Kubernetes/GKE
        "container-cluster-admin") echo "roles/container.clusterAdmin" ;;
        "container-developer") echo "roles/container.developer" ;;
        "container-service-agent") echo "roles/container.serviceAgent" ;;
        "container-host-service-agent-user") echo "roles/container.hostServiceAgentUser" ;;
        
        # Database
        "cloudsql-client") echo "roles/cloudsql.client" ;;
        "cloudsql-editor") echo "roles/cloudsql.editor" ;;
        "cloudsql-viewer") echo "roles/cloudsql.viewer" ;;
        
        # BigQuery
        "bigquery-data-editor") echo "roles/bigquery.dataEditor" ;;
        "bigquery-data-viewer") echo "roles/bigquery.dataViewer" ;;
        "bigquery-job-user") echo "roles/bigquery.jobUser" ;;
        "bigquery-user") echo "roles/bigquery.user" ;;
        
        # Pub/Sub
        "pubsub-editor") echo "roles/pubsub.editor" ;;
        "pubsub-publisher") echo "roles/pubsub.publisher" ;;
        "pubsub-subscriber") echo "roles/pubsub.subscriber" ;;
        "pubsub-viewer") echo "roles/pubsub.viewer" ;;
        "pubsub-service-agent") echo "roles/pubsub.serviceAgent" ;;
        
        # Cloud Functions
        "cloudfunctions-developer") echo "roles/cloudfunctions.developer" ;;
        "cloudfunctions-invoker") echo "roles/cloudfunctions.invoker" ;;
        "cloudfunctions-viewer") echo "roles/cloudfunctions.viewer" ;;
        
        # Cloud Run
        "run-invoker") echo "roles/run.invoker" ;;
        "run-developer") echo "roles/run.developer" ;;
        "run-viewer") echo "roles/run.viewer" ;;
        
        # IAM
        "iam-service-account-admin") echo "roles/iam.serviceAccountAdmin" ;;
        "iam-service-account-creator") echo "roles/iam.serviceAccountCreator" ;;
        "iam-service-account-deleter") echo "roles/iam.serviceAccountDeleter" ;;
        "iam-service-account-key-admin") echo "roles/iam.serviceAccountKeyAdmin" ;;
        
        # Monitoring & Logging
        "monitoring-admin") echo "roles/monitoring.admin" ;;
        "monitoring-editor") echo "roles/monitoring.editor" ;;
        "monitoring-viewer") echo "roles/monitoring.viewer" ;;
        "monitoring-metric-writer") echo "roles/monitoring.metricWriter" ;;
        "logging-admin") echo "roles/logging.admin" ;;
        "logging-config-writer") echo "roles/logging.configWriter" ;;
        "logging-writer") echo "roles/logging.logWriter" ;;
        "logging-viewer") echo "roles/logging.viewer" ;;
        "logging-private-log-viewer") echo "roles/logging.privateLogViewer" ;;
        
        # Security
        "secret-manager-admin") echo "roles/secretmanager.admin" ;;
        "secret-manager-secret-accessor") echo "roles/secretmanager.secretAccessor" ;;
        "secret-manager-viewer") echo "roles/secretmanager.viewer" ;;
        "cloudkms-admin") echo "roles/cloudkms.admin" ;;
        "cloudkms-crypto-key-encrypter") echo "roles/cloudkms.cryptoKeyEncrypter" ;;
        "cloudkms-crypto-key-decrypter") echo "roles/cloudkms.cryptoKeyDecrypter" ;;
        
        # Artifact Registry (GAR)
        "artifactregistry-admin") echo "roles/artifactregistry.admin" ;;
        "artifactregistry-reader") echo "roles/artifactregistry.reader" ;;
        "artifactregistry-writer") echo "roles/artifactregistry.writer" ;;
        "artifactregistry-repo-admin") echo "roles/artifactregistry.repoAdmin" ;;
        "artifactregistry-service-agent") echo "roles/artifactregistry.serviceAgent" ;;
        
        # Cloud Build
        "cloudbuild-builds-editor") echo "roles/cloudbuild.builds.editor" ;;
        "cloudbuild-builds-viewer") echo "roles/cloudbuild.builds.viewer" ;;
        "cloudbuild-service-account") echo "roles/cloudbuild.serviceAccount" ;;
        
        # Resource Manager
        "resourcemanager-project-creator") echo "roles/resourcemanager.projectCreator" ;;
        "resourcemanager-project-deleter") echo "roles/resourcemanager.projectDeleter" ;;
        "resourcemanager-project-iam-admin") echo "roles/resourcemanager.projectIamAdmin" ;;
        "resourcemanager-project-mover") echo "roles/resourcemanager.projectMover" ;;
        "resourcemanager-folder-admin") echo "roles/resourcemanager.folderAdmin" ;;
        "resourcemanager-folder-creator") echo "roles/resourcemanager.folderCreator" ;;
        "resourcemanager-organization-admin") echo "roles/resourcemanager.organizationAdmin" ;;
        "resourcemanager-organization-viewer") echo "roles/resourcemanager.organizationViewer" ;;
        
        # Service Networking
        "servicenetworking-service-agent") echo "roles/servicenetworking.serviceAgent" ;;
        "servicenetworking-service-consumer") echo "roles/servicenetworking.serviceConsumer" ;;
        
        # DNS
        "dns-admin") echo "roles/dns.admin" ;;
        "dns-reader") echo "roles/dns.reader" ;;
        "dns-peer") echo "roles/dns.peer" ;;
        
        # Load Balancing
        "compute-load-balancer-admin") echo "roles/compute.loadBalancerAdmin" ;;
        
        # Service Usage
        "serviceusage-service-consumer") echo "roles/serviceusage.serviceUsageConsumer" ;;
        "serviceusage-admin") echo "roles/serviceusage.serviceUsageAdmin" ;;
        
        # Billing
        "billing-admin") echo "roles/billing.admin" ;;
        "billing-account-creator") echo "roles/billing.creator" ;;
        "billing-account-viewer") echo "roles/billing.viewer" ;;
        "billing-account-costs-manager") echo "roles/billing.costsManager" ;;
        
        # Source Repository
        "source-repo-admin") echo "roles/source.admin" ;;
        "source-repo-writer") echo "roles/source.writer" ;;
        "source-repo-reader") echo "roles/source.reader" ;;
        
        # Cloud Scheduler
        "cloudscheduler-admin") echo "roles/cloudscheduler.admin" ;;
        "cloudscheduler-job-runner") echo "roles/cloudscheduler.jobRunner" ;;
        "cloudscheduler-viewer") echo "roles/cloudscheduler.viewer" ;;
        
        # Cloud Tasks
        "cloudtasks-admin") echo "roles/cloudtasks.admin" ;;
        "cloudtasks-enqueuer") echo "roles/cloudtasks.enqueuer" ;;
        "cloudtasks-viewer") echo "roles/cloudtasks.viewer" ;;
        
        # Additional IAM
        "iam-role-admin") echo "roles/iam.roleAdmin" ;;
        "iam-security-reviewer") echo "roles/iam.securityReviewer" ;;
        "iam-service-account-token-creator") echo "roles/iam.serviceAccountTokenCreator" ;;
        
        # Organization Policy
        "orgpolicy-policy-admin") echo "roles/orgpolicy.policyAdmin" ;;
        
        # API Gateway
        "apigateway-admin") echo "roles/apigateway.admin" ;;
        "apigateway-viewer") echo "roles/apigateway.viewer" ;;
        
        # General
        "owner") echo "roles/owner" ;;
        
        # If already a full role name, return as-is
        *) 
            if [[ "$key" == roles/* ]]; then
                echo "$key"
            else
                echo ""
            fi
            ;;
    esac
}

# Browse role mapping (number to key)
get_browse_key() {
    local num=$1
    case $num in
        1) echo "storage-admin" ;;
        2) echo "storage-object-admin" ;;
        3) echo "storage-object-creator" ;;
        4) echo "storage-object-viewer" ;;
        5) echo "storage-bucket-admin" ;;
        6) echo "compute-admin" ;;
        7) echo "compute-instance-admin" ;;
        8) echo "compute-network-admin" ;;
        9) echo "compute-security-admin" ;;
        10) echo "compute-storage-admin" ;;
        11) echo "container-admin" ;;
        12) echo "container-cluster-admin" ;;
        13) echo "container-developer" ;;
        14) echo "cloudsql-admin" ;;
        15) echo "cloudsql-client" ;;
        16) echo "cloudsql-editor" ;;
        17) echo "cloudsql-viewer" ;;
        18) echo "bigquery-admin" ;;
        19) echo "bigquery-data-editor" ;;
        20) echo "bigquery-data-viewer" ;;
        21) echo "bigquery-job-user" ;;
        22) echo "bigquery-user" ;;
        23) echo "pubsub-admin" ;;
        24) echo "pubsub-publisher" ;;
        25) echo "pubsub-subscriber" ;;
        26) echo "pubsub-viewer" ;;
        27) echo "cloudfunctions-admin" ;;
        28) echo "cloudfunctions-developer" ;;
        29) echo "cloudfunctions-invoker" ;;
        30) echo "run-admin" ;;
        31) echo "run-invoker" ;;
        32) echo "run-developer" ;;
        33) echo "iam-service-account-user" ;;
        34) echo "iam-service-account-admin" ;;
        35) echo "iam-service-account-creator" ;;
        36) echo "monitoring-admin" ;;
        37) echo "monitoring-viewer" ;;
        38) echo "logging-admin" ;;
        39) echo "logging-writer" ;;
        40) echo "logging-viewer" ;;
        41) echo "secret-manager-admin" ;;
        42) echo "secret-manager-secret-accessor" ;;
        43) echo "cloudkms-admin" ;;
        44) echo "artifactregistry-admin" ;;
        45) echo "artifactregistry-reader" ;;
        46) echo "artifactregistry-writer" ;;
        47) echo "artifactregistry-repo-admin" ;;
        48) echo "artifactregistry-service-agent" ;;
        49) echo "cloudbuild-builds-editor" ;;
        50) echo "cloudbuild-builds-viewer" ;;
        51) echo "resourcemanager-project-creator" ;;
        52) echo "resourcemanager-project-iam-admin" ;;
        53) echo "resourcemanager-folder-admin" ;;
        54) echo "resourcemanager-organization-admin" ;;
        55) echo "servicenetworking-service-agent" ;;
        56) echo "servicenetworking-service-consumer" ;;
        57) echo "dns-admin" ;;
        58) echo "dns-reader" ;;
        59) echo "compute-load-balancer-admin" ;;
        60) echo "serviceusage-service-consumer" ;;
        61) echo "serviceusage-admin" ;;
        62) echo "billing-admin" ;;
        63) echo "billing-viewer" ;;
        64) echo "source-repo-admin" ;;
        65) echo "source-repo-writer" ;;
        66) echo "cloudscheduler-admin" ;;
        67) echo "cloudtasks-admin" ;;
        68) echo "iam-role-admin" ;;
        69) echo "iam-security-reviewer" ;;
        70) echo "iam-service-account-token-creator" ;;
        71) echo "orgpolicy-policy-admin" ;;
        72) echo "editor" ;;
        73) echo "viewer" ;;
        74) echo "owner" ;;
        *) echo "" ;;
    esac
}

echo "=========================================="
echo "Create Service Account & Generate JSON Key"
echo "=========================================="
echo "Project: $PROJECT_ID"
echo ""

# Check current authentication
CURRENT_ACCOUNT=$(gcloud config get-value account 2>/dev/null || echo "")
CURRENT_ACCOUNT_TYPE="unknown"

if [ -n "$CURRENT_ACCOUNT" ]; then
    if echo "$CURRENT_ACCOUNT" | grep -q "@.*\.iam\.gserviceaccount\.com$"; then
        CURRENT_ACCOUNT_TYPE="service_account"
        echo "⚠️  WARNING: Currently authenticated as service account:"
        echo "   $CURRENT_ACCOUNT"
        echo ""
        echo "Service accounts typically don't have permission to create other"
        echo "service accounts. You may need to authenticate with a user account."
        echo ""
        read -p "Continue anyway? (y/N): " CONTINUE_ANYWAY
        if [[ ! "$CONTINUE_ANYWAY" =~ ^[Yy]$ ]]; then
            echo ""
            echo "To authenticate with a user account, run:"
            echo "  gcloud auth login"
            echo ""
            echo "To switch accounts, run:"
            echo "  gcloud auth login --update-adc"
            echo ""
            exit 0
        fi
        echo ""
    else
        CURRENT_ACCOUNT_TYPE="user"
        echo "Authenticated as: $CURRENT_ACCOUNT"
        echo ""
    fi
else
    echo "⚠️  No active authentication found."
    echo "Please authenticate first:"
    echo "  gcloud auth login"
    echo ""
    exit 1
fi

# Set project
gcloud config set project $PROJECT_ID &>/dev/null

# Get service account details
echo "Service Account Configuration:"
echo ""
read -p "Service account name (lowercase, alphanumeric, hyphens): " SA_NAME
read -p "Display name (optional, press Enter for auto-generated): " SA_DISPLAY_NAME
read -p "Description (optional, press Enter for default): " SA_DESCRIPTION

if [ -z "$SA_NAME" ]; then
    echo "Error: Service account name is required"
    exit 1
fi

# Sanitize name
SA_NAME=$(echo "$SA_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

if [ -z "$SA_DISPLAY_NAME" ]; then
    SA_DISPLAY_NAME=$(echo "$SA_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
fi

if [ -z "$SA_DESCRIPTION" ]; then
    SA_DESCRIPTION="Service account created via script"
fi

echo ""
echo "Service account details:"
echo "  Name: $SA_NAME"
echo "  Email: $SA_EMAIL"
echo "  Display Name: $SA_DISPLAY_NAME"
echo "  Description: $SA_DESCRIPTION"
echo ""

# Role selection menu
echo "=========================================="
echo "Role Selection"
echo "=========================================="
echo ""
echo "QUICK PRESETS (enter numbers, comma-separated):"
echo "  [1]  Storage Admin (GCS)"
echo "  [2]  Compute Admin"
echo "  [3]  Container Admin (GKE)"
echo "  [4]  Cloud SQL Admin"
echo "  [5]  BigQuery Admin"
echo "  [6]  Pub/Sub Admin"
echo "  [7]  Cloud Functions Admin"
echo "  [8]  Cloud Run Admin"
echo "  [9]  Service Account User"
echo "  [10] Editor (Broad Permissions)"
echo "  [11] Viewer (Read Only)"
echo "  [12] Artifact Registry Admin (GAR)"
echo ""
echo "OR browse all roles by category:"
echo "  [browse] - Show all available roles"
echo ""
echo "OR enter role names directly:"
echo "  Example: roles/storage.admin,roles/compute.admin"
echo "  Or: storage-admin,compute-admin"
echo ""
read -p "Enter selection: " SELECTION

if [ -z "$SELECTION" ]; then
    echo "Error: At least one role must be selected"
    exit 1
fi

SELECTED_ROLES=""
BROWSE_MODE=false

# Handle browse option
if [ "$SELECTION" = "browse" ] || [ "$SELECTION" = "BROWSE" ]; then
    BROWSE_MODE=true
    echo ""
    echo "=========================================="
    echo "All Available Roles by Category"
    echo "=========================================="
    echo ""
    echo "STORAGE:"
    echo "  1) storage-admin"
    echo "  2) storage-object-admin"
    echo "  3) storage-object-creator"
    echo "  4) storage-object-viewer"
    echo "  5) storage-bucket-admin"
    echo ""
    echo "COMPUTE:"
    echo "  6) compute-admin"
    echo "  7) compute-instance-admin"
    echo "  8) compute-network-admin"
    echo "  9) compute-security-admin"
    echo "  10) compute-storage-admin"
    echo ""
    echo "KUBERNETES/GKE:"
    echo "  11) container-admin"
    echo "  12) container-cluster-admin"
    echo "  13) container-developer"
    echo ""
    echo "DATABASE:"
    echo "  14) cloudsql-admin"
    echo "  15) cloudsql-client"
    echo "  16) cloudsql-editor"
    echo "  17) cloudsql-viewer"
    echo ""
    echo "BIGQUERY:"
    echo "  18) bigquery-admin"
    echo "  19) bigquery-data-editor"
    echo "  20) bigquery-data-viewer"
    echo "  21) bigquery-job-user"
    echo "  22) bigquery-user"
    echo ""
    echo "PUB/SUB:"
    echo "  23) pubsub-admin"
    echo "  24) pubsub-publisher"
    echo "  25) pubsub-subscriber"
    echo "  26) pubsub-viewer"
    echo ""
    echo "CLOUD FUNCTIONS:"
    echo "  27) cloudfunctions-admin"
    echo "  28) cloudfunctions-developer"
    echo "  29) cloudfunctions-invoker"
    echo ""
    echo "CLOUD RUN:"
    echo "  30) run-admin"
    echo "  31) run-invoker"
    echo "  32) run-developer"
    echo ""
    echo "IAM:"
    echo "  33) iam-service-account-user"
    echo "  34) iam-service-account-admin"
    echo "  35) iam-service-account-creator"
    echo ""
    echo "MONITORING & LOGGING:"
    echo "  36) monitoring-admin"
    echo "  37) monitoring-viewer"
    echo "  38) logging-admin"
    echo "  39) logging-writer"
    echo "  40) logging-viewer"
    echo ""
    echo "SECURITY:"
    echo "  41) secret-manager-admin"
    echo "  42) secret-manager-secret-accessor"
    echo "  43) cloudkms-admin"
    echo ""
    echo "ARTIFACT REGISTRY (GAR):"
    echo "  44) artifactregistry-admin"
    echo "  45) artifactregistry-reader"
    echo "  46) artifactregistry-writer"
    echo "  47) artifactregistry-repo-admin"
    echo "  48) artifactregistry-service-agent"
    echo ""
    echo "CLOUD BUILD:"
    echo "  49) cloudbuild-builds-editor"
    echo "  50) cloudbuild-builds-viewer"
    echo ""
    echo "RESOURCE MANAGER:"
    echo "  51) resourcemanager-project-creator"
    echo "  52) resourcemanager-project-iam-admin"
    echo "  53) resourcemanager-folder-admin"
    echo "  54) resourcemanager-organization-admin"
    echo ""
    echo "SERVICE NETWORKING:"
    echo "  55) servicenetworking-service-agent"
    echo "  56) servicenetworking-service-consumer"
    echo ""
    echo "DNS:"
    echo "  57) dns-admin"
    echo "  58) dns-reader"
    echo ""
    echo "LOAD BALANCING:"
    echo "  59) compute-load-balancer-admin"
    echo ""
    echo "SERVICE USAGE:"
    echo "  60) serviceusage-service-consumer"
    echo "  61) serviceusage-admin"
    echo ""
    echo "BILLING:"
    echo "  62) billing-admin"
    echo "  63) billing-viewer"
    echo ""
    echo "SOURCE REPOSITORY:"
    echo "  64) source-repo-admin"
    echo "  65) source-repo-writer"
    echo ""
    echo "CLOUD SCHEDULER:"
    echo "  66) cloudscheduler-admin"
    echo ""
    echo "CLOUD TASKS:"
    echo "  67) cloudtasks-admin"
    echo ""
    echo "IAM (Additional):"
    echo "  68) iam-role-admin"
    echo "  69) iam-security-reviewer"
    echo "  70) iam-service-account-token-creator"
    echo ""
    echo "ORGANIZATION POLICY:"
    echo "  71) orgpolicy-policy-admin"
    echo ""
    echo "GENERAL:"
    echo "  72) editor"
    echo "  73) viewer"
    echo "  74) owner"
    echo ""
    echo "Or enter role keys directly (comma-separated):"
    echo "  Example: storage-admin,compute-admin,container-admin"
    echo ""
    read -p "Enter selection: " BROWSE_SELECTION
    
    SELECTION="$BROWSE_SELECTION"
fi

# Parse selection
OLD_IFS=$IFS
IFS=','
for sel in $SELECTION; do
    sel=$(echo "$sel" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//') # trim
    
    # If in browse mode, treat all numbers as browse numbers
    if [ "$BROWSE_MODE" = true ]; then
        if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$sel" -ge 1 ] && [ "$sel" -le 74 ]; then
            role_key=$(get_browse_key "$sel")
            if [ -n "$role_key" ]; then
                role=$(get_role "$role_key")
                if [ -n "$role" ]; then
                    SELECTED_ROLES="${SELECTED_ROLES}${role} "
                fi
            fi
        else
            # Try to get role directly (role name or key)
            role=$(get_role "$sel")
            if [ -n "$role" ]; then
                SELECTED_ROLES="${SELECTED_ROLES}${role} "
            else
                echo "Warning: Unknown role '$sel', skipping"
            fi
        fi
    else
        # Not in browse mode - check quick presets first
        if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$sel" -ge 1 ] && [ "$sel" -le 12 ]; then
            role=$(get_role "$sel")
            if [ -n "$role" ]; then
                SELECTED_ROLES="${SELECTED_ROLES}${role} "
            fi
        else
            # Try to get role directly (role name or key)
            role=$(get_role "$sel")
            if [ -n "$role" ]; then
                SELECTED_ROLES="${SELECTED_ROLES}${role} "
            else
                echo "Warning: Unknown role '$sel', skipping"
            fi
        fi
    fi
done
IFS=$OLD_IFS

# Remove duplicates and trim
SELECTED_ROLES=$(echo "$SELECTED_ROLES" | tr ' ' '\n' | sort -u | tr '\n' ' ' | sed 's/[[:space:]]*$//')

if [ -z "$SELECTED_ROLES" ]; then
    echo "Error: No valid roles selected"
    exit 1
fi

# Count roles
ROLE_COUNT=$(echo "$SELECTED_ROLES" | wc -w | tr -d ' ')

echo ""
echo "Selected roles ($ROLE_COUNT):"
for role in $SELECTED_ROLES; do
    echo "  - $role"
done
echo ""

read -p "Continue? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# Create service account
echo ""
echo "Creating service account..."
CREATE_OUTPUT=$(gcloud iam service-accounts create "$SA_NAME" \
    --display-name="$SA_DISPLAY_NAME" \
    --description="$SA_DESCRIPTION" \
    --project="$PROJECT_ID" 2>&1)
CREATE_EXIT_CODE=$?

if [ $CREATE_EXIT_CODE -eq 0 ]; then
    echo "✓ Service account created"
else
    # Check if already exists
    if gcloud iam service-accounts describe "$SA_EMAIL" --project="$PROJECT_ID" &>/dev/null; then
        echo "⚠ Service account already exists, continuing..."
    else
        echo "✗ Failed to create service account"
        echo ""
        echo "Error details:"
        echo "$CREATE_OUTPUT" | head -10
        echo ""
        
        # Check for permission errors
        if echo "$CREATE_OUTPUT" | grep -qi "permission.*denied\|IAM_PERMISSION_DENIED\|does not have permission"; then
            echo "=========================================="
            echo "Permission Error Detected"
            echo "=========================================="
            echo ""
            echo "The current account doesn't have permission to create service accounts."
            echo ""
            echo "Current account: $CURRENT_ACCOUNT"
            echo ""
            
            if [ "$CURRENT_ACCOUNT_TYPE" = "service_account" ]; then
                echo "You're authenticated as a service account, which typically cannot"
                echo "create other service accounts."
                echo ""
                echo "Solution: Authenticate with a user account that has the"
                echo "required permissions (e.g., Service Account Admin or Editor role)."
                echo ""
                echo "To fix this:"
                echo ""
                echo "1. Authenticate with a user account:"
                echo "   gcloud auth login"
                echo ""
                echo "2. Verify you have the required role:"
                echo "   gcloud projects get-iam-policy $PROJECT_ID \\"
                echo "     --flatten='bindings[].members' \\"
                echo "     --filter='bindings.members:user:YOUR_EMAIL' \\"
                echo "     --format='table(bindings.role)'"
                echo ""
                echo "3. Required roles include:"
                echo "   - roles/iam.serviceAccountAdmin"
                echo "   - roles/iam.serviceAccountCreator"
                echo "   - roles/editor (broad permissions)"
                echo "   - roles/owner (full access)"
                echo ""
            else
                echo "Solution: Grant your user account the required permissions:"
                echo ""
                echo "Required roles:"
                echo "  - roles/iam.serviceAccountAdmin"
                echo "  - roles/iam.serviceAccountCreator"
                echo "  - OR roles/editor (includes service account creation)"
                echo ""
                echo "Ask your project admin to grant you one of these roles."
                echo ""
            fi
            echo "After fixing permissions, re-run this script."
            echo ""
        fi
        
        exit 1
    fi
fi

# Grant roles
echo ""
echo "Granting roles..."
SUCCESS_COUNT=0
FAIL_COUNT=0

for role in $SELECTED_ROLES; do
    echo -n "  Granting $role... "
    if gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:$SA_EMAIL" \
        --role="$role" \
        --condition=None \
        --quiet 2>&1; then
        echo "✓"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo "✗ (may already be granted)"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
done

# Generate JSON key
echo ""
echo "Generating JSON key file..."
KEY_FILE="${SA_NAME}-key.json"

KEY_OUTPUT=$(gcloud iam service-accounts keys create "$KEY_FILE" \
    --iam-account="$SA_EMAIL" \
    --project="$PROJECT_ID" 2>&1)
KEY_EXIT_CODE=$?

if [ $KEY_EXIT_CODE -eq 0 ]; then
    echo "✓ JSON key file created: $KEY_FILE"
    KEY_CREATED=true
else
    # Check if it's the organization policy blocking key creation
    if echo "$KEY_OUTPUT" | grep -q "disableServiceAccountKeyCreation"; then
        echo "⚠ Key creation blocked by organization policy"
        echo ""
        echo "=========================================="
        echo "Organization Policy Constraint Detected"
        echo "=========================================="
        echo ""
        echo "The organization policy 'iam.disableServiceAccountKeyCreation' is"
        echo "preventing service account key creation."
        echo ""
        echo "Options:"
        echo ""
        echo "1. Update the organization policy (requires Organization Policy Admin):"
        echo "   Run: ./fix-service-account-key-policy.sh"
        echo "   Note: After running the fix script, wait 10-30 seconds for policy"
        echo "         propagation, then re-run this script or create the key manually."
        echo ""
        echo "2. Use Workload Identity (for GKE/Kubernetes):"
        echo "   This is the recommended approach for GKE workloads"
        echo ""
        echo "3. Use Service Account Impersonation:"
        echo "   Grant users permission to impersonate the service account"
        echo "   gcloud iam service-accounts add-iam-policy-binding $SA_EMAIL \\"
        echo "     --member='user:YOUR_EMAIL' \\"
        echo "     --role='roles/iam.serviceAccountTokenCreator'"
        echo ""
        echo "4. Use Application Default Credentials (ADC):"
        echo "   gcloud auth application-default login"
        echo "   # Then use the service account via impersonation"
        echo ""
        KEY_CREATED=false
    else
        echo "✗ Failed to create JSON key file"
        echo "Error: $KEY_OUTPUT"
        KEY_CREATED=false
    fi
fi

# Display summary
echo ""
if [ "$KEY_CREATED" = true ]; then
    KEY_PATH=$(pwd)/$KEY_FILE
    echo "=========================================="
    echo "✓ Service Account Created Successfully!"
    echo "=========================================="
    echo ""
    echo "Service Account Details:"
    echo "  Email: $SA_EMAIL"
    echo "  Display Name: $SA_DISPLAY_NAME"
    echo "  Description: $SA_DESCRIPTION"
    echo ""
    echo "Key File:"
    echo "  Path: $KEY_PATH"
    echo ""
    echo "Granted Roles ($ROLE_COUNT):"
    for role in $SELECTED_ROLES; do
        echo "  - $role"
    done
    echo ""
    if [ $FAIL_COUNT -gt 0 ]; then
        echo "Note: $FAIL_COUNT role(s) may have already been granted"
        echo ""
    fi
    echo "Usage Examples:"
    echo "  # Set environment variable"
    echo "  export GOOGLE_APPLICATION_CREDENTIALS=\"$KEY_PATH\""
    echo ""
    echo "  # Use with gcloud"
    echo "  gcloud auth activate-service-account --key-file=\"$KEY_PATH\""
    echo ""
    echo "  # Use with Terraform"
    echo "  export GOOGLE_APPLICATION_CREDENTIALS=\"$KEY_PATH\""
    echo "  terraform plan"
    echo ""
    echo "  # Use with Python"
    echo "  from google.oauth2 import service_account"
    echo "  credentials = service_account.Credentials.from_service_account_file('$KEY_FILE')"
    echo ""
    echo "⚠️  SECURITY WARNING:"
    echo "  - Keep this JSON key file secure!"
    echo "  - Do NOT commit it to version control!"
    echo "  - Store it in a secret management system"
    echo "  - Rotate keys regularly"
    echo "  - Use least privilege (minimum roles needed)"
    echo ""
else
    echo "=========================================="
    echo "⚠ Service Account Created (Key Creation Blocked)"
    echo "=========================================="
    echo ""
    echo "Service Account Details:"
    echo "  Email: $SA_EMAIL"
    echo "  Display Name: $SA_DISPLAY_NAME"
    echo "  Description: $SA_DESCRIPTION"
    echo ""
    echo "Granted Roles ($ROLE_COUNT):"
    for role in $SELECTED_ROLES; do
        echo "  - $role"
    done
    echo ""
    if [ $FAIL_COUNT -gt 0 ]; then
        echo "Note: $FAIL_COUNT role(s) may have already been granted"
        echo ""
    fi
    echo "=========================================="
    echo "Next Steps"
    echo "=========================================="
    echo ""
    echo "The service account was created but key generation was blocked."
    echo ""
    echo "To enable key creation, run:"
    echo "  ./fix-service-account-key-policy.sh"
    echo ""
    echo "Or use alternative authentication methods (see above)."
    echo ""
fi
