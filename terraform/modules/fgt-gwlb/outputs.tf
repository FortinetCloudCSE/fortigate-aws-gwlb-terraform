output "fgt_ids_a" {
  value = aws_instance.fgts_a[*].id
}

output "fgt_data_plane_eips_a" {
  value = aws_eip.fgt_data_plane_eips_a[*].public_ip
}

output "fgt_dedicated_management_eips_a" {
  value = aws_eip.fgt_dedicated_management_eips_a[*].public_ip
}

output "fgt_dedicated_managment_ips_a" {
  value = aws_network_interface.dedicated_managment_enis_a[*].private_ip
}

output "fgt_one_arm_ips_a" {
  value = aws_network_interface.one_arm_enis_a[*].private_ip
}

output "fgt_two_arm_ips_a" {
  value = aws_network_interface.two_arm_public_enis_a[*].private_ip
}

output "fgt_ids_b" {
  value = aws_instance.fgts_b[*].id
}

output "fgt_data_plane_eips_b" {
  value = aws_eip.fgt_data_plane_eips_b[*].public_ip
}

output "fgt_dedicated_management_eips_b" {
  value = aws_eip.fgt_dedicated_management_eips_b[*].public_ip
}

output "fgt_dedicated_managment_ips_b" {
  value = aws_network_interface.dedicated_managment_enis_b[*].private_ip
}

output "fgt_one_arm_ips_b" {
  value = aws_network_interface.one_arm_enis_b[*].private_ip
}

output "fgt_two_arm_ips_b" {
  value = aws_network_interface.two_arm_public_enis_b[*].private_ip
}