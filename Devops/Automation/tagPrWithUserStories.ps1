# This script is meant to be run in a Build/Release pipeline; it links an Azure DevOps PR with a work item.

$token = "$(System.AccessToken)"
$devOpsOrganization = "<your org name>"
$devOpsProject = "<your project name>" 
$devOpsRepoName = "<your repo name>"

# hardcode for testing - update with your values
$workItemId = 1
$pullRequestId = 1

$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($token)"))
$headers = @{
    "Authorization" = "Basic $token"
    "Content-Type"  = "application/json"
}

$getPrUri = "https://dev.azure.com/$devOpsOrganization/$devOpsProject/_apis/git/repositories/$devOpsRepoName/pullrequests/$pullRequestId?api-version=7.0"

$getPrResponse = Invoke-RestMethod -Uri $getPrUri -Method Get -Headers $headers

$body = @"
    [
        {
            "op": "add",
            "path": "/relations/-",
            "value": {
                "rel": "ArtifactLink",
                "url": "$($getPrResponse.artifactId)",
                "attributes": { "name": "Pull Request" }
            }
        }
    ]
"@
# "Build" may also be "Integrated in build"

$updateWorkItemurl = "https://dev.azure.com/${devOpsOrganization}/${devOpsProject}/_apis/wit/workitems/${workItemId}?api-version=6.0"

# will throw error if work item is already linked to PR
Invoke-RestMethod -Uri $updateWorkItemurl -Method Patch -ContentType "application/json-patch+json" -Headers $headers -Body $body