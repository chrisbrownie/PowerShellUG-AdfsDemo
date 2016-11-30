# https://pleasework.robbievance.net/howto-desired-state-configuration-dsc-overview/

$settings = @{
    "ComputerName"    = "FS"
    "DomainFqdn"      = "lab.flamingkeys.com"
    "DNSIP"           = "192.168.1.20"
    "DomainAdminUser" = "xareid"
    "Password"        = "Pass@word1"
    "DNSClientInterfaceAlias" = $(Get-NetIPConfiguration | Select -first 1 | Select -ExpandProperty InterfaceAlias)
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
        Password = $settings.Password
        DomainAdminUser = $settings.DomainAdminUser
        DNSClientInterfaceAlias = $settings.DNSClientInterfaceAlias
        DNSIP = $settings.DNSIP
        # DO NOT USE the below in production. Lab only!
        PsDscAllowPlainTextPassword = $true
        PSDscAllowDomainUser = $true
    })
}

Configuration FS {
    Import-DscResource -ModuleName xComputerManagement,xActiveDirectory,xNetworking

    Node $AllNodes.NodeName {
        LocalConfigurationManager {
            ActionAfterReboot = "ContinueConfiguration"
            ConfigurationMode = "ApplyAndAutoCorrect"
            RebootNodeIfNeeded = $true
        }

        $Credential = New-Object System.Management.Automation.PSCredential(
            "$($Node.DomainFqdn)\$($Node.DomainAdminUser)",
            (ConvertTo-SecureString $Node.Password -AsplainText -Force)
        )

        xDNSServerAddress SetDNS {
            Address = $Node.DNSIP
            InterfaceAlias = $Node.DNSClientInterfaceAlias
            AddressFamily = "IPv4"
        }

        xWaitForADDomain DscForestWait {
            DomainName = $Node.DomainFqdn
            DomainUserCredential = $Credential
            RetryCount = 100
            RetryIntervalSec = 30
            DependsOn = '[xDNSServerAddress]SetDNS'
        }

        xComputer Computer {
            Name = $Node.MachineName
            DomainName = $Node.DomainFqdn
            Credential = $Credential
            DependsOn = '[xWaitForADDomain]DscForestWait'
        }
    }
}

FS -ConfigurationData $ConfigData
Start-DscConfiguration -Wait -Force -Path .\FS -Verbose
