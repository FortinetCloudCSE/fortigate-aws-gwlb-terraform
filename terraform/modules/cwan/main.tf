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
      asn      = 64512
    }
    vpn_ecmp_support = true
  }

  segments {
    name                          = "production"
    description                   = "production-segment"
    edge_locations                = [var.region]
    require_attachment_acceptance = false
    isolate_attachments           = false
  }
  segments {
    name                          = "development"
    description                   = "development-segment"
    edge_locations                = [var.region]
    require_attachment_acceptance = false
    isolate_attachments           = false
  }
  segments {
    name                          = "sharedservices"
    description                   = "sharedservices-segment"
    edge_locations                = [var.region]
    require_attachment_acceptance = false
    isolate_attachments           = false
  }
  network_function_groups {
    name                          = "inspection"
    description                   = "ngfw-network-function-group"
    require_attachment_acceptance = false
  }

  segment_actions {
    action  = "send-to"
    segment = "production"
    via {
      network_function_groups = ["inspection"]
    }
  }
  segment_actions {
    action  = "send-to"
    segment = "development"
    via {
      network_function_groups = ["inspection"]
    }
  }
  segment_actions {
    action  = "send-to"
    segment = "sharedservices"
    via {
      network_function_groups = ["inspection"]
    }
  }
  
  segment_actions {
    segment = "production"
    action  = "send-via"
    mode    = "single-hop" 
    when_sent_to {
      segments = ["production", "development", "sharedservices"]
    }
    via {
      network_function_groups = ["inspection"]
    }
  }

  attachment_policies {
    rule_number     = 1
    condition_logic = "and"
    conditions {
      type     = "tag-value"
      operator = "contains"
      key      = "segment"
      value    = "production"
    }
    action {
      association_method = "constant"
      segment            = "production"
    }
  }
  attachment_policies {
    rule_number     = 2
    condition_logic = "and"
    conditions {
      type     = "tag-value"
      operator = "contains"
      key      = "segment"
      value    = "development"
    }
    action {
      association_method = "constant"
      segment            = "development"
    }
  }
  attachment_policies {
    rule_number     = 3
    condition_logic = "and"
    conditions {
      type     = "tag-value"
      operator = "contains"
      key      = "segment"
      value    = "sharedservices"
    }
    action {
      association_method = "constant"
      segment            = "sharedservices"
    }
  }
  attachment_policies {
    rule_number     = 4
    condition_logic = "and"
    conditions {
      type     = "tag-value"
      operator = "contains"
      key      = "segment"
      value    = "inspection"
    }
    action {
      add_to_network_function_group = "inspection"
    }
  }
}