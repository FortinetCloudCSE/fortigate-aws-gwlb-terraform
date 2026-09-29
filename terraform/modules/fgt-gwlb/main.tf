resource "aws_iam_role" "iam-role" {
  name               = "${var.tag_name_prefix}-iam-role"
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
  name   = "${var.tag_name_prefix}-iam-role-policy"
  role   = aws_iam_role.iam-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SDNConnectorFortiView",
      "Effect": "Allow",
      "Action": [
		"ec2:DescribeInstances",
		"ec2:DescribeNetworkInterfaces",
		"ec2:DescribeRegions",
		"ec2:DescribeVpcEndpoints",
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
        "flex" = "FortiGate-VM64-AWS *(7.4.*)*|dlaioq277sglm5mw1y1dmeuqa"
        "payg" = "FortiGate-VM64-AWSONDEMAND *(7.4.*)*|2wqkpek696qhdeo7lbbjncqli"
      }
    },
    "7.6" = {
      "arm" = {
        "byol" = "FortiGate-VMARM64-AWS *(7.6.*)*|33ndn84xbrajb9vmu5lxnfpjq"
        "flex" = "FortiGate-VMARM64-AWS *(7.6.*)*|33ndn84xbrajb9vmu5lxnfpjq"
        "payg" = "FortiGate-VMARM64-AWSONDEMAND *(7.6.*)*|8gc40z1w65qjt61p9ps88057n"
      },
      "intel" = {
        "byol" = "FortiGate-VM64-AWS *(7.6.*)*|dlaioq277sglm5mw1y1dmeuqa"
        "flex" = "FortiGate-VM64-AWS *(7.6.*)*|dlaioq277sglm5mw1y1dmeuqa"
        "payg" = "FortiGate-VM64-AWSONDEMAND *(7.6.*)*|2wqkpek696qhdeo7lbbjncqli"
      }
    }
  }
}

locals {
  instance_family   = split(".", "${var.instance_type}")[0]
  graviton          = (local.instance_family == "c6g") || (local.instance_family == "c6gn") || (local.instance_family == "c7g") || (local.instance_family == "c7gn") || (local.instance_family == "c8g") || (local.instance_family == "c8gn") ? true : false
  arch              = local.graviton == true ? "arm" : "intel"
  ami_search_string = split("|", "${var.fgtami[var.fortios_version][local.arch][var.license_type]}")[0]
  product_code      = split("|", "${var.fgtami[var.fortios_version][local.arch][var.license_type]}")[1]

  one_arm = var.arm_mode == "1-arm" ? true : false
}

data "aws_ami" "fortigate_ami" {
  most_recent = true
  owners      = ["aws-marketplace"]
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
  name        = "${var.tag_name_prefix}-secgrp"
  description = "secgrp"
  vpc_id      = var.vpc_id
  ingress {
    description = "Allow remote access to FGT"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_for_access]
  }
  ingress {
    description = "Allow local VPC access to FGT"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.tag_name_prefix}-fgt-secgrp"
  }
}

resource "aws_network_interface" "one_arm_enis_a" {
  count             = var.arm_mode == "1-arm" ? length(var.availability_zones) : 0
  subnet_id         = var.public_subnet_ids[count.index]
  security_groups   = [aws_security_group.secgrp.id]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}a-1arm-public-${var.availability_zones[count.index]}"
  }
}

resource "aws_network_interface" "two_arm_public_enis_a" {
  count             = var.arm_mode == "2-arm" ? length(var.availability_zones) : 0
  subnet_id         = var.public_subnet_ids[count.index]
  security_groups   = [aws_security_group.secgrp.id]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}a-2arm-public-${var.availability_zones[count.index]}"
  }
}

resource "aws_network_interface" "two_arm_private_enis_a" {
  count             = var.arm_mode == "2-arm" ? length(var.availability_zones) : 0
  subnet_id         = var.private_subnet_ids[count.index]
  security_groups   = [aws_security_group.secgrp.id]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}a-2arm-private-${var.availability_zones[count.index]}"
  }
}

resource "aws_network_interface" "dedicated_managment_enis_a" {
  count             = var.dedicated_management ? length(var.availability_zones) : 0
  subnet_id         = var.dedicated_management_placement == "public" ? var.public_subnet_ids[count.index] : var.private_subnet_ids[count.index]
  security_groups   = [aws_security_group.secgrp.id]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}a-mgmt-${var.availability_zones[count.index]}"
  }
}

resource "aws_eip" "fgt_data_plane_eips_a" {
  count             = var.internet_access == "eip" ? length(var.availability_zones) : 0
  domain            = "vpc"
  network_interface = local.one_arm ? aws_network_interface.one_arm_enis_a[count.index].id : aws_network_interface.two_arm_public_enis_a[count.index].id
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}a-eip-${var.availability_zones[count.index]}"
  }
}

resource "aws_eip" "fgt_dedicated_management_eips_a" {
  count             = var.internet_access == "eip" && var.dedicated_management && var.dedicated_management_placement == "public" ? length(var.availability_zones) : 0
  domain            = "vpc"
  network_interface = aws_network_interface.dedicated_managment_enis_a[count.index].id
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}a-mgmt-eip-${var.availability_zones[count.index]}"
  }
}

resource "aws_instance" "fgts_a" {
  count                = length(var.availability_zones)
  ami                  = data.aws_ami.fortigate_ami.id
  instance_type        = var.instance_type
  availability_zone    = var.availability_zones[count.index]
  key_name             = var.keypair
  iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.id
  user_data            = data.template_file.fgt_userdata_a[count.index].rendered
  root_block_device {
    volume_type = "gp2"
    encrypted   = var.encrypt_volumes
    volume_size = "2"
  }
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "gp2"
    encrypted   = var.encrypt_volumes
  }
  dynamic "network_interface" {
    for_each = local.one_arm ? (
      concat(
        [
          {
            device_index = 0
            eni_id       = aws_network_interface.one_arm_enis_a[count.index].id
          }
        ],
        var.dedicated_management ? [
          {
            device_index = 1
            eni_id       = aws_network_interface.dedicated_managment_enis_a[count.index].id
          }
        ] : []
      )
      ) : (
      concat(
        [
          {
            device_index = 0
            eni_id       = aws_network_interface.two_arm_public_enis_a[count.index].id
          },
          {
            device_index = 1
            eni_id       = aws_network_interface.two_arm_private_enis_a[count.index].id
          }
        ],
        var.dedicated_management ? [
          {
            device_index = 2
            eni_id       = aws_network_interface.dedicated_managment_enis_a[count.index].id
          }
        ] : []
      )
    )
    content {
      device_index         = network_interface.value.device_index
      network_interface_id = network_interface.value.eni_id
    }
  }
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}a-${var.availability_zones[count.index]}"
  }
}

data "template_file" "fgt_userdata_a" {
  count    = length(var.availability_zones)
  template = file("${path.module}/fgt-${var.arm_mode}-userdata.tpl")

  vars = {
    azs            = length(var.availability_zones)
    dedicated_mgmt = var.dedicated_management ? "true" : "false"
    gwlb_ip1       = var.gwlb_ips[0]
    gwlb_ip2       = var.gwlb_ips[1]
    gwlb_ip3       = length(var.availability_zones) >= 3 ? var.gwlb_ips[2] : ""
    gwlb_ip4       = length(var.availability_zones) >= 4 ? var.gwlb_ips[3] : ""
    gwlb_ip5       = length(var.availability_zones) >= 5 ? var.gwlb_ips[4] : ""
    gwlb_ip6       = length(var.availability_zones) >= 6 ? var.gwlb_ips[5] : ""
    hostname       = "fgt${format("%d", count.index + 1)}a-${var.availability_zones[count.index]}"
    license_type   = var.license_type
    license_file   = var.license_type == "byol" ? "${path.root}/${var.license_files[count.index]}" : ""
    license_token  = var.license_type == "flex" ? var.flex_tokens[count.index] : ""
  }
}

resource "aws_lb_target_group_attachment" "gwlb_target_group_attachments_a" {
  count            = length(var.availability_zones)
  target_group_arn = var.gwlb_target_group_arn
  target_id        = local.one_arm ? aws_network_interface.one_arm_enis_a[count.index].private_ip : aws_network_interface.two_arm_private_enis_a[count.index].private_ip
}

resource "aws_network_interface" "one_arm_enis_b" {
  count             = var.num_of_fgts_per_az == 2 && var.arm_mode == "1-arm" ? length(var.availability_zones) : 0
  subnet_id         = var.public_subnet_ids[count.index]
  security_groups   = [aws_security_group.secgrp.id]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}b-1arm-public-${var.availability_zones[count.index]}"
  }
}

resource "aws_network_interface" "two_arm_public_enis_b" {
  count             = var.num_of_fgts_per_az == 2 && var.arm_mode == "2-arm" ? length(var.availability_zones) : 0
  subnet_id         = var.public_subnet_ids[count.index]
  security_groups   = [aws_security_group.secgrp.id]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}b-2arm-public-${var.availability_zones[count.index]}"
  }
}

resource "aws_network_interface" "two_arm_private_enis_b" {
  count             = var.num_of_fgts_per_az == 2 && var.arm_mode == "2-arm" ? length(var.availability_zones) : 0
  subnet_id         = var.private_subnet_ids[count.index]
  security_groups   = [aws_security_group.secgrp.id]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}b-2arm-private-${var.availability_zones[count.index]}"
  }
}

resource "aws_network_interface" "dedicated_managment_enis_b" {
  count             = var.num_of_fgts_per_az == 2 && var.dedicated_management ? length(var.availability_zones) : 0
  subnet_id         = var.dedicated_management_placement == "public" ? var.public_subnet_ids[count.index] : var.private_subnet_ids[count.index]
  security_groups   = [aws_security_group.secgrp.id]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}b-mgmt-${var.availability_zones[count.index]}"
  }
}

resource "aws_eip" "fgt_data_plane_eips_b" {
  count             = var.num_of_fgts_per_az == 2 && var.internet_access == "eip" ? length(var.availability_zones) : 0
  domain            = "vpc"
  network_interface = local.one_arm ? aws_network_interface.one_arm_enis_b[count.index].id : aws_network_interface.two_arm_public_enis_b[count.index].id
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}b-eip-${var.availability_zones[count.index]}"
  }
}

resource "aws_eip" "fgt_dedicated_management_eips_b" {
  count             = var.num_of_fgts_per_az == 2 && var.internet_access == "eip" && var.dedicated_management && var.dedicated_management_placement == "public" ? length(var.availability_zones) : 0
  domain            = "vpc"
  network_interface = aws_network_interface.dedicated_managment_enis_b[count.index].id
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}b-mgmt-eip-${var.availability_zones[count.index]}"
  }
}

resource "aws_instance" "fgts_b" {
  count                = var.num_of_fgts_per_az == 2 ? length(var.availability_zones) : 0
  ami                  = data.aws_ami.fortigate_ami.id
  instance_type        = var.instance_type
  availability_zone    = var.availability_zones[count.index]
  key_name             = var.keypair
  iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.id
  user_data            = data.template_file.fgt_userdata_b[count.index].rendered
  root_block_device {
    volume_type = "gp2"
    encrypted   = var.encrypt_volumes
    volume_size = "2"
  }
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "gp2"
    encrypted   = var.encrypt_volumes
  }
  dynamic "network_interface" {
    for_each = local.one_arm ? (
      concat(
        [
          {
            device_index = 0
            eni_id       = aws_network_interface.one_arm_enis_b[count.index].id
          }
        ],
        var.dedicated_management ? [
          {
            device_index = 1
            eni_id       = aws_network_interface.dedicated_managment_enis_b[count.index].id
          }
        ] : []
      )
      ) : (
      concat(
        [
          {
            device_index = 0
            eni_id       = aws_network_interface.two_arm_public_enis_b[count.index].id
          },
          {
            device_index = 1
            eni_id       = aws_network_interface.two_arm_private_enis_b[count.index].id
          }
        ],
        var.dedicated_management ? [
          {
            device_index = 2
            eni_id       = aws_network_interface.dedicated_managment_enis_b[count.index].id
          }
        ] : []
      )
    )
    content {
      device_index         = network_interface.value.device_index
      network_interface_id = network_interface.value.eni_id
    }
  }
  tags = {
    Name = "${var.tag_name_prefix}-fgt${format("%d", count.index + 1)}b-${var.availability_zones[count.index]}"
  }
}

data "template_file" "fgt_userdata_b" {
  count    = var.num_of_fgts_per_az == 2 ? length(var.availability_zones) : 0
  template = file("${path.module}/fgt-${var.arm_mode}-userdata.tpl")

  vars = {
    azs            = length(var.availability_zones)
    dedicated_mgmt = var.dedicated_management ? "true" : "false"
    gwlb_ip1       = var.gwlb_ips[0]
    gwlb_ip2       = var.gwlb_ips[1]
    gwlb_ip3       = length(var.availability_zones) >= 3 ? var.gwlb_ips[2] : ""
    gwlb_ip4       = length(var.availability_zones) >= 4 ? var.gwlb_ips[3] : ""
    gwlb_ip5       = length(var.availability_zones) >= 5 ? var.gwlb_ips[4] : ""
    gwlb_ip6       = length(var.availability_zones) >= 6 ? var.gwlb_ips[5] : ""
    hostname       = "fgt${format("%d", count.index + 1)}b-${var.availability_zones[count.index]}"
    license_type   = var.license_type
    license_file   = var.license_type == "byol" ? "${path.root}/${var.license_files[count.index + length(var.availability_zones)]}" : ""
    license_token  = var.license_type == "flex" ? var.flex_tokens[count.index + length(var.availability_zones)] : ""
  }
}

resource "aws_lb_target_group_attachment" "gwlb_target_group_attachments_b" {
  count            = var.num_of_fgts_per_az == 2 ? length(var.availability_zones) : 0
  target_group_arn = var.gwlb_target_group_arn
  target_id        = local.one_arm ? aws_network_interface.one_arm_enis_b[count.index].private_ip : aws_network_interface.two_arm_private_enis_b[count.index].private_ip
}