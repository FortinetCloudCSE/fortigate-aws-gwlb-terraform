module "inspection-vpc-gwlb" {
  source = "../../modules/gwlb"
  count  = var.gwlb_integration == "new" ? 1 : 0
  region = var.region

  vpc_id     = var.existing_vpc_id
  subnet_ids = var.existing_vpc_gwlb_subnet_ids

  tag_name_prefix = var.tag_name_prefix
  tag_name_unique = "sec-gwlb"
}

module "fgts" {
  source = "../../modules/fgt-gwlb"
  region = var.region

  availability_zones             = var.availability_zones
  public_subnet_ids              = var.existing_vpc_public_subnet_ids
  private_subnet_ids             = var.existing_vpc_private_subnet_ids
  vpc_id                         = var.existing_vpc_id
  vpc_cidr                       = var.existing_vpc_cidr
  gwlb_ips                       = var.gwlb_integration == "new" ? module.inspection-vpc-gwlb[0].gwlb_ips : var.existing_vpc_gwlb_ips
  gwlb_target_group_arn          = var.gwlb_integration == "new" ? module.inspection-vpc-gwlb[0].gwlb_target_group_arn : var.existing_vpc_gwlb_target_group_arn
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