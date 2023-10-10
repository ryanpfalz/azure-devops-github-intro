$devResGroupName = "<dev-rg-name>"
$qaResGroupName = "<qa-rg-name>"
$devInstanceName = "<dev-logic-app-name>"
$qaInstanceName = "<qa-logic-app-name>"
$resourceType = "Microsoft.Logic/workflows"
$currPath = "."

# export the ARM template from dev
# https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/export-template-cli
$logicAppId = $(az resource show --resource-group $devResGroupName --name $devInstanceName --resource-type $resourceType --query id --output tsv)
az group export --resource-group $devResGroupName --resource-ids $logicAppId > "${currPath}dev.json"

# https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-azure-resource-manager-templates-overview
# https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-create-azure-resource-manager-templates
# https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-deploy-azure-resource-manager-templates

# Example: insert a value in the dev.json file under the paramaters section key called "defaultValue" to rename the workflow
$jsonContent = Get-Content -Path "${currPath}dev.json" | ConvertFrom-Json

$workflowName = "workflows_" + $devInstanceName + "_name"

# if the defaultValue property doesn't exist, add it
if ($jsonContent.parameters.$workflowName.PSObject.Properties.Name -notcontains "defaultValue") {
    $jsonContent.parameters.$workflowName | Add-Member -Type NoteProperty -Name "defaultValue" -Value $null
}

# set the defaultValue property to the new workflow name
$jsonContent.parameters.$workflowName.defaultValue = $qaInstanceName

# Convert the object back to JSON and overwrite the original file
$jsonContent | ConvertTo-Json -Depth 20 | Set-Content -Path "${currPath}dev.json"

# deploy to qa
# https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-deploy-azure-resource-manager-templates#deploy-with-azure-cli
az group create --location "eastus" --name $qaResGroupName
az deployment group create -g $qaResGroupName --template-file "${currPath}dev.json"
