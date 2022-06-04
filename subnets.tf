resource "aws_subnet" "subnet" {
  count                   = length(var.subnets_cidr_block)
  vpc_id                  = var.vpc_id
  cidr_block              = element(var.subnets_cidr_block, count.index)
  availability_zone       = element(data.aws_availability_zones.azs.names, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    var.tags,
    tomap({
      "Name" = "${var.vpc_name}-${var.subnet_group_name}-${element(data.aws_availability_zones.azs.names, count.index)}"
    })
  )
}
output "subnet_ids" {
  value = aws_subnet.subnet.*.id
}