# AWS Subnets Module

This module can be used to generate AWS subnets based on cidr blocks using Terraform.

# Use

```terraform
locals {
    tags = {
        "Owner"       = "Put Your Name here"
        "Account"     = "YourAccountName"
        "Environment" = "YourEnvironmentName"
        "Iac"         = "Terraform"
        "Product"     = "Example"
    }
    vpc_name = "example"
    vpc_cidr_block = "10.100.0.0/16"
    app_subnets_cidr_block = ["10.100.0.0/20", "10.100.16.0/20", "10.100.32.0/20", "10.100.48.0/20"]
    pub_subnets_cidr_block = ["10.100.200.0/22", "10.100.204.0/22"]
}
resource "aws_vpc" "vpc" {
  cidr_block           = local.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_classiclink   = false

  tags = merge(
    local.tags,
    tomap({
      "Name" = local.vpc_name
    })
  )
}
module "app_subnets" {
  source = "git::https://github.com/moreno-terraform/aws_subnets.git"

  vpc_id = aws_vpc.vpc.id
  vpc_name = local.vpc_name
  subnet_group_name = "app"
  subnets_cidr_block = local.app_subnets_cidr_block
  map_public_ip_on_launch = false
  tags = local.tags
}
module "pub_subnets" {
  source = "git::https://github.com/moreno-terraform/aws_subnets.git"

  vpc_id = aws_vpc.vpc.id
  vpc_name = local.vpc_name
  subnet_group_name = "pub"
  subnets_cidr_block = local.pub_subnets_cidr_block
  map_public_ip_on_launch = true
  tags = local.tags
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.tags,
    tomap({
      "Name" = "${local.vpc_name}-igw",
    })
  )
}
resource "aws_route" "igw-route" {
  route_table_id         = module.pub_subnets.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_eip" "nat-ip" {
  vpc = true
  tags = merge(
    local.tags,
    tomap({
      "Name" = "${local.vpc_name}-nat-eip"
    })
  )
}
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat-ip.id
  subnet_id     = module.pub_subnets.subnet_ids[0]

  tags = merge(
    local.tags,
    tomap({
      "Name" = "${local.vpc_name}-nat-gw"
    })
  )
}
resource "aws_route" "nat-route" {
  route_table_id         = module.app_subnets.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gw.id
}
```

# Arguments

* `vpc_id` - (Required) VPC ID where the subnets will be created.

* `vpc_name` - (Required) VPC name. It is used to define resources names in this module.

* `subnet_group_name` - (Required) Subnet group name, that is used with `vpc_name` to define resources names in this module.

* `subnets_cidr_block` - (Required) list of cidr blocks used to create subnets, it is used available zones in the region, if the list of cidr blocks length is greater than available zones length, then some subnets will be in the same aws zone.

* `route_table_id` - (Optional) aws route table ID, it can be used to use an existing route table without create another to subnets created in this module.

* `map_public_ip_on_launch` - (Optional) if true map a public IP when something enters the subnet, it needs a Internet Gateway configured in the same subnet. The default value is `false`.

* `tags` - (Optional) string map with the tags to put on resources created in this module.

# Outputs

* `vpc_id` - VPC ID, the same got in the arguments.

* `vpc_name` - VPC name, the same got in the arguments.

* `route_table_id` - aws route table ID of the subnets

* `subnet_ids` - aws subnet IDs of the subnets