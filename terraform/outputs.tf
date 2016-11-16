output "DC-IP" {
    value = "${aws_instance.dc.public_ip}"
}

output "DC-DNS" {
    value = "${aws_route53_record.dc.fqdn}"
}