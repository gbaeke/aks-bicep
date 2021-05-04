# installing the template

export ACR_ROLE=$(az role definition list --name 'AcrPull' | jq -r .[].id)
az deployment sub create --location westeurope --template-file main.bicep --parameter @parameters.json --parameter acrRole=$ACR_ROLE
