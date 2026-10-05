resource "aws_lb" "gwlb" {
  name                             = "${var.tag_name_prefix}-${var.tag_name_unique}"
  enable_cross_zone_load_balancing = true
  load_balancer_type               = "gateway"
  subnets                          = var.subnet_ids[*]
}

resource "aws_lb_target_group" "gwlb_target_group" {
  name                 = "${var.tag_name_prefix}-${var.tag_name_unique}-tgrp"
  protocol             = "GENEVE"
  port                 = "6081"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = 20
  target_failover {
    on_deregistration = "rebalance"
    on_unhealthy      = "rebalance"
  }
  health_check {
    protocol = "HTTP"
    port     = "8008"
    interval            = "5"
    timeout             = "5"
    healthy_threshold   = "3"
    unhealthy_threshold = "3"
  }
}

resource "aws_lb_listener" "gwlb_listner" {
  load_balancer_arn = aws_lb.gwlb.id
  tcp_idle_timeout_seconds = 3600
  default_action {
    target_group_arn = aws_lb_target_group.gwlb_target_group.id
    type             = "forward"
  }
}

resource "aws_vpc_endpoint_service" "gwlb_endpoint_service" {
  acceptance_required        = false
  gateway_load_balancer_arns = [aws_lb.gwlb.arn]
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-vpce-service"
  }
}

data "aws_network_interfaces" "gwlb_enis" {
  count = length(var.subnet_ids)
  filter {
    name   = "description"
    values = ["ELB ${aws_lb.gwlb.arn_suffix}"]
  }
  filter {
    name   = "subnet-id"
    values = [var.subnet_ids[count.index]]
  }
}

locals {
  gwlb_eni_ids = flatten(data.aws_network_interfaces.gwlb_enis[*].*.ids)
}

data "aws_network_interface" "gwlb_ips" {
  count = length(var.subnet_ids)
  id    = element(local.gwlb_eni_ids, count.index)
}

