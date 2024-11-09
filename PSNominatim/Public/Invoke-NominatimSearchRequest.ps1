Function Invoke-NominatimSearchRequest {
	[CmdletBinding(DefaultParameterSetName = 'FreeFormQuery')]

	Param(
		[Parameter(Mandatory, ParameterSetName = 'FreeFormQuery', Position = 0)]
		[String]$Query,

		[Parameter(ParameterSetName = 'StructuredQuery', Position = 0)]
		[String]$Amenity,

		[Parameter(ParameterSetName = 'StructuredQuery', Position = 1)]
		[String]$Street,

		[Parameter(ParameterSetName = 'StructuredQuery', Position = 2)]
		[String]$City,

		[Parameter(ParameterSetName = 'StructuredQuery', Position = 3)]
		[String]$County,

		[Parameter(ParameterSetName = 'StructuredQuery', Position = 4)]
		[String]$State,

		[Parameter(ParameterSetName = 'StructuredQuery', Position = 5)]
		[String]$Country,

		[Parameter(ParameterSetName = 'StructuredQuery', Position = 6)]
		[String]$PostalCode,


		[ValidateSet('xml', 'json', 'jsonv2', 'geojson', 'geocodejson', 'psobject')]
		[Alias('Format')]
		[String]$OutputFormat = 'psobject',

		[ValidateRange(1, 40)]
		[int]$Limit,

		[Switch]$Addressdetails,
		[Switch]$ExtraTags,
		[Switch]$NameDetails,

		[ValidateSet('country', 'city', 'state', 'settlement')]
		[String]$FeatureType,

		[String]$RawParameter,

		[String]$Endpoint = 'https://nominatim.openstreetmap.org/search?'
	)

	$ConstructedUri = $Endpoint

	# Append the single query for free form requests
	If($Query) { $ConstructedUri += "q=$Query&" }

	# Append all of the parameters for structured queries
	If($Amenity) { $ConstructedUri += "amenity=$Amenity&" }
	If($Street) { $ConstructedUri += "street=$Street&" }
	If($City) { $ConstructedUri += "city=$City&" }
	If($County) { $ConstructedUri += "county=$County&" }
	If($State) { $ConstructedUri += "county=$State&" }
	If($Country) { $ConstructedUri += "country=$Country&" }
	If($PostalCode) { $ConstructedUri += "postalcode=$PostalCode&" }

	# Apend the output format
	# We will only need the psobject value for later output
	If($OutputFormat -ne 'psobject') {
		$ConstructedUri += "format=$OutputFormat&"
	} Else {
		$ConstructedUri += 'format=jsonv2&'
	}

	# Append the generic parameters
	If($Limit) { $ConstructedUri += "limit=$Limit&" }
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
}
