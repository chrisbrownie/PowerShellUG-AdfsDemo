# Preparing to run the real DSC script

# Instal the nuget provider
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Trust the PSGallery repo
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted


Install-Module xActiveDirectory,xComputerManagement,xNetworking -confirm:$false

Invoke-WebRequest -Uri https://raw.githubusercontent.com/chrisbrownie/PowerShellUG-AdfsDemo/master/200-terraform/dsc/DSC-DC.ps1 -UseBasicParsing | Invoke-Expression