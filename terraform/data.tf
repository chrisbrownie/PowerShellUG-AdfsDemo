data "aws_ami" "windowsserver" {
    most_recent = true
    filter {
        name = "name"
        values = ["*Windows_Server-2016-English-Full-Base-*"]
    }
    owners = ["amazon"]
}