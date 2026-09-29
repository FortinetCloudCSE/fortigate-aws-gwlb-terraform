output "gwlb_arn_suffix" {
  value = aws_lb.gwlb.*.arn_suffix
}

output "gwlb_ips" {
  value = flatten(data.aws_network_interface.gwlb_ips[*].*.private_ips)
}

output "gwlb_endpoint_service_name" {
  value = aws_vpc_endpoint_service.gwlb_endpoint_service.service_name
}

output "gwlb_endpoint_service_type" {
  value = aws_vpc_endpoint_service.gwlb_endpoint_service.service_type
}

output "gwlb_target_group_arn" {
  value = aws_lb_target_group.gwlb_target_group.arn
}