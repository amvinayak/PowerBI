# Function to open a file dialog and select a PBIX file
function Get-FileName($initialDirectory) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.InitialDirectory = $initialDirectory
    $OpenFileDialog.Filter = "PBIX (*.pbix)|*.pbix"
    $OpenFileDialog.ShowDialog() | Out-Null

    return $OpenFileDialog.FileName
}

# Function to check if a file is locked
function IsFileLocked([string]$filePath) {
    Rename-Item $filePath $filePath -ErrorVariable errs -ErrorAction SilentlyContinue
    return ($errs.Count -ne 0)
}

# Choose file
try {
    $pathn = Get-FileName
} catch {
    Write-Host "Incompatible File"
    exit
}

# Check for errors
if ([string]::IsNullOrEmpty($pathn)) {
    exit
} elseif (IsFileLocked($pathn)) {
    exit
}

# Run script
else {
    # Load compression assembly
    [Reflection.Assembly]::LoadWithPartialName('System.IO.Compression') | Out-Null

    # Rename .pbix to .zip
    $zipfile = $pathn.Substring(0, $pathn.Length - 4) + "zip"
    Rename-Item -Path $pathn -NewName $zipfile

    # Delete specific files from the zip
    $filesToDelete = 'Connections', 'SecurityBindings'
    $stream = New-Object IO.FileStream($zipfile, [IO.FileMode]::Open)
    $mode = [IO.Compression.ZipArchiveMode]::Update
    $zip = New-Object IO.Compression.ZipArchive($stream, $mode)

    $zip.Entries | Where-Object { $filesToDelete -contains $_.Name } | ForEach-Object { $_.Delete() }

    # Close and dispose resources
    $zip.Dispose()
    $stream.Close()
    $stream.Dispose()

    # Rename back to .pbix and open
    Rename-Item -Path $zipfile -NewName $pathn
    Invoke-Item $pathn
}
