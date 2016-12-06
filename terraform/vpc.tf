###############################################################################
# PowerShellUG-AdfsDemo vpc.tf
#
# Author: Chris Brown (chris@chrisbrown.id.au)
# Date:   08/12/2016
###############################################################################

# Create the VPC holding all resources
resource "aws_vpc" "main" {
    cidr_block = "${var.vpccidr}"
    tags {
        Name = "${var.vpcname}"
    }
}

# Create and attach an internet gateway to permit VPC resources internet access 
resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.main.id}"
    tags {
        Name = "${var.vpcname}-igw"
    }
}

# Update the default route table for the VPC to utilise the IGW created above
resource "aws_default_route_table" "main" {
    default_route_table_id = "${aws_vpc.main.default_route_table_id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }

    tags {
        Name = "${var.vpcname} default"
    }
}

# Create DHCP options to set the DNS domain name
resource "aws_vpc_dhcp_options" "main" {
    domain_name = "${var.vpcdomainname}"
    tags {
        Name = "${var.vpcname}-dhcp"
    }
}

# Attach the DHCP options to the VPC
resource "aws_vpc_dhcp_options_association" "vpc-dhcp-association" {
    vpc_id = "${aws_vpc.main.id}"
    dhcp_options_id = "${aws_vpc_dhcp_options.main.id}"
}

# Create the public subnets
resource "aws_subnet" "public1" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${var.PublicSubnet1Cidr}"
    map_public_ip_on_launch = false
    tags {
        Name = "${var.PublicSubnet1Cidr}"
    }
}