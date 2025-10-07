variable "ami_id" {
  default = "ami-0360c520857e3138f"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "prefix" {
  default = "tf"
}

variable "project" {
  default = "devops-101"
}

variable "contact" {
  default = "rajeshchandran007@gmail.com"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr_list" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "instance_type" {
  default = "t2.micro"
}

variable "db_name" {
  description = "The name of the RDS database"
  type        = string
  default     = "mydatabase"
}

variable "db_username" {
  description = "The username for the RDS database"
  type        = string
  default     = "postgres"
}
