# https://pleasework.robbievance.net/howto-desired-state-configuration-dsc-overview/

$settings = @{
    "ComputerName"    = "DC"
    "DomainFqdn"      = "lab.flamingkeys.com"
    "DomainNetBIOS"   = "lab"
    "DNSIP"           = "127.0.0.1"
    "DNSForwarderIPs" = "8.8.8.8","8.8.4.4"
    "Password"        = "Pass@word1"
    "DNSClientInterfaceAlias" = "Ethernet"
    "DomainAdminUser" = "alan.reid"
}

# Instal the nuget provider
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Trust the PSGallery repo
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted


Install-Module xActiveDirectory,xComputerManagement,xNetworking -confirm:$false

configuration LCM {
    LocalConfigurationManager {            
        RebootNodeIfNeeded = $true
    }            
}

LCM -OutputPath $env:TEMP
Set-DscLocalConfigurationManager -Path $env:TEMP

$ConfigData = @{
    AllNodes = @(@{
        NodeName = "localhost"
        MachineName = $settings.ComputerName
        DomainFqdn = $settings.DomainFqdn
        DomainNetbios = $settings.DomainNetBIOS
        Password = $settings.Password
        DomainAdminUser = $settings.DomainAdminUser
    })
}

Configuration DC {
    Import-DscResource -ModuleName xActiveDirectory, xComputerManagement, xNetworking

    Node $AllNodes.NodeName {
        LocalConfigurationManager {
            ActionAfterReboot = "ContinueConfiguration"
            ConfigurationMode = "ApplyAndAutoCorrect"
            RebootNodeIfNeeded = $true
        }

        $Credential = New-Object System.Management.Automation.PSCredential(
            "$($Node.DomainFqdn)\Administrator",
            (ConvertTo-SecureString $Node.Password -AsplainText -Force)
        )

        xComputer SetName {
            Name = $Node.MachineName
        }

        # Do I need to do this?
        <#xIPAddress SetIP {

        }#>

        xDNSServerAddress SetDNS {
            Address = $Node.DNSIP
            InterfaceAlias = $Node.DNSClientInterfaceAlias
            AddressFamily = "IPv4"
        }

        # Make sure AD DS is installed
        WindowsFeature ADDSInstall {
            Ensure = 'Present'
            Name   = 'AD-Domain-Services'
        }

        # Make sure AD DS Tools are installed
        WindowsFeature ADDSTools {
            Ensure = 'Present'
            Name   = 'RSAT-ADDS'
        }

        xADDomain DC {
            DomainName = $node.DomainFqdn
            DomainNetbiosName = $node.DomainNetBIOS
            DomainAdministratorCredential = $Credential
            SafemodeAdministratorPassword = $Credential
            DependsOn = '[xComputer]SetName', '[xIPAddress]SetIP', '[WindowsFeature]ADDSInstall'
        }

        xADUser demouser1 {
            DomainAdministratorCredential = $Credential
            DomainName                    = $Node.DomainFqdn
            UserName                      = $Node.DomainAdminUser
            Password                      = $Credential
            Ensure                        = 'Present'
        }

        Script PromoteDemoUser1 {
            SetScript = { Add-ADGroupMember -Identity "Domain Admins" -Members $using:Node.DomainAdminUser }
            TestScript = { Get-ADGroupMember -Identity "Domain Admins" | Where {$_.Name -eq $using:Node.DomainAdminUser } }
            GetScript = { Get-ADGroupMember -Identity "Domain Admins" | Where {$_.Name -eq $using:Node.DomainAdminUser } }
        }
    }
}

DC -ConfigurationData $ConfigData
Start-DscConfiguration -Wait -Force -Path .\DC -Verbose