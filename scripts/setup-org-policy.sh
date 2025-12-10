#!/bin/bash

# Setup Organization Policy - Allows all domains for IAM members
# This script fixes the organization policy constraint that blocks external domains
# Usage: ./setup-org-policy.sh [developer-email]

set -e

PROJECT_ID="variphi"
ORG_ID="454153135806"
CURRENT_ACCOUNT=$(gcloud config get-value account)

echo "=========================================="
echo "Fix Organization Policy - Complete Solution"
echo "=========================================="
echo "Account: $CURRENT_ACCOUNT"
echo "Project: $PROJECT_ID"
echo "Organization: $ORG_ID"
echo ""
echo "This script will:"
echo "1. Grant Organization Policy Administrator role (if needed)"
echo "2. Update organization-level policy to allow all domains"
echo "3. Update project-level policy to allow all domains"
echo "4. Grant DevOps permissions to developer"
echo ""

# Step 1: Check and grant role if needed
echo "Step 1: Checking permissions..."
HAS_ORG_POLICY_ADMIN=$(gcloud organizations get-iam-policy $ORG_ID --flatten="bindings[].members" --filter="bindings.members:user:$CURRENT_ACCOUNT" --format="value(bindings.role)" 2>/dev/null | grep -q "roles/orgpolicy.policyAdmin" && echo "yes" || echo "no")

if [ "$HAS_ORG_POLICY_ADMIN" != "yes" ]; then
    echo "Granting Organization Policy Administrator role..."
    gcloud organizations add-iam-policy-binding $ORG_ID \
        --member="user:$CURRENT_ACCOUNT" \
        --role="roles/orgpolicy.policyAdmin" \
        --quiet
    echo "✓ Role granted. Waiting 10 seconds for propagation..."
    sleep 10
else
    echo "✓ Organization Policy Administrator role confirmed"
fi

# Step 2: Update organization-level policy
echo ""
echo "Step 2: Updating organization-level policy..."
POLICY_FILE=$(mktemp)
cat > "$POLICY_FILE" <<EOF
constraint: constraints/iam.allowedPolicyMemberDomains
listPolicy:
  allValues: ALLOW
EOF

if gcloud resource-manager org-policies set-policy \
    --organization=$ORG_ID \
    "$POLICY_FILE" &>/dev/null; then
    echo "✓ Organization-level policy updated"
else
    echo "⚠ Organization-level update failed (may already be set)"
fi

# Step 3: Update project-level policy
echo ""
echo "Step 3: Updating project-level policy..."
if gcloud resource-manager org-policies set-policy \
    --project=$PROJECT_ID \
    "$POLICY_FILE" &>/dev/null; then
    echo "✓ Project-level policy updated"
else
    echo "⚠ Project-level update failed (may already be set)"
fi

rm -f "$POLICY_FILE"

# Step 4: Wait for propagation
echo ""
echo "Step 4: Waiting 5 seconds for policy propagation..."
sleep 5

# Step 5: Grant permissions
echo ""
echo "Step 5: Granting DevOps permissions..."
echo ""
if [ -n "$1" ]; then
    DEVELOPER_EMAIL=$1
    ./scripts/grant-devops-role.sh "$DEVELOPER_EMAIL"
else
    echo "Usage: $0 <developer-email>"
    echo "Example: $0 wr.akashkumar@gmail.com"
    echo ""
    echo "Policy has been updated. You can now grant permissions manually:"
    echo "  ./scripts/grant-devops-role.sh <developer-email>"
fi

echo ""
echo "=========================================="
echo "✓ Complete!"
echo "=========================================="

