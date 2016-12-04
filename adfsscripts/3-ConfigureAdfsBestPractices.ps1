# From https://flamingkeys.com/adfsbp16

# Set the below to $true to enable each feature. Setting a value to $false will
# not disable it, the script will just make no changes
$BPs = @{
    "RaiseFBL" = $true
    "EnableKMSI" = $true
    "EnableEndUserPasswordChange" = $true
    "WsTrust13" = $true
    "Office365PasswordExpiry" = $true
    "Office365AuthNMethods" = $true
    "ExtranetLockout" = $true
    "ExtendedTokenCertificateLifetime" = $true
    "SensibleLogging" = $true
}

$ExtranetLockoutThreshold = 3
$ExtranetObservationWindow = 30
$ExtranetLockoutRequirePDC = $false

$VerbosePreference = "Continue"

# Ensure AD FS farm behaviour level is 2016


# Enable KMSI
if ($BPs.EnableKMSI) {
    Write-Verbose "Enabling Keep Me Signed In (KMSI)"
    Set-AdfsProperties -EnableKmsi:$true
} else {
    Write-Verbose "KMSI check is disabled"
}

# Enable end-user password change
if ($BPs.EnableEndUserPasswordChange) {
    Write-Verbose "Enabling End-User Password Change"
    Enable-AdfsEndpoint "/adfs/portal/updatepassword/"
    Set-AdfsEndpoint "/adfs/portal/updatepassword/" -Proxy:$true
} else {
    Write-Verbose "End-User Password Change check is disabled"
}

# Enable WS-Trust 1.3
if ($BPs.WsTrust13) {
    Write-Verbose "Enabling WS-Trust 1.3"
    Enable-AdfsEndpoint -TargetAddressPath "/adfs/services/trust/13/windowstransport"
} else {
    Write-Verbose "WS-Trust 1.3 check is disabled"
}

# Enable Office 365 Password Expiry Notifications
if ($BPs.Office365PasswordExpiry) {
    Write-Verbose "Enabling Office 365 Password Expiry Claim"
    Write-Warning "NOT IMPLEMENTED"
} else {
    Write-Verbose "Office 365 Password Expiry check is disabled"
}

# Enable OFfice 365 AuthN Methods References
if ($BPs.Office365AuthNMethods) {
    Write-Verbose "Enabling Office 365 AuthN Methods Claim"
    Write-Warning "NOT IMPLEMENTED"
} else {
    Write-Verbose "Office 365 AuthN Methods check is disabled"
}

# Enable Extranet Lockout
if ($BPs.ExtranetLockout) {
    Write-Verbose "Enabling Extranet Lockout"
    Set-AdfsProperties -EnableExtranetLockout:$true `
        -ExtranetLockoutThreshold $ExtranetLockoutThreshold `
        -ExtranetObservationWindow (New-TimeSpan -Minutes $ExtranetObservationWindow) `
        -ExtranetLockoutRequirePDC $ExtranetLockoutRequirePDC
} else {
    Write-Verbose "Extranet Lockout check is disabled"
}

if ($BPs.ExtendedTokenCertificateLifetime) {
    Write-Verbose "Extending Token Certifciate Lifetime"
    Set-AdfsProperties -CertificateDuration 1827
    # Add check here to renew the certs only if there are no relying parties configured
    Update-AdfsCertificate -CertificateType Token-Decrypting -Urgent
    Update-AdfsCertificate -CertificateType Token-Signing -Urgent
} else {
    Write-Verbose "Extended Token Certificate Lifetime check disabled"
}

# Enable Sensible Logging
if ($BPs.SensibleLogging) {
    Write-Verbose "Enabling Sensible Logging"
    Set-ADFSProperties –LogLevel Information,Errors,Verbose,Warnings,FailureAudits,SuccessAudits
    auditpol.exe /set /subcategory:"Application Generated" /failure:enable /success:enable
} else {
    Write-Verbose "Sensible Logging check is disabled"
}


Write-Verbose "Restarting AD FS"
Restart-Service AdfsSrv -Force
Write-Warning "AD FS has been restarted on this server, you must restart it on all other servers in the farm."