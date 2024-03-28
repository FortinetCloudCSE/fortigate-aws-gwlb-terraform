---
title: "Deployment"
chapter: false
menuTitle: "Deployment"
weight: 30
---

Once the prerequisites have been satisfied proceed with the deployment steps below.

1.  Clone this repo with the command below.
```
git clone https://github.com/FortinetCloudCSE/fortigate-aws-gwlb-terraform.git
```

2.  Change directories and modify the terraform.tfvars file with your credentials and deployment information. 

{{% notice note %}} In the terraform.tfvars file, the comments explain what inputs are expected for the variables. For further details on a given variable or to see all possible variables, reference the variables.tf file. We chose to deploy 2 FGTs per AZ and set tgw_creation to yes.  {{% /notice %}}
```
cd fortigate-aws-gwlb-terraform/terraform
nano terraform.tfvars
```

3.  When ready to deploy, use the commands below to run through the deployment.
```
terraform init
terraform validate
terraform apply --auto-approve
```

4.  When the deployment is complete, you will see the public IPs and instance IDs listed in the outputs to access each FGT and other information.
```
Apply complete! Resources: 85 added, 0 changed, 0 destroyed.

Outputs:

fgt_login_info = <<EOT
# fgt username: admin
# fgt initial password: instance-id of the fgt
# fgt_ids_a : ["i-053888445f2e677ef","i-09c5e7a6bf403cd77"]  
# fgt_ips_a : ["34.235.8.29","52.70.176.130"]
# fgt_ids_b : ["i-094aae24d8f1665b0","i-0575b16f6aeeb0e15"]  
# fgt_ips_b : ["3.210.241.134","44.196.135.34"]

EOT
gwlb_info = <<EOT
# gwlb arn_suffix: gwy/poc-sec-gwlb/09856ffbfe1862f3
# gwlb service_name : com.amazonaws.vpce.us-east-1.vpce-svc-0db0f1b8e4b8445f1
# gwlb service_type : GatewayLoadBalancer
# gwlb ips : ["10.0.13.83","10.0.14.93"]

EOT
tgw_info = <<EOT
# tgw id: tgw-09eb29c4aa20fe1ce
# tgw spoke route table id: tgw-rtb-0b080f43f34fd129d
# tgw security route table id: tgw-rtb-0c09fcc9ce8d3e917

EOT
```

5.  This concludes the template deployment example.
