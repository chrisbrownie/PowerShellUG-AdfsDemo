# Preparing to run the real DSC script

function DownloadFilesFromRepo {
Param(
    [string]$Owner,
    [string]$Repository,
    [string]$Path,
    [string]$Filter = "*",
    [string]$DestinationPath
    )

    $baseUri = "https://api.github.com/"
    $args = "repos/$Owner/$Repository/contents/$Path"
    $wr = Invoke-WebRequest -Uri $($baseuri+$args)
    $json = $wr.Content | ConvertFrom-Json
    $files = $json | Select-Object -ExpandProperty download_url | Where-Object { $_ -ilike $Filter }

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
            Invoke-WebRequest -Uri $file -OutFile $fileDestination -ErrorAction Stop
            "Grabbed '$file'"
        } catch {
            throw "Unable to download '$file'"
        }
    }

}

# Grab the bits and pieces we need
DownloadFilesFromRepo -Owner chrisbrownie -Repository "PowerShellUG-AdfsDemo" -Path "adfsscripts" -Filter "*.ps1" -DestinationPath "C:\adfsscripts\"

# Install the nuget provider
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Trust the PSGallery repo
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

Install-Module xComputerManagement,xActiveDirectory,xNetworking -confirm:$false

Invoke-WebRequest -Uri https://raw.githubusercontent.com/chrisbrownie/PowerShellUG-AdfsDemo/master/terraform/dsc/DSC-FS.ps1 -UseBasicParsing | Invoke-Expression