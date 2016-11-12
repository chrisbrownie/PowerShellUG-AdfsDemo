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

variable "route53domainsuffix" {
    default = "lab"
}

variable "DCName" {
    default = "DC"
}

variable "DCIP" {
    default = "192.168.1.20"
}

variable "DCConfigScriptUri" {
    description = "URL to the script that should be launched to configure DC."
}

variable "FSName" {
    default = "FS"
}

variable "FSIP" {
    default = "192.168.1.50"
}

variable "FSConfigScriptUri" {
    description = "URL to the script that should be launched to configure FS."
}

variable "awskey" {
    default = "labkey"
}

