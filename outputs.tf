output "PublicIp" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.publicInstance.public_ip
}

output "PrivateIp" {
  description = "Private IP of EC2 instance"
  value       = aws_instance.publicInstance.private_ip
}