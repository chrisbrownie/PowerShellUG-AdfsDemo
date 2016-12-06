###############################################################################
# PowerShellUG-AdfsDemo outputs.tf
#
# Author: Chris Brown (chris@chrisbrown.id.au)
# Date:   08/12/2016
###############################################################################

output "DC-IP" {
    value = "${aws_instance.dc.public_ip}"
}

output "DC-DNS" {
    value = "${aws_route53_record.dc.fqdn}"
}

output "FS-IP" {
    value = "${aws_instance.fs.public_ip}"
}

output "FS-DNS" {
    value = "${aws_route53_record.fs.fqdn}"
}

output "CL01-IP" {
    value = "${aws_instance.cl01.public_ip}"
}

output "CL01-DNS" {
    value = "${aws_instance.cl01.fqdn}"
}