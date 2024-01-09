param(
    [string]$pat
)

$devStagePath = "dev_stage_path"
$repo = "Sandbox"

mkdir $devStagePath
cd ./$devStagePath
git clone "https://$pat@dev.azure.com/<your-org>/<your-project>/_git/$repo"
cd "$repo"
ls .