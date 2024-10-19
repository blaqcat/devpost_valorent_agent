variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type = string
  description = "id for the vpc"
}

variable "subnet_ids" {
  type = list(string)
  description = "id for the subnet"
}