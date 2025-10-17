output "cwan_id" {
  value = aws_networkmanager_core_network.core_network.id
}

output "cwan_arn" {
  value = aws_networkmanager_core_network.core_network.arn
}

output "cwan_policy_state" {
  value = aws_networkmanager_core_network_policy_attachment.policy_attachment.state
}