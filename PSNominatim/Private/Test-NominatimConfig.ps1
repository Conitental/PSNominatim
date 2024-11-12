Function Test-NominatimConfig {
    [CmdletBinding()]

    Param(
        [String]$Parameter
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

        # We do not return at this point as we wight be able to work with the default values
    }

    Try {
        $Configuration = Get-Content $FilePath | ConvertFrom-Json -AsHashtable
    } Catch {
        Write-Error "Could not read $FilePath"
        Write-Error $_

        Return $false
    }

    If(-not ($Configuration.ContainsKey($Parameter))) {
        Write-Error "Parameter $Parameter could not be found in configuration file:"
        Write-Error $FilePath

        Write-Error "Setup the configuration using Set-NominatimConfig"

        Return $false
    }

    If([String]::IsNullOrEmpty($Configuration."$Parameter")) {
        Write-Error "Parameter $Parameter is not configured in configuration file:"
        Write-Error $FilePath

        Write-Error "Setup the configuration using Set-NominatimConfig"

        Return $false
    }

    # If all tests were successful return something truthy
    Return $true
}
