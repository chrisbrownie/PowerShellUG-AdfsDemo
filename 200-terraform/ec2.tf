data "aws_ami" "windowsserver" {
    most_recent = true
    filter {
        name = "name"
        values = ["*Windows_Server-2016-English-Full-Base-*"]
    }
    owners = ["amazon"]
}

resource "aws_instance" "dc" {
    ami = "${data.aws_ami.windowsserver.id}"
    instance_type = "${var.instanceSize}"
    vpc_security_group_ids = ["${aws_security_group.rdp.id}"]
    subnet_id = "${aws_subnet.public1.id}"
    associate_public_ip_address = true
    key_name = "${var.awskey}"

    # Terminate when the instances shut themselves down
    instance_initiated_shutdown_behavior = "terminate"

    private_ip = "${var.DCIP}" 

    user_data = <<EOF
<powershell>
Start-Transcript C:\provisionlog.txt
Set-ExecutionPolicy Unrestricted -confirm:$false
Get-NetIPAddress | Where {$_.InterfaceAlias -ilike "Ethernet*" -and $_.AddressFamily -eq "IPv4"} | % { Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ServerAddresses "8.8.8.8","8.8.4.4" }
iwr https://gist.githubusercontent.com/chrisbrownie/e2b819e0cc87a31c742ec7a5468b7536/raw/3888bf37100f6cbb3c7c68cbc561a89d6c4d4cf4/ConfigureDC.ps1 -UseBasicParsing | iex
Stop-Transcript
</powershell>
EOF
    
    tags {
        Name = "${var.DCName}"
    }
}

resource "aws_route53_record" "dc" {
    zone_id = "${var.route53zoneid}"
    name    = "${var.DCName}.${var.route53domainsuffix}"
    type    = "A"
    ttl     = "60"
    records = ["${aws_instance.dc.public_ip}"]
}