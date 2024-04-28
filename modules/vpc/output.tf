output "ami" {
  value = data.aws_ssm_parameter.ssmParam.value
}

output "subnet_public" {
  value = aws_subnet.publicSubnet.id
}

output "subnet_private" {
  value = aws_subnet.privateSubnet.id
}

output "security_group" {
  value = aws_security_group.allow_all.id
}
