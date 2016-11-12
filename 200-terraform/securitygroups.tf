resource "aws_security_group" "rdp" {
    name = "rdp-anywhere"
    description = "Allows RDP from anywhere"
    vpc_id = "${aws_vpc.main.id}"

    ingress {
        from_port = 3389
        to_port   = 3389
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}