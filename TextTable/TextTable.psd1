@{
    RootModule = 'TextTable.psm1'
    ModuleVersion = '1.0.2'
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

    FunctionsToExport = @(
        'Get-TextTableInfo',
        'ConvertFrom-TextTable')
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()

    # ModuleList = @()
    FileList = @(
        'TextTable.psd1',
        'TextTable.psm1'
    )

    PrivateData = @{

        PSData = @{
            Tags = @('Windows', 'MacOS', 'Linux', 'Text', 'Table', 'Converter')
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
