[string]$TruncationCharSequence1 = [char]0x393 # Gamma
[string]$TruncationCharSequence2 = [char]0xC7  # C-Cedilla
[string]$TruncationCharSequence3 = [char]0xAA  # Feminine ordinal indicator
[string]$TruncationCharSequence = "$TruncationCharSequence1$TruncationCharSequence2$TruncationCharSequence3"
[string]$TruncationChar = [char]0x2026 # Represents the ellipsis character
[string]$TruncationRegex = "($TruncationChar|$TruncationCharSequence)"


<#
.DESCRIPTION
	Parse a text-based table for attributes that characterize it.
.OUTPUTS
	[PSCustomObject] Metadata for the table.
#>
function Get-TextTableInfo
{
	[CmdletBinding()]
	param (
		# The text-based table to extract information about.
		[Parameter()]
		[string[]]$Text,

		# A regular expression to determine where the column header ends and
		# table data begins. If null, empty, or whitespace, the first line will
		# be treated as the header row, and subsequent lines will be the table
		# data. The default regex requires at least two dashes for the row
		# separator. This is to accomodate tools that cycle through '-', '\',
		# '|', and '/' as a busy sequence.
		[Parameter()]
		[string]$HeaderRowSeparatorRegEx = '^\s*\-\s*\-+[\s\-]*$',

		# May be optionally set to indicate that no header separator exists.
		# This is automatically set if $HeaderRowSeparatorRegEx is null, empty,
		# or whitespace.
		[Parameter()]
		[switch]$NoHeaderSeparator,

		# A regular expression to determine the last line of the table.
		# By default, this is the first empty line in the output.
		[Parameter()]
		[string]$LastLineRegEx = '^\s*$'
	)

	if ($NoHeaderSeparator -or [string]::IsNullOrWhiteSpace($HeaderRowSeparatorRegEx)) {
		$NoHeaderSeparator = $true
		$separatorMatch = $Text | Select-String -Pattern $Text[0]
	} else {
		$separatorMatch = @($Text | Select-String -Pattern $HeaderRowSeparatorRegEx)

		if ($separatorMatch.Count -eq 0)
		{
			return $null
		}
	}

	# Only use first match
	$separatorMatch = $separatorMatch[0]

	$terminatorMatch = @($Text[$separatorMatch.LineNumber..($Text.Count-1)] | Select-String -Pattern $LastLineRegEx)

	if ($terminatorMatch.Count -eq 0) {
		$rowCount = $Text.Count - $separatorMatch.LineNumber
	} else {
		$rowCount = $terminatorMatch[0].LineNumber - 2
	}

	# Compute the column width by determining the offset between the first character of adjecent header names.
	if ($NoHeaderSeparator) {
		$headerRow = $separatorMatch.LineNumber - 1
	} else {
		$headerRow = $separatorMatch.LineNumber - 2
	}
	$headerNames = $Text[$headerRow] | Select-String '[a-zA-Z]+' -AllMatches

	$tableInfo = [PSCustomObject]@{
		FirstRow = $separatorMatch.LineNumber
		LastRow = $separatorMatch.LineNumber + $rowCount
		RowCount = $rowCount
		ColumnInfo = $null
	}

	$columnMetadata = @()

	for ($columnIndexNumber = 0; $columnIndexNumber -lt $headerNames.Matches.Count; $columnIndexNumber++)
	{
		if ($columnIndexNumber -eq ($headerNames.Matches.Count - 1)) {
			if ($NoHeaderSeparator) {
				# In this case, the column's width should be based on the max line length of all the rows
				$maxLength = 0; @($Text[$separatorMatch.LineNumber..($separatorMatch.LineNumber + $rowCount - 1)]) | ForEach-Object {
					$maxLength = [Math]::Max($maxLength, $_.Length)
				}
				$columnWidth = $maxLength - $headerNames.Matches[$columnIndexNumber].Index
			} else {
				# NOTE: This may need similar logic used in $NoHeaderSeparator above. This would mainly be
				# for tables where the separator row does not span the whole line and instead only underlines
				# the column header name. This is the case for powershell-like tables (via Format-Table).
				$columnWidth = $Text[$headerRow].Length - $headerNames.Matches[$columnIndexNumber].Index
			}
		} else {
			$columnWidth = $headerNames.Matches[$columnIndexNumber + 1].Index - $headerNames.Matches[$columnIndexNumber].Index
		}

		$columnItem = [PSCustomObject]@{
			Name = $headerNames.Matches[$columnIndexNumber].Value
			StartIndex = $headerNames.Matches[$columnIndexNumber].Index
			EndIndex = ($headerNames.Matches[$columnIndexNumber].Index + $columnWidth - 1)
			Width = $columnWidth
		}

		$columnMetadata += $columnItem
	}

	$tableInfo.ColumnInfo = $columnMetadata
	return $tableInfo
}

<#
.DESCRIPTION
	Returns a PSCustomObject table entry based on table metadata.
#>
function ConvertFrom-TextTableItem
{
	param (
		# The table metadata.
		[PSCustomObject]$TableInfo,

		# The entry to convert.
		[string]$ItemText,

		# When set, additional properties will be created to indicate whether
		# a value contains a trialing ellipsis, indicating the value is
		# truncated.
		[switch]$ReportTrucated
	)

	$Entry = $ItemText.Replace($TruncationCharSequence, $TruncationChar)
	$item = New-Object PSObject

	foreach ($columnInfo in $TableInfo.ColumnInfo)
	{
		try {
			if ($columnInfo.StartIndex + $columnInfo.Width -gt $Entry.Length) {
				$entryField = $Entry.Substring($columnInfo.StartIndex).Trim()
			} else {
				$entryField = $Entry.Substring($columnInfo.StartIndex, $columnInfo.Width).Trim()
			}
		} catch {
			$entryField = ""
		}

		if ($ReportTrucated) {
			$item | Add-Member -Type NoteProperty -Name "$($columnInfo.Name)Truncated" -Value ($entryField -match $TruncationRegex)
		}

		$item | Add-Member -Type NoteProperty -Name $columnInfo.Name -Value $entryField
	}

	return $item
}

<#
.DESCRIPTION
	Converts a text-based table into a PSCustomObject[] based on the detected
	(column) metadata from the table. NOTE: In the case where multiple tables
	in the output exists, only the first table will be processed.
#>
function ConvertFrom-TextTable
{
	[CmdletBinding(PositionalBinding)]
	param (
		# The text-based table to convert to a PSCustomObject.
		[Parameter(ValueFromPipeline)]
		[string[]]$Text,

		# May be optionally set to indicate that no header separator exists.
		# This is automatically set if $HeaderRowSeparatorRegEx is null, empty,
		# or whitespace.
		[Parameter()]
		[switch]$NoHeaderSeparator,

		# Contains metadata describing the structure of the table.
		# Use Get-TextTableInfo for PSCustomObject.
		[Parameter()]
		[PSCustomObject]$TableInfo,

		# A regular expression to determine the last line of the table.
		# By default, this is the first empty line in the output.
		[Parameter()]
		[string]$LastLineRegEx = '^\s*$'
	)

	begin
	{
		if ($null -eq $TableInfo) {
			$textRows = @()
		} else {
			$rowIndex = 0;
		}
	}
	process
	{
		if ($null -eq $TableInfo) {
			$textRows += $Text
		} else {
			if ($rowIndex -ge $TextInfo.FirstRow -and $rowIndex -ge $TextInfo.LastRow) {
				ConvertFrom-TextTableItem -TableInfo $TextInfo -ItemText $Text
			}
			$rowIndex++
		}
	}
	end
	{
		if ($null -eq $TableInfo) {
			$TextInfo = Get-TextTableInfo -Text $textRows -LastLineRegEx $LastLineRegEx -NoHeaderSeparator:$NoHeaderSeparator
			$textRows[$TextInfo.FirstRow..$TextInfo.LastRow] | ForEach-Object { ConvertFrom-TextTableItem -TableInfo $TextInfo -ItemText $_ }
		}
	}
}
