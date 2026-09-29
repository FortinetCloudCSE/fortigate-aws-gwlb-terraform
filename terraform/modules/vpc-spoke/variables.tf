variable "region" {}

variable "vpc_cidr" {}

variable "availability_zones" {}

variable "public_subnet_cidrs" {}

variable "private_subnet_cidrs" {}

variable "gwlb_subnet_cidrs" {}

variable "distributed_inspection" {}

variable "tgw_used" {}

variable "transit_gateway_id" {}

variable "tgw_security_route_table_id" {}

variable "tgw_spoke_route_table_id" {}

variable "cwan_used" {}

variable "cwan_id" {}

variable "cwan_account_id" {}

variable "cwan_segment_key" {}

variable "cwan_segment_value" {}

variable "cwan_policy_state" {}

variable "vpc_endpoint_service_name" {}

variable "route_to_cwan_or_tgw" {}

variable "tag_name_prefix" {}

variable "tag_name_unique" {}
