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
    instance_type = "t2.micro"
    vpc_security_group_ids = ["${aws_security_group.rdp.id}"]
    subnet_id = "${aws_subnet.public1.id}"
    associate_public_ip_address = true
    key_name = "${var.awskey}"

    # Terminate when the instances shut themselves down
    instance_initiated_shutdown_behavior = "terminate"

    private_ip = "${var.DCIP}" 

    user_data = <<EOF
<powershell>
"Hello, world!" | Out-File C:\provisionoutput.txt
</powershell>
EOF
    
    tags {
        Name = "${var.DCName}"
    }
}

resource "aws_route53_record" "dc" {
    zone_id = "${var.route53zoneid}"
    name    = "${var.DCName}.${route53domainsubdomain}"
    type    = "A"
    ttl     = "60"
    records = ["${aws_instance.dc.public_ip}"]
}