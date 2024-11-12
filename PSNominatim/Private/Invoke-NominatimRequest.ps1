Function Invoke-NominatimRequest {
    [CmdletBinding()]

    Param(
        [String]$Path,
        [String]$UserAgent = 'PSNominatim/1.0',
        [Int]$MaxCachedResults = 20,
        [Switch]$IgnoreCache
    )

    If(Test-NominatimConfig -Parameter 'NominatimServer') {
        $NominatimServer = Get-NominatimConfig -Parameter 'NominatimServer'

        Write-Verbose "Read Nominatim server from config:"
        Write-Verbose $NominatimServer
    } Else {
        Return
    }

    # Construct the actual URI to be queried
    $Uri = $NominatimServer + $Path

    If(-not $IgnoreCache) {
        If(-not (Test-Path Variable:NominatimRequestCache)) {
            # Create the cache if did not already in this session
            Set-Variable -Scope Script -Name NominatimRequestCache -Value (New-Object System.Collections.ArrayList)
        } Else {
            $CacheResult = $NominatimRequestCache | Where-Object -Property 'RequestUri' -eq $Uri

            If($CacheResult) {
                # Return the cached content and move the content back to the top of the "stack"
                Write-Verbose "Found cached result for uri:"
                Write-Verbose $Uri
                $OldIndex = $NominatimRequestCache.IndexOf($CacheResult)

                $NominatimRequestCache.Remove($CacheResult)
                $NewIndex = $NominatimRequestCache.Add($CacheResult)

                Write-Verbose "Moved found cache result from index $OldIndex to $NewIndex"

                Return $CacheResult.Content
            }
        }
    } Else { Write-Verbose "-IgnoreCache parameter set. Request cache will not be checked"}

    # Regulate usage if we are using the public API
    If($NominatimServer -match 'https://nominatim.openstreetmap.org') {
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
    }

    Try {
        Write-Verbose "Perform Invoke-WebRequest to Uri:"
        Write-Verbose $Uri

        $Result = Invoke-WebRequest -Uri $Uri -UserAgent $UserAgent

        If($Result.StatusCode -ne 200) {
            Write-Error "Received HTTP $($Result.StatusCode) ($($Result.StatusDescription))"
            Return
        }

        If(-not $IgnoreCache) {
            $NewCacheIndex = $NominatimRequestCache.Add(@{
                RequestUri = $Uri
                Content    = $Result.Content
            })

            Write-Verbose "Add new cache entry at index $NewCacheIndex"

            If($NominatimRequestCache.Count -gt $MaxCachedResults) {
                # Remove first entry in cache
                Write-Verbose "Remove cache entry at index 0"
                $NominatimRequestCache.RemoveAt(0)
            }
        }

        Return $Result.Content
    } Catch {
        Write-Error "Request could not be completed"
        Write-Error $_
    }
}
