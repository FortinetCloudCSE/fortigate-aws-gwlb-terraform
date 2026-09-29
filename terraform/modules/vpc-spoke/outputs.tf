output "distributed_inspection" {
  description = "Distributed inspection option selected"
  value       = var.distributed_inspection
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "gwlb_subnet_ids" {
  description = "GWLB subnet IDs"
  value       = aws_subnet.gwlb[*].id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.igw.id
}

output "gwlb_endpoint_ids" {
  description = "GWLB Endpoint IDs"
  value       = local.use_gwlbe ? aws_vpc_endpoint.gwlbe[*].id : []
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = local.use_nat_gw ? aws_nat_gateway.natgw[0].id : null
}

output "cwan_id" {
  description = "Cloud WAN Core Network ID"
  value       = var.cwan_used == 1 ? var.cwan_id : null
}

output "cwan_segment_key" {
  description = "Cloud WAN segment key"
  value       = var.cwan_used == 1 ? var.cwan_segment_key : null
}

output "cwan_segment_value" {
  description = "Cloud WAN segment value"
  value       = var.cwan_used == 1 ? var.cwan_segment_value : null
}

output "route_to_cwan" {
  description = "VPC route to Cloud WAN in private subnets"
  value       = var.cwan_used == 1 ? var.route_to_cwan_or_tgw : null
}

output "transit_gateway_id" {
  description = "Transit Gateway ID"
  value       = var.tgw_used == 1 ? var.transit_gateway_id : null
}

output "tgw_security_route_table_id" {
  description = "Transit Gateway Route Table ID that the VPC will propagate to"
  value       = var.tgw_used == 1 ? var.tgw_security_route_table_id : null
}

output "tgw_spoke_route_table_id" {
  description = "Transit Gateway Route Table ID that the VPC is associated to"
  value       = var.tgw_used == 1 ? var.tgw_spoke_route_table_id : null
}

output "route_to_tgw" {
  description = "VPC route to Transit Gateway in private subnets"
  value       = var.tgw_used == 1 ? var.route_to_cwan_or_tgw : null
}

output "transit_gateway_vpc_attachment_id" {
  description = "Transit Gateway VPC Attachment ID"
  value       = var.tgw_used == 1 ? aws_ec2_transit_gateway_vpc_attachment.main[0].id : null
}

output "cloud_wan_vpc_attachment_id" {
  description = "Cloud WAN VPC Attachment ID"
  value       = var.cwan_used == 1 ? aws_networkmanager_vpc_attachment.main[0].id : null
}
