resource "aws_route_table_association" "route_table_association" {
  count          = length(var.subnets_cidr_block)
  subnet_id      = element(aws_subnet.subnet.*.id, count.index)
  route_table_id = local.route_table_id
}