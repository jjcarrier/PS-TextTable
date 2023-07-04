# TextTable Converter PowerShell Module

[![CI](https://github.com/jjcarrier/TextTable/actions/workflows/ci.yml/badge.svg)](https://github.com/jjcarrier/TextTable/actions/workflows/ci.yml)

## Description

Provides a simple way to convert text-based tables into PowerShell objects.

The underlying `ConvertFrom-TextTable` cmdlet provides:

* Conversion from text-based tables often encountered in cmd/bash-centric tools to PowerShell objects.
* Various options for handling the conversion logic when working with more complex/verbose output.
* Detect (and optionally report) table truncation (indicate by presence of trailing ellipsis).

Below are the `current` requirements for table conversion:

* Column headers must be left aligned.
* Column headers must be single words.
* Column headers must be on a single line.
* In the absence of a column separator, the first line of the `-Text` input is treated as the column header.
* All rows in the table respect the bounds setup by the first character of each column header.

With the above requirements, it is possible to support a simple solution for parsing table entries with spaces.

> __NOTE__: The primary use-case of this module was to provide a simple way to access the output of `winget update`.

## Installation

Initialize the repository:

Add the following to `$PROFILE` replacing `$PathToTextTablePsm1` with the path to the TextTable `.psm1` file:

```pwsh
Import-Module $PathToTextTablePsm1
```

Alternatively, this module may be installed in the [$PSModulePath](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_psmodulepath?view=powershell-7.3)

## Usage

An example use-case of this cmdlet is to interact with the `winget update` output as shown below:

```pwsh
$updates = @(winget update | ConvertFrom-TextTable)

if ($updates.Count -gt 0) {
    Write-Output "Below are all of the available updates:"
    $updates | Format-Table
    Write-Output "The first available update is:"
    $updates[0]
}
```

It is worth noting that the above is not a complete solution to capturing the updates from `winget update` as this
may output more than one tab that may need to be parsed and this cmdlet only parses the first table encountered.
Additionally, the table that is output typically includes a count of how many packages are upgradable before a
blank line is encountered. To solve both of these issues means that the user should:

* Split the `winget update` output to separate the two tables and pass them to this cmdlet individually
* Use the `-LastLineRegEx` option to specify the line containing the number of upgradable packages as the last line,
  or simply drop the entry from the resulting array of objects.

## Testing

Basic tests are available via [Pester](https://pester.dev/). With Pester setup, run:

```pwsh
Invoke-Pester
```
