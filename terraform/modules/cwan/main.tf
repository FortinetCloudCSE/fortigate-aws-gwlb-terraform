resource "aws_networkmanager_global_network" "global_network" {
  tags = {
    Name = "${var.tag_name_prefix}-global-network"
  }
}

resource "aws_networkmanager_core_network" "core_network" {
  global_network_id = aws_networkmanager_global_network.global_network.id
  tags = {
    Name = "${var.tag_name_prefix}-core-network"
  }
}

resource "aws_networkmanager_core_network_policy_attachment" "policy_attachment" {
  core_network_id = aws_networkmanager_core_network.core_network.id
  policy_document = data.aws_networkmanager_core_network_policy_document.policy_data.json
}

data "aws_networkmanager_core_network_policy_document" "policy_data" {
  version = "2021.12"
  core_network_configuration {
    asn_ranges = ["64512-64518"]
    edge_locations {
      location = var.region
      asn = 64512
    }
    vpn_ecmp_support = true
  }
  
  segments {
    name = "production"
    description = "production-segment"
    edge_locations = [var.region]
    require_attachment_acceptance = false
    isolate_attachments  = false
  }
  segments {
    name = "development"
    description = "development-segment"
    edge_locations = [var.region]
    require_attachment_acceptance = false
    isolate_attachments  = false
  }
  segments {
    name = "sharedservices"
    description = "sharedservices-segment"
    edge_locations = [var.region]
    require_attachment_acceptance = false
    isolate_attachments  = false
  }
  segments {
    name = "inspection"
    description = "ngfw-segment"
    edge_locations = [var.region]
    require_attachment_acceptance = false
    isolate_attachments  = false
  }
  
  segment_actions {
    action = "share"
    mode = "attachment-route"
    segment = "production"
    share_with = ["inspection"]
  }
  segment_actions {
    action = "share"
    mode = "attachment-route"
    segment = "development"
    share_with = ["inspection"]
  }
  segment_actions {
   action = "share"
   mode = "attachment-route"
   segment = "sharedservices"
   share_with = ["inspection"]
  }

  attachment_policies {
    rule_number = 100
    condition_logic = "and"
    conditions {
      type = "tag-value"
      operator = "contains"
      key = "segment"
      value = "production"
    }
    action {
      association_method = "constant"
	  segment = "production"
    }
  }
  attachment_policies {
    rule_number = 200
    condition_logic = "and"
    conditions {
      type = "tag-value"
      operator = "contains"
      key = "segment"
      value = "development"
    }
    action {
      association_method = "constant"
	  segment = "development"
    }
  }
  attachment_policies {
    rule_number = 300
    condition_logic = "and"
    conditions {
      type = "tag-value"
      operator = "contains"
      key = "segment"
      value = "sharedservices"
    }
    action {
      association_method = "constant"
	  segment = "sharedservices"
    }
  }
  attachment_policies {
    rule_number = 400
    condition_logic = "and"
    conditions {
      type = "tag-value"
      operator = "contains"
      key = "segment"
      value = "inspection"
    }
    action {
      association_method = "constant"
	  segment = "inspection"
    }
  }
}