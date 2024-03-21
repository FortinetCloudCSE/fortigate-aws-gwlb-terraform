variable "access_key" {}
variable "secret_key" {}
variable "region" {
  description = "Provide the region to deploy the VPC in"
  default = "us-east-1"
}
variable "availability_zones" {
  description = "Provide a list of availability zone names to use (Min 2, Max 6)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]

}
variable "security_vpc_cidr" {
  description = "Provide the network CIDR for the VPC"
  default = "10.0.0.0/16"
}
variable "security_vpc_public_subnet_cidrs" {
  description = "Provide a list of network CIDRs for public subnets (Min 2, Max 6)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "security_vpc_private_subnet_cidrs" {
  description = "Provide a list of network CIDRs for private subnets (Min 2, Max 6)"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}
variable "security_vpc_gwlb_subnet_cidrs" {
  description = "Provide a list of network CIDRs for gwlb subnets (Min 2, Max 6)"
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}
variable "security_vpc_tgwattach_subnet_cidrs" {
  description = "Provide a list of network CIDRs for tgwattach subnets (Min 2, Max 6)"
  type        = list(string)
  default     = ["10.0.7.0/24", "10.0.8.0/24"]
}
variable "tgw_creation" {
  description = "Provide a 'yes' to deply a new TGW and configure the security VPC and fgts accordingly, otherwise leave as 'no'"
  default = "no"
}
variable "spoke_vpc1_cidr" {
  description = "Provide the network CIDR for the VPC"
  default = "10.1.0.0/16"
}
variable "spoke_vpc1_public_subnet_cidrs" {
  description = "Provide a list of network CIDRs for public subnets (Min 2, Max 6)"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}
variable "spoke_vpc1_private_subnet_cidrs" {
    description = "Provide a list of network CIDRs for private subnets (Min 2, Max 6)"
    type        = list(string)
    default     = ["10.1.3.0/24", "10.1.4.0/24"]
}
variable "spoke_vpc1_gwlb_subnet_cidrs" {
    description = "Provide a list of network CIDRs for gwlb subnets (Min 2, Max 6)"
    type        = list(string)
    default     = ["10.1.5.0/24", "10.1.6.0/24"]
}
variable "spoke_vpc2_cidr" {
  description = "Provide the network CIDR for the VPC"
  default = "10.2.0.0/16"
}
variable "spoke_vpc2_public_subnet_cidrs" {
  description = "Provide a list of network CIDRs for public subnets (Min 2, Max 6)"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24"]
}
variable "spoke_vpc2_private_subnet_cidrs" {
    description = "Provide a list of network CIDRs for private subnets (Min 2, Max 6)"
    type        = list(string)
    default     = ["10.2.3.0/24", "10.2.4.0/24"]
}
variable "spoke_vpc2_gwlb_subnet_cidrs" {
    description = "Provide a list of network CIDRs for gwlb subnets (Min 2, Max 6)"
    type        = list(string)
    default     = ["10.2.5.0/24", "10.2.6.0/24"]
}
variable "num_of_fgts_per_az" {
  description = "Provide the number of Fgts to deploy in each AZ (ie Fgt1a-us-east-1a, Fgt1b-us-east-1a) (Min 1, Max 2)"
  default = "c6i.xlarge"
}
variable "instance_type" {
  description = "Provide the instance type for the Fgts"
  default = "c6i.xlarge"
}
variable "cidr_for_access" {
  description = "Provide a network CIDR for accessing the Fgts"
  default = "0.0.0.0/0"
}
variable "keypair" {
  description = "Provide a keypair for accessing the Fgts"
  default = "kp-poc-common"
}
variable "encrypt_volumes" {
  description = "Provide 'true' to encrypt the Fgts OS and Log volumes with your account's KMS default master key for EBS.  Otherwise provide 'false' to leave unencrypted"
  default = "true"
}
variable "fortios_version" {
  description = "Provide the verion of FortiOS to use (latest GA AMI will be used), 7.0, 7.2, or 7.4"
  default = "7.2"
}
variable "license_type" {
  description = "Provide the license type for the Fgts, byol flex, or payg"
  default = "payg"
}
variable "license_files_for_1st_fgt_per_az" {
  description = "[BYOL Only, leave default otherwise] Provide a list of BYOL license filenames for the first Fgts to be deployed in each AZ and place the file in the root module folder (Min 2, Max 6)"
  default = ["fgt1a-license.lic", "fgt2a-license.lic"]
}
variable "license_files_for_2nd_fgt_per_az" {
  description = "[BYOL Only, leave default otherwise]Provide a list of BYOL license filenames for the second Fgts to be deployed in each AZ and place the file in the root module folder (Min 2, Max 6)"
  default = ["fgt1a-license.lic", "fgt2a-license.lic"]
}
variable "flex_tokens_for_1st_fgt_per_az" {
  description = "[FortiFlex only, leave default otherwise] Provide a list of FortiFlex Tokens for the first Fgts to be deployed in each AZ (Min 2, Max 6)"
  default = ["1A1A1A1A1A1A1A1A1A1A", "2A2A2A2A2A2A2A2A2A2A"]
}
variable "flex_Tokens_for_2nd_fgt_per_az" {
  description = "[FortiFlex only, leave default otherwise] Provide a list of FortiFlex Tokens for the second Fgts to be deployed in each AZ (Min 2, Max 6)"
  default = ["1B1B1B1B1B1B1B1B1B1B", "2B2B2B2B2B2B2B2B2B2B"]
}
variable "tag_name_prefix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  default = "stack-1"
}
variable "tag_name_unique" {
  description = "Provide a unique tag prefix value that will be used in the name tag for each modules resources"
  default = "automatically handled by terraform modules"
}
