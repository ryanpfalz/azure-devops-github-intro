# Recursive function to remove an object by key from a JSON object
function Remove-KeyFromJson {
    param (
        [PSCustomObject]$JsonObject,
        [string]$KeyToRemove
    )

    foreach ($prop in $JsonObject.PSObject.Properties) {
        if ($prop.Value -is [PSCustomObject] -or $prop.Value -is [Collections.Generic.Dictionary[Object, Object]]) {
            # Recursively call the function for nested objects
            Remove-KeyFromJson -JsonObject $prop.Value -KeyToRemove $KeyToRemove
        }
        elseif ($prop.Value -is [Object[]]) {
            # Handle arrays in the JSON
            foreach ($item in $prop.Value) {
                if ($item -is [PSCustomObject] -or $item -is [Collections.Generic.Dictionary[Object, Object]]) {
                    Remove-KeyFromJson -JsonObject $item -KeyToRemove $KeyToRemove
                }
            }
        }
    }

    # Remove the key if it exists at the current level
    if ($JsonObject.PSObject.Properties.Name -contains $KeyToRemove) {
        $JsonObject.PSObject.Properties.Remove($KeyToRemove)
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

# In this example, I'm using a sample JSON file that contains keys called "connectionProperties" that I want to remove.
$jsonFile = "<path-to-file>.json"

# Read the content of the file
$jsonData = Get-Content $jsonFile -Raw | ConvertFrom-Json

# Process the JSON object
Remove-KeyFromJson -JsonObject $jsonData -KeyToRemove "connectionProperties"

# Convert the object back to JSON string and format it to remove the unicode characters (from https://stackoverflow.com/a/47779605)
$updatedJson = @($jsonData) | ConvertTo-Json -Depth 100 | Format-Json | %{
    [Regex]::Replace($_, 
        "\\u(?<Value>[a-zA-Z0-9]{4})", {
            param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
                [System.Globalization.NumberStyles]::HexNumber))).ToString() } )}

Write-Output $updatedJson

# Write the modified content back to the file
$updatedJson | Set-Content $jsonFile
