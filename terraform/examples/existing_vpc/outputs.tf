locals {
  one_arm = var.arm_mode == "1-arm" ? true : false
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
  value = (
    var.gwlb_integration == "new" ? (
      <<-GWLBINFO
      # gwlb arn_suffix: ${element(module.inspection-vpc-gwlb[0].gwlb_arn_suffix, 0)}
      # gwlb service_name: ${module.inspection-vpc-gwlb[0].gwlb_endpoint_service_name}
      # gwlb service_type: ${module.inspection-vpc-gwlb[0].gwlb_endpoint_service_type}
      # gwlb ips: ${jsonencode(module.inspection-vpc-gwlb[0].gwlb_ips[*])}
      GWLBINFO
      ) : (
      <<-GWLBINFO
      # existing gwlb target_group_arn: ${var.existing_vpc_gwlb_target_group_arn}
      # existing gwlb ips: ${jsonencode(var.existing_vpc_gwlb_ips[*])}
      GWLBINFO
    )
  )

}