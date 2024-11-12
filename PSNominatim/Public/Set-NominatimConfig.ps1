Function Set-NominatimConfig {
	[CmdletBinding()]

    Param(
        [Parameter(Mandatory)]
        [String]$Parameter,
        [Parameter(Mandatory)]
        $Value
    )

    # Check OS to decide configuration path
    $Path = If($IsWindows) {
        Join-Path -Path $Env:APPDATA -ChildPath 'PSNominatim'
    } Else {
        Join-Path -Path $Env:HOME -ChildPath 'PSNominatim'
    }

    $FilePath = Join-Path -Path $Path -ChildPath 'module.config.json'

    If(-not (Test-Path $FilePath)) {
        Write-Verbose "Could not find configuration file. Will be created"
        New-NominatimConfig
    }

    Try {
        $Configuration = Get-Content $FilePath | ConvertFrom-Json -AsHashtable
    } Catch {
        Write-Error "Could not read $FilePath"
        Write-Error $_

        Return
    }

    # Change the parameter
    $Configuration."$Parameter" = $Value

    Write-Verbose "Set modified content to configuration file"
    $Configuration | ConvertTo-Json | Set-Content -Path $FilePath
}
