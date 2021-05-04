# aks-private

## installing the template

```
export ACR_ROLE=$(az role definition list --name 'AcrPull' | jq -r .[].id)
az deployment sub create --location westeurope --template-file main.bicep --parameter @parameters.json --parameter acrRole=$ACR_ROLE
```

## what does this deploy

- resource group
  - deployments in resource group via modules scoped to the resource group
- vnet with subnets for aks, ilb, Azure Firewall, Azure Bastion, management
  - subnets created as part of the vnet; not as separate entities
- Azure Bastion
  - to connect to the Jump Box or AKS nodes
- Azure Firewall + rules for Azure Kubernetes Service (AKS)
- Private AKS Cluster (one system pool)
  - egress via Azure Firewall
- User defined route (UDR) on AKS subnet to route traffic to Azure Firewall
  - Azure Firewall internal IP hardcoded (1st IP of AzFw subnet)
- Jump Box (Ubuntu 18.04 LTS)
- Azure Container Registry with Private Endpoint and private DNS
