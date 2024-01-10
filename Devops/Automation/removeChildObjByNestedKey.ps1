# Recursive function to remove a child object by nested key from a JSON object
function Remove-ConnectionProperties {
    param (
        [PSCustomObject]$JsonObject,
        [string]$Identifier,
        [string]$KeyToRemove
    )

    foreach ($key in $JsonObject.PSObject.Properties.Name) {
        $value = $JsonObject.$key

        # Write-Host "Checking key: $key"

        if ($key -eq $Identifier -and $value.PSObject.Properties.Name -contains $KeyToRemove) {
            # Write-Host "Removing $KeyToRemove from $key"
            $value.PSObject.Properties.Remove($KeyToRemove)
        }
        elseif ($value -is [PSCustomObject] -or $value -is [Collections.Generic.Dictionary[Object, Object]]) {
            Remove-ConnectionProperties -JsonObject $value -Identifier $Identifier -KeyToRemove $KeyToRemove
        }
    }
}

# This is purely a cosmetic function to format the JSON output, from https://stackoverflow.com/a/55384556
function Format-Json([Parameter(Mandatory, ValueFromPipeline)][String] $json) {
    $indent = 0;
    ($json -Split "`n" | % {
        if ($_ -match '[\}\]]\s*,?\s*$') {
            # This line ends with ] or }, decrement the indentation level
            $indent--
        }
        $line = ('  ' * $indent) + $($_.TrimStart() -replace '":  (["{[])', '": $1' -replace ':  ', ': ')
        if ($_ -match '[\{\[]\s*$') {
            # This line ends with [ or {, increment the indentation level
            $indent++
        }
        $line
    }) -Join "`n"
}


# Example usage:

# In this example, I'm using a sample JSON file that contains an object with an "azureblob_2" key with a child called "connectionProperties" that I want to remove.
$jsonFile = "<path-to-json>.json"

# Read the content of the file
$jsonData = Get-Content $jsonFile -Raw | ConvertFrom-Json

# Process the JSON object
Remove-ConnectionProperties -JsonObject $jsonData -Identifier "azureblob_2" -KeyToRemove "connectionProperties"

# Convert the object back to JSON string and format it to remove the unicode characters (from https://stackoverflow.com/a/47779605)
$updatedJson = @($jsonData) | ConvertTo-Json -Depth 100 | Format-Json | %{
    [Regex]::Replace($_, 
        "\\u(?<Value>[a-zA-Z0-9]{4})", {
            param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
                [System.Globalization.NumberStyles]::HexNumber))).ToString() } )}

Write-Output $updatedJson

# Write the modified content back to the file
$updatedJson | Set-Content $jsonFile