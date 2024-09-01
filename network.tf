locals {
  subnet_cidrs         = cidrsubnets(var.vpc_cidr, 2, 2, 2, 2)
  public_subnet_cidrs  = slice(local.subnet_cidrs, 0, 2)
  private_subnet_cidrs = slice(local.subnet_cidrs, 2, 4)

  # Create indexed maps
  public_subnet_map = zipmap([for idx, cidr in local.public_subnet_cidrs : idx], local.public_subnet_cidrs)
  private_subnet_map = zipmap([for idx, cidr in local.private_subnet_cidrs : idx], local.private_subnet_cidrs)
}

resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public_subnets" {
  for_each = local.public_subnet_map

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = each.value
  availability_zone = element(var.azs, each.key)

  tags = {
    Name = "Public Subnet ${each.key}"
  }
}

resource "aws_subnet" "private_subnets" {
  for_each = local.private_subnet_map

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = each.value
  availability_zone = element(var.azs, each.key)

  tags = {
    Name = "Private Subnet ${each.key}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  
  tags = {
    Name = "main-igw"
  }
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = values(aws_subnet.public_subnets)[0].id   # Placing NAT in the first public subnet

  tags = {
    Name = "main-nat-gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  for_each = aws_subnet.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_rt_assoc" {
  for_each = aws_subnet.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-sg"
  }
}

resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.main_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-sg"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private_subnets: subnet.id]

  tags = {
    Name = "MyDBSubnetGroup"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_security_group"
  description = "Allow traffic from VPC"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS security group"
  }
}