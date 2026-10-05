locals {
  use_gwlbe  = var.distributed_inspection != "5: No Distributed Ingress or Egress Inspection (use Cwan or Tgw for centralized inspection)"
  use_nat_gw = var.route_to_cwan_or_tgw != "0.0.0.0/0"

  vpc_routing_option_1 = var.distributed_inspection == "1: Distributed Ingress @ IGW"
  vpc_routing_option_2 = var.distributed_inspection == "2: Distributed Ingress @ Public Subnets"
  vpc_routing_option_3 = var.distributed_inspection == "3: Distributed Egress"
  vpc_routing_option_4 = var.distributed_inspection == "4: Option 2 + 3 above"
  vpc_routing_option_5 = var.distributed_inspection == "5: No Distributed Ingress or Egress Inspection (use Cwan or Tgw for centralized inspection)"

  use_nat_gw_and_vpc_option_1 = local.use_nat_gw && local.vpc_routing_option_1
  use_nat_gw_and_vpc_option_2 = local.use_nat_gw && local.vpc_routing_option_2
  use_nat_gw_and_vpc_option_3 = local.use_nat_gw && local.vpc_routing_option_3
  use_nat_gw_and_vpc_option_4 = local.use_nat_gw && local.vpc_routing_option_4
  use_nat_gw_and_vpc_option_5 = local.use_nat_gw && local.vpc_routing_option_5
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-vpc"
  }
}

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-public-subnet-${var.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-private-subnet-${var.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "gwlb" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.gwlb_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-gwlb-subnet-${var.availability_zones[count.index]}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-igw"
  }
}

resource "aws_vpc_endpoint" "gwlbe" {
  count = local.use_gwlbe ? length(var.availability_zones) : 0

  vpc_id            = aws_vpc.vpc.id
  service_name      = var.vpc_endpoint_service_name
  vpc_endpoint_type = "GatewayLoadBalancer"
  subnet_ids        = [aws_subnet.gwlb[count.index].id]

  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-gwlbe-${var.availability_zones[count.index]}"
  }
}

resource "aws_eip" "natgw_eips" {
  count      = local.use_nat_gw ? length(var.availability_zones) : 0
  depends_on = [aws_internet_gateway.igw]
  domain     = "vpc"
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-natgw-eip-${format("%d", count.index + 1)}-${var.availability_zones[count.index]}"
  }
}

resource "aws_nat_gateway" "natgw" {
  count             = local.use_nat_gw ? 1 : 0
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
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-natgw-regional"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  count = var.tgw_used == 1 ? 1 : 0

  subnet_ids         = slice(aws_subnet.private[*].id, 0, length(var.availability_zones))
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.vpc.id

  appliance_mode_support = "enable"

  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-vpc-attachment"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "main" {
  count = var.tgw_used == 1 ? 1 : 0

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main[0].id
  transit_gateway_route_table_id = var.tgw_spoke_route_table_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.main]
}

resource "aws_ec2_transit_gateway_route_table_propagation" "main" {
  count = var.tgw_used == 1 ? 1 : 0

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main[0].id
  transit_gateway_route_table_id = var.tgw_security_route_table_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.main]
}

resource "aws_networkmanager_vpc_attachment" "main" {
  count           = var.cwan_used == 1 ? 1 : 0
  depends_on      = [var.cwan_policy_state]
  core_network_id = var.cwan_id
  subnet_arns = [
    for i in range(length(var.availability_zones)) :
    "arn:aws:ec2:${var.region}:${var.cwan_account_id}:subnet/${aws_subnet.private[i].id}"
  ]
  vpc_arn = "arn:aws:ec2:${var.region}:${var.cwan_account_id}:vpc/${aws_vpc.vpc.id}"

  options {
    appliance_mode_support = true
  }

  tags = merge(
    {
      Name = "${var.tag_name_prefix}-${var.tag_name_unique}-vpc-attachment"
    },
    {
      (var.cwan_segment_key) = var.cwan_segment_value
    }
  )
}

resource "aws_route_table" "public" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-public-rtb-${var.availability_zones[count.index]}"
  }
}

resource "aws_route_table" "private" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-private-rtb-${var.availability_zones[count.index]}"
  }
}

resource "aws_route_table" "gwlb" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-gwlb-rtb"
  }
}

resource "aws_route_table" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-ingress-rtb"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "gwlb" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.gwlb[count.index].id
  route_table_id = aws_route_table.gwlb.id
}

resource "aws_route_table_association" "igw" {
  gateway_id     = aws_internet_gateway.igw.id
  route_table_id = aws_route_table.igw.id
}

# VPC Routing Option 1: Distributed Ingress @ IGW
resource "aws_route" "option1_igw_to_public_subnets" {
  count = local.vpc_routing_option_1 ? length(var.availability_zones) : 0

  route_table_id         = aws_route_table.igw.id
  destination_cidr_block = var.public_subnet_cidrs[count.index]
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbe[count.index].id

  depends_on = [aws_vpc_endpoint.gwlbe]
}

resource "aws_route" "option1_public_default_to_gwlbe" {
  count = local.vpc_routing_option_1 ? length(var.availability_zones) : 0

  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbe[count.index].id

  depends_on = [aws_vpc_endpoint.gwlbe]
}

resource "aws_route" "option1_gwlb_to_igw" {
  count = local.vpc_routing_option_1 ? 1 : 0

  route_table_id         = aws_route_table.gwlb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "option1_private_default_to_nat" {
  count = local.use_nat_gw_and_vpc_option_1 ? length(var.availability_zones) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw[0].id
}

# VPC Routing Option 2: Distributed Ingress @ Public Subnets
resource "aws_route" "option2_public_to_private_cross_az" {
  count = local.vpc_routing_option_2 ? length(var.availability_zones) * length(var.availability_zones) : 0

  route_table_id         = aws_route_table.public[floor(count.index / length(var.availability_zones))].id
  destination_cidr_block = var.private_subnet_cidrs[count.index % length(var.availability_zones)]
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbe[count.index % length(var.availability_zones)].id

  depends_on = [aws_vpc_endpoint.gwlbe]
}

resource "aws_route" "option2_private_to_public_cross_az" {
  count = local.vpc_routing_option_2 ? length(var.availability_zones) * length(var.availability_zones) : 0

  route_table_id         = aws_route_table.private[floor(count.index / length(var.availability_zones))].id
  destination_cidr_block = var.public_subnet_cidrs[count.index % length(var.availability_zones)]
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbe[floor(count.index / length(var.availability_zones))].id

  depends_on = [aws_vpc_endpoint.gwlbe]
}

resource "aws_route" "option2_private_default_to_nat" {
  count = local.use_nat_gw_and_vpc_option_2 ? length(var.availability_zones) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw[0].id
}

resource "aws_route" "option2_public_default_to_igw" {
  count = local.use_nat_gw_and_vpc_option_2 ? length(var.availability_zones) : 0

  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# VPC Routing Option 3: Distributed Egress
resource "aws_route" "option3_private_default_to_gwlbe" {
  count = local.vpc_routing_option_3 ? length(var.availability_zones) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbe[count.index].id

  depends_on = [aws_vpc_endpoint.gwlbe]
}

resource "aws_route" "option3_public_default_to_igw" {
  count = local.vpc_routing_option_3 ? length(var.availability_zones) : 0

  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "option3_gwlb_default_to_nat" {
  count = local.use_nat_gw_and_vpc_option_3 ? 1 : 0

  route_table_id         = aws_route_table.gwlb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw[0].id
}

resource "aws_route" "option3_natgw_to_private_via_gwlbe" {
  count = local.vpc_routing_option_3 ? length(var.availability_zones) : 0

  route_table_id         = aws_nat_gateway.natgw[0].route_table_id
  destination_cidr_block = var.private_subnet_cidrs[count.index]
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbe[count.index].id

  depends_on = [aws_vpc_endpoint.gwlbe, aws_nat_gateway.natgw]
}

# VPC Routing Option 4: Option 2 + 3 combined
resource "aws_route" "option4_public_to_private_cross_az" {
  count = local.vpc_routing_option_4 ? length(var.availability_zones) * length(var.availability_zones) : 0

  route_table_id         = aws_route_table.public[floor(count.index / length(var.availability_zones))].id
  destination_cidr_block = var.private_subnet_cidrs[count.index % length(var.availability_zones)]
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbe[count.index % length(var.availability_zones)].id

  depends_on = [aws_vpc_endpoint.gwlbe]
}

resource "aws_route" "option4_private_to_public_cross_az" {
  count = local.vpc_routing_option_4 ? length(var.availability_zones) * length(var.availability_zones) : 0

  route_table_id         = aws_route_table.private[floor(count.index / length(var.availability_zones))].id
  destination_cidr_block = var.public_subnet_cidrs[count.index % length(var.availability_zones)]
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbe[floor(count.index / length(var.availability_zones))].id

  depends_on = [aws_vpc_endpoint.gwlbe]
}

resource "aws_route" "option4_private_default_to_gwlbe" {
  count = local.vpc_routing_option_4 ? length(var.availability_zones) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbe[count.index].id

  depends_on = [aws_vpc_endpoint.gwlbe]
}

resource "aws_route" "option4_public_default_to_igw" {
  count = local.use_nat_gw_and_vpc_option_4 ? length(var.availability_zones) : 0

  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "option4_gwlb_default_to_nat" {
  count = local.use_nat_gw_and_vpc_option_4 ? 1 : 0

  route_table_id         = aws_route_table.gwlb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw[0].id
}

resource "aws_route" "option4_natgw_to_private_via_gwlbe" {
  count = local.vpc_routing_option_4 ? length(var.availability_zones) : 0

  route_table_id         = aws_nat_gateway.natgw[0].route_table_id
  destination_cidr_block = var.private_subnet_cidrs[count.index]
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbe[count.index].id

  depends_on = [aws_vpc_endpoint.gwlbe, aws_nat_gateway.natgw]
}

# VPC Routing Option 5: No Distributed Inspection
resource "aws_route" "option5_public_default_to_igw" {
  count = local.vpc_routing_option_5 ? length(var.availability_zones) : 0

  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "option5_private_default_to_nat" {
  count = local.use_nat_gw_and_vpc_option_5 ? length(var.availability_zones) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw[0].id
}

# Transit Gateway Routes
resource "aws_route" "private_to_tgw" {
  count = var.tgw_used == 1 ? length(var.availability_zones) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = var.route_to_cwan_or_tgw
  transit_gateway_id     = var.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.main]
}

# Cloud WAN Routes
resource "aws_route" "private_to_cwan" {
  count = var.cwan_used == 1 ? length(var.availability_zones) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = var.route_to_cwan_or_tgw
  core_network_arn       = "arn:aws:networkmanager::${var.cwan_account_id}:core-network/${var.cwan_id}"

  depends_on = [aws_networkmanager_vpc_attachment.main]
}
