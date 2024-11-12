Function Get-NominatimConfig {
	[Cmdletbinding()]

	Param(
        [String]$Parameter
	)

    $Path = If($IsWindows) {
        Join-Path -Path $Env:APPDATA -ChildPath 'PSNominatim'
    } Else {
        Join-Path -Path $Env:HOME -ChildPath 'PSNominatim'
    }

    $FilePath = Join-Path -Path $Path -ChildPath 'module.config.json'

    Try {
        $Configuration = Get-Content $FilePath | ConvertFrom-Json -AsHashtable
    } Catch {
        Write-Error "Could not read $FilePath"
        Write-Error $_

        Return
    }

    If($Parameter) {
        # Only return the expanded Parameter from config
        Return $Configuration."$Parameter"
    } Else {
        # Return whole config by default
        Return $Configuration
    }
}
