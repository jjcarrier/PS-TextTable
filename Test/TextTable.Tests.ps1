# Basic tests for supporting various table formats

BeforeAll {
  Import-Module "$PSScriptRoot\..\TextTable\TextTable.psm1"
}

Describe 'ConvertFrom-TextTable' {
  It "returns an object only containing data from the first table when the pipelined text contains multiple tables with column-header separators" {
    $table = Get-Content "$PSScriptRoot/TextTests/winget.txt" | ConvertFrom-TextTable
    $table.Count | Should -Be 17
  }

  It "returns an object only containing data from the first table when the non-pipelined text contains multiple tables with column-header separators" {
    $table = ConvertFrom-TextTable -Text (Get-Content "$PSScriptRoot/TextTests/winget.txt")
    $table.Count | Should -Be 17
  }

  It "excludes and prevents further table parsing past the first -LastLineRegex match" {
    $table = Get-Content "$PSScriptRoot/TextTests/winget.txt" | ConvertFrom-TextTable -LastLineRegEx "\d+ upgrades available."
    $table.Count | Should -Be 16
  }

  It "treats the first row of -Text as the column header when -NoHeaderSeparator is set" {
    $table = Get-Content "$PSScriptRoot/TextTests/no-column-separator.txt" | ConvertFrom-TextTable -NoHeaderSeparator
    $table.Count | Should -Be 4
  }

  It "splits words that span across column boundaries" {
    $table = Get-Content "$PSScriptRoot/TextTests/not-a-wellformed-table.txt" | ConvertFrom-TextTable -NoHeaderSeparator
    $table.Count | Should -Be 1
    $table.ColA | Should -Be "Anoth"
    $table.ColB | Should -Be "er te"
    $table.ColC | Should -Be "st case."
  }

  It "trims indentation from the first column's header and values" {
    $table = Get-Content "$PSScriptRoot/TextTests/indented-numbers.txt" | ConvertFrom-TextTable
    $table.Count | Should -Be 4
    $table[0].Name | Should -Be "One"
  }

  It "does not truncate the last column of text" {
    $table = ConvertFrom-TextTable -Text (Get-Content "$PSScriptRoot/TextTests/winget.txt")
    $testEntry = $table | Where-Object { $_.Id -eq "Microsoft.VCRedist.2013.x64" }
    $testEntry.Available | Should -Be "12.0.40664.0"
  }
}
