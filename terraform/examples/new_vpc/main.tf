data "aws_caller_identity" "current" {}

locals {
  create_cwan       = var.cwan_integration == "new" && var.tgw_integration == "no" ? 1 : 0
  existing_cwan     = var.cwan_integration == "existing" && var.tgw_integration == "no" ? 1 : 0
  cwan_id           = local.create_cwan == 1 ? module.cloud-wan[0].cwan_id : (local.existing_cwan == 1 ? var.cwan_existing_id : "")
  cwan_account_id   = local.create_cwan == 1 ? data.aws_caller_identity.current.account_id : (local.existing_cwan == 1 ? var.cwan_existing_account_id : "")
  cwan_segment_key  = local.create_cwan == 1 ? "segment" : (local.existing_cwan == 1 ? var.cwan_existing_segment_key : "")
  cwan_policy_state = local.create_cwan == 1 ? module.cloud-wan[0].cwan_policy_state : (local.existing_cwan == 1 ? "AVAILABLE" : "")

  create_tgw                  = var.cwan_integration == "no" && var.tgw_integration == "new" ? 1 : 0
  existing_tgw                = var.cwan_integration == "no" && var.tgw_integration == "existing" ? 1 : 0
  transit_gateway_id          = local.create_tgw == 1 ? module.transit-gw[0].tgw_id : (local.existing_tgw == 1 ? var.tgw_existing_id : "")
  tgw_security_route_table_id = local.create_tgw == 1 ? module.transit-gw[0].tgw_security_route_table_id : (local.existing_tgw == 1 ? var.tgw_existing_security_tgw_route_table_id : "")
  tgw_spoke_route_table_id    = local.create_tgw == 1 ? module.transit-gw[0].tgw_spoke_route_table_id : (local.existing_tgw == 1 ? var.tgw_existing_spoke_tgw_route_table_id : "")
  tgw_spoke_route_table_route = local.create_tgw == 1 ? "0.0.0.0/0" : (local.existing_tgw == 1 ? var.tgw_existing_spoke_tgw_route_table_route : "")

  create_attachment_subnets = local.create_cwan == 1 || local.existing_cwan == 1 || local.create_tgw == 1 || local.existing_tgw == 1 ? 1 : 0
  create_spokes             = var.cwan_integration == "new" || var.tgw_integration == "new" ? 1 : 0
}

module "transit-gw" {
  source = "../../modules/tgw"
  count  = local.create_tgw
  region = var.region

  tag_name_prefix = var.tag_name_prefix
}

module "cloud-wan" {
  source = "../../modules/cwan"
  count  = local.create_cwan
  region = var.region

  tag_name_prefix = var.tag_name_prefix
}

module "inspection-vpc" {
  source = "../../modules/vpc-inspection"
  region = var.region

  vpc_cidr                       = var.inspection_vpc_cidr
  availability_zones             = var.availability_zones
  public_subnet_cidrs            = var.inspection_vpc_public_subnet_cidrs
  private_subnet_cidrs           = var.inspection_vpc_private_subnet_cidrs
  gwlb_subnet_cidrs              = var.inspection_vpc_gwlb_subnet_cidrs
  attachment_subnet_cidrs        = var.inspection_vpc_attachment_subnet_cidrs
  attachment_creation            = local.create_attachment_subnets
  internet_access                = var.internet_access
  arm_mode                       = var.arm_mode
  dedicated_management           = var.dedicated_management
  dedicated_management_placement = var.dedicated_management_placement

  cwan_used          = local.create_cwan == 1 || local.existing_cwan == 1 ? 1 : 0
  cwan_id            = local.cwan_id
  cwan_account_id    = local.cwan_account_id
  cwan_segment_key   = local.cwan_segment_key
  cwan_segment_value = local.create_cwan == 1 ? "inspection" : (local.existing_cwan == 1 ? var.cwan_existing_segment_value : "")
  cwan_policy_state  = local.cwan_policy_state

  tgw_used                    = local.create_tgw == 1 || local.existing_tgw == 1 ? 1 : 0
  transit_gateway_id          = local.transit_gateway_id
  tgw_security_route_table_id = local.tgw_security_route_table_id
  tgw_spoke_route_table_id    = local.tgw_spoke_route_table_id
  tgw_spoke_route_table_route = local.tgw_spoke_route_table_route

  gwlb_endpoint_service_name = module.inspection-vpc-gwlb.gwlb_endpoint_service_name
  gwlb_endpoint_service_type = module.inspection-vpc-gwlb.gwlb_endpoint_service_type

  tag_name_prefix = var.tag_name_prefix
  tag_name_unique = "inspection"
}

module "inspection-vpc-gwlb" {
  source = "../../modules/gwlb"
  region = var.region

  vpc_id     = module.inspection-vpc.vpc_id
  subnet_ids = module.inspection-vpc.gwlb_subnet_ids

  tag_name_prefix = var.tag_name_prefix
  tag_name_unique = "gwlb"
}

module "spoke-vpc1" {
  source = "../../modules/vpc-spoke"
  count  = local.create_spokes
  region = var.region

  vpc_cidr               = var.spoke_vpc1_cidr
  availability_zones     = var.availability_zones
  public_subnet_cidrs    = var.spoke_vpc1_public_subnet_cidrs
  private_subnet_cidrs   = var.spoke_vpc1_private_subnet_cidrs
  gwlb_subnet_cidrs      = var.spoke_vpc1_gwlb_subnet_cidrs
  distributed_inspection = var.spoke_vpc1_distributed_inspection
  route_to_cwan_or_tgw   = var.spoke_vpc1_route_to_cwan_or_tgw

  cwan_used          = local.create_cwan == 1 || local.existing_cwan == 1 ? 1 : 0
  cwan_id            = local.cwan_id
  cwan_account_id    = local.cwan_account_id
  cwan_segment_key   = local.cwan_segment_key
  cwan_segment_value = "production"
  cwan_policy_state  = local.cwan_policy_state

  tgw_used                    = local.create_tgw == 1 || local.existing_tgw == 1 ? 1 : 0
  transit_gateway_id          = local.transit_gateway_id
  tgw_security_route_table_id = local.tgw_security_route_table_id
  tgw_spoke_route_table_id    = local.tgw_spoke_route_table_id

  vpc_endpoint_service_name = module.inspection-vpc-gwlb.gwlb_endpoint_service_name

  tag_name_prefix = var.tag_name_prefix
  tag_name_unique = "spoke1"
}

module "spoke-vpc2" {
  source = "../../modules/vpc-spoke"
  count  = local.create_spokes
  region = var.region

  vpc_cidr               = var.spoke_vpc2_cidr
  availability_zones     = var.availability_zones
  public_subnet_cidrs    = var.spoke_vpc2_public_subnet_cidrs
  private_subnet_cidrs   = var.spoke_vpc2_private_subnet_cidrs
  gwlb_subnet_cidrs      = var.spoke_vpc2_gwlb_subnet_cidrs
  distributed_inspection = var.spoke_vpc2_distributed_inspection
  route_to_cwan_or_tgw   = var.spoke_vpc2_route_to_cwan_or_tgw

  cwan_used          = local.create_cwan == 1 || local.existing_cwan == 1 ? 1 : 0
  cwan_id            = local.cwan_id
  cwan_account_id    = local.cwan_account_id
  cwan_segment_key   = local.cwan_segment_key
  cwan_segment_value = "development"
  cwan_policy_state  = local.cwan_policy_state

  tgw_used                    = local.create_tgw == 1 || local.existing_tgw == 1 ? 1 : 0
  transit_gateway_id          = local.transit_gateway_id
  tgw_security_route_table_id = local.tgw_security_route_table_id
  tgw_spoke_route_table_id    = local.tgw_spoke_route_table_id

  vpc_endpoint_service_name = module.inspection-vpc-gwlb.gwlb_endpoint_service_name

  tag_name_prefix = var.tag_name_prefix
  tag_name_unique = "spoke2"
}

module "fgts" {
  source = "../../modules/fgt-gwlb"
  region = var.region

  availability_zones             = var.availability_zones
  public_subnet_ids              = module.inspection-vpc.public_subnet_ids
  private_subnet_ids             = module.inspection-vpc.private_subnet_ids
  vpc_id                         = module.inspection-vpc.vpc_id
  vpc_cidr                       = var.inspection_vpc_cidr
  gwlb_ips                       = module.inspection-vpc-gwlb.gwlb_ips
  gwlb_target_group_arn          = module.inspection-vpc-gwlb.gwlb_target_group_arn
  num_of_fgts_per_az             = var.num_of_fgts_per_az
  arm_mode                       = var.arm_mode
  internet_access                = var.internet_access
  dedicated_management           = var.dedicated_management
  dedicated_management_placement = var.dedicated_management_placement
  instance_type                  = var.instance_type
  cidr_for_access                = var.cidr_for_access
  keypair                        = var.keypair
  encrypt_volumes                = var.encrypt_volumes
  fortios_version                = var.fortios_version
  license_type                   = var.license_type
  license_files                  = var.license_files
  flex_tokens                    = var.flex_tokens

  tag_name_prefix = var.tag_name_prefix
}