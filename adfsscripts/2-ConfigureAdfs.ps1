###############################################################################
# PowerShellUG-AdfsDemo 2-ConfigureAdfs.ps1
#
# This script acquires a certificate and configures AD FS 
#
# Author: Chris Brown (chris@chrisbrown.id.au)
# Date:   08/12/2016
###############################################################################

# Domain name we want to use for AD FS
$adfsFqdn = "sts.lab.flamingkeys.com"

# Go request a certificate from the online CA
# (obviously this is no good for prod)
$myCert = Get-Certificate -Template WebServer `
    -CertStoreLocation Cert:\LocalMachine\My `
    -DnsName "$adfsFqdn" `
    -SubjectName "CN=$adfsFqdn" 

# Create the KdsRootKey in AD so we can use a GMSA for AD FS
Add-KdsRootKey -EffectiveTime (Get-Date).AddHours(-10)

# Instal lAD FS using the name, certificate, and KDS root key from above
Install-AdfsFarm -CertificateThumbprint $myCert.Certificate.Thumbprint `
    -FederationServiceName "$adfsFqdn" `
    -GroupServiceAccountIdentifier "LAB\svc_adfs$"

# Enable the IdP Initiated Sign-On Page
Set-AdfsProperties -EnableIdPInitiatedSignonPage:$true