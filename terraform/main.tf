provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}

module "transit-gw" {
  source = ".//modules/vpc/tgw"
  count = var.tgw_creation == "yes" ? 1 : 0
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
  tag_name_prefix = var.tag_name_prefix
}

module "security-vpc" {
  source = ".//modules/vpc/vpc-security-tgw"
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
  vpc_cidr = var.security_vpc_cidr
  availability_zones = var.availability_zones
  public_subnet_cidrs = var.security_vpc_public_subnet_cidrs
  private_subnet_cidrs = var.security_vpc_private_subnet_cidrs
  gwlb_subnet_cidrs = var.security_vpc_gwlb_subnet_cidrs
  tgwattach_subnet_cidrs = var.security_vpc_tgwattach_subnet_cidrs
  tgw_creation = var.tgw_creation
  transit_gateway_id = var.tgw_creation == "yes" ? module.transit-gw[0].tgw_id : ""
  tgw_spoke_route_table_id = var.tgw_creation == "yes" ? module.transit-gw[0].tgw_spoke_route_table_id : ""
  tgw_security_route_table_id = var.tgw_creation == "yes" ? module.transit-gw[0].tgw_security_route_table_id : ""
  gwlb_endpoint_service_name = module.security-vpc-gwlb.gwlb_endpoint_service_name
  gwlb_endpoint_service_type = module.security-vpc-gwlb.gwlb_endpoint_service_type
  tag_name_prefix = var.tag_name_prefix
  tag_name_unique = "security"
}

module "security-vpc-gwlb" {
  source = ".//modules/vpc/gwlb"
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
  vpc_id = module.security-vpc.vpc_id
  subnet_ids = module.security-vpc.gwlb_subnet_ids
  num_of_fgts_per_az = var.num_of_fgts_per_az
  instance_ids_a = module.fgts.fgt_ids_a
  instance_ids_b = module.fgts.fgt_ids_b
  tag_name_prefix = var.tag_name_prefix
  tag_name_unique = "sec-gwlb"
}


module "spoke-vpc1" {
  source = ".//modules/vpc/vpc-spoke-tgw"
  count = var.tgw_creation == "yes" ? 1 : 0
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region

  vpc_cidr = var.spoke_vpc1_cidr
  availability_zones = var.availability_zones
  public_subnet_cidrs = var.spoke_vpc1_public_subnet_cidrs
  private_subnet_cidrs = var.spoke_vpc1_private_subnet_cidrs
  gwlb_subnet_cidrs = var.spoke_vpc1_gwlb_subnet_cidrs
  tgw_creation = var.tgw_creation
  transit_gateway_id = module.transit-gw[0].tgw_id
  tgw_spoke_route_table_id = module.transit-gw[0].tgw_spoke_route_table_id
  tgw_security_route_table_id = module.transit-gw[0].tgw_security_route_table_id
  gwlb_endpoint_service_name = module.security-vpc-gwlb.gwlb_endpoint_service_name
  gwlb_endpoint_service_type = module.security-vpc-gwlb.gwlb_endpoint_service_type

  tag_name_prefix = var.tag_name_prefix
  tag_name_unique = "spoke1"
}

module "spoke-vpc2" {
  source = ".//modules/vpc/vpc-spoke-tgw"
  count = var.tgw_creation == "yes" ? 1 : 0
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region

  vpc_cidr = var.spoke_vpc2_cidr
  availability_zones = var.availability_zones
  public_subnet_cidrs = var.spoke_vpc2_public_subnet_cidrs
  private_subnet_cidrs = var.spoke_vpc2_private_subnet_cidrs
  gwlb_subnet_cidrs = var.spoke_vpc2_gwlb_subnet_cidrs
  tgw_creation = var.tgw_creation
  transit_gateway_id = module.transit-gw[0].tgw_id
  tgw_spoke_route_table_id = module.transit-gw[0].tgw_spoke_route_table_id
  tgw_security_route_table_id = module.transit-gw[0].tgw_security_route_table_id
  gwlb_endpoint_service_name = module.security-vpc-gwlb.gwlb_endpoint_service_name
  gwlb_endpoint_service_type = module.security-vpc-gwlb.gwlb_endpoint_service_type

  tag_name_prefix = var.tag_name_prefix
  tag_name_unique = "spoke2"
}

module "fgts" {
  source = ".//modules/ftnt_aws/fgt-gwlb"
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region

  availability_zones = var.availability_zones
  public_subnet_ids = module.security-vpc.public_subnet_ids
  private_subnet_ids = module.security-vpc.private_subnet_ids
  vpc_id = module.security-vpc.vpc_id
  vpc_cidr = var.security_vpc_cidr
  gwlb_ips = module.security-vpc-gwlb.gwlb_ips

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

