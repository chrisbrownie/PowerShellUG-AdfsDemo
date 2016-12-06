###############################################################################
# PowerShellUG-AdfsDemo variables.tf
#
# Author: Chris Brown (chris@chrisbrown.id.au)
# Date:   08/12/2016
###############################################################################

variable "aws_access_key" {
    description = "AWS IAM Access Key"
}
variable "aws_secret_key" {
    description = "AWS IAM Secret Key"
}
variable "aws_region" {
    description = "AWS Region in which to build the resources"
}

variable "vpcname" {
    description = "VPC Name"
    default     = "psugdemo" 
}

variable "vpccidr" {
    description = "Encompassing CIDR mask for VPC"
    default = "192.168.0.0/16"
}

variable "vpcdomainname" {
    description = "DNS domain name to be used by resources"
    default = "lab.flamingkeys.com" 
}

variable "PublicSubnet1Name" {
    description = "Name for public subnet"
    default = "publicSubnet"
}

variable "PublicSubnet1Cidr" {
    description = "CIDR mask for public subnet"
    default = "192.168.1.0/24"
}

variable "route53zoneid" {
    description = "ID of the Route 53 zone in which to create the records"
}

variable "route53domainsuffix" {
    description = "This string will be appended to the VM name. 'lab' would result in dc.lab.yourdomain.com"
    default = "lab"
}

variable "instanceSize" {
    description = "EC2 instance sizes to create"
    default = "t2.large"
}

variable "DCName" {
    description = "Computer name for DC instance"
    default = "DC"
}

variable "DCIP" {
    description = "IP address for DC instance"
    default = "192.168.1.20"
}

variable "FSName" {
    description = "Computer name for FS instance"
    default = "FS"
}

variable "FSIP" {
    description = "IP address for FS instance"
    default = "192.168.1.50"
}

variable "CL01Name" {
    description = "Computer name for CL01 instance"
    default = "CL01"
}

variable "CL01IP" {
    description = "IP address for CL01 instance"
    default = "192.168.1.101"
}

variable "awskey" {
    description = "Name of SSH key to encrypt password"
}

variable "env" {
    default = "lab"
    description = "Resources will be tagged with this 'env' value"
}