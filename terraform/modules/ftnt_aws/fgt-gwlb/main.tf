provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}

resource "aws_iam_role" "iam-role" {
  name = "${var.tag_name_prefix}-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
    name = "${var.tag_name_prefix}-iam-instance-profile"
    role = "${var.tag_name_prefix}-iam-role"
}

resource "aws_iam_role_policy" "iam-role-policy" {
  name = "${var.tag_name_prefix}-iam-role-policy"
  role = aws_iam_role.iam-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SDNConnectorFortiView",
      "Effect": "Allow",
      "Action": [
		"ec2:DescribeRegions",
  		"eks:DescribeCluster",
  		"eks:ListClusters",
  		"inspector:DescribeFindings",
  		"inspector:ListFindings"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

variable "fgtami" {
  type = map(any)
  default = {
    "7.0" = {
      "arm" = {
        "byol" = "FortiGate-VMARM64-AWS *(7.0.*)*|33ndn84xbrajb9vmu5lxnfpjq"
		"flex" = "FortiGate-VMARM64-AWS *(7.0.*)*|33ndn84xbrajb9vmu5lxnfpjq"
        "payg" = "FortiGate-VMARM64-AWSONDEMAND *(7.0.*)*|8gc40z1w65qjt61p9ps88057n"
      },
      "intel" = {
        "byol" = "FortiGate-VM64-AWS *(7.0.*)*|dlaioq277sglm5mw1y1dmeuqa"
		"flex" = "FortiGate-VM64-AWS *(7.0.*)*|dlaioq277sglm5mw1y1dmeuqa"
        "payg" = "FortiGate-VM64-AWSONDEMAND *(7.0.*)*|2wqkpek696qhdeo7lbbjncqli"
      }
    },
    "7.2" = {
      "arm" = {
        "byol" = "FortiGate-VMARM64-AWS *(7.2.*)*|33ndn84xbrajb9vmu5lxnfpjq"
		"flex" = "FortiGate-VMARM64-AWS *(7.2.*)*|33ndn84xbrajb9vmu5lxnfpjq"
        "payg" = "FortiGate-VMARM64-AWSONDEMAND *(7.2.*)*|8gc40z1w65qjt61p9ps88057n"
      },
      "intel" = {
        "byol" = "FortiGate-VM64-AWS *(7.2.*)*|dlaioq277sglm5mw1y1dmeuqa"
		"flex" = "FortiGate-VM64-AWS *(7.2.*)*|dlaioq277sglm5mw1y1dmeuqa"
        "payg" = "FortiGate-VM64-AWSONDEMAND *(7.2.*)*|2wqkpek696qhdeo7lbbjncqli"
      }
    },
    "7.4" = {
      "arm" = {
        "byol" = "FortiGate-VMARM64-AWS *(7.4.*)*|33ndn84xbrajb9vmu5lxnfpjq"
		"flex" = "FortiGate-VMARM64-AWS *(7.4.*)*|33ndn84xbrajb9vmu5lxnfpjq"
        "payg" = "FortiGate-VMARM64-AWSONDEMAND *(7.4.*)*|8gc40z1w65qjt61p9ps88057n"
      },
      "intel" = {
        "byol" = "FortiGate-VM64-AWS *(7.4.*)*|dlaioq277sglm5mw1y1dmeuqa"
		"flex"  = "FortiGate-VM64-AWS *(7.4.*)*|dlaioq277sglm5mw1y1dmeuqa"
        "payg" = "FortiGate-VM64-AWSONDEMAND *(7.4.*)*|2wqkpek696qhdeo7lbbjncqli"
      }
    }
  }
}

locals {
  instance_family = split(".", "${var.instance_type}")[0]
  graviton = (local.instance_family == "c6g") || (local.instance_family == "c6gn") || (local.instance_family == "c7g") || (local.instance_family == "c7gn") ? true : false
  arch = local.graviton == true ? "arm" : "intel"
  ami_search_string = split("|", "${var.fgtami[var.fortios_version][local.arch][var.license_type]}")[0]
  product_code = split("|", "${var.fgtami[var.fortios_version][local.arch][var.license_type]}")[1]
}

data "aws_ami" "fortigate_ami" {
  most_recent      = true
  owners           = ["aws-marketplace"]

  filter {
    name   = "name"
    values = [local.ami_search_string]
  }
  filter {
    name   = "product-code"
    values = [local.product_code]
  }
}

resource "aws_security_group" "secgrp" {
  name = "${var.tag_name_prefix}-secgrp"
  description = "secgrp"
  vpc_id = var.vpc_id
  ingress {
    description = "Allow remote access to FGT"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.cidr_for_access]
  }
  ingress {
    description = "Allow local VPC access to FGT"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.tag_name_prefix}-fgt-secgrp"
  }
}

resource "aws_network_interface" "public_enis_a" {
  count = length(var.availability_zones)
  subnet_id = var.public_subnet_ids[count.index]
  security_groups = [ aws_security_group.secgrp.id ]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}a-eni0-${var.availability_zones[count.index]}"
  }
}

resource "aws_network_interface" "private_enis_a" {
  count = length(var.availability_zones)
  subnet_id = var.private_subnet_ids[count.index]
  security_groups = [ aws_security_group.secgrp.id ]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}a-eni0-${var.availability_zones[count.index]}"
  }
}

resource "aws_eip" "fgt_eips_a" {
  count = length(var.availability_zones)
  domain = "vpc"
  network_interface = aws_network_interface.public_enis_a[count.index].id
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}a-eip-${var.availability_zones[count.index]}"
  }
}

resource "aws_instance" "fgts_a" {
  count = length(var.availability_zones)
  ami = data.aws_ami.fortigate_ami.id
  instance_type = var.instance_type
  availability_zone = var.availability_zones[count.index]
  key_name = var.keypair
  iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.id
  user_data = data.template_file.fgt_userdata_a[count.index].rendered
  root_block_device {
    volume_type = "gp2"
    encrypted = var.encrypt_volumes
    volume_size = "2"
  }
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "gp2"
    encrypted = var.encrypt_volumes
  }
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.public_enis_a[count.index].id
  }
  network_interface {
    device_index = 1
    network_interface_id = aws_network_interface.private_enis_a[count.index].id
  }
  tags = {
	Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}a-${var.availability_zones[count.index]}"
  }
}

data "template_file" "fgt_userdata_a" {
  count = length(var.availability_zones)
  template = file("${path.module}/fgt-userdata.tpl")
  
  vars = {
    gwlb_ip1 = var.gwlb_ips[0]
    gwlb_ip2 = var.gwlb_ips[1]
	gwlb_ip3 = length(var.availability_zones) >= 3 ? var.gwlb_ips[2] : ""
	gwlb_ip4 = length(var.availability_zones) >= 4 ? var.gwlb_ips[3] : ""
	gwlb_ip5 = length(var.availability_zones) >= 5 ? var.gwlb_ips[4] : ""
	gwlb_ip6 = length(var.availability_zones) >= 6 ? var.gwlb_ips[5] : ""
	hostname = "fgt${format("%d", count.index + 1)}a-${var.availability_zones[count.index]}"
	azs = length(var.availability_zones)
    license_type = var.license_type
    license_file = var.license_type == "byol" ? "${path.root}/${var.license_files_for_1st_fgt_per_az[count.index]}" : ""
    license_token = var.license_type == "flex" ? var.flex_tokens_for_1st_fgt_per_az[count.index] : ""
  }
}

resource "aws_network_interface" "public_enis_b" {
  count = var.num_of_fgts_per_az == 2 ? length(var.availability_zones) : 0
  subnet_id = var.public_subnet_ids[count.index]
  security_groups = [ aws_security_group.secgrp.id ]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}b-eni0-${var.availability_zones[count.index]}"
  }
}

resource "aws_network_interface" "private_enis_b" {
  count = var.num_of_fgts_per_az == 2 ? length(var.availability_zones) : 0
  subnet_id = var.private_subnet_ids[count.index]
  security_groups = [ aws_security_group.secgrp.id ]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}b-eni0-${var.availability_zones[count.index]}"
  }
}

resource "aws_eip" "fgt_eips_b" {
  count = var.num_of_fgts_per_az == 2 ? length(var.availability_zones) : 0
  domain = "vpc"
  network_interface = aws_network_interface.public_enis_b[count.index].id
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}b-eip-${var.availability_zones[count.index]}"
  }
}

resource "aws_instance" "fgts_b" {
  count = var.num_of_fgts_per_az == 2 ? length(var.availability_zones) : 0
  ami = data.aws_ami.fortigate_ami.id
  instance_type = var.instance_type
  availability_zone = var.availability_zones[count.index]
  key_name = var.keypair
  iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.id
  user_data = data.template_file.fgt_userdata_b[count.index].rendered
  root_block_device {
    volume_type = "gp2"
    encrypted = var.encrypt_volumes
    volume_size = "2"
  }
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "gp2"
    encrypted = var.encrypt_volumes
  }
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.public_enis_b[count.index].id
  }
  network_interface {
    device_index = 1
    network_interface_id = aws_network_interface.private_enis_b[count.index].id
  }
  tags = {
	Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}b-${var.availability_zones[count.index]}"
  }
}

data "template_file" "fgt_userdata_b" {
  count = var.num_of_fgts_per_az == 2 ? length(var.availability_zones) : 0
  template = file("${path.module}/fgt-userdata.tpl")
  
  vars = {
    gwlb_ip1 = var.gwlb_ips[0]
    gwlb_ip2 = var.gwlb_ips[1]
	gwlb_ip3 = length(var.availability_zones) >= 3 ? var.gwlb_ips[2] : ""
	gwlb_ip4 = length(var.availability_zones) >= 4 ? var.gwlb_ips[3] : ""
	gwlb_ip5 = length(var.availability_zones) >= 5 ? var.gwlb_ips[4] : ""
	gwlb_ip6 = length(var.availability_zones) >= 6 ? var.gwlb_ips[5] : ""
	hostname = "fgt${format("%d", count.index + 1)}b-${var.availability_zones[count.index]}"
	azs = length(var.availability_zones)
    license_type = var.license_type
    license_file = var.license_type == "byol" ? "${path.root}/${var.license_files_for_2nd_fgt_per_az[count.index]}" : ""
    license_token = var.license_type == "flex" ? var.flex_Tokens_for_2nd_fgt_per_az[count.index] : ""
  }
}