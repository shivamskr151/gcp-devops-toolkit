# CIDR Allocation Summary

This document outlines the complete CIDR allocation for the GCP infrastructure.

## VPC CIDR

- **VPC**: `10.10.0.0/16`

## Subnet CIDRs

### Production
- **prod-frontend-subnet**: `10.10.1.0/24` (VMs)
- **prod-backend-subnet**: `10.10.2.0/24` (VMs)
- **prod-db-subnet**: `10.10.3.0/24` (VMs)

### Staging
- **staging-frontend-subnet**: `10.10.10.0/24` (VMs)
- **staging-backend-subnet**: `10.10.11.0/24` (VMs)
- **staging-db-subnet**: `10.10.12.0/24` (VMs)

### Shared Infrastructure
- **shared-infra-subnet**: `10.10.20.0/24` (NAT, Cloud Router, CI/CD, Monitoring)

## Secondary IP Ranges (GKE Pods & Services)

### Production Clusters
Both `prod-frontend-subnet` and `prod-backend-subnet` share:
- **prod-pods-range**: `10.20.0.0/20`
- **prod-services-range**: `10.20.16.0/20`

### Staging Clusters
Both `staging-frontend-subnet` and `staging-backend-subnet` share:
- **staging-pods-range**: `10.21.0.0/20`
- **staging-services-range**: `10.21.16.0/20`

## GKE Master Peering CIDRs

Each GKE cluster requires a unique `/28` CIDR block for master peering:

### Production Cluster
- **gke-prod**: `172.16.0.0/28` (gke-prod-master-cidr)
  - Contains both frontend and backend node pools

### Staging Cluster
- **gke-staging**: `172.16.1.0/28` (gke-staging-master-cidr)
  - Contains both frontend and backend node pools

## Firewall Rules

The `allow-internal` firewall rule allows traffic from:
- `10.10.0.0/16` - VPC CIDR
- `10.20.0.0/20` - Production secondary ranges (pods)
- `10.21.0.0/20` - Staging secondary ranges (pods)

## CIDR Range Summary

| Resource Type | CIDR Range | Purpose |
|--------------|------------|---------|
| VPC | 10.10.0.0/16 | Main VPC network |
| Prod Frontend Subnet | 10.10.1.0/24 | Production frontend VMs |
| Prod Backend Subnet | 10.10.2.0/24 | Production backend VMs |
| Prod DB Subnet | 10.10.3.0/24 | Production databases |
| Staging Frontend Subnet | 10.10.10.0/24 | Staging frontend VMs |
| Staging Backend Subnet | 10.10.11.0/24 | Staging backend VMs |
| Staging DB Subnet | 10.10.12.0/24 | Staging databases |
| Shared Infra Subnet | 10.10.20.0/24 | Shared infrastructure |
| Prod Pods Range | 10.20.0.0/20 | Production GKE pods |
| Prod Services Range | 10.20.16.0/20 | Production GKE services |
| Staging Pods Range | 10.21.0.0/20 | Staging GKE pods |
| Staging Services Range | 10.21.16.0/20 | Staging GKE services |
| Prod Master | 172.16.0.0/28 | GKE master peering (gke-prod) |
| Staging Master | 172.16.1.0/28 | GKE master peering (gke-staging) |

## Notes

1. **Secondary IP Ranges**: Production frontend and backend subnets share the same secondary IP ranges (10.20.x.x) since they're in the same environment. Similarly, staging subnets share 10.21.x.x ranges.

2. **Master CIDRs**: Each GKE cluster requires a unique `/28` CIDR block. The production cluster uses 172.16.0.0/28 and the staging cluster uses 172.16.1.0/28. Each cluster contains both frontend and backend node pools.

3. **Firewall Rules**: The internal firewall rule has been updated to allow traffic from the VPC CIDR and secondary IP ranges.

4. **CIDR Validation**: All CIDR ranges are non-overlapping and properly sized for their intended use.

