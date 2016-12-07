###############################################################################
# PowerShellUG-AdfsDemo data.tf
#
# Author: Chris Brown (chris@chrisbrown.id.au)
# Date:   08/12/2016
###############################################################################

# Get the AMI ID for the latest WS2016 image
data "aws_ami" "windowsserver" {
    most_recent = true
    filter {
        name = "name"
        # Uncomment for WS2016
        #values = ["*Windows_Server-2016-English-Full-Base-*"]
        # Uncomment for WS2012R2
        values = ["*Windows_Server-2012-R2_RTM-English-64Bit-Base*"]
    }
    owners = ["amazon"]
}