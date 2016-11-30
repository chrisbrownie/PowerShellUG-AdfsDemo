# https://pleasework.robbievance.net/howto-desired-state-configuration-dsc-overview/

$settings = @{
    "ComputerName"    = "DC"
    "DomainFqdn"      = "lab.flamingkeys.com"
    "DomainNetBIOS"   = "lab"
    "DNSIP"           = "127.0.0.1"
    "DNSForwarderIPs" = "8.8.8.8","8.8.4.4"
    "Password"        = "Pass@word1"
    "DNSClientInterfaceAlias" = $(Get-NetIPConfiguration | Select -first 1 | Select -ExpandProperty InterfaceAlias)
    "DomainAdminUser" = "xareid"
    "DomainAdminUserDisplayName" = "Alan Reid (Admin)"
    "LabLifeSpan"      = 4 #hours (until the lab shuts itself down)
}


#region schedtask
# Add a scheduled task to shut the machine down (at which point the host will terminate it)
$EndOfDays = (Get-Date).AddHours($LabLifeSpan)
$action = New-ScheduledTaskAction -Execute 'shutdown.exe' -Argument '-s -t 180 -f'
$trigger = New-ScheduledTaskTrigger -Once -At $EndOfDays
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Shut down computer" -Description "Shut down and trigger termination"
#endregion

configuration LCM {
    LocalConfigurationManager {            
        RebootNodeIfNeeded = $true
    }            
}

LCM -OutputPath $env:TEMP
Set-DscLocalConfigurationManager -Path $env:TEMP
# Show info for logging purposes
Get-DscLocalConfigurationManager

$ConfigData = @{
    AllNodes = @(@{
        NodeName = "localhost"
        MachineName = $settings.ComputerName
        DomainFqdn = $settings.DomainFqdn
        DomainNetbios = $settings.DomainNetBIOS
        Password = $settings.Password
        DomainAdminUser = $settings.DomainAdminUser
        DomainAdminUserDisplayName = $settings.DomainAdminUserDisplayName
        DNSClientInterfaceAlias = $settings.DNSClientInterfaceAlias
        DNSIP = $settings.DNSIP
        DnsForwarders = $settings.DnsForwarderIPs
        # DO NOT USE the below in production. Lab only!
        PsDscAllowPlainTextPassword = $true
        PSDscAllowDomainUser = $true
    })
}

Configuration DC {
    Import-DscResource -ModuleName xActiveDirectory, xComputerManagement, `
                        xNetworking, xAdcsDeployment, xDnsServer

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
            DependsOn = '[xComputer]SetName', '[WindowsFeature]ADDSInstall'
        }

        xDnsServerForwarder Forwarder {
            IsSingleInstance = 'Yes'
            IPAddresses = $node.DnsForwarders
            DependsOn = "[xADDomain]DC"
        }

        WindowsFeature ADCS-Cert-Authority {
            Ensure = 'Present'
            Name = 'ADCS-Cert-Authority'
        }

        WindowsFeature RSAT-ADCS {
            Ensure = 'Present'
            Name   = 'RSAT-ADCS'
            IncludeAllSubFeature = $true
        }

        WindowsFeature ADCS-Web-Enrollment {
            Ensure = 'Present'
            Name   = 'ADCS-Web-Enrollment'
            DependsOn = '[WindowsFeature]ADCS-Cert-Authority' 
        }

        WindowsFeature Web-Mgmt-Console {
            Ensure = 'Present'
            Name   = 'Web-Mgmt-Console'
        }

        xAdcsCertificationAuthority CA {
            Ensure            = 'Present'        
            Credential        = $Credential
            CAType            = 'EnterpriseRootCA'
            CACommonName      = "$($node.DomainNetBIOS) Root CA"
            HashAlgorithmName = 'SHA256'
            DependsOn         = '[WindowsFeature]ADCS-Cert-Authority'
        }

        xAdcsWebEnrollment CertSrv {
            Ensure           = 'Present'
            IsSingleInstance = 'Yes'
            Credential       = $Credential
            DependsOn        = '[WindowsFeature]ADCS-Web-Enrollment','[xAdcsCertificationAuthority]CA' 
        }

        xADUser adminUser {
            Ensure     = 'Present'
            DomainName = $node.DomainFqdn
            Username   = $node.DomainAdminUser
            Password   = $Credential
            DisplayName = $node.DomainAdminUserDisplayName
            DependsOn = '[xADDomain]DC'
        }

        xADGroup DomainAdmins {
            Ensure = 'Present'
            GroupName = 'Domain Admins'
            MembersToInclude = $node.DomainAdminUser
        }
    }
}

DC -ConfigurationData $ConfigData
Start-DscConfiguration -Wait -Force -Path .\DC -Verbose
