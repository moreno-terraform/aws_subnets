variable "vpc_id" { type = string }
variable "vpc_name" { type = string }
variable "subnet_group_name" { type = string }
variable "subnets_cidr_block" { type = list(string) }
variable "route_table_id" {
  type = string
  default = null
}
variable "map_public_ip_on_launch" {
  type = bool 
  default = false
}
variable "tags" {
  type = map(string)
  default = {}
}