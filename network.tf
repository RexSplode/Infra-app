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