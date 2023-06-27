# inspired by https://stackoverflow.com/a/67519684/8333117

$personalToken = "<your personal access token here>"
$devOpsOrganization = "ryanpfalz"
$devOpsProject = "Sandbox" 

$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($personalToken)"))
$header = @{authorization = "Basic $token" }

# $buildId = $(Build.BuildId) # get from pipeline
$buildId = 198 # hardcode for testing
$workItemId = 2334 # hardcode for testing; this could be a pipeline parameter

$body = "[
  {
    ""op"": ""add"",
    ""path"": ""/relations/-"",
    ""value"": {
      ""rel"": ""ArtifactLink"",
      ""url"": ""vstfs:///Build/Build/${buildId}"",
      ""attributes"": {
        ""name"": ""Build""
      }
    }
  }
]"
# "Build" may also be "Integrated in build"

$updateWorkItemurl = "https://dev.azure.com/${devOpsOrganization}/${devOpsProject}/_apis/wit/workitems/${workItemId}?api-version=6.0"

Invoke-RestMethod -Uri $updateWorkItemurl -Method Patch -ContentType "application/json-patch+json" -Headers $header -Body $body
