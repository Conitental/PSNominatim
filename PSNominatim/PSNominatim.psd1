# Module manifest docs: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_module_manifests

@{

  RootModule = 'PSNominatim.psm1'
  ModuleVersion = '1.0.0'
  GUID = '1f1b55c2-4af1-49d0-8504-5c19cd6803de'
  Author = 'Conitental'
  Description = 'PowerShell geocoder leveraging the Nomitatim API of openstreetmap.org'

  FunctionsToExport = @(
    'Get-NominatimCity',
    'Invoke-NominatimSearchRequest',
    'Invoke-NominatimDetailsRequest'
  )

}
