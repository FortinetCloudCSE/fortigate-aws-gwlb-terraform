variable "access_key" {}
variable "secret_key" {}
variable "region" {
  description = "Provide the region to deploy the VPC in"
  type = string
  default = "us-east-1"
}
variable "availability_zones" {
  description = "Provide a list of availability zone names to use (Min 2, Max 6)"
  type = list(string)
  default = ["us-east-1a", "us-east-1b"]
}
variable "inspection_vpc_cidr" {
  description = "Provide the network CIDR for the VPC"
    type = string
  default = "10.0.0.0/16"
}
variable "inspection_vpc_public_subnet_cidrs" {
  description = "Provide a list of network CIDRs for public subnets (Min 2, Max 6)"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "inspection_vpc_private_subnet_cidrs" {
  description = "Provide a list of network CIDRs for private subnets (Min 2, Max 6)"
  type = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}
variable "inspection_vpc_gwlb_subnet_cidrs" {
  description = "Provide a list of network CIDRs for gwlb subnets (Min 2, Max 6)"
  type = list(string)
  default = ["10.0.5.0/24", "10.0.6.0/24"]
}
variable "inspection_vpc_attachment_subnet_cidrs" {
  description = "Provide a list of network CIDRs for attachment subnets (Min 2, Max 6)"
  type = list(string)
  default = ["10.0.7.0/24", "10.0.8.0/24"]
}
variable "tgw_creation" {
  description = "Provide a 'yes' to deply a new TGW and configure the inspection VPC and fgts accordingly, otherwise leave as 'no'"
  type = string
  default = "no"
}
variable "cwan_creation" {
  description = "Provide a 'yes' to deply a new CWAN and configure the inspection VPC and fgts accordingly, otherwise leave as 'no'"
  type = string
  default = "no"
}
variable "spoke_vpc1_cidr" {
  description = "Provide the network CIDR for the VPC"
  type = string
  default = "10.1.0.0/16"
}
variable "spoke_vpc1_public_subnet_cidrs" {
  description = "Provide a list of network CIDRs for public subnets (Min 2, Max 6)"
  type = list(string)
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}
variable "spoke_vpc1_private_subnet_cidrs" {
  description = "Provide a list of network CIDRs for private subnets (Min 2, Max 6)"
  type = list(string)
  default = ["10.1.3.0/24", "10.1.4.0/24"]
}
variable "spoke_vpc1_gwlb_subnet_cidrs" {
  description = "Provide a list of network CIDRs for gwlb subnets (Min 2, Max 6)"
  type = list(string)
  default = ["10.1.5.0/24", "10.1.6.0/24"]
}
variable "spoke_vpc2_cidr" {
  description = "Provide the network CIDR for the VPC"
  type = string
  default = "10.2.0.0/16"
}
variable "spoke_vpc2_public_subnet_cidrs" {
  description = "Provide a list of network CIDRs for public subnets (Min 2, Max 6)"
  type = list(string)
  default = ["10.2.1.0/24", "10.2.2.0/24"]
}
variable "spoke_vpc2_private_subnet_cidrs" {
  description = "Provide a list of network CIDRs for private subnets (Min 2, Max 6)"
  type = list(string)
  default = ["10.2.3.0/24", "10.2.4.0/24"]
}
variable "spoke_vpc2_gwlb_subnet_cidrs" {
  description = "Provide a list of network CIDRs for gwlb subnets (Min 2, Max 6)"
  type = list(string)
  default = ["10.2.5.0/24", "10.2.6.0/24"]
}
variable "num_of_fgts_per_az" {
  description = "Provide the number of Fgts to deploy in each AZ (ie Fgt1a-us-east-1a, Fgt1b-us-east-1a) (Min 1, Max 2)"
  type = string
  default = "1"
}
variable "instance_type" {
  description = "Provide the instance type for the Fgts"
  type = string
  default = "c6i.xlarge"
  /*
  Here is a list of supported instance types:
  c5.large 
  c5.xlarge 
  c5.2xlarge 
  c5.4xlarge 
  c5.9xlarge 
  c5.18xlarge 
  c5n.large 
  c5n.xlarge 
  c5n.2xlarge 
  c5n.4xlarge 
  c5n.9xlarge 
  c5n.18xlarge 
  c6i.large 
  c6i.xlarge 
  c6i.2xlarge 
  c6i.4xlarge 
  c6i.8xlarge 
  c6i.16xlarge 
  c6i.24xlarge 
  c6in.large 
  c6in.xlarge 
  c6in.2xlarge 
  c6in.4xlarge 
  c6in.8xlarge 
  c6in.16xlarge 
  c6g.large 
  c6g.xlarge 
  c6g.2xlarge 
  c6g.4xlarge 
  c6g.8xlarge 
  c6g.16xlarge 
  c6gn.large 
  c6gn.xlarge 
  c6gn.2xlarge 
  c6gn.4xlarge 
  c6gn.8xlarge 
  c6gn.16xlarge 
  c7g.large 
  c7g.xlarge 
  c7g.2xlarge 
  c7g.4xlarge 
  c7g.8xlarge 
  c7g.16xlarge 
  c7gn.large 
  c7gn.xlarge 
  c7gn.2xlarge 
  c7gn.4xlarge 
  c7gn.8xlarge 
  c7gn.16xlarge"
  */
}
variable "cidr_for_access" {
  description = "Provide a network CIDR for accessing the Fgts"
  type = string
  default = "0.0.0.0/0"
}
variable "keypair" {
  description = "Provide a keypair for accessing the Fgts"
  type = string
  default = "kp-poc-common"
}
variable "encrypt_volumes" {
  description = "Provide 'true' to encrypt the Fgts OS and Log volumes with your account's KMS default master key for EBS.  Otherwise provide 'false' to leave unencrypted"
  type = string
  default = "true"
}
variable "fortios_version" {
  description = "Provide the verion of FortiOS to use (latest GA AMI will be used), 7.2, 7.4, or 7.6"
  type = string
  default = "7.4"
}
variable "license_type" {
  description = "Provide the license type for the Fgts, byol flex, or payg"
  type = string
  default = "payg"
}
variable "license_files_for_1st_fgt_per_az" {
  description = "[BYOL Only, leave default otherwise] Provide a list of BYOL license filenames for the first Fgts to be deployed in each AZ and place the file in the root module folder (Min 2, Max 6)"
  type = list(string)
  default = ["fgt1a-license.lic", "fgt2a-license.lic"]
}
variable "license_files_for_2nd_fgt_per_az" {
  description = "[BYOL Only, leave default otherwise]Provide a list of BYOL license filenames for the second Fgts to be deployed in each AZ and place the file in the root module folder (Min 2, Max 6)"
  type = list(string)
  default = ["fgt1a-license.lic", "fgt2a-license.lic"]
}
variable "flex_tokens_for_1st_fgt_per_az" {
  description = "[FortiFlex only, leave default otherwise] Provide a list of FortiFlex Tokens for the first Fgts to be deployed in each AZ (Min 2, Max 6)"
  type = list(string)
  default = ["1A1A1A1A1A1A1A1A1A1A", "2A2A2A2A2A2A2A2A2A2A"]
}
variable "flex_Tokens_for_2nd_fgt_per_az" {
  description = "[FortiFlex only, leave default otherwise] Provide a list of FortiFlex Tokens for the second Fgts to be deployed in each AZ (Min 2, Max 6)"
  type = list(string)
  default = ["1B1B1B1B1B1B1B1B1B1B", "2B2B2B2B2B2B2B2B2B2B"]
}
variable "tag_name_prefix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  type = string
  default = "stack-1"
}
#variable "tag_name_unique" {
#  description = "Provide a unique tag prefix value that will be used in the name tag for each modules resources"
#  default = "automatically handled by terraform modules"
#}
