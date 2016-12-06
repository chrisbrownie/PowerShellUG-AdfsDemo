###############################################################################
# PowerShellUG-AdfsDemo ConfigureFS.ps1
#
# This script bootstraps the instance in preparation for DSC configuration
#
# Author: Chris Brown (chris@chrisbrown.id.au)
# Date:   08/12/2016
###############################################################################

# This script downloads files from a GitHub repo
function DownloadFilesFromRepo {
Param(
    [string]$Owner,
    [string]$Repository,
    [string]$Path,
    [string]$DestinationPath
    )

    $baseUri = "https://api.github.com/"
    $args = "repos/$Owner/$Repository/contents/$Path"
    $wr = Invoke-WebRequest -Uri $($baseuri+$args)
    $objects = $wr.Content | ConvertFrom-Json
    $files = $objects | where {$_.type -eq "file"} | Select -exp download_url
    $directories = $objects | where {$_.type -eq "dir"}
    
    $directories | ForEach-Object { 
        DownloadFilesFromRepo -Owner $Owner -Repository $Repository -Path $_.path -DestinationPath $($DestinationPath+$_.name)
    }

    
    if (-not (Test-Path $DestinationPath)) {
        # Destination path does not exist, let's create it
        try {
            New-Item -Path $DestinationPath -ItemType Directory -ErrorAction Stop
        } catch {
            throw "Could not create path '$DestinationPath'!"
        }
    }

    foreach ($file in $files) {
        $fileDestination = Join-Path $DestinationPath (Split-Path $file -Leaf)
        try {
            Invoke-WebRequest -Uri $file -OutFile $fileDestination -ErrorAction Stop -Verbose
            "Grabbed '$($file)' to '$fileDestination'"
        } catch {
            throw "Unable to download '$($file.path)'"
        }
    }

}

# Grab the bits and pieces we need to configure/build/skin/test AD FS 
DownloadFilesFromRepo -Owner chrisbrownie -Repository "PowerShellUG-AdfsDemo" -Path "adfsscripts" -DestinationPath "C:\adfs\"

# Install the nuget provider
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Trust the PSGallery repo
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

Install-Module xComputerManagement,xActiveDirectory,xNetworking,Pester -confirm:$false

Invoke-WebRequest -Uri https://raw.githubusercontent.com/chrisbrownie/PowerShellUG-AdfsDemo/master/terraform/dsc/DSC-FS.ps1 -UseBasicParsing | Invoke-Expression