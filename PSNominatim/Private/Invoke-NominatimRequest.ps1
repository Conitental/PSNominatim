Function Invoke-NominatimRequest {
    [CmdletBinding()]

    Param(
        [Uri]$Uri,
        [String]$UserAgent = 'PSNominatim/1.0'
    )

    If(-not (Test-Path Variable:NominatimLastRequestTime)) {
        # Create the module variable if we are called for the first time
        Set-Variable -Scope 'Script' -Name 'NominatimLastRequestTime' -Value (Get-Date)
    } Else {
        # Decide if need to delay the request to comply with Nominatims usage policy
        [int]$MillisSinceLastRequest = (Get-Date) - $NominatimLastRequestTime | Select-Object -ExpandProperty 'TotalMilliseconds'

        Write-Verbose "$MillisSinceLastRequest milliseconds since last request"

        If($MillisSinceLastRequest -lt 1000) {
            Write-Verbose "Waiting for $(1000 - $MillisSinceLastRequest) milliseconds to comply with Nominatims usage policy:"
            Write-Verbose "https://operations.osmfoundation.org/policies/nominatim/"

            Start-Sleep -Milliseconds (1000 - $MillisSinceLastRequest)
        }

        Set-Variable -Scope 'Script' -Name 'NominatimLastRequestTime' -Value (Get-Date)
    }

    Try {
        Write-Verbose "Perform Invoke-WebRequest to Uri:"
        Write-Verbose $Uri

        $Result = Invoke-WebRequest -Uri $Uri -UserAgent $UserAgent

        If($Result.StatusCode -ne 200) {
            Write-Error "Received HTTP $($Result.StatusCode) ($($Result.StatusDescription))"
            Return
        }

        $Result.Content
    } Catch {
        Write-Error "Request could not be completed"
        Write-Error $_
    }
}
