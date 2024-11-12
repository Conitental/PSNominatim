Function Invoke-NominatimReverseRequest {
    [CmdletBinding(DefaultParameterSetName = 'ByCoordinates')]

    Param(
        [Parameter(Mandatory, ParameterSetName = 'ByCoordinates', Position = 0)]
        [Alias('lat')]
        [String]$Latitude,

        [Parameter(Mandatory, ParameterSetName = 'ByCoordinates', Position = 1)]
        [Alias('lon')]
        [String]$Longitude,

        [ValidateSet('xml', 'json', 'jsonv2', 'geojson', 'geocodejson', 'psobject')]
        [Alias('Format')]
        [String]$OutputFormat = 'psobject',

        [Switch]$Addressdetails,
        [Switch]$ExtraTags,
        [Switch]$NameDetails,


        [String]$RawParameter,

        [String]$Endpoint = '/reverse?'
    )

    $ConstructedPath = $Endpoint

    # Append the single query for free form requests
    $ConstructedPath += "lat=$Latitude&"
    $ConstructedPath += "lon=$Longitude&"

    # Apend the output format
    # We will only need the psobject value for later output
    If($OutputFormat -ne 'psobject') {
        $ConstructedPath += "format=$OutputFormat&"
    } Else {
        $ConstructedPath += 'format=jsonv2&'
    }

    # Append the generic parameters
    If($Addressdetails) { $ConstructedPath += 'addressdetails=1&' }
    If($ExtraTags) { $ConstructedPath += 'extratags=1&' }
    If($NameDetails) { $ConstructedPath += 'namedetail=1&' }

    If($RawParameter) { $ConstructedPath += "$RawParameter&" }

    # Remove the last parameter separator
    $ConstructedPath = $ConstructedPath -replace '&$'

    $Content = Invoke-NominatimRequest -Path $ConstructedPath

    If($OutputFormat -eq 'psobject') {
        Write-Output ($Content | ConvertFrom-Json)
    } Else {
        Write-Output $Content
    }
}
