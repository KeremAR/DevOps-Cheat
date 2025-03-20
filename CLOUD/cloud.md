# Cloud Computing Cheatsheet

[cloud](/Media/cloud.png)

## Platform as a Service (PaaS)
- **Azure App Service**: Easily build, deploy, and scale web apps without managing servers.
- **Azure SQL Database**: Fully managed relational database service.
- **Azure Kubernetes Service (AKS)**: Deploy and manage containerized applications.
- **Azure Container Instance (ACI)**: Quickest way to deploy a single container.
- **Azure Key Vault**: Securely store and manage sensitive information like encryption keys, passwords, and API keys.

## Infrastructure as a Service (IaaS)
- **Azure Virtual Machines (VMs)**: Run virtualized servers in the cloud.
- **Azure Virtual Network**: Create private, isolated networks.
- **Azure Virtual Network Peering**: Connect multiple virtual networks within or across regions.
- **Azure Load Balancer**: Distribute network traffic across multiple VMs.
- **Virtual Private Network (VPN)**: Connects two networks securely as if they were on the same network.

## Storage Solutions
- **Azure Blob Storage**: Store and manage unstructured data.
- **Azure File Sync**: Synchronize files between on-premises servers and Azure Files.
- **AzCopy**: Transfer files between local storage and Azure Blob, File, and Table storage.
- **Azure Data Box**: Physical data transfer solution for large-scale data migration.

## Migration & Resource Management
- **Azure Migrate**: Discover, assess, and migrate on-premises resources to Azure.
- **Azure Resource Manager (ARM)**: Organize, deploy, and manage resources.
- **Azure Blueprints**: Define, automate, and manage resource deployments with governance.

## Software as a Service (SaaS)
- **Azure Active Directory (AAD)**: Manage user access securely with SSO and MFA.
- **Microsoft 365**: Cloud-based productivity tools.
- **Microsoft Purview**: Data governance service.

## Function as a Service (FaaS)
- **Azure Functions**: Run event-driven code without managing servers.

## Security & Governance
- **VPN Gateway**: Connect on-premises data centers to Azure virtual networks.
- **Role-Based Access Control (RBAC)**: Manage access based on roles and permissions.
- **Azure AD B2B**: Secure collaboration with external partners.
- **Azure Conditional Access**: Restrict access based on user location, device compliance, and time of day.
- **Zero Trust Security**: Encrypts data at rest and in transit, using continuous authentication.
- **Azure Policy**: Enforce compliance by defining rules for resource configurations.

## Security Layers
- **Data**: Virtual network endpoint.
- **Application**: API Management.
- **Compute**: Limit RDP access.
- **Network**: NSG, subnets, deny by default.
- **Perimeter**: DDoS protection, firewalls.
- **Identity & Access**: Azure AD authentication.
- **Physical**: Door locks, key cards.

## Scalability & Elasticity
- **Elasticity**: Automatically adjust resources in real-time based on demand.
- **Scalability**: Increase or decrease resource capacity as needed.
  - **Vertical Scaling**: Add more resources to an existing instance.
  - **Horizontal Scaling**: Add more instances of a component.

## Cloud Deployment Models
- **Public Cloud**: Cost-effective, scalable, no maintenance.
- **Private Cloud**: More control, enhanced security, supports legacy systems.
- **Hybrid Cloud**: Flexibility, disaster recovery, combines public and private cloud benefits.

## Azure Hierarchy
- **Subscription**: Consolidate billing and manage access.
- **Resource Groups**: Organize related resources.
- **Resources**: Individual instances like VMs, databases, and storage accounts.

