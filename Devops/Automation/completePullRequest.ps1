# Set variables
$completedBy = "user@email.com"
$organization = "your-devops-organization"
$project = "your-devops-project"
$repository = "your-repository"
$pullRequestId = "0" # This is the ID of the existing pull request

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

# Get identity
$identityUrl = "https://vssps.dev.azure.com/$organization/_apis/identities?searchFilter=General&filterValue=$completedBy&queryMembership=None&api-version=6.0"
$identityResponse = Invoke-RestMethod -Uri $identityUrl -Method Get -Headers $headers
$identity = $identityResponse.value
$identityId = $identity.id

# Approve PR
$approveJson = @{
    "vote" = 10
} | ConvertTo-Json

$pullRequestApproveUrl = ('pullRequests/' + $pullRequestId + '/reviewers/' + $identityId + '?api-version=5.1')
$approveResult = Invoke-RestMethod -Method PUT -Headers $headers -Body $approveJson -Uri "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repoId/$pullRequestApproveUrl"