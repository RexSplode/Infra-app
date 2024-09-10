output "vpc_arn" {
  value = aws_vpc.main_vpc.arn
}

output "public_subnet_arns" {
  value = { for subnet in aws_subnet.public_subnets : subnet.id => subnet.arn }
}

output "private_subnet_arns" {
  value = { for subnet in aws_subnet.private_subnets : subnet.id => subnet.arn }
}
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.my_rds.endpoint
}

resource "local_file" "output_file" {
  content = <<EOT
bastion_ip: ${aws_instance.bastion.public_ip}
ci_cd_ip: ${aws_instance.cicd_instance.private_ip}
rds_enpoint: ${aws_db_instance.my_rds.endpoint}
database_name: ${var.db_name}
database_username:  ${var.db_username}
database_password:  ${var.db_password}
EOT

  filename = "${path.module}/endpoints.txt"
}