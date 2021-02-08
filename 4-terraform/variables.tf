variable "project_tag" {
  default = "ramp-up-devops"
}

variable "responsible_tag" {
  default = "jose.posadam"
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id_public_0" {
  type = string
}

variable "subnet_id_public_1" {
  type = string
}

variable "subnet_id_private_0" {
  type = string
}

variable "subnet_id_private_1" {
  type = string
}

variable "amis" {
  type = map(string)
}

variable "key_name" {
  type = string
}

variable "api_instance_type" {
  type = string
}

variable "api_port" {
  type = string
}

variable "ui_instance_type" {
  type = string
}

variable "ui_port" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_port" {
  type = string
}
