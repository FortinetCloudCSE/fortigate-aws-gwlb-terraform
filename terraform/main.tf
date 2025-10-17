provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}

locals {
  create_tgw = var.cwan_creation == "no" && var.tgw_creation == "yes" ? 1 : 0
  create_cwan = var.cwan_creation == "yes" && var.tgw_creation == "no" ? 1 : 0
  create_spokes = var.cwan_creation == "yes" || var.tgw_creation == "yes" ? 1 : 0
}

module "transit-gw" {
  source = ".//modules/tgw"
  count = local.create_tgw
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
  
  tag_name_prefix = var.tag_name_prefix
}

module "cloud-wan" {
  source = ".//modules/cwan"
  count = local.create_cwan
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
  
  tag_name_prefix = var.tag_name_prefix
}

module "inspection-vpc" {
  source = ".//modules/vpc-inspection"
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
  
  vpc_cidr = var.inspection_vpc_cidr
  availability_zones = var.availability_zones
  public_subnet_cidrs = var.inspection_vpc_public_subnet_cidrs
  private_subnet_cidrs = var.inspection_vpc_private_subnet_cidrs
  gwlb_subnet_cidrs = var.inspection_vpc_gwlb_subnet_cidrs
  attachment_subnet_cidrs = var.inspection_vpc_attachment_subnet_cidrs
  attachment_creation = local.create_spokes
  tgw_creation = local.create_tgw
  cwan_creation = local.create_cwan
  transit_gateway_id = local.create_tgw == 1 ? module.transit-gw[0].tgw_id : ""
  tgw_spoke_route_table_id = local.create_tgw == 1 ? module.transit-gw[0].tgw_spoke_route_table_id : ""
  tgw_security_route_table_id = local.create_tgw == 1 ? module.transit-gw[0].tgw_security_route_table_id : ""
  cwan_id = local.create_cwan == 1 ? module.cloud-wan[0].cwan_id : ""
  cwan_arn = local.create_cwan == 1 ? module.cloud-wan[0].cwan_arn : ""
  cwan_segment = "inspection"
  cwan_policy_state =  local.create_cwan == 1 ? module.cloud-wan[0].cwan_policy_state : ""
  gwlb_endpoint_service_name = module.inspection-vpc-gwlb.gwlb_endpoint_service_name
  gwlb_endpoint_service_type = module.inspection-vpc-gwlb.gwlb_endpoint_service_type
  
  tag_name_prefix = var.tag_name_prefix
  tag_name_unique = "inspection"
}

module "inspection-vpc-gwlb" {
  source = ".//modules/gwlb"
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
  
  vpc_id = module.inspection-vpc.vpc_id
  subnet_ids = module.inspection-vpc.gwlb_subnet_ids
  num_of_fgts_per_az = var.num_of_fgts_per_az
  instance_ids_a = module.fgts.fgt_ids_a
  instance_ids_b = module.fgts.fgt_ids_b
  
  tag_name_prefix = var.tag_name_prefix
  tag_name_unique = "sec-gwlb"
}

module "spoke-vpc1" {
  source = ".//modules/vpc-spoke"
  count = local.create_spokes
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region

  vpc_cidr = var.spoke_vpc1_cidr
  availability_zones = var.availability_zones
  public_subnet_cidrs = var.spoke_vpc1_public_subnet_cidrs
  private_subnet_cidrs = var.spoke_vpc1_private_subnet_cidrs
  gwlb_subnet_cidrs = var.spoke_vpc1_gwlb_subnet_cidrs
  tgw_creation = local.create_tgw
  cwan_creation = local.create_cwan
  transit_gateway_id = local.create_tgw == 1 ? module.transit-gw[0].tgw_id : ""
  tgw_spoke_route_table_id = local.create_tgw == 1 ? module.transit-gw[0].tgw_spoke_route_table_id : ""
  tgw_security_route_table_id = local.create_tgw == 1 ? module.transit-gw[0].tgw_security_route_table_id : ""
  cwan_id = local.create_cwan == 1 ? module.cloud-wan[0].cwan_id : ""
  cwan_arn = local.create_cwan == 1 ? module.cloud-wan[0].cwan_arn : ""
  cwan_segment = "production"
  cwan_policy_state =  local.create_cwan == 1 ? module.cloud-wan[0].cwan_policy_state : ""
  gwlb_endpoint_service_name = module.inspection-vpc-gwlb.gwlb_endpoint_service_name
  gwlb_endpoint_service_type = module.inspection-vpc-gwlb.gwlb_endpoint_service_type

  tag_name_prefix = var.tag_name_prefix
  tag_name_unique = "spoke1"
}

module "spoke-vpc2" {
  source = ".//modules/vpc-spoke"
  count = local.create_spokes
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region

  vpc_cidr = var.spoke_vpc2_cidr
  availability_zones = var.availability_zones
  public_subnet_cidrs = var.spoke_vpc2_public_subnet_cidrs
  private_subnet_cidrs = var.spoke_vpc2_private_subnet_cidrs
  gwlb_subnet_cidrs = var.spoke_vpc2_gwlb_subnet_cidrs
  tgw_creation = local.create_tgw
  cwan_creation = local.create_cwan
  transit_gateway_id = local.create_tgw == 1 ? module.transit-gw[0].tgw_id : ""
  tgw_spoke_route_table_id = local.create_tgw == 1 ? module.transit-gw[0].tgw_spoke_route_table_id : ""
  tgw_security_route_table_id = local.create_tgw == 1 ? module.transit-gw[0].tgw_security_route_table_id : ""
  cwan_id = local.create_cwan == 1 ? module.cloud-wan[0].cwan_id : ""
  cwan_arn = local.create_cwan == 1 ? module.cloud-wan[0].cwan_arn : ""
  cwan_segment = "development"
  cwan_policy_state =  local.create_cwan == 1 ? module.cloud-wan[0].cwan_policy_state : ""
  gwlb_endpoint_service_name = module.inspection-vpc-gwlb.gwlb_endpoint_service_name
  gwlb_endpoint_service_type = module.inspection-vpc-gwlb.gwlb_endpoint_service_type

  tag_name_prefix = var.tag_name_prefix
  tag_name_unique = "spoke2"
}

module "fgts" {
  source = ".//modules/fgt-gwlb"
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region

  availability_zones = var.availability_zones
  public_subnet_ids = module.inspection-vpc.public_subnet_ids
  private_subnet_ids = module.inspection-vpc.private_subnet_ids
  vpc_id = module.inspection-vpc.vpc_id
  vpc_cidr = var.inspection_vpc_cidr
  gwlb_ips = module.inspection-vpc-gwlb.gwlb_ips
  num_of_fgts_per_az = var.num_of_fgts_per_az
  instance_type = var.instance_type
  cidr_for_access = var.cidr_for_access
  keypair = var.keypair
  encrypt_volumes = var.encrypt_volumes
  fortios_version = var.fortios_version
  license_type = var.license_type
  license_files_for_1st_fgt_per_az = var.license_files_for_1st_fgt_per_az
  license_files_for_2nd_fgt_per_az = var.license_files_for_2nd_fgt_per_az
  flex_tokens_for_1st_fgt_per_az = var.flex_tokens_for_1st_fgt_per_az
  flex_Tokens_for_2nd_fgt_per_az = var.flex_Tokens_for_2nd_fgt_per_az
  
  tag_name_prefix = var.tag_name_prefix
}