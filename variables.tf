#variables.tf  
variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "key name"
  default = "mysql"
}
