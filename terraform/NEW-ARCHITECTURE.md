# New Infrastructure Architecture

## VPC Structure

```
main-vpc (10.10.0.0/16)
│
├── prod-frontend-subnet (10.10.1.0/24) - Public
│   └── Reserved for future use
│
├── prod-backend-subnet (10.10.2.0/24) - Private
│   └── gke-prod cluster (frontend + backend node pools)
│       ├── Pods: 10.20.0.0/20
│       └── Services: 10.20.16.0/20
│
├── prod-db-subnet (10.10.3.0/24) - Private
│   └── CloudSQL, MongoDB, Redis (Production)
│
├── staging-frontend-subnet (10.10.10.0/24) - Public
│   └── Reserved for future use
│
│
├── staging-backend-subnet (10.10.11.0/24) - Private
│   └── gke-staging cluster (frontend + backend node pools)
│       ├── Pods: 10.21.0.0/20
│       └── Services: 10.21.16.0/20
│
├── staging-db-subnet (10.10.12.0/24) - Private
│   └── CloudSQL, MongoDB, Redis (Staging)
│
└── shared-infra-subnet (10.10.20.0/24) - Private
    ├── Cloud Router
    ├── Cloud NAT
    ├── CI/CD Agents
    └── Monitoring/Logging
```

## GKE Clusters

### Production
- **gke-prod**: `prod-backend-subnet` (private)
  - Contains both frontend and backend node pools
  - Master CIDR: `172.16.0.0/28`

### Staging
- **gke-staging**: `staging-backend-subnet` (private)
  - Contains both frontend and backend node pools
  - Master CIDR: `172.16.1.0/28`

## Secondary IP Ranges

### Production Backend Subnet (used by gke-prod)
- Pods: `10.20.0.0/20`
- Services: `10.20.16.0/20`

### Staging Backend Subnet (used by gke-staging)
- Pods: `10.21.0.0/20`
- Services: `10.21.16.0/20`

## Benefits

1. **Environment Isolation**: Separate subnets for prod and staging
2. **Network Segmentation**: Frontend (public) and backend (private) separation
3. **Database Isolation**: Dedicated subnets for databases
4. **Shared Infrastructure**: Centralized NAT, Router, CI/CD, Monitoring
5. **No pe-subnet conflicts**: Each cluster uses its environment-specific subnet

## Note on pe-subnets

GKE will still create `pe-subnet` subnets for private endpoint peering when `enable_private_nodes: true`. These are:
- Automatically managed by GKE
- Required for private nodes
- Use master IP CIDR blocks (172.16.x.0/28)
- Don't interfere with your subnets

