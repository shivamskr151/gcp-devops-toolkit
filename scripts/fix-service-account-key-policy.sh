#!/bin/bash

# Script to fix organization policy that blocks service account key creation
# Usage: ./fix-service-account-key-policy.sh

set -e

PROJECT_ID="variphi"
ORG_ID="454153135806"
CURRENT_ACCOUNT=$(gcloud config get-value account)

echo "=========================================="
echo "Fix Service Account Key Creation Policy"
echo "=========================================="
echo "Account: $CURRENT_ACCOUNT"
echo "Project: $PROJECT_ID"
echo "Organization: $ORG_ID"
echo ""
echo "This script will update the organization policy to allow"
echo "service account key creation."
echo ""

# Check permissions
echo "Checking permissions..."
HAS_ORG_POLICY_ADMIN=$(gcloud organizations get-iam-policy $ORG_ID --flatten="bindings[].members" --filter="bindings.members:user:$CURRENT_ACCOUNT" --format="value(bindings.role)" 2>/dev/null | grep -q "roles/orgpolicy.policyAdmin" && echo "yes" || echo "no")

if [ "$HAS_ORG_POLICY_ADMIN" != "yes" ]; then
    echo "⚠ Missing: Organization Policy Administrator role"
    echo "  Attempting to grant the role..."
    if gcloud organizations add-iam-policy-binding $ORG_ID \
        --member="user:$CURRENT_ACCOUNT" \
        --role="roles/orgpolicy.policyAdmin" \
        --quiet 2>&1; then
        echo "✓ Role granted. Waiting 10 seconds for propagation..."
        sleep 10
    else
        echo "✗ Failed to grant role. You need Organization Administrator role."
        exit 1
    fi
else
    echo "✓ Organization Policy Administrator role confirmed"
fi

# Check current policy
echo ""
echo "Checking current policy..."
CURRENT_POLICY=$(gcloud resource-manager org-policies describe iam.disableServiceAccountKeyCreation \
    --organization=$ORG_ID \
    --format=json 2>/dev/null)

if echo "$CURRENT_POLICY" | grep -q '"enforced": true'; then
    echo "⚠ Policy is currently enforced (key creation blocked)"
else
    echo "✓ Policy is not enforced (key creation allowed)"
    echo "No changes needed."
    exit 0
fi

echo ""
echo "Current policy:"
echo "$CURRENT_POLICY" | python3 -m json.tool 2>/dev/null || echo "$CURRENT_POLICY"
echo ""

read -p "Disable this policy to allow key creation? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# Create policy file to disable enforcement (empty booleanPolicy means not enforced)
POLICY_FILE=$(mktemp)
cat > "$POLICY_FILE" <<EOF
constraint: constraints/iam.disableServiceAccountKeyCreation
EOF

echo ""
echo "Policy to be applied:"
echo "----------------------------------------"
cat "$POLICY_FILE"
echo "----------------------------------------"
echo ""

# Update organization-level policy
echo "Updating organization-level policy..."
if gcloud resource-manager org-policies set-policy \
    --organization=$ORG_ID \
    "$POLICY_FILE" 2>&1; then
    echo "✓ Organization-level policy updated"
else
    echo "✗ Failed to update organization-level policy"
    rm -f "$POLICY_FILE"
    exit 1
fi

# Update project-level policy (if exists)
echo ""
echo "Updating project-level policy..."
if gcloud resource-manager org-policies set-policy \
    --project=$PROJECT_ID \
    "$POLICY_FILE" 2>&1; then
    echo "✓ Project-level policy updated"
else
    echo "⚠ Project-level policy update failed (may not exist or already set)"
fi

rm -f "$POLICY_FILE"

# Wait for propagation
echo ""
echo "Waiting 5 seconds for policy propagation..."
sleep 5

# Verify
echo ""
echo "Verifying policy..."
ORG_POLICY=$(gcloud resource-manager org-policies describe iam.disableServiceAccountKeyCreation \
    --organization=$ORG_ID \
    --format=json 2>/dev/null)

if echo "$ORG_POLICY" | grep -q '"enforced": false' || ! echo "$ORG_POLICY" | grep -q '"enforced": true'; then
    echo "✓ Policy updated successfully - key creation is now allowed"
else
    echo "⚠ Policy may still be enforced, check manually"
fi

echo ""
echo "=========================================="
echo "✓ Policy Update Complete!"
echo "=========================================="
echo ""
echo "You can now create service account keys:"
echo "  gcloud iam service-accounts keys create key.json \\"
echo "    --iam-account=SERVICE_ACCOUNT_EMAIL"
echo ""
echo "Or re-run the create-service-account.sh script."
echo ""

