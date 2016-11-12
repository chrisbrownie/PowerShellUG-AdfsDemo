variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

variable "vpcname" {
    default     = "psugdemo" 
}

variable "vpccidr" {
    default = "192.168.0.0/16"
}

variable "vpcdomainname" {
    default = "lab.flamingkeys.com" 
}

variable "PublicSubnet1Name" {
    default = "publicSubnet"
}

variable "PublicSubnet1Cidr" {
    default = "192.168.1.0/24"
}

variable "route53zoneid" {
    description = "ID of the Route 53 zone in which to create the records"
}

variable "route53domainsubdomain" {
    default = "lab"
}

variable "DCName" {
    default = "DC"
}

variable "DCIP" {
    default = "192.168.1.20"
}

variable "FSName" {
    default = "FS"
}

variable "FSIP" {
    default = "192.168.1.50"
}

variable "awskey" {
    default = "labkey"
}