Function Get-NominatimCity {
	[CmdletBinding()]

	Param(
		[String]$Query
	)

	Invoke-NominatimSearchRequest -Query $Query -FeatureType 'city'
}
