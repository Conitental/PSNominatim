Function Get-NominatimStatus {
	[CmdletBinding()]

    Param(
        [ValidateSet('text', 'json', 'psobject')]
        [Alias('Format')]
        [String]$OutputFormat = 'psobject',

        [String]$RawParameter,


        [String]$Endpoint = '/status?'
    )

    Process {

    $ConstructedPath = $Endpoint

    # Apend the output format
    # We will only need the psobject value for later output
    If($OutputFormat -ne 'psobject') {
        $ConstructedPath += "format=$OutputFormat&"
    } Else {
        $ConstructedPath += 'format=json&'
    }

    If($RawParameter) { $ConstructedPath += "$RawParameter&" }

    # Remove the last parameter separator
    $ConstructedPath = $ConstructedPath -replace '&$'

    $Content = Invoke-NominatimRequest -Path $ConstructedPath -IgnoreCache

    If($OutputFormat -eq 'psobject') {
        Write-Output ($Content | ConvertFrom-Json)
    } Else {
        Write-Output $Content
    }

    } # End Process
}
