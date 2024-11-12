Function New-NominatimConfig {
    [CmdletBinding()]

    Param(
        [Switch]$Force
    )

    # Set the default configuration path depending on the operating system
    $Path = If($IsWindows) {
        Join-Path -Path $Env:APPDATA -ChildPath 'PSNominatim'
    } Else {
        Join-Path -Path $Env:HOME -ChildPath 'PSNominatim'
    }

    # Make sure we are having a home for our config file
    If(-not (Test-Path $Path)) {
        Write-Verbose "Create directory:"
        Write-Verbose $Path
        New-Item -ItemType Directory $Path | Out-Null
    }

    $FilePath = Join-Path -Path $Path -ChildPath 'module.config.json'

    $ConfigScaffold = @{
        NominatimServer = ''
    }

    If(Test-Path $FilePath) {
        Write-Verbose "Config file does already exist"

        If($Force) {
            Write-Verbose "-Force switch is set. Recreate configuration file"
        } Else {
            Return
        }
    }

    Write-Verbose "Write default values to configuration file"
    $ConfigScaffold | ConvertTo-Json | Set-Content -Path $FilePath
}
