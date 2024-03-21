resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
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

resource "aws_subnet" "public_subnets" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-public-sub-${var.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "private_subnets" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-private-sub-${var.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "gwlb_subnets" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.gwlb_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-gwlb-sub-${var.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "tgwattach_subnets" {
  count = var.tgw_creation == "yes" ? length(var.availability_zones) : 0
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.tgwattach_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-tgwattach-sub-${var.availability_zones[count.index]}"
  }
}

resource "aws_vpc_endpoint" "gwlb_endpoints" {
  count = length(var.availability_zones)
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
  route {
    cidr_block = "0.0.0.0/0"
	gateway_id = aws_internet_gateway.igw.id
  }
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

resource "aws_route" "route_to_tgw" {
  count = var.tgw_creation == "yes" ? 1 : 0
  route_table_id = aws_route_table.gwlb_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id = var.transit_gateway_id
}

resource "aws_route_table" "tgwattach_rtbs" {
  count = var.tgw_creation == "yes" ? length(var.availability_zones) : 0
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
	vpc_endpoint_id = aws_vpc_endpoint.gwlb_endpoints[count.index].id
  }
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-tgwattach-rtb-${var.availability_zones[count.index]}"
  }
}

resource "aws_route_table_association" "public_rtb_associations" {
  count = length(var.availability_zones)
  subnet_id = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "private_rtb_associations" {
  count = length(var.availability_zones)
  subnet_id = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rtb.id
}

resource "aws_route_table_association" "gwlb_rtb_associations" {
  count = length(var.availability_zones)
  subnet_id = aws_subnet.gwlb_subnets[count.index].id
  route_table_id = aws_route_table.gwlb_rtb.id
}

resource "aws_route_table_association" "tgwattach_rtb_associations" {
  count = var.tgw_creation == "yes" ? length(var.availability_zones) : 0
  subnet_id = aws_subnet.tgwattach_subnets[count.index].id
  route_table_id = aws_route_table.tgwattach_rtbs[count.index].id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
  count = var.tgw_creation == "yes" ? 1 : 0
  subnet_ids = aws_subnet.tgwattach_subnets[*].id
  transit_gateway_id = var.transit_gateway_id
  vpc_id = aws_vpc.vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  appliance_mode_support = "enable"
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-tgw-attach"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_association" {
  count = var.tgw_creation == "yes" ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment[0].id
  transit_gateway_route_table_id = var.tgw_security_route_table_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_propagation" {
  count = var.tgw_creation == "yes" ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment[0].id
  transit_gateway_route_table_id = var.tgw_spoke_route_table_id
}

resource "aws_ec2_transit_gateway_route" "tgw_defaultroute" {
  count = var.tgw_creation == "yes" ? 1 : 0
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment[0].id
  transit_gateway_route_table_id = var.tgw_spoke_route_table_id
}