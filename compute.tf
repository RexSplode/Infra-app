data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}



resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = values(aws_subnet.public_subnets)[0].id # Placing in the first public subnet
  associate_public_ip_address = true

  tags = {
    Name = "Bastion"
  }

  key_name = var.ec2_keypair_name # Replace with your key pair
  security_groups = [
    aws_security_group.public_sg.id
  ]
}

resource "aws_instance" "cicd_instance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = values(aws_subnet.private_subnets)[0].id # Placing in the first private subnet

  tags = {
    Name = "CI/CD-instance"
  }

  key_name = var.ec2_keypair_name # Replace with your key pair
  security_groups = [
    aws_security_group.private_sg.id
  ]
}

resource "aws_db_instance" "my_rds" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name

  # Ensure that the RDS instance is created in the private subnet
  publicly_accessible = false

  tags = {
    Name = "MyRDSInstance"
  }
}