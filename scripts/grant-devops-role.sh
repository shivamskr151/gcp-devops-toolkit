#!/bin/bash

# Script to grant DevOps/Infrastructure Architect permissions to a developer
# Usage: ./grant-devops-role.sh <developer-email>

PROJECT_ID="variphi"
DEVELOPER_EMAIL=$1

if [ -z "$DEVELOPER_EMAIL" ]; then
    echo "Error: Developer email is required"
    echo "Usage: ./grant-devops-role.sh <developer-email>"
    exit 1
fi

echo "Granting DevOps/Infrastructure Architect permissions to $DEVELOPER_EMAIL in project $PROJECT_ID..."
echo ""

# Set the project
if ! gcloud config set project $PROJECT_ID &>/dev/null; then
    echo "Error: Failed to set project to $PROJECT_ID"
    exit 1
fi

# Array to track results
declare -a SUCCESSFUL_ROLES
declare -a FAILED_ROLES
declare -a FAILED_ROLES_ERRORS

# Function to grant a role
grant_role() {
    local role=$1
    local role_name=$2
    
    echo -n "Granting $role_name role... "
    
    if output=$(gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="user:$DEVELOPER_EMAIL" \
        --role="$role" 2>&1); then
        echo "✓ Success"
        SUCCESSFUL_ROLES+=("$role_name ($role)")
        return 0
    else
        echo "✗ Failed"
        FAILED_ROLES+=("$role_name ($role)")
        
        # Check for specific error types
        if echo "$output" | grep -q "allowedPolicyMemberDomains"; then
            FAILED_ROLES_ERRORS+=("Organization policy constraint: User domain not permitted")
        elif echo "$output" | grep -q "PERMISSION_DENIED"; then
            FAILED_ROLES_ERRORS+=("Permission denied: Insufficient privileges")
        else
            FAILED_ROLES_ERRORS+=("Unknown error")
        fi
        return 1
    fi
}

# Grant all roles
grant_role "roles/editor" "Editor"
grant_role "roles/compute.admin" "Compute Admin"
grant_role "roles/container.admin" "Container Admin"
grant_role "roles/iam.serviceAccountUser" "Service Account User"
grant_role "roles/storage.admin" "Storage Admin"
grant_role "roles/cloudsql.admin" "Cloud SQL Admin"
grant_role "roles/iam.securityReviewer" "IAM Security Reviewer"

echo ""

# Summary
if [ ${#SUCCESSFUL_ROLES[@]} -gt 0 ]; then
    echo "✓ Successfully granted ${#SUCCESSFUL_ROLES[@]} role(s):"
    for role in "${SUCCESSFUL_ROLES[@]}"; do
        echo "  - $role"
    done
    echo ""
fi

if [ ${#FAILED_ROLES[@]} -gt 0 ]; then
    echo "✗ Failed to grant ${#FAILED_ROLES[@]} role(s):"
    for i in "${!FAILED_ROLES[@]}"; do
        echo "  - ${FAILED_ROLES[$i]}"
        if [ -n "${FAILED_ROLES_ERRORS[$i]}" ]; then
            echo "    Error: ${FAILED_ROLES_ERRORS[$i]}"
        fi
    done
    echo ""
    
    # Check if all failures are due to organization policy
    all_org_policy_errors=true
    for error in "${FAILED_ROLES_ERRORS[@]}"; do
        if [[ ! "$error" =~ "Organization policy constraint" ]]; then
            all_org_policy_errors=false
            break
        fi
    done
    
    if [ "$all_org_policy_errors" = true ] && [ ${#FAILED_ROLES[@]} -gt 0 ]; then
        echo "⚠️  Organization Policy Constraint Detected"
        echo ""
        echo "The project has an organization policy (iam.allowedPolicyMemberDomains) that"
        echo "restricts which domains can be added as IAM members."
        echo ""
        echo "To fix this, you need to:"
        echo "1. Check the organization policy constraint:"
        echo "   gcloud resource-manager org-policies describe iam.allowedPolicyMemberDomains --project=$PROJECT_ID"
        echo ""
        echo "2. Either:"
        echo "   a) Add the user's domain to the allowed domains list (requires Org Admin)"
        echo "   b) Use a service account instead of a user account"
        echo "   c) Disable the constraint if you have sufficient permissions"
        echo ""
        echo "3. Or check if the user needs to be added to your Google Workspace organization"
        echo ""
    fi
    
    exit 1
fi

if [ ${#SUCCESSFUL_ROLES[@]} -eq 0 ]; then
    echo "✗ No roles were granted. Please check the errors above."
    exit 1
fi

