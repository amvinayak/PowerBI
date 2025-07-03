
# Create a New Folder
New-Item -Path 'D:\AllPBIFiles\' -ItemType Directory -Force

<#
  This script requires the MicrosoftPowerBIMgmt module.
  Run the following commands to install it if not already installed: 
  Find-Module -Name PowerShellGet
  Install-Module -Name MicrosoftPowerBIMgmt 
#>

<#
  If the login step to Power BI fails, try running the following line first:
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#>

# Log in to Power BI Service
Login-PowerBI -Environment Public

# Get all workspace names
$PBIWorkspaceList = Get-PowerBIWorkspace

# Loop through each workspace
foreach ($Workspace in $PBIWorkspaceList) {
    $FolderName = "D:\AllPBIFiles\" + $Workspace.Name
    New-Item -Path $FolderName -ItemType Directory -Force

    $PBIReports = Get-PowerBIReport -WorkspaceId $Workspace.Id

    # Loop through each report in the workspace
    foreach ($Report in $PBIReports) {
        Write-Host "Processing report: $($Report.Name)"

        $OutputFile = Join-Path -Path $FolderName -ChildPath ($Report.Name + ".pbix")

        # If the file exists, delete it first
        if (Test-Path $OutputFile) {
            Remove-Item $OutputFile -Force
        }

        # Export the report
        Export-PowerBIReport -WorkspaceId $Workspace.Id -Id $Report.Id -OutFile $OutputFile
    }
}
