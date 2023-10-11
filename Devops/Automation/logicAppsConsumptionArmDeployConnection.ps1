$devResGroupName = "<dev-rg-name>"
$qaResGroupName = "<qa-rg-name>"
$devInstanceName = "<dev-logic-app-name>"
$qaInstanceName = "<qa-logic-app-name>"
$resourceType = "Microsoft.Logic/workflows"
$currPath = "."

# this example uses an office 365 connection
$o365connectionParameter = "<office365-connection-name>_externalid"
$subscription = "<your-subscription-id>"

### Export pipeline (Dev)
# TODO: The below export logic may exist within the dev stage of your pipeline, followed by a git push of the .json file to your repository
# export the ARM template from dev
# https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/export-template-cli
$logicAppId = $(az resource show --resource-group $devResGroupName --name $devInstanceName --resource-type $resourceType --query id --output tsv)
az group export --resource-group $devResGroupName --resource-ids $logicAppId > "${currPath}dev.json"

# sample code to push dev json to Git from within the pipeline. $env:SYSTEM_ACCESSTOKEN requires you to choose 'Allow scripts to access the OAuth token' in the release pipeline agent options
# can be tested locally by leaving the below 2 lines commented out and uncommenting the git commands
# $url = "$(Build.Repository.Uri)".Replace("https://", "")
# $url = "https://$env:SYSTEM_ACCESSTOKEN@$url"

# git fetch $url
# git checkout <branch>

# git add "${currPath}dev.json"
# git commit -m "Adding exported dev.json file"
# git push origin <branch>

### End Export pipeline (Dev)

### Deploy pipeline (QA)

# https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-azure-resource-manager-templates-overview
# https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-create-azure-resource-manager-templates
# https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-deploy-azure-resource-manager-templates

# TODO: The below may be split into another stage in your pipeline. This would require you to checkout the code that was pushed to your repository in the previous step
# $url = "$(Build.Repository.Uri)".Replace("https://", "")
# $url = "https://$env:SYSTEM_ACCESSTOKEN@$url"

# git fetch $url
# git checkout <branch>

$jsonContent = Get-Content -Path "${currPath}dev.json" | ConvertFrom-Json

# reusable function to update the parameters in the dev.json file
function Update-Parameters {
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$json,

        [Parameter(Mandatory = $true)]
        [string]$parameter,

        [Parameter(Mandatory = $true)]
        [string]$value
    )

    if ($json.parameters.$parameter.PSObject.Properties.Name -notcontains "defaultValue") {
        $json.parameters.$parameter | Add-Member -Type NoteProperty -Name "defaultValue" -Value $null
    }
    $json.parameters.$parameter.defaultValue = $value

    return $json
}

# 1. Update workflow name
$workflowName = "workflows_" + $devInstanceName + "_name"
$workflowValue = $qaInstanceName
$updatedObject = Update-Parameters -json $jsonContent -parameter $workflowName -value $workflowValue
$jsonContent = $updatedObject

# 2. Update O365 connection
# TODO This reuses the dev connection; need to create a new connection in the QA environment  
# https://techcommunity.microsoft.com/t5/azure-integration-services-blog/how-to-create-api-connection-logic-app-consumption-using-arm/ba-p/3567231

$connectionName = "connections_" + $o365connectionParameter
$o365ConnectionValue = "/subscriptions/$subscription/resourceGroups/$devResGroupName/providers/Microsoft.Web/connections/office365"
$updatedObject = Update-Parameters -json $jsonContent -parameter $connectionName -value $o365ConnectionValue
$jsonContent = $updatedObject

# Convert the object back to JSON and overwrite the original file
$jsonContent | ConvertTo-Json -Depth 20 | Set-Content -Path "${currPath}dev.json"

# deploy to qa
# https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-deploy-azure-resource-manager-templates#deploy-with-azure-cli
az group create --location "eastus" --name $qaResGroupName
az deployment group create -g $qaResGroupName --template-file "${currPath}dev.json"

### End Deploy pipeline (QA)