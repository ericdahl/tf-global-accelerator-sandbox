output "alb_dns" {
  value = "http://${aws_lb.alb.dns_name}"
}


output "globalaccelerator_dns" {
  value = aws_globalaccelerator_accelerator.default.dns_name
}


output "globalaccelerator_ip" {
  value = aws_globalaccelerator_accelerator.default.ip_sets
}
