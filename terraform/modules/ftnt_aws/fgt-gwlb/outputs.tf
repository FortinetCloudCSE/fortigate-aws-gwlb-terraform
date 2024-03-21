output "fgt_ids_a" {
  value = aws_instance.fgts_a[*].id
}

output "fgt_eip_public_ips_a" {
  value = aws_eip.fgt_eips_a[*].public_ip
}

output "fgt_ids_b" {
  value = aws_instance.fgts_b[*].id
}

output "fgt_eip_public_ips_b" {
  value = aws_eip.fgt_eips_b[*].public_ip
}