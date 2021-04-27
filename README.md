# aks-bicep
AKS Deployment with Bicep

Many thanks to the Cloud Native GBB team for the AKS webinars and example Bicep files. See https://github.com/CloudNativeGBB/webinars

Note: the yaml files in the root are Azure DevOps pipelines

Azure DevOps requirements:
- service connection with Owner rights to the subscriptions (need to set RBAC); service connection in sample pipelines is AKSBicep
- Pipeline variable SSH_KEY with the public key of a key pair; public key required by AKS deployment
- Instead of pipeline variable, sample pipelines use a variable group
