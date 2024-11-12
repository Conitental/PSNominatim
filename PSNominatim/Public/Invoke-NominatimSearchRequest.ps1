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

		[String]$Endpoint = '/search?'
	)

	$ConstructedPath = $Endpoint

	# Append the single query for free form requests
	If($Query) { $ConstructedPath += "q=$Query&" }

	# Append all of the parameters for structured queries
	If($Amenity) { $ConstructedPath += "amenity=$Amenity&" }
	If($Street) { $ConstructedPath += "street=$Street&" }
	If($City) { $ConstructedPath += "city=$City&" }
	If($County) { $ConstructedPath += "county=$County&" }
	If($State) { $ConstructedPath += "county=$State&" }
	If($Country) { $ConstructedPath += "country=$Country&" }
	If($PostalCode) { $ConstructedPath += "postalcode=$PostalCode&" }

	# Apend the output format
	# We will only need the psobject value for later output
	If($OutputFormat -ne 'psobject') {
		$ConstructedPath += "format=$OutputFormat&"
	} Else {
		$ConstructedPath += 'format=jsonv2&'
	}

	# Append the generic parameters
	If($Limit) { $ConstructedPath += "limit=$Limit&" }
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
