Function Invoke-NominatimDetailsRequest {
    [CmdletBinding(DefaultParameterSetName = 'ByPlaceId')]

    Param(
        [Parameter(Mandatory, ParameterSetName = 'ByPlaceId', Position = 0, ValueFromPipelineByPropertyName=$True)]
        [Alias('place_id')]
        [String]$PlaceId,

        [Parameter(Mandatory, ParameterSetName = 'ByOSMDetails', Position = 0, ValueFromPipelineByPropertyName=$True)]
        [Alias('Osm_Id')]
        [String]$OsmId,

        [Parameter(Mandatory, ParameterSetName = 'ByOSMDetails', Position = 1, ValueFromPipelineByPropertyName=$True)]
        [Alias('Osm_Type')]
        [ValidateSet('Node', 'Way', 'Relation')]
        [String]$OsmType,

        [Parameter(ParameterSetName = 'ByOSMDetails', Position = 2)]
        [String]$Class,

        [ValidateSet('json', 'psobject')]
        [Alias('Format')]
        [String]$OutputFormat = 'psobject',

        [Switch]$Keywords,
        [Switch]$LinkedPlaces,
        [Switch]$Addressdetails,

        [String]$RawParameter,


        [String]$Endpoint = 'https://nominatim.openstreetmap.org/details?'
    )

    Process {

    $ConstructedUri = $Endpoint

    # Append parameters for different sets
    If($PlaceId) { $ConstructedUri += "place_id=$PlaceId&" }

    If($OsmId) { $ConstructedUri += "osmid=$OsmId&" }
    If($OsmType) {
        Switch($OsmType) {
            'Node'      { $ConstructedUri += "osmtype=N&" }
            'Way'       { $ConstructedUri += "osmtype=W&" }
            'Relation'  { $ConstructedUri += "osmtype=R&" }
        }
    }
    If($Class) { $ConstructedUri += "class=$Class&" }

    # Apend the output format
    # We will only need the psobject value for later output
    If($OutputFormat -ne 'psobject') {
        $ConstructedUri += "format=$OutputFormat&"
    } Else {
        $ConstructedUri += 'format=json&'
    }

    # Append the generic parameters
    If($Addressdetails) { $ConstructedUri += 'addressdetails=1&' }
    If($ExtraTags) { $ConstructedUri += 'extratags=1&' }
    If($NameDetails) { $ConstructedUri += 'namedetail=1&' }

    If($RawParameter) { $ConstructedUri += "$RawParameter&" }

    # Remove the last parameter separator
    $ConstructedUri = $ConstructedUri -replace '&$'

    $Content = Invoke-NominatimRequest -Uri $ConstructedUri

    If($OutputFormat -eq 'psobject') {
        Write-Output ($Content | ConvertFrom-Json)
    } Else {
        Write-Output $Content
    }

    } # End Process
}
