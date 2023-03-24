# note: this only updates a single variable
$releaseId = $(Release.ReleaseId)
$organization = "your-organization-name"
$project = "your-project-name"
$editVariableName = "your-variable" # variable to update
$editVariableValue = "your-value"

$user = "automation"
$userPat = $user + ":$(System.AccessToken)"
$encodedBytes = [System.Text.Encoding]::UTF8.GetBytes($userPat)
$encodedPat = [System.Convert]::ToBase64String($encodedBytes)

# $url = "https://vsrm.dev.azure.com/$organization/$project/_apis/release/definitions?api-version=7.0"
$headers = @{
    Authorization  = "Basic $encodedPat"
    "Content-Type" = "application/json"
}

## Get the current release - https://learn.microsoft.com/en-us/rest/api/azure/devops/release/releases/get-release?view=azure-devops-rest-7.0&tabs=HTTP

$releaseUri = "https://vsrm.dev.azure.com/$organization/$project/_apis/release/releases/$($releaseId)?api-version=7.0"
$individualReleaseRes = Invoke-RestMethod -Uri $releaseUri -Method Get -Headers $headers # -Body $body

# Set the release variable - https://learn.microsoft.com/en-us/rest/api/azure/devops/release/releases/update-release-resource?view=azure-devops-rest-7.0&tabs=HTTP
$releaseUpdateUri = "https://vsrm.dev.azure.com/$organization/$project/_apis/release/releases/$($releaseId)?api-version=7.0"

# update the value from above
$individualReleaseRes.variables.$editVariableName.value = $editVariableValue
$updateBody = $individualReleaseRes | ConvertTo-Json -Depth 100

# update the release
$individualReleaseUpdateRes = Invoke-RestMethod -Uri $releaseUpdateUri -Method Put -Headers $headers -Body $updateBody
