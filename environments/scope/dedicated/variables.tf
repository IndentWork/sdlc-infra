variable "env" {
  type = string
}

variable "location" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "resource_code" {
  type = string
}

variable "vnet_cidr" {
  type = string
}

variable "endpoint_subnet_cidr" {
  type = string
}
