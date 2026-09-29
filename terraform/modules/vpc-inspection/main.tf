locals {
  cwan_mgmt_routes = var.cwan_used == 1
  tgw_mgmt_routes  = var.tgw_used == 1
  rfc1918_cidrs = {
    class_a = "10.0.0.0/8"
    class_b = "172.16.0.0/12"
    class_c = "192.168.0.0/16"
  }
  rfc1918_routes = {
    public_class_a = {
      route_table_id         = aws_route_table.public_rtb.id
      destination_cidr_block = local.rfc1918_cidrs.class_a
    }
    public_class_b = {
      route_table_id         = aws_route_table.public_rtb.id
      destination_cidr_block = local.rfc1918_cidrs.class_b
    }
    public_class_c = {
      route_table_id         = aws_route_table.public_rtb.id
      destination_cidr_block = local.rfc1918_cidrs.class_c
    }

    private_class_a = {
      route_table_id         = aws_route_table.private_rtb.id
      destination_cidr_block = local.rfc1918_cidrs.class_a
    }
    private_class_b = {
      route_table_id         = aws_route_table.private_rtb.id
      destination_cidr_block = local.rfc1918_cidrs.class_b
    }
    private_class_c = {
      route_table_id         = aws_route_table.private_rtb.id
      destination_cidr_block = local.rfc1918_cidrs.class_c
    }

    gwlb_class_a = {
      route_table_id         = aws_route_table.gwlb_rtb.id
      destination_cidr_block = local.rfc1918_cidrs.class_a
    }
    gwlb_class_b = {
      route_table_id         = aws_route_table.gwlb_rtb.id
      destination_cidr_block = local.rfc1918_cidrs.class_b
    }
    gwlb_class_c = {
      route_table_id         = aws_route_table.gwlb_rtb.id
      destination_cidr_block = local.rfc1918_cidrs.class_c
    }
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-igw"
  }
}

resource "aws_eip" "natgw_eips" {
  count  = var.internet_access == "natgw" ? length(var.availability_zones) : 0
  domain = "vpc"
  tags = {
    Name = "${var.tag_name_prefix}-natgw-eip-${format("%d", count.index + 1)}-${var.availability_zones[count.index]}"
  }
}

resource "aws_nat_gateway" "natgw" {
  count             = var.internet_access == "natgw" ? 1 : 0
  depends_on        = [aws_internet_gateway.igw]
  vpc_id            = aws_vpc.vpc.id
  availability_mode = "regional"
  connectivity_type = "public"

  dynamic "availability_zone_address" {
    for_each = var.availability_zones

    content {
      availability_zone = availability_zone_address.value

      allocation_ids = [
        aws_eip.natgw_eips[availability_zone_address.key].allocation_id
      ]
    }
  }
  tags = {
    Name = "${var.tag_name_prefix}-natgw-regional"
  }
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-public-subnet-${var.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-private-subnet-${var.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "gwlb_subnets" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.gwlb_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-gwlb-subnet-${var.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "attachment_subnets" {
  count             = var.attachment_creation == 1 ? length(var.availability_zones) : 0
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.attachment_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-attachment-subnet-${var.availability_zones[count.index]}"
  }
}

resource "aws_vpc_endpoint" "gwlb_endpoints" {
  count             = length(var.availability_zones)
  service_name      = var.gwlb_endpoint_service_name
  subnet_ids        = [aws_subnet.gwlb_subnets[count.index].id]
  vpc_endpoint_type = var.gwlb_endpoint_service_type
  vpc_id            = aws_vpc.vpc.id
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-gwlbe-${var.availability_zones[count.index]}"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-public-rtb"
  }
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-private-rtb"
  }
}

resource "aws_route_table" "gwlb_rtb" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-gwlb-rtb"
  }
}

resource "aws_route" "route_to_igw" {
  count                  = var.internet_access == "eip" ? 1 : 0
  route_table_id         = aws_route_table.public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "route_to_natgw1" {
  count                  = var.internet_access == "natgw" ? 1 : 0
  route_table_id         = aws_route_table.public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw[count.index].id
}

resource "aws_route" "route_to_natgw2" {
  count                  = var.arm_mode == "1-arm" && var.internet_access == "natgw" && var.cwan_used == 1 && var.tgw_used == 1 ? 1 : 0
  route_table_id         = aws_route_table.gwlb_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw[count.index].id
}

resource "aws_route" "route_to_cwan_rfc1918" {
  for_each               = local.cwan_mgmt_routes ? local.rfc1918_routes : {}
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  core_network_arn       = "arn:aws:networkmanager::${var.cwan_account_id}:core-network/${var.cwan_id}"
  depends_on             = [aws_networkmanager_vpc_attachment.cwan_attachment]
}

resource "aws_route" "route_to_tgw_rfc1918" {
  for_each               = local.tgw_mgmt_routes ? local.rfc1918_routes : {}
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route_table" "attachment_rtbs" {
  count  = var.attachment_creation == 1 ? length(var.availability_zones) : 0
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoints[count.index].id
  }
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-attachment-rtb-${var.availability_zones[count.index]}"
  }
}

resource "aws_route_table_association" "public_rtb_associations" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "private_rtb_associations" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rtb.id
}

resource "aws_route_table_association" "gwlb_rtb_associations" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.gwlb_subnets[count.index].id
  route_table_id = aws_route_table.gwlb_rtb.id
}

resource "aws_route_table_association" "attachment_rtb_associations" {
  count          = var.attachment_creation == 1 ? length(var.availability_zones) : 0
  subnet_id      = aws_subnet.attachment_subnets[count.index].id
  route_table_id = aws_route_table.attachment_rtbs[count.index].id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
  count                                           = var.tgw_used
  subnet_ids                                      = aws_subnet.attachment_subnets[*].id
  transit_gateway_id                              = var.transit_gateway_id
  vpc_id                                          = aws_vpc.vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  appliance_mode_support                          = "enable"
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-vpc-attachment"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_association" {
  count                          = var.tgw_used
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment[0].id
  transit_gateway_route_table_id = var.tgw_security_route_table_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_propagation" {
  count                          = var.tgw_used
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment[0].id
  transit_gateway_route_table_id = var.tgw_spoke_route_table_id
}

resource "aws_ec2_transit_gateway_route" "tgw_defaultroute" {
  count                          = var.tgw_used
  destination_cidr_block         = var.tgw_spoke_route_table_route
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment[0].id
  transit_gateway_route_table_id = var.tgw_spoke_route_table_id
}

resource "aws_networkmanager_vpc_attachment" "cwan_attachment" {
  count           = var.cwan_used
  depends_on      = [var.cwan_policy_state]
  core_network_id = var.cwan_id
  subnet_arns     = aws_subnet.attachment_subnets[*].arn
  vpc_arn         = aws_vpc.vpc.arn
  options {
    appliance_mode_support = true
  }
  tags = {
    Name                   = "${var.tag_name_prefix}-${var.tag_name_unique}-vpc-attachment"
    (var.cwan_segment_key) = "${var.cwan_segment_value}"
  }
}