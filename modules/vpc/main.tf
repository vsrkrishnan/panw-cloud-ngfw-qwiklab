
locals {
  subnet_ids = {
    for k, subnet in aws_subnet.this: 
      subnet.tags["Name"] => subnet.id
  }

  vpc_route_table_ids = {
    for k, route_table in aws_route_table.this:
      route_table.tags["Name"] => route_table.id
  }

  sg-ids = [
    for k, sg in aws_security_group.this:
      sg.id
  ]

  ec2-ids = {
    for k, instance in aws_instance.this:
      instance.tags["Name"] => instance.id
  }

  igw-id = {
    "${aws_internet_gateway.this.tags["Name"]}" : aws_internet_gateway.this.id
  }
}

resource "aws_vpc" "this" {
  tags                 = merge({ Name = "${var.prefix-name-tag}${var.vpc.name}" }, var.global_tags)
  cidr_block           = var.vpc.cidr_block
  instance_tenancy     = var.vpc.instance_tenancy
  enable_dns_support   = var.vpc.enable_dns_support
  enable_dns_hostnames = var.vpc.enable_dns_hostnames
}

resource "aws_internet_gateway" "this" {
  tags    = merge({ Name = "${var.prefix-name-tag}${var.vpc.name}-igw" }, var.global_tags)
  vpc_id  = aws_vpc.this.id
}

resource "aws_subnet" "this" {
  for_each = { for subnet in var.subnets: subnet.name => subnet }

  cidr_block = each.value.cidr
  availability_zone = "${var.region}${lookup(each.value, "az", null)}"
  tags = merge({ Name = "${var.prefix-name-tag}${var.vpc.name}-${each.value.name}" }, var.global_tags)
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "this" {
  for_each = { for route in var.route-tables: route.name => route }
  vpc_id = aws_vpc.this.id
  tags = merge({ Name = "${var.prefix-name-tag}${var.vpc.name}-${each.value.name}" }, var.global_tags)
}

resource "aws_route_table_association" "this" {
  for_each = { 
    for route in var.route-tables: route.subnet => route
    if route.subnet != ""
  }

  subnet_id = local.subnet_ids["${var.prefix-name-tag}${var.vpc.name}-${each.value.subnet}"]
  route_table_id = local.vpc_route_table_ids["${var.prefix-name-tag}${var.vpc.name}-${each.value.name}"]
}

resource "aws_security_group" "this" {
  for_each = { for k, v in var.security-groups: k => v }

  name     = "${var.prefix-name-tag}${each.value.name}"
  vpc_id   = aws_vpc.this.id

  dynamic "ingress" {
    for_each = [
      for rule in each.value.rules :
      rule
      if rule.type == "ingress"
    ]

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = lookup(ingress.value, "description", "")
    }
  }

  dynamic "egress" {
    for_each = [
      for rule in each.value.rules :
      rule
      if rule.type == "egress"
    ]

    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = lookup(egress.value, "description", "")
    }
  }

  tags = merge({ Name = "${var.prefix-name-tag}${each.value.name}" }, var.global_tags)

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami" "latest_ecs" {
  most_recent = true
  owners = ["591542846629"] # AWS

  filter {
      name   = "name"
      values = ["*amazon-ecs-optimized"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

resource "aws_instance" "this" {
  for_each = { for instance in var.ec2-instances: instance.name => instance }

  ami                         = data.aws_ami.latest_ecs.id
  instance_type               = each.value.instance_type
  user_data                   = file(each.value.setup-file)
  subnet_id                   = local.subnet_ids["${var.prefix-name-tag}${var.vpc.name}-${each.value.subnet}"]
  security_groups             = local.sg-ids
  key_name                    = var.ssh-key-name

  tags = merge({ Name = "${var.prefix-name-tag}${each.value.name}" }, var.global_tags)
}

resource "aws_eip" "elasticip" {
    for_each = { for key, instance in aws_instance.this: key => instance }

  instance = each.value.id
}

output "vpc_details" {
  value = {
    "id"              : aws_vpc.this.id
    "name"            : aws_vpc.this.tags["Name"]
    "internet_gateway": local.igw-id
    "subnet_ids"      : local.subnet_ids
    "vpc_route_tables": local.vpc_route_table_ids
    "security-groups" : local.sg-ids
    "instance"        : local.ec2-ids
  }
}