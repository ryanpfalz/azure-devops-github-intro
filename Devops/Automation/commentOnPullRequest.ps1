# Set variables
$organization = "your-devops-organization"
$project = "your-devops-project"
$repository = "your-repository"
$pullRequestId = "0" # This is the ID of the existing pull request

# https://learn.microsoft.com/en-us/dotnet/api/microsoft.teamfoundation.sourcecontrol.webapi.commentthreadstatus?view=azure-devops-dotnet
$statusCode = 5

# Get + format token 
$accessToken = Get-Content './ado_pat.txt' # Replace with your access token - in this example, I'm reading it from a txt file
$user = "prcomment"
$userPat = $user + ":" + $accessToken
$encodedBytes = [System.Text.Encoding]::UTF8.GetBytes($userPat)
$encodedPat = [System.Convert]::ToBase64String($encodedBytes)

# Set headers
$headers = @{
    "Authorization" = "Basic $encodedPat"
    "Content-Type"  = "application/json"
}

$markdown = @"
Write your comment here 
"@

# request json
$body = @"
{
    "comments": [
      {
        "parentCommentId": 0,
        "content": "$markdown",
        "commentType": 1
      }
    ],
    "status": $statusCode 
  }
"@

# https://learn.microsoft.com/en-us/rest/api/azure/devops/git/pull-request-threads/create?view=azure-devops-rest-7.0&tabs=HTTP
$url = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repository/pullRequests/$pullRequestId/threads?api-version=7.0"

$response = Invoke-RestMethod -Uri $url -Method POST -Headers $headers -Body $Body

Write-Host $response