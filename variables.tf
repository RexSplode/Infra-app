variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "azs" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b"]
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/25"
}

