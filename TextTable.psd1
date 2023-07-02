@{
    RootModule = 'TextTable.psm1'
    ModuleVersion = '1.0'
    GUID = '16a5ab4c-4d8c-42d6-8f72-227aea552a84'
    Author = 'Jon Carrier'
    CompanyName = 'Unknown'
    Copyright = '(c) Jon Carrier. All rights reserved.'
    Description = 'Provides a generic toolset to convert text-based table output from various CLI programs into PowerShell objects.'

    # CompatiblePSEditions = @()
    # PowerShellVersion = ''
    # RequiredModules = @()
    # ScriptsToProcess = @()
    # TypesToProcess = @()
    # FormatsToProcess = @()
    # NestedModules = @()

    FunctionsToExport = @()
    CmdletsToExport = @(
        "Get-TextTableInfo",
        "ConvertFrom-TextTable"
    )
    VariablesToExport = '*'
    AliasesToExport = @()

    # ModuleList = @()
    # FileList = @()

    PrivateData = @{

        PSData = @{
            Tags = @('Text', 'Table', 'Converter')
            LicenseUri = 'https://github.com/jjcarrier/PS-TextTable/blob/main/LICENSE'
            ProjectUri = 'https://github.com/jjcarrier/PS-TextTable'
            # IconUri = ''
            # ReleaseNotes = ''
            # Prerelease = ''
            # RequireLicenseAcceptance = $false
            # ExternalModuleDependencies = @()

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfoURI = ''
    # DefaultCommandPrefix = ''
}
