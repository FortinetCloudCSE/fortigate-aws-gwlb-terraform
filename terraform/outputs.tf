output "fgt_login_info" {
  value = (
    var.num_of_fgts_per_az == 2 ? (
      <<-FGTLOGIN
      # fgt username: admin
      # fgt initial password: instance-id of the fgt
      # fgt_ids_a : ${jsonencode(module.fgts.fgt_ids_a)}  
      # fgt_ips_a : ${jsonencode(module.fgts.fgt_eip_public_ips_a)}
      # fgt_ids_b : ${jsonencode(module.fgts.fgt_ids_b)}  
      # fgt_ips_b : ${jsonencode(module.fgts.fgt_eip_public_ips_b)}
      FGTLOGIN
	) : (
      <<-FGTLOGIN
      # fgt username: admin
      # fgt initial password: instance-id of the fgt
      # fgt_ids_a : ${jsonencode(module.fgts.fgt_ids_a)}  
      # fgt_ips_a : ${jsonencode(module.fgts.fgt_eip_public_ips_a)}
      FGTLOGIN
	)
  )
}

output "gwlb_info" {
  value = <<-GWLBINFO
  # gwlb arn_suffix: ${element(module.security-vpc-gwlb.gwlb_arn_suffix, 0)}
  # gwlb service_name : ${module.security-vpc-gwlb.gwlb_endpoint_service_name}
  # gwlb service_type : ${module.security-vpc-gwlb.gwlb_endpoint_service_type}
  # gwlb ips : ${jsonencode(module.security-vpc-gwlb.gwlb_ips[*])}
  GWLBINFO
}

output "tgw_info" {
  value =  var.tgw_creation == "no" ? "tgw_creation = no" : <<-TGWINFO
  # tgw id: ${module.transit-gw[0].tgw_id}
  # tgw spoke route table id: ${module.transit-gw[0].tgw_spoke_route_table_id}
  # tgw security route table id: ${module.transit-gw[0].tgw_security_route_table_id}
  TGWINFO
}
