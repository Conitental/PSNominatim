Function Invoke-NominatimLookupRequest {
        [CmdletBinding()]

        Param(
            [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName=$True)]
            [Alias('Osm_Id')]
            [String[]]$OsmId,

            [Parameter(ParameterSetName = 'ByOSMDetails', Position = 2)]
            [String]$Class,

            [ValidateSet('xml', 'json', 'jsonv2', 'geojson', 'geocodejson', 'psobject')]
            [Alias('Format')]
            [String]$OutputFormat = 'psobject',

            [Switch]$Addressdetails,
            [Switch]$LinkedPlaces,
            [Switch]$Addressdetails,

            [String]$RawParameter,


            [String]$Endpoint = '/lookup?'
        )

        Process {

        $ConstructedPath = $Endpoint

        # Append parameters for different sets
        If($PlaceId) { $ConstructedPath += "place_id=$PlaceId&" }

        If($OsmId) { $ConstructedPath += "osmid=$OsmId&" }
        If($OsmType) {
            Switch($OsmType) {
                'Node'      { $ConstructedPath += "osmtype=N&" }
                'Way'       { $ConstructedPath += "osmtype=W&" }
                'Relation'  { $ConstructedPath += "osmtype=R&" }
            }
        }
        If($Class) { $ConstructedPath += "class=$Class&" }

        # Apend the output format
        # We will only need the psobject value for later output
        If($OutputFormat -ne 'psobject') {
            $ConstructedPath += "format=$OutputFormat&"
        } Else {
            $ConstructedPath += 'format=json&'
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

        } # End Process
    }