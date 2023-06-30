# This script is meant to be run in a Build/Release pipeline; it gets a list of work items linked to an Azure DevOps PR, and updates the work item(s) with tags of the release name and environment name of the Build/Release pipeline.

$token = "$(System.AccessToken)"
$devOpsOrganization = "<your org name>"
$devOpsProject = "<your project name>" 
$devOpsRepoName = "<your repo name>"
$releasePrefix = "rel:"
$environmentPrefix = "env:"

# hardcode for testing - update with your value
$pullRequestId = 1

$releaseName = "$(Release.ReleaseName)" 
$environmentName = "$(Release.EnvironmentName)"
Write-Host $releaseName
Write-Host $environmentName

$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($token)"))
$headers = @{
    "Authorization" = "Basic $token"
    "Content-Type"  = "application/json"
}

# Get list of work items on PR
# https://learn.microsoft.com/en-us/rest/api/azure/devops/git/pull-request-work-items/list?view=azure-devops-rest-7.0
$workItemsPrUrl = "https://dev.azure.com/$devOpsOrganization/$devOpsProject/_apis/git/repositories/$devOpsRepoName/pullRequests/$pullRequestId/workitems?api-version=7.0"
Write-Host $workItemsPrUrl

$workItemsPrResponse = Invoke-RestMethod -Uri $workItemsPrUrl -Method GET -Headers $headers
Write-Host $workItemsPrResponse

# Loop over work item(s) and update with tag of release ID
foreach ($item in $workItemsPrResponse.value) {
    # get tags for given work item
    # https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/work-items/get-work-item?view=azure-devops-rest-7.0&tabs=HTTP
    $workItemId = $item.id

    Write-Host "Work Item ID:" $workItemId

    $getWorkItemUrl = "https://dev.azure.com/${devOpsOrganization}/${devOpsProject}/_apis/wit/workitems/${workItemId}?api-version=7.0"
    Write-Host $getWorkItemUrl
    $getWorkItemResponse = Invoke-RestMethod -Uri $getWorkItemUrl -Method Get -Headers $headers

    $patchWorkItemUrl = "https://dev.azure.com/${devOpsOrganization}/${devOpsProject}/_apis/wit/workitems/${workItemId}?api-version=7.0"
    # if no tags, $getWorkItemResponse.fields.'System.Tags' will be null
    $tagsArray = @()
    $verb = ""
    if ($getWorkItemResponse.fields.'System.Tags' -eq $null) {
        Write-Host "No tags exist - adding"
        # create tag
        # https://jsonpatch.com/
        $verb = "add"
        $tagsArray += "$releasePrefix$releaseName;$environmentPrefix$environmentName"

    }
    else {
        # iterate through tags on work item, building up array of tags. Multiple tags will be delimited by ;
        $verb = "replace"
        foreach ($tag in $getWorkItemResponse.fields.'System.Tags'.Split(";") | ForEach-Object { $_.Trim() }) {
            Write-Host "Existing tag:" $tag
        
            if ($tag.StartsWith($releasePrefix)) {
                $tagsArray += "$releasePrefix$releaseName"
            }
            elseif ($tag.StartsWith($environmentPrefix)) {
                $tagsArray += "$environmentPrefix$environmentName"
            }
            else {
                $tagsArray += $tag
            }
        } # inner foreach end
    } # else end
    $tagsString = $tagsArray -join ';'

    Write-Host "New tags:" $tagsString

    # https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/work-items/update?view=azure-devops-rest-7.0&tabs=HTTP#add-a-tag
    $patchBody = @"
            [
                {
                    "op": "$verb",
                    "path": "/fields/System.Tags",
                    "value": "$tagsString"
                }
            ]
"@

    Invoke-RestMethod -Uri $patchWorkItemUrl -Method Patch -ContentType "application/json-patch+json" -Headers $headers -Body $patchBody

    # check if either the release or environment tag does not exist/was not replaced, and add it if it doesn't
    # -inotmatch = "does not contain"
    if ($tagsString -inotmatch "$releasePrefix$releaseName") {
        $addPatchBody = @"
            [
                {
                    "op": "add",
                    "path": "/fields/System.Tags",
                    "value": "$releasePrefix$releaseName"
                }
            ]
"@
        Invoke-RestMethod -Uri $patchWorkItemUrl -Method Patch -ContentType "application/json-patch+json" -Headers $headers -Body $addPatchBody
    } # if end

    if ($tagString -inotmatch "$environmentPrefix$environmentName") {
        $addPatchBody = @"
            [
                {
                    "op": "add",
                    "path": "/fields/System.Tags",
                    "value": "$environmentPrefix$environmentName"
                }
            ]
"@
        Invoke-RestMethod -Uri $patchWorkItemUrl -Method Patch -ContentType "application/json-patch+json" -Headers $headers -Body $addPatchBody
    } # if end
} # outer foreach end