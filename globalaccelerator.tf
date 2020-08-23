resource "aws_globalaccelerator_accelerator" "default" {
  name = "tf-global-accelerator-sandbox"

  ip_address_type = "IPV4"
}

resource "aws_globalaccelerator_listener" "default" {
  accelerator_arn = aws_globalaccelerator_accelerator.default.id
  protocol        = "TCP"
  port_range {
    from_port = 80
    to_port   = 80
  }
}

resource "aws_globalaccelerator_endpoint_group" "default" {
  listener_arn = aws_globalaccelerator_listener.default.id

  endpoint_group_region = "us-east-1"

  endpoint_configuration {
    endpoint_id = aws_lb.alb.arn
  }
}
