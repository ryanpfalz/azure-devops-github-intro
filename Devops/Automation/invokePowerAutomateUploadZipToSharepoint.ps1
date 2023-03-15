# THIS WORKS
param(
    [Parameter()]
    [String]$filePath,
    [String]$fileName
)

$uri = "<your-power-automate-http-endpoint>"

# Read the contents of the file into a byte array
$bytes = [System.IO.File]::ReadAllBytes($filePath)

# Serialize the byte array into a base64 string
$content = [System.Convert]::ToBase64String($bytes)

# Create a dictionary to store the attributes
$data = @{
    body = @{
        "`$content" = $content
        "`$content-type" = "application/zip" # "multipart/form-data"
    }
    "fileName" = $fileName
}

# Convert the dictionary to a JSON string
$body = ConvertTo-Json $data

# Create an HTTP request to send the file
$request = [System.Net.WebRequest]::Create($uri)
$request.Method = "POST"
$request.ContentType = "application/json"
$request.ContentLength = $body.Length

# Write the JSON string to the request stream
$requestStream = $request.GetRequestStream()
$writer = New-Object System.IO.StreamWriter($requestStream)
$writer.Write($body)
$writer.Flush()
$requestStream.Close()

# Send the request and get the response
$response = $request.GetResponse()
$responseStream = $response.GetResponseStream()

# Read the response stream into a string
$reader = New-Object System.IO.StreamReader($responseStream)
$responseString = $reader.ReadToEnd()