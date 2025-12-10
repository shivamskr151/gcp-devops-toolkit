#!/usr/bin/env python3
"""
Script to grant DevOps/Infrastructure Architect permissions to a developer in GCP
Usage: python grant-devops-role.py <developer-email>
"""

import sys
import subprocess
from typing import List, Tuple, Optional

PROJECT_ID = "variphi"

# Roles to grant for DevOps/Infrastructure Architect
ROLES = [
    ("roles/editor", "Editor"),
    ("roles/compute.admin", "Compute Admin"),
    ("roles/container.admin", "Container Admin"),
    ("roles/iam.serviceAccountUser", "Service Account User"),
    ("roles/storage.admin", "Storage Admin"),
    ("roles/cloudsql.admin", "Cloud SQL Admin"),
    ("roles/iam.securityReviewer", "IAM Security Reviewer"),
]


def grant_iam_role(project_id: str, member: str, role: str) -> Tuple[bool, Optional[str]]:
    """Grant an IAM role to a member in a GCP project.
    
    Returns:
        Tuple of (success: bool, error_type: Optional[str])
    """
    try:
        cmd = [
            "gcloud", "projects", "add-iam-policy-binding", project_id,
            "--member", f"user:{member}",
            "--role", role,
            "--quiet"
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return True, None
    except subprocess.CalledProcessError as e:
        error_output = e.stderr or e.stdout or ""
        
        # Detect specific error types
        error_type = None
        if "allowedPolicyMemberDomains" in error_output:
            error_type = "org_policy_constraint"
        elif "PERMISSION_DENIED" in error_output:
            error_type = "permission_denied"
        
        return False, error_type


def main():
    if len(sys.argv) < 2:
        print("Error: Developer email is required", file=sys.stderr)
        print(f"Usage: {sys.argv[0]} <developer-email>", file=sys.stderr)
        sys.exit(1)

    developer_email = sys.argv[1]
    
    print(f"Granting DevOps/Infrastructure Architect permissions to {developer_email} in project {PROJECT_ID}...")
    print()

    # Set the project
    try:
        subprocess.run(
            ["gcloud", "config", "set", "project", PROJECT_ID],
            check=True,
            capture_output=True
        )
    except subprocess.CalledProcessError as e:
        print(f"Error setting project: {e.stderr}", file=sys.stderr)
        sys.exit(1)

    # Grant all roles
    successful_roles = []
    failed_roles = []
    org_policy_errors = []
    
    for role, role_name in ROLES:
        print(f"Granting {role_name} role... ", end="", flush=True)
        success, error_type = grant_iam_role(PROJECT_ID, developer_email, role)
        
        if success:
            print("✓ Success")
            successful_roles.append(f"{role_name} ({role})")
        else:
            print("✗ Failed")
            failed_roles.append(f"{role_name} ({role})")
            if error_type == "org_policy_constraint":
                org_policy_errors.append(role)

    print()
    
    # Summary
    if successful_roles:
        print(f"✓ Successfully granted {len(successful_roles)} role(s):")
        for role in successful_roles:
            print(f"  - {role}")
        print()
    
    if failed_roles:
        print(f"✗ Failed to grant {len(failed_roles)} role(s):")
        for role in failed_roles:
            print(f"  - {role}")
        print()
        
        # Check if all failures are due to organization policy
        if len(org_policy_errors) == len(failed_roles) and len(failed_roles) > 0:
            print("⚠️  Organization Policy Constraint Detected")
            print()
            print("The project has an organization policy (iam.allowedPolicyMemberDomains) that")
            print("restricts which domains can be added as IAM members.")
            print()
            print("To fix this, you need to:")
            print("1. Check the organization policy constraint:")
            print(f"   gcloud resource-manager org-policies describe iam.allowedPolicyMemberDomains --project={PROJECT_ID}")
            print()
            print("2. Either:")
            print("   a) Add the user's domain to the allowed domains list (requires Org Admin)")
            print("   b) Use a service account instead of a user account")
            print("   c) Disable the constraint if you have sufficient permissions")
            print()
            print("3. Or check if the user needs to be added to your Google Workspace organization")
            print()
    
    if not successful_roles:
        print("✗ No roles were granted. Please check the errors above.")
        sys.exit(1)
    elif failed_roles:
        sys.exit(1)


if __name__ == "__main__":
    main()

