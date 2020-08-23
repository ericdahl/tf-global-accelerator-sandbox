provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "github.com/ericdahl/tf-vpc"
}


data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_launch_template" "default" {

  image_id      = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = "t3.small"
  vpc_security_group_ids = [
    module.vpc.sg_allow_egress,
    module.vpc.sg_allow_80,
    module.vpc.sg_allow_vpc
  ]

  iam_instance_profile {
    arn = aws_iam_instance_profile.web.arn
  }

  user_data = base64encode(<<-EOF
#!/bin/bash

amazon-linux-extras install -y nginx1
systemctl enable nginx
systemctl start nginx
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web"
    }
  }
}


resource "aws_autoscaling_group" "web" {

  vpc_zone_identifier = [
    module.vpc.subnet_private1,
    module.vpc.subnet_private2,
    module.vpc.subnet_private3,
  ]

  min_size         = 3
  desired_capacity = 3
  max_size         = 3

  launch_template {
    id      = aws_launch_template.default.id
    version = "$Latest"
  }

  target_group_arns = [
    aws_lb_target_group.tg_alb.arn,
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 60
}

resource "aws_lb_target_group" "tg_alb" {

  name     = "tg-alb"
  vpc_id   = module.vpc.vpc_id
  port     = 80
  protocol = "HTTP"

  deregistration_delay = 0
}


resource "aws_lb" "alb" {
  name               = "alb"
  load_balancer_type = "application"
  security_groups = [
    module.vpc.sg_allow_egress,
    module.vpc.sg_allow_vpc,
    module.vpc.sg_allow_80,
  ]

  subnets = [
    module.vpc.subnet_public1,
    module.vpc.subnet_public2,
    module.vpc.subnet_public3,
  ]
}

resource "aws_lb_listener" "alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  default_action {
    target_group_arn = aws_lb_target_group.tg_alb.arn
    type             = "forward"
  }
}

