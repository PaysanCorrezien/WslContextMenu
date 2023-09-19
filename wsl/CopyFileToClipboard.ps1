param (
    [string]$filePath
)

Add-Type -AssemblyName System.Windows.Forms
$paths = New-Object System.Collections.Specialized.StringCollection
$paths.Add($filePath)
[System.Windows.Forms.Clipboard]::SetFileDropList($paths)

