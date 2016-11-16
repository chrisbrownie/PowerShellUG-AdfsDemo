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

