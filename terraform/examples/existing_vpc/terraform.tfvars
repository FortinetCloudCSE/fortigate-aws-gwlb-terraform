/*
Please update the example values here to override the default values in variables.tf.
Any variables in variables.tf can be overriden here.
Overriding variables here keeps the variables.tf as a clean local reference.
*/

/*
Credentials are automatically detected from standard AWS authentication means:
 - AWS creds file used with AWS CLI (~/.aws/credentials)
 - Environment variables (AWSACCESSKEYID, AWSSECRETACCESSKEY)
 - IAM Roles (preferred for EC2, ECS)
 - AWS SSO (aws sso login)
For more documentation on how to authenticate, reference the link below: https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration
*/

# Specify a tag prefix that will be used to name resources.
tag_name_prefix = "poc"

# Specify the region and AZs to use. For AZs specify a minimum of 2 and a maximum of 6.
region             = "us-west-1"
availability_zones = ["us-west-1a", "us-west-1b"]

/*
Provide the CIDRs for the inspection VPC where the FortiGates will be deployed.
For the subnet variables, provide a minimum of 2 CIDRs and a maximum of 6.
*/
existing_vpc_cidr               = "10.0.0.0/16"
existing_vpc_id                 = "vpc-00000000000000000"
existing_vpc_public_subnet_ids     = ["subnet-00000000000000000", "subnet-00000000000000000"]
existing_vpc_private_subnet_ids    = ["subnet-00000000000000000", "subnet-00000000000000000"]
existing_vpc_gwlb_subnet_ids       = ["subnet-00000000000000000", "subnet-00000000000000000"]

/*
Specify if a new GWLB will be deployed or if an existing one will be used.
Allowed values are "new" or "existing".
If "existing" is specified, provide the values for the "existing_vpc_..." variables
*/
gwlb_integration                   = "new"
existing_vpc_gwlb_target_group_arn = ""
existing_vpc_gwlb_ips              = []

/*
Specify if the FortiGates will use EIPs to access the internet or not.
If "natgw" is specified, the VPC routing for the public subnets should allow the FortiGates to access the internet directly (without an explicit proxy).
Allowed values are "eip" or "natgw".
*/
internet_access = "eip"

/*
Specify the arm mode, this effects the FortiGate ENIs, policy routes, and firewall policy used.
Provide "1-arm" for a single data ENI (FortiOS hairpins all traffic, no SNAT). 
Provide "2-arm" for two data ENIs (FortiOS hairpins private traffic, SNATs public egress traffic out port2).
*/
arm_mode = "1-arm"

/*
Specify true or false to attach a dedicated management ENI on the highest device index (1arm: port2, 2-arm: port3)
Specify "public" or "private" to attach the dedicated management ENI in the Public or Private subnet.
*/
dedicated_management           = true
dedicated_management_placement = "public"

# Specify number of Fgts to deploy per AZ (Min 1, Max 2)
num_of_fgts_per_az = 1

# Specify the instance type, reference variables.tf for the list of instance types
instance_type = "c6i.xlarge"

# Specify the name of the keypair that the FGTs will use.
keypair = ""

# Specify "true" to encrypt the Fgts OS and Log volumes with your account's KMS default master key for EBS or not with "false".
encrypt_volumes = true

# Specify the CIDR block which you will be logging into the FGTs from.
cidr_for_access = ""

# Specify the FortiOS version to use "7.4", "7.6", or "8.0"
fortios_version = "7.6"

/*
For license_type, specify byol, flex, or payg.

To use traditional byol license files, place the license files in this root directory (same as this file) and specify the file names in a list like so.
Otherwise, leave these as empty strings.
license_files = ["fgt1a-license.lic", "fgt2a-license.lic", "fgt1b-license.lic", "fgt2b-license.lic"]

To use FortiFlex tokens, please provide the token values in a list like so.
Otherwise, leave these as empty strings.
flex_tokens = ["1A1A1A1A1A1A1A1A1A1A", "2A2A2A2A2A2A2A2A2A2A", "1B1B1B1B1B1B1B1B1B1B", "2B2B2B2B2B2B2B2B2B2B"]
*/
license_type  = "payg"
license_files = []
flex_tokens   = []