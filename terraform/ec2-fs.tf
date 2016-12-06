###############################################################################
# PowerShellUG-AdfsDemo ec2-fs.tf
#
# Author: Chris Brown (chris@chrisbrown.id.au)
# Date:   08/12/2016
###############################################################################

# Create the FS instance
resource "aws_instance" "fs" {
    ami = "${data.aws_ami.windowsserver.id}"
    instance_type = "${var.instanceSize}"
    vpc_security_group_ids = ["${aws_security_group.rdp.id}"]
    subnet_id = "${aws_subnet.public1.id}"
    associate_public_ip_address = true
    key_name = "${var.awskey}"
    private_ip = "${var.FSIP}" 

    # Terminate when the instances shut themselves down
    instance_initiated_shutdown_behavior = "terminate"

    # Wrapper to:
    # - configure DNS client so we can resolve internet URLs
    # - download and execute the config script
    # - log everything to c:\provisionlog.txt
    user_data = <<EOF
<powershell>
Start-Transcript C:\provisionlog.txt
Set-ExecutionPolicy Unrestricted -confirm:$false
Get-NetIPAddress | Where {$_.InterfaceAlias -ilike "Ethernet*" -and $_.AddressFamily -eq "IPv4"} | % { Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ServerAddresses "8.8.8.8","8.8.4.4" }
iwr 'https://raw.githubusercontent.com/chrisbrownie/PowerShellUG-AdfsDemo/master/terraform/dsc/ConfigureFS.ps1' -UseBasicParsing | iex
Stop-Transcript
</powershell>
EOF
    
    tags {
        Name = "${var.FSName}"
        env = "${var.env}"
    }
}

# Create the DNS record to point at the FS instance
resource "aws_route53_record" "fs" {
    zone_id = "${var.route53zoneid}"
    name    = "${var.FSName}.${var.route53domainsuffix}"
    type    = "A"
    ttl     = "60"
    records = ["${aws_instance.fs.public_ip}"]
}