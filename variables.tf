variable "region" {
    type = string
}

variable "environment" {
    type = string
}

variable "vpc_cidr" {
    type        = string
    description = "The primary CIDR block for the VPC" 
}
variable "public_subnet_cidrs" {
    type        = list(string)
    description = "A list of IPv4 CIDR blocks for the public subnets."
}
variable "private_app_subnet_cidrs" {
    type        = list(string)
    description = "A list of IPv4 CIDR blocks for the private subnets."
}
variable "private_db_subnet_cidrs" {
    type        = list(string)
    description = "A list of IPv4 CIDR blocks for the db private subnets."
}
variable "instance_type" {
    type = string
}
variable "key_name" {
    type = string
}
variable "db_name" {
    type = string   
}
variable "db_username" {
    type = string
}
variable "db_password" {
    type = string
    sensitive = true
}