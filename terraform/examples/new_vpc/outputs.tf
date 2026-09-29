locals {
  cwan_used = var.cwan_integration == "new" || var.cwan_integration == "existing" ? true : false
  tgw_used  = var.tgw_integration == "new" || var.tgw_integration == "existing" ? true : false
  one_arm   = var.arm_mode == "1-arm" ? true : false
  fgt_login_ips_a = (
    var.internet_access == "eip"
    ? (
      var.dedicated_management
      ? (
        var.dedicated_management_placement == "public"
        ? module.fgts.fgt_dedicated_management_eips_a
        : module.fgts.fgt_dedicated_managment_ips_a
      )
      : module.fgts.fgt_data_plane_eips_a
    )
    : (
      var.dedicated_management
      ? module.fgts.fgt_dedicated_managment_ips_a
      : (
        local.one_arm
        ? module.fgts.fgt_one_arm_ips_a
        : module.fgts.fgt_two_arm_ips_a
      )
    )
  )
  fgt_login_ips_b = (
    var.internet_access == "eip"
    ? (
      var.dedicated_management
      ? (
        var.dedicated_management_placement == "public"
        ? module.fgts.fgt_dedicated_management_eips_b
        : module.fgts.fgt_dedicated_managment_ips_b
      )
      : module.fgts.fgt_data_plane_eips_b
    )
    : (
      var.dedicated_management
      ? module.fgts.fgt_dedicated_managment_ips_b
      : (
        local.one_arm
        ? module.fgts.fgt_one_arm_ips_b
        : module.fgts.fgt_two_arm_ips_b
      )
    )
  )
}

output "fgt_login_info" {
  value = (
    var.num_of_fgts_per_az == 2 ? (
      <<-FGTLOGIN
      # fgt username: admin
      # fgt initial password: instance-id of the fgt
      # fgt_ids_a: ${jsonencode(module.fgts.fgt_ids_a)}
      # fgt_ips_a: ${jsonencode(local.fgt_login_ips_a)}
      # fgt_ids_b: ${jsonencode(module.fgts.fgt_ids_b)}
      # fgt_ips_b: ${jsonencode(local.fgt_login_ips_b)}
      FGTLOGIN
      ) : (
      <<-FGTLOGIN
      # fgt username: admin
      # fgt initial password: instance-id of the fgt
      # fgt_ids_a: ${jsonencode(module.fgts.fgt_ids_a)}
      # fgt_ips_a: ${jsonencode(local.fgt_login_ips_a)}
      FGTLOGIN
    )
  )
}

output "gwlb_info" {
  value = <<-GWLBINFO
  # gwlb arn_suffix: ${element(module.inspection-vpc-gwlb.gwlb_arn_suffix, 0)}
  # gwlb service_name: ${module.inspection-vpc-gwlb.gwlb_endpoint_service_name}
  # gwlb service_type: ${module.inspection-vpc-gwlb.gwlb_endpoint_service_type}
  # gwlb ips: ${jsonencode(module.inspection-vpc-gwlb.gwlb_ips[*])}
  GWLBINFO
}

output "cwan_info_new" {
  value = (var.cwan_integration == "new" ? <<-CWANINFO
  # cwan id: ${module.cloud-wan[0].cwan_id}
  # cwan arn: ${module.cloud-wan[0].cwan_arn}
  CWANINFO
    : ""
  )
}

output "cwan_info_existing" {
  value = (var.cwan_integration == "existing" ? <<-CWANINFO
  # cwan id: ${var.cwan_existing_id}
  # cwan arn: ${"arn:aws:networkmanager::${var.cwan_existing_account_id}:core-network/${var.cwan_existing_id}"}
  CWANINFO
    : ""
  )
}

output "tgw_info_new" {
  value = (var.tgw_integration == "new" ? <<-TGWINFO
  # tgw id: ${module.transit-gw[0].tgw_id}
  # tgw spoke route table id: ${module.transit-gw[0].tgw_spoke_route_table_id}
  # tgw security route table id: ${module.transit-gw[0].tgw_security_route_table_id}
  TGWINFO
    : ""
  )
}
output "tgw_info_existing" {
  value = (var.tgw_integration == "existing" ? <<-TGWINFO
  # tgw id: ${var.tgw_existing_id}
  # tgw spoke route table id: ${var.tgw_existing_spoke_tgw_route_table_id}
  # tgw security route table id: ${var.tgw_existing_security_tgw_route_table_id}
  TGWINFO
    : ""
  )
}