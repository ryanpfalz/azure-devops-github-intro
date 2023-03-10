# Set variables
$organization = "your-devops-organization"
$project = "your-devops-project"
$repository = "your-repository"
$sourceBranch = "your-source-branch"
$targetBranch = "your-target-branch"
$title = "Pull Request Title"
$description = "Pull Request Description"

# Get + format token
$accessToken = Get-Content './ado_pat.txt' # Replace with your access token - in this example, I'm reading it from a txt file
$user = "prcreation"
$userPat = $user + ":" + $accessToken
$encodedBytes = [System.Text.Encoding]::UTF8.GetBytes($userPat)
$encodedPat = [System.Convert]::ToBase64String($encodedBytes)

# Set headers
$headers = @{
    "Authorization" = "Basic $encodedPat"
    "Content-Type"  = "application/json"
}

# Get repo ID
$repoUrl = "https://dev.azure.com/$organization/$project/_apis/git/repositories?api-version=7.0"
$repoResponse = Invoke-RestMethod -Uri $repoUrl -Method Get -Headers $headers
$repo = $repoResponse.value | Where-Object { $_.name -eq $repository }
$repoId = $repo.id

# Create a Pull Request
$pullRequestUrl = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repoId/pullrequests?api-version=7.0"
$pullRequestJson = @{
    sourceRefName = "refs/heads/$sourceBranch"
    targetRefName = "refs/heads/$targetBranch"
    title         = $title
    description   = $description
} | ConvertTo-Json

$pullRequestResult = Invoke-RestMethod -Method POST -Headers $headers -Body $pullRequestJson -Uri $pullRequestUrl;
$pullRequestId = $pullRequestResult.pullRequestId

# Set PR to auto-complete
$setAutoCompleteJson = @{
    "autoCompleteSetBy" = @{
        "id" = $pullRequestResult.createdBy.id
    }
    "completionOptions" = @{       
        "deleteSourceBranch" = $False
        "bypassPolicy"       = $False
    }
} | ConvertTo-Json

$pullRequestUpdateUrl = ('pullRequests/' + $pullRequestId + '?api-version=5.1')
$setAutoCompleteResult = Invoke-RestMethod -Method PATCH -Headers $headers -Body $setAutoCompleteJson -Uri "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repoId/$pullRequestUpdateUrl"