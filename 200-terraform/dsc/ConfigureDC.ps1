# Preparing to run the real DSC script

# Instal the nuget provider
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Trust the PSGallery repo
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted


Install-Module xActiveDirectory,xComputerManagement,xNetworking -confirm:$false