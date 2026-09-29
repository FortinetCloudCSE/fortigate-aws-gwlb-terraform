#####################################
#									#
#	Inspection VPC Configuration	#
#									#
#####################################
variable "tag_name_prefix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  type        = string
  default     = "poc-ngfw"
}
variable "region" {
  description = "Provide the region to use for all resources in this deployment"
  type        = string
  default     = "us-east-1"
}
variable "availability_zones" {
  description = "Provide a list of availability zone names to use (Min 2, Max 6)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  validation {
    condition     = length(var.availability_zones) >= 2 && length(var.availability_zones) <= 6
    error_message = "availability_zones must contain between 2 and 6 zones"
  }
}
variable "inspection_vpc_cidr" {
  description = "Provide the network CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.inspection_vpc_cidr, 0))
    error_message = "Must be a valid CIDR block format."
  }
}
variable "inspection_vpc_public_subnet_cidrs" {
  description = "Provide a list of network CIDRs for public subnets (Min 2, Max 6)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  validation {
    condition     = length(var.inspection_vpc_public_subnet_cidrs) >= 2 && length(var.inspection_vpc_public_subnet_cidrs) <= 6
    error_message = "inspection_vpc_public_subnet_cidrs must contain between 2 and 6 CIDRs"
  }
}
variable "inspection_vpc_private_subnet_cidrs" {
  description = "Provide a list of network CIDRs for private subnets (Min 2, Max 6)"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
  validation {
    condition     = length(var.inspection_vpc_private_subnet_cidrs) >= 2 && length(var.inspection_vpc_private_subnet_cidrs) <= 6
    error_message = "inspection_vpc_private_subnet_cidrs must contain between 2 and 6 CIDRs"
  }
}
variable "inspection_vpc_gwlb_subnet_cidrs" {
  description = "Provide a list of network CIDRs for gwlb subnets (Min 2, Max 6)"
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
  validation {
    condition     = length(var.inspection_vpc_gwlb_subnet_cidrs) >= 2 && length(var.inspection_vpc_gwlb_subnet_cidrs) <= 6
    error_message = "inspection_vpc_gwlb_subnet_cidrs must contain between 2 and 6 CIDRs"
  }
}
variable "inspection_vpc_attachment_subnet_cidrs" {
  description = "Provide a list of network CIDRs for attachment subnets (Min 2, Max 6)"
  type        = list(string)
  default     = ["10.0.7.0/24", "10.0.8.0/24"]
  validation {
    condition     = length(var.inspection_vpc_attachment_subnet_cidrs) >= 2 && length(var.inspection_vpc_attachment_subnet_cidrs) <= 6
    error_message = "inspection_vpc_attachment_subnet_cidrs must contain between 2 and 6 CIDRs"
  }
}
variable "internet_access" {
  description = "Provide 'eip' to assign Elastic IPs to the FortiGate interfaces in public subnets, or 'natgw' to use a regional NAT Gateway for outbound internet access"
  type        = string
  default     = "eip"
  validation {
    condition     = contains(["eip", "natgw"], var.internet_access)
    error_message = "internet_access must be one of: eip or natgw"
  }
}

#################################
#								#
#	Cloud WAN Configuration		#
#								#
#################################
variable "cwan_integration" {
  description = "Provide 'new' if you want to deploy a new Cloud WAN network with production, development, sharedservices, and firewall segments and two Spoke VPCs (Spoke1 & Spoke2). Otherwise select 'existing' to use an existing Cloud WAN or 'No'"
  type        = string
  default     = "no"
  validation {
    condition     = contains(["no", "new", "existing"], var.cwan_integration)
    error_message = "cwan_integration must be one of: no, new, existing"
  }
}
variable "cwan_existing_id" {
  description = "[Leave blank if an existing Cwan will not be used] If you are using an existing Cloud WAN, provide the Cloud WAN Core Network ID to create VPC routes to reach it"
  type        = string
}
variable "cwan_existing_account_id" {
  description = "[Leave blank if an existing Cwan will not be used] If you are using an existing Cloud WAN, provide the AWS Account ID where the Cloud WAN Core Network exists to create VPC routes to reach it"
  type        = string
}
variable "cwan_existing_segment_key" {
  description = "[Leave blank if an existing Cwan will not be used] Provide the name that should be used to create a Tag on the Cwan VPC Attachment to allow CWAN attachment automation"
  type        = string
}
variable "cwan_existing_segment_value" {
  description = "[Leave blank if an existing Cwan will not be used] Provide the value that should be used to create a Tag on the Cwan VPC Attachment to allow CWAN attachment automation"
  type        = string
}


#########################################
#										#
#	Transit Gateway Configuration		#
#										#
#########################################
variable "tgw_integration" {
  description = "Provide 'new' if you want to deploy a new Transit GW, two Transit GW Route Tables, and two Spoke VPCs (Spoke1 & Spoke2). Otherwise select 'existing' to use an existing Transit GW or 'No'"
  type        = string
  default     = "no"
  validation {
    condition     = contains(["no", "new", "existing"], var.tgw_integration)
    error_message = "tgw_integration must be one of: no, new, existing"
  }
}
variable "tgw_existing_id" {
  description = "[Leave blank if an existing TGW will not be used] If you are using an existing Transit GW, provide the Transit GW ID to create VPC routes to reach it"
  type        = string
}
variable "tgw_existing_security_tgw_route_table_id" {
  description = "[Leave blank if an existing TGW will not be used] If you are using an existing Transit GW, provide the Transit GW RouteTable ID for the security VPC to associate to"
  type        = string
}
variable "tgw_existing_spoke_tgw_route_table_id" {
  description = "[Leave blank if an existing TGW will not be used] If you are using an existing Transit GW, provide the Transit GW RouteTable ID that your spoke VPCs are associated with"
  type        = string
}
variable "tgw_existing_spoke_tgw_route_table_route" {
  description = "[Leave blank if an existing TGW will not be used] If you are using an existing Transit GW, provide a network CIDR to create a route in your Transit GW RouteTable that your spoke VPCs are associated with"
  type        = string
}


#########################################################################################
#																						#
#	Spoke1 VPC Configuration (Only used if cwan_integration or tgw_integration = new)	#
#																						#
#########################################################################################
variable "spoke_vpc1_cidr" {
  description = "Provide the network CIDR for the VPC"
  type        = string
  default     = "10.1.0.0/16"
  validation {
    condition     = can(cidrhost(var.spoke_vpc1_cidr, 0))
    error_message = "Must be a valid CIDR block format."
  }
}
variable "spoke_vpc1_public_subnet_cidrs" {
  description = "Provide a list of network CIDRs for public subnets (Min 2, Max 6)"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
  validation {
    condition     = length(var.spoke_vpc1_public_subnet_cidrs) >= 2 && length(var.spoke_vpc1_public_subnet_cidrs) <= 6
    error_message = "spoke_vpc1_public_subnet_cidrs must contain between 2 and 6 CIDRs"
  }
}
variable "spoke_vpc1_private_subnet_cidrs" {
  description = "Provide a list of network CIDRs for private subnets (Min 2, Max 6)"
  type        = list(string)
  default     = ["10.1.3.0/24", "10.1.4.0/24"]
  validation {
    condition     = length(var.spoke_vpc1_private_subnet_cidrs) >= 2 && length(var.spoke_vpc1_private_subnet_cidrs) <= 6
    error_message = "spoke_vpc1_private_subnet_cidrs must contain between 2 and 6 CIDRs"
  }
}
variable "spoke_vpc1_gwlb_subnet_cidrs" {
  description = "Provide a list of network CIDRs for gwlb subnets (Min 2, Max 6)"
  type        = list(string)
  default     = ["10.1.5.0/24", "10.1.6.0/24"]
  validation {
    condition     = length(var.spoke_vpc1_gwlb_subnet_cidrs) >= 2 && length(var.spoke_vpc1_gwlb_subnet_cidrs) <= 6
    error_message = "spoke_vpc1_gwlb_subnet_cidrs must contain between 2 and 6 CIDRs"
  }
}
variable "spoke_vpc1_distributed_inspection" {
  description = "Select an option below for distributed inspection. This creates VPC routes to use the spoke VPC's GWLB endpoints to intercept traffic."
  type        = string
  /*
    For distributed inspection choose one of:
     - "1: Distributed Ingress @ IGW"
     - "2: Distributed Ingress @ Public Subnets"
     - "3: Distributed Egress"
     - "4: Option 2 + 3 above"
     - "5: No Distributed Ingress or Egress Inspection (use Cwan or Tgw for centralized inspection)" 
    */
  default = "1: Distributed Ingress @ IGW"
  validation {
    condition     = contains(["1: Distributed Ingress @ IGW", "2: Distributed Ingress @ Public Subnets", "3: Distributed Egress", "4: Option 2 + 3 above", "5: No Distributed Ingress or Egress Inspection (use Cwan or Tgw for centralized inspection)"], var.spoke_vpc1_distributed_inspection)
    error_message = "spoke_vpc1_distributed_inspection must be one of: '1: Distributed Ingress @ IGW', '2: Distributed Ingress @ Public Subnets', '3: Distributed Egress', '4: Option 2 + 3 above'"
  }
}
variable "spoke_vpc1_route_to_cwan_or_tgw" {
  description = "Provide the CIDR to create a VPC route to reach resources via cwan or tgw"
  type        = string
  default     = "0.0.0.0/0"
  validation {
    condition     = can(cidrhost(var.spoke_vpc1_route_to_cwan_or_tgw, 0))
    error_message = "Must be a valid CIDR block format."
  }
}




#########################################################################################
#																						#
#	Spoke2 VPC Configuration (Only used if cwan_integration or tgw_integration = new)	#
#																						#
#########################################################################################
variable "spoke_vpc2_cidr" {
  description = "Provide the network CIDR for the VPC"
  type        = string
  default     = "10.2.0.0/16"
  validation {
    condition     = can(cidrhost(var.spoke_vpc2_cidr, 0))
    error_message = "Must be a valid CIDR block format."
  }
}
variable "spoke_vpc2_public_subnet_cidrs" {
  description = "Provide a list of network CIDRs for public subnets (Min 2, Max 6)"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24"]
  validation {
    condition     = length(var.spoke_vpc2_public_subnet_cidrs) >= 2 && length(var.spoke_vpc2_public_subnet_cidrs) <= 6
    error_message = "spoke_vpc2_public_subnet_cidrs must contain between 2 and 6 CIDRs"
  }
}
variable "spoke_vpc2_private_subnet_cidrs" {
  description = "Provide a list of network CIDRs for private subnets (Min 2, Max 6)"
  type        = list(string)
  default     = ["10.2.3.0/24", "10.2.4.0/24"]
  validation {
    condition     = length(var.spoke_vpc2_private_subnet_cidrs) >= 2 && length(var.spoke_vpc2_private_subnet_cidrs) <= 6
    error_message = "spoke_vpc2_private_subnet_cidrs must contain between 2 and 6 CIDRs"
  }
}
variable "spoke_vpc2_gwlb_subnet_cidrs" {
  description = "Provide a list of network CIDRs for gwlb subnets (Min 2, Max 6)"
  type        = list(string)
  default     = ["10.2.5.0/24", "10.2.6.0/24"]
  validation {
    condition     = length(var.spoke_vpc2_gwlb_subnet_cidrs) >= 2 && length(var.spoke_vpc2_gwlb_subnet_cidrs) <= 6
    error_message = "spoke_vpc2_gwlb_subnet_cidrs must contain between 2 and 6 CIDRs"
  }
}
variable "spoke_vpc2_distributed_inspection" {
  description = "Select an option below for distributed inspection. This creates VPC routes to use the spoke VPC's GWLB endpoints to intercept traffic."
  type        = string
  /*
    For distributed inspection choose one of:
     - "1: Distributed Ingress @ IGW"
     - "2: Distributed Ingress @ Public Subnets"
     - "3: Distributed Egress"
     - "4: Option 2 + 3 above"
     - "5: No Distributed Ingress or Egress Inspection (use Cwan or Tgw for centralized inspection)" 
    */
  default = "4: Option 2 + 3 above"
  validation {
    condition     = contains(["1: Distributed Ingress @ IGW", "2: Distributed Ingress @ Public Subnets", "3: Distributed Egress", "4: Option 2 + 3 above", "5: No Distributed Ingress or Egress Inspection (use Cwan or Tgw for centralized inspection)"], var.spoke_vpc2_distributed_inspection)
    error_message = "spoke_vpc2_distributed_inspection must be one of: '1: Distributed Ingress @ IGW', '2: Distributed Ingress @ Public Subnets', '3: Distributed Egress', '4: Option 2 + 3 above'"
  }
}
variable "spoke_vpc2_route_to_cwan_or_tgw" {
  description = "Provide the CIDR to create a VPC route to reach resources via cwan or tgw"
  type        = string
  default     = "10.0.0.0/8"
  validation {
    condition     = can(cidrhost(var.spoke_vpc2_route_to_cwan_or_tgw, 0))
    error_message = "Must be a valid CIDR block format."
  }
}


#############################################
#											#
#	FortiGate Instance VPC Configuration	#
#											#
#############################################
variable "arm_mode" {
  description = "Provide '1-arm' for a single data ENI (FortiOS hairpins all traffic, no SNAT). '2-arm' for two data ENIs (FortiOS hairpins private traffic, SNATs public egress traffic out port2)"
  type        = string
  default     = "1-arm"
  validation {
    condition     = contains(["1-arm", "2-arm"], var.arm_mode)
    error_message = "arm_mode must be one of: 1-arm or 2-arm"
  }
}
variable "dedicated_management" {
  description = "Provide true or false to attach a dedicated management ENI on the highest device index (1arm: port2, 2-arm: port3)"
  type        = bool
  default     = false
}
variable "dedicated_management_placement" {
  description = "[Ignore if 'DedicatedManagement' is 'False'] Attach the dedicated management ENI in the Public or Private subnet."
  type        = string
  default     = "private"
  validation {
    condition     = contains(["public", "private"], var.dedicated_management_placement)
    error_message = "dedicated_management_placement must be one of: public or private"
  }
}
variable "num_of_fgts_per_az" {
  description = "Provide the number of Fgts to deploy in each AZ (ie Fgt1a-us-east-1a, Fgt1b-us-east-1a) (Min 1, Max 2)"
  type        = number
  default     = 1
  validation {
    condition     = contains([1, 2], var.num_of_fgts_per_az)
    error_message = "num_of_fgts_per_az must be one of: 1 or 2"
  }
}
variable "instance_type" {
  description = "Provide the instance type for the Fgts"
  type        = string
  default     = "c6i.xlarge"
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
  c7gn.16xlarge
  c8g.xlarge
  c8g.2xlarge
  c8g.4xlarge
  c8g.8xlarge
  c8g.16xlarge
  c8gn.large
  c8gn.xlarge
  c8gn.2xlarge
  c8gn.4xlarge
  c8gn.8xlarge
  c8gn.16xlarge
  */
}
variable "cidr_for_access" {
  description = "Provide a network CIDR for accessing the Fgts"
  type        = string
  default     = ""
}
variable "keypair" {
  description = "Provide a keypair for accessing the Fgts"
  type        = string
  default     = "kp-poc-common"
}
variable "encrypt_volumes" {
  description = "Provide 'true' to encrypt the Fgts OS and Log volumes with your account's KMS default master key for EBS.  Otherwise provide 'false' to leave unencrypted"
  type        = string
  default     = "true"
  validation {
    condition     = contains(["true", "false"], var.encrypt_volumes)
    error_message = "encrypt_volumes must be one of: public or private"
  }
}
variable "fortios_version" {
  description = "Provide the verion of FortiOS to use (latest GA AMI will be used), 7.4, 7.6, or 8.0"
  type        = string
  default     = "7.4"
  validation {
    condition     = contains(["7.4", "7.6", "8.0"], var.fortios_version)
    error_message = "fortios_version must be one of: 7.4, 7.6, or 8.0"
  }
}
variable "license_type" {
  description = "Provide the license type for the Fgts, byol flex, or payg"
  type        = string
  default     = "payg"
  validation {
    condition     = contains(["byol", "flex", "payg"], var.license_type)
    error_message = "license_type must be one of: byol, flex, payg"
  }
}
variable "license_files" {
  description = "[BYOL Only, leave default otherwise] Provide a list of BYOL license filenames for the Fgts and place the file in the root module folder (Min 2, Max 6)"
  type        = list(string)
  default     = ["fgt1a-license.lic", "fgt2a-license.lic", "fgt1b-license.lic", "fgt2b-license.lic"]
}
variable "flex_tokens" {
  description = "[FortiFlex only, leave default otherwise] Provide a list of FortiFlex Tokens for the Fgts (Min 2, Max 6)"
  type        = list(string)
  default     = ["1A1A1A1A1A1A1A1A1A1A", "2A2A2A2A2A2A2A2A2A2A", "1B1B1B1B1B1B1B1B1B1B", "2B2B2B2B2B2B2B2B2B2B"]
}