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
        values = ["*Windows_Server-2016-English-Full-Base-*"]
    }
    owners = ["amazon"]
}