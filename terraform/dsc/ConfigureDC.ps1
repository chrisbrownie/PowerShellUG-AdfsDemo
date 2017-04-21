###############################################################################
# PowerShellUG-AdfsDemo ConfigureDC.ps1
#
# This script bootstraps the instance in preparation for DSC configuration
#
# Author: Chris Brown (chris@chrisbrown.id.au)
# Date:   08/12/2016
###############################################################################

Write-Output "ConfigureDC.ps1 beginning"

# Install the nuget provider
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Trust the PSGallery repo
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

# Install the required DSC modules
Install-Module xActiveDirectory,xComputerManagement,xNetworking,xAdcsDeployment,xDnsServer,xSystemSecurity,Pester -confirm:$false

# Download and execute the configuration script from GitHub
Invoke-WebRequest -Uri https://raw.githubusercontent.com/chrisbrownie/PowerShellUG-AdfsDemo/master/terraform/dsc/DSC-DC.ps1 -UseBasicParsing | Invoke-Expression