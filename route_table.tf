resource "aws_route_table" "route_table" {
  count = var.route_table_id == null ? 1 : 0
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    tomap({
      "Name" = "${var.vpc_name}-${var.subnet_group_name}-rt"
    })
  )
}
locals {
  route_table_id = var.route_table_id == null ? aws_route_table.route_table.0.id : var.route_table_id
}
output "route_table_id" {
  value = local.route_table_id
}