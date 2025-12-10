# Quick Start Guide

## One-Command Setup (Recommended)

For first-time setup or when organization policy is blocking external domains:

```bash
./setup-org-policy.sh wr.akashkumar@gmail.com
```

This single command will:
- ✅ Fix organization policy
- ✅ Grant all DevOps permissions

## Grant Permissions Only

If policy is already configured:

```bash
./grant-devops-role.sh wr.akashkumar@gmail.com #
```

## Verify Setup

```bash
# Check if permissions were granted
gcloud projects get-iam-policy variphi \
    --flatten="bindings[].members" \
    --filter="bindings.members:user:wr.akashkumar@gmail.com" \
    --format="table(bindings.role)"
```

## Troubleshooting

**Problem:** "User is not in permitted organization"

**Solution:** Run `./setup-org-policy.sh <email>` to fix the policy first.

**Problem:** "Permission denied"

**Solution:** Ensure you have Organization Administrator or Organization Policy Administrator role.

## Scripts Overview

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `setup-org-policy.sh` | Fix policy + grant roles | First time, policy blocking |
| `grant-devops-role.sh` | Grant roles only | Policy already configured |
| `grant-devops-role.py` | Python version | Same as .sh, Python preference |


For detailed documentation, see [README.md](README.md).

