output "vpc_arn" {
  value = aws_vpc.main_vpc.arn
}

output "public_subnet_arns" {
  value = { for subnet in aws_subnet.public_subnets : subnet.id => subnet.arn }
}

output "private_subnet_arns" {
  value = { for subnet in aws_subnet.private_subnets : subnet.id => subnet.arn }
}