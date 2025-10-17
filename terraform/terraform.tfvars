/*
Please update the example values here to override the default values in variables.tf.
Any variables in variables.tf can be overriden here.
Overriding variables here keeps the variables.tf as a clean local reference.
*/

# Provide the credentials to access the AWS account
access_key = ""
secret_key = ""

# Specify the region and AZs to use.
region = "us-east-1"
availability_zones = ["us-east-1a", "us-east-1b"]

/*
To deploy a new TGW and two spoke VPCs, specify 'yes'.
To deploy a new CWAN and two spoke VPCs, specify 'yes'.
Only specify yes for tgw_creation or cwan_creation not both.
*/
cwan_creation = "no"
tgw_creation = "no"

# Specify number of Fgts to deploy per AZ (Min 1, Max 2)
num_of_fgts_per_az = 1

# Specify the name of the keypair that the FGTs will use.
keypair = ""

# Specify the CIDR block which you will be logging into the FGTs from.
cidr_for_access = "0.0.0.0/0"

# Specify a tag prefix that will be used to name resources.
tag_name_prefix = "poc"

# Specify the FortiOS version to use 7.2, 7.4, or 7.6
fortios_version = "7.4"

/*
For license_type, specify byol, flex, or payg.

To use traditional byol license files, place the license files in this root directory (same as this file) and specify the file names in a list like so.
Otherwise, leave these as empty strings.
license_files_for_1st_fgt_per_az = ["fgt1a-license.lic", "fgt2a-license.lic"]
license_files_for_2nd_fgt_per_az = ["fgt1b-license.lic", "fgt2b-license.lic"]

To use FortiFlex tokens, please provide the token values in a list like so.
Otherwise, leave these as empty strings.
flex_tokens_for_1st_fgt_per_az = ["1A1A1A1A1A1A1A1A1A1A", "2A2A2A2A2A2A2A2A2A2A"]
flex_Tokens_for_2nd_fgt_per_az = ["1B1B1B1B1B1B1B1B1B1B", "2B2B2B2B2B2B2B2B2B2B"]
*/
license_type = "payg"
license_files_for_1st_fgt_per_az = []
license_files_for_2nd_fgt_per_az = []
flex_tokens_for_1st_fgt_per_az = []
flex_Tokens_for_2nd_fgt_per_az = []