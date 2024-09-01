variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "azs" {
  type    = list(string)
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/25"
}

variable "preferred_ami" {
    type = string
    default = "ami-0c0493bbac867d427"
  
}

variable "ec2_keypair_name" {
  type = string
}
variable "db_name" {
  type = string
  default = "mydatabase"
}

variable "db_username" {
    type = string
}

variable "db_password" {
  type = string
}

