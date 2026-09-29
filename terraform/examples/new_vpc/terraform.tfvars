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
inspection_vpc_cidr                    = "10.0.0.0/16"
inspection_vpc_public_subnet_cidrs     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
inspection_vpc_private_subnet_cidrs    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
inspection_vpc_gwlb_subnet_cidrs       = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
inspection_vpc_attachment_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]

/*
Specify if the FortiGates will use EIPs to access the internet or a regional Nat Gateway.
Allowed values are "eip" or "natgw".
*/
internet_access = "eip"


/*
To deploy a new CWAN and two spoke VPCs, specify "new".
To integrate with an existing CWAN specify "existing" then provide the cwan_existing variables below.
Otherwise specify "no""
Only specify "new" or "existing" for cwan_integration or tgw_integration not both.
*/
cwan_integration            = "no"
cwan_existing_id            = ""
cwan_existing_account_id    = ""
cwan_existing_segment_key   = ""
cwan_existing_segment_value = ""

/*
To deploy a new TGW and two spoke VPCs, specify "new".
To integrate with an existing TGW specify "existing" then provide the tgw_existing variables below.
Otherwise specify "no".
Only specify "new" or "existing" for cwan_integration or tgw_integration not both.
*/
tgw_integration                          = "no"
tgw_existing_id                          = ""
tgw_existing_security_tgw_route_table_id = ""
tgw_existing_spoke_tgw_route_table_id    = ""
tgw_existing_spoke_tgw_route_table_route = ""


/*
Specify the arm mode, this effects the FortiGate ENIs, policy routes, and firewall policy used.
Provide "1-arm" for a single data ENI (FortiOS hairpins all traffic, no SNAT). 
Provide "2-arm" for two data ENIs (FortiOS hairpins private traffic, SNATs public egress traffic out port2).
*/
arm_mode = "1-arm"

/*
Specify "true" or "false" to attach a dedicated management ENI on the highest device index (1arm: port2, 2-arm: port3)
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

/*
If specifying "new" for cwan_integration or tgw_integration, 2 spoke VPCs will be created.
Provide the CIDRs to use for the spoke VPCs.
Otherwise, ignore these variables.

For distributed inspection choose one of:
 - "1: Distributed Ingress @ IGW"
 - "2: Distributed Ingress @ Public Subnets"
 - "3: Distributed Egress"
 - "4: Option 2 + 3 above"
 - "5: No Distributed Ingress or Egress Inspection (use Cwan or Tgw for centralized inspection)" 

For route_to_cwan_or_tgw, specify a CIDR to create a VPC route to reach resources via cwan or tgw.
*/
spoke_vpc1_cidr                   = "10.1.0.0/16"
spoke_vpc1_public_subnet_cidrs    = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
spoke_vpc1_private_subnet_cidrs   = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
spoke_vpc1_gwlb_subnet_cidrs      = ["10.1.7.0/24", "10.1.8.0/24", "10.1.9.0/24"]
spoke_vpc1_distributed_inspection = "1: Distributed Ingress @ IGW"
spoke_vpc1_route_to_cwan_or_tgw   = "0.0.0.0/0"

spoke_vpc2_cidr                   = "10.2.0.0/16"
spoke_vpc2_public_subnet_cidrs    = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
spoke_vpc2_private_subnet_cidrs   = ["10.2.4.0/24", "10.2.5.0/24", "10.2.6.0/24"]
spoke_vpc2_gwlb_subnet_cidrs      = ["10.2.7.0/24", "10.2.8.0/24", "10.2.9.0/24"]
spoke_vpc2_distributed_inspection = "4: Option 2 + 3 above"
spoke_vpc2_route_to_cwan_or_tgw   = "10.0.0.0/8"