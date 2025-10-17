resource "aws_lb" "gwlb" {
  name = "${var.tag_name_prefix}-${var.tag_name_unique}"
  enable_cross_zone_load_balancing = true
  load_balancer_type = "gateway"
  subnets = var.subnet_ids[*]
}

resource "aws_lb_target_group" "gwlb_target_group" {
  name = "${var.tag_name_prefix}-${var.tag_name_unique}-tgrp"
  protocol = "GENEVE"
  port = "6081"
  vpc_id = var.vpc_id
  health_check {
    protocol = "TCP"
    port = "80"
	interval = "10"
	healthy_threshold = "2"
	unhealthy_threshold = "2"
  }
}

resource "aws_lb_listener" "gwlb_listner" {
  load_balancer_arn = aws_lb.gwlb.id
  default_action {
    target_group_arn = aws_lb_target_group.gwlb_target_group.id
    type = "forward"
  }
}

resource "aws_vpc_endpoint_service" "gwlb_endpoint_service" {
  acceptance_required = false
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
  id = element(local.gwlb_eni_ids, count.index)
}

resource "aws_lb_target_group_attachment" "gwlb_target_group_attachments_a" {
  count = length(var.instance_ids_a)
  target_group_arn = aws_lb_target_group.gwlb_target_group.arn
  target_id = var.instance_ids_a[count.index]
}

resource "aws_lb_target_group_attachment" "gwlb_target_group_attachments_b" {
  count = var.num_of_fgts_per_az == 2 ? length(var.instance_ids_b) : 0
  target_group_arn = aws_lb_target_group.gwlb_target_group.arn
  target_id = var.instance_ids_b[count.index]
}