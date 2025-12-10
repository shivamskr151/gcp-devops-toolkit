# GKE Node Management Scripts

Scripts to stop and start GKE nodes to eliminate compute costs when clusters are not in use.

## Overview

When you're not actively using your GKE clusters, you can stop all nodes to eliminate compute costs. The cluster control planes will remain running (minimal cost ~$0.10/hour per cluster), but all worker nodes will be stopped.

## Scripts

### `stop-nodes.sh`
Stops all nodes by scaling all node pools to 0 nodes.

**What it does:**
- Scales all production node pools to 0 nodes
- Scales all staging node pools to 0 nodes
- Eliminates all compute costs from worker nodes
- Cluster control planes remain running (minimal cost)

**Usage:**
```bash
./scripts/stop-nodes.sh
```

### `start-nodes.sh`
Starts all nodes by scaling node pools back to minimum (1 node per pool).

**What it does:**
- Scales production node pools back to 1 node each
- Scales staging node pools back to 1 node each
- Restores cluster functionality

**Usage:**
```bash
./scripts/start-nodes.sh
```

## Cost Impact

### When Nodes Are Stopped (0 nodes):
- **Worker Node Costs**: $0 (all nodes stopped)
- **Control Plane Costs**: $0 (FREE)
- **Total Compute Cost**: $0/month ✅

### When Nodes Are Running (12 nodes):
- **Worker Node Costs**: ~$50-100/month (depending on machine types)
- **Control Plane Costs**: $0 (FREE)
- **Total Cost**: ~$50-100/month

## Important Notes

1. **Regional Clusters**: Your clusters are regional (spanning multiple zones). When scaling to 1 node, GKE may maintain 1 node per zone (3 nodes total per pool) for high availability.

2. **Application Deployment**: When nodes are stopped, you cannot deploy applications. You must start nodes before deploying.

3. **Autoscaling**: The autoscaler will automatically scale nodes up when workloads are deployed, and scale down when idle (respecting min_node_count).

4. **Data Persistence**: Stopping nodes does not affect persistent volumes or cluster configuration. All data and settings are preserved.

## Quick Commands

```bash
# Stop all nodes (eliminate compute costs)
./scripts/stop-nodes.sh

# Start all nodes (restore functionality)
./scripts/start-nodes.sh

# Check current node status
gcloud compute instances list --project=variphi --filter="name~'gke-'"
```

## Troubleshooting

If nodes don't scale down to 0:
- Check if there are any system pods preventing scale-down
- Verify autoscaling settings allow 0 nodes (may need to temporarily disable autoscaling)
- Check for any persistent workloads that require nodes

If nodes don't start:
- Verify cluster control planes are running
- Check for quota limits in your GCP project
- Ensure you have proper IAM permissions

