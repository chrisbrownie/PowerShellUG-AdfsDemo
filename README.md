# PowerShellUG-AdfsDemo
Content from my demonstration at the 
[Melbourne PowerShell meetup](https://www.meetup.com/Melbourne-PowerShell-Meetup/events/235311212/)
in December 2016.



## The environment
If you want to just skip ahead, here's the environment as built:

| Hostname | Operating System | IP Address(es) | Role |
|---|---|---|---
| DC01 | Windows Server 2016 Standard | 192.168.1.20 | Domain Controller, Certificate Authority |
| FS01 | Windows Server 2016 Standard | 192.168.1.50 | AD FS Server |
| CL01 | Windows 10 Professional | 192.168.1.101 | Client Computer |

## The code

### terraform
This directory contains the content used by Terraform to create this lab.

| File | Purpose |
|--- | ---
| data.tf | This file is used for pulling data from providers that will be used in the Terraform template. In this instance, it pulls the ID of the latest Windows Server 2016 (English) AMI
| ec2-dc.tf | This file is used to provision the domain controller, DC
| ec2-fs.tf | This file is used to provision the member server, FS 
| outputs.tf | This file determines the Terraform outputs 
| providers.tf | This file configures the providers (AWS, in this case)
| securitygroups.tf | This file configures security groups to allow instances to access each other, the Internet, and to allow RDP access inbound
| variables.tf | This file configures variables used elsewhere in the Terraform configuration
| vpc.tf | This file configures the VPC that lives underneath the preceding infrastructure
| dsc/ConfigureDC.ps1 | This script is run as part of the user data for the DC instance. It installs the DSC prerequisites and kicks off the DSC script. This script is pulled from its URL at instance boot time.
| dsc/ConfigureFS.ps1 | This script is run as part of the user data for the FS instance. It installs the DSC prerequisites and kicks off the DSC script. This script is pulled from its URL at instance boot time.
| dsc/DSC-DC.ps1 | This script configures the domain controller instance with AD DS, DNS Server, and AD CS
| dsc/DSC-fs.ps1 | This script configures the basics of the FS instance, just the DNS Client and domain membership

### adfsscripts
This directory contains the scripts used within the AD FS server to set up 
and configure AD FS in the environment.

    .\Apply-AdfsBestPractices.ps1 -Verbose

This script applies my list of AD FS best practices for Windows Server 2016 to the AD FS environment

    .\Invoke-AdfsBranding.ps1
    .\Invoke-AdfsAnalyzer.ps1


## References
* Review the slides from the presentation on [Docs.com](https://docs.com/chrisbrown)
* Contribute to or view my [AD FS Branding](https://github.com/chrisbrownie/Invoke-AdfsBranding) script