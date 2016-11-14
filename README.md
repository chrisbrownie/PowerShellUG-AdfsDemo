# PowerShellUG-AdfsDemo
Content from my demonstration at the 
[Melbourne PowerShell meetup](https://www.meetup.com/Melbourne-PowerShell-Meetup/events/235311212/)
in December 2016.



## The environment
If you want to just skip ahead, here's the environment as built:

| Hostname | Operating System | IP Address(es) | Role |
|---|---|---|---
| DC01 | Windows Server 2016 Standard | 192.168.99.20 | Domain Controller, Certificate Authority |
| FS01 | Windows Server 2016 Standard | 192.168.99.50 | AD FS Server |
| CL01 | Windows 10 Professional | 192.168.99.101 | Client Computer |

## The code

### 200-terraform
This directory contains the content used by Terraform to create this lab.

### 300-adfsscripts
This directory contains the scripts used within the AD FS server to set up 
and configure AD FS in the environment.

    .\Apply-AdfsBestPractices.ps1 -Verbose

This script applies my list of AD FS best practices for Windows Server 2016 to the AD FS environment

    .\Invoke-AdfsBranding.ps1
    .\Invoke-AdfsAnalyzer.ps1


## References
* Review the slides from the presentation on [Docs.com](https://docs.com/chrisbrown)
* Learn more about [Packer](https://www.packer.io/)
* Learn more about [Vagrant](https://www.vagrantup.com/)
* Contribute to or view my [AD FS Branding](https://github.com/chrisbrownie/Invoke-AdfsBranding) script