resource "aws_instance" "dc" {
    ami = "${data.aws_ami.windowsserver.id}"
    instance_type = "${var.instanceSize}"
    vpc_security_group_ids = ["${aws_security_group.rdp.id}"]
    subnet_id = "${aws_subnet.public1.id}"
    associate_public_ip_address = true
    key_name = "${var.awskey}"
    private_ip = "${var.DCIP}" 

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
iwr 'https://raw.githubusercontent.com/chrisbrownie/PowerShellUG-AdfsDemo/master/terraform/dsc/ConfigureDC.ps1' -UseBasicParsing | iex
Stop-Transcript
</powershell>
EOF
    
    tags {
        Name = "${var.DCName}"
        env = "${var.env}"
    }
}

# The LabServer role must preexist in the account
resource "aws_iam_instance_profile" "labserver" {
    name = "labserver"
    roles = ["LabServer"]
}


resource "aws_route53_record" "dc" {
    zone_id = "${var.route53zoneid}"
    name    = "${var.DCName}.${var.route53domainsuffix}"
    type    = "A"
    ttl     = "60"
    records = ["${aws_instance.dc.public_ip}"]
}