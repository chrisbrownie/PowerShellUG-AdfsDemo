$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Describe "AdfsTests" {
    It "has AD FS Installed" {
        Get-WindowsFeature Adfs-Federation |
            Where-Object { $_.Installed -eq $true } |
            Should Be $true
    }

    It "has AD FS Configured" {
        if ((Get-AdfsProperties).Identifier) {
            $configured = $true
        } else {
            $configured = $false
        }
        $configured | Should Be $true
    } 

    It "has AD FS Running" {
        if ((Get-Service AdfsSrv).Status -eq "Running") {
            $running = $true
        } else {
            $running = $false
        }
        $running | Should Be $true
    }

    It "is running WS2016 FBL" {
        Get-AdfsProperties | Select -Expand CurrentFarmBehavior | Should Be 3
    }

    It "has KMSI enabled" {
        (Get-AdfsProperties).EnableKmsi |
            Should Be $true
    }

    It "has End-User Password Change Enabled" {
        $ep = Get-AdfsEndpoint "/adfs/portal/updatepassword/"
        if (
            ($ep.Enabled -eq $true) `
            -and ($ep.Proxy -eq $true)
        ) {
            $eupcEnabled = $true
        } else {
            $eupcEnabled = $false
        }

        $eupcEnabled | Should Be $true
    }

    It "has WS-Trust 1.3 Enabled" {
        $ep = Get-AdfsEndpoint "/adfs/services/trust/13/windowstransport"
        if (
            ($ep.Enabled -eq $true) `
            -and ($ep.Proxy -eq $true)
        ) {
            $eupcEnabled = $true
        } else {
            $eupcEnabled = $false
        }

        $eupcEnabled | Should Be $true
    }

    It "has Office 365 Password Expiry Notifications Enabled" {
        $true | Should Be $False
    }

    It "has Office 365 AuthN Methods References Enabled" {
        $true | Should Be $False
    }

    It "has Extranet Lockout enabled" {
        (Get-AdfsProperties).EnableExtranetLockout |
            Should Be $true
    }

    It "has extended token signing/decrypting lifetimes" {
        $true | Should Be $False
    }

    It "has sensible logging enabled" {
        $RequiredLogLevels = @(
            "Information",
            "Errors",
            "Verbose",
            "Warnings",
            "FailureAudits",
            "SuccessAudits"
        )

        $ActiveLogLevels = (Get-AdfsProperties).LogLevel

        if (Compare-Object $RequiredLogLevels $ActiveLogLevels) {
            # If a value is returned, there's a mismatch
            # We're turning all logging on, so the logging can't be *too* Verbose
            # So any return of data must be a fail
            $sensibleLogging = $false
        } else {
            # If no results returned, the log levels match
            $sensibleLogging = $true
        }
        $sensibleLogging | Should Be $true
    }
}