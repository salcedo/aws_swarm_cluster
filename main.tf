data "aws_subnets" "cluster" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_subnet" "cluster_subnets" {
  for_each = toset(data.aws_subnets.cluster.ids)
  id       = each.key
}

locals {
  subnet_map = {
    for id, subnet in data.aws_subnet.cluster_subnets :
    substr(subnet.availability_zone, -1, 1) => id
  }
}

module "manager" {
  source = "./manager"

  cluster_name = var.cluster_name
  environment  = var.environment
  region       = var.region

  subnet_map    = local.subnet_map
  manager_count = var.manager_pool.manager_count

  ami                         = var.manager_pool.ami
  associate_public_ip_address = var.manager_pool.associate_public_ip_address != null ? var.manager_pool.associate_public_ip_address : false
  availability_zones          = var.manager_pool.availability_zones
  disable_api_stop            = var.manager_pool.disable_api_stop != null ? var.manager_pool.disable_api_stop : true
  disable_api_termination     = var.manager_pool.disable_api_termination != null ? var.manager_pool.disable_api_termination : true
  instance_type               = var.manager_pool.instance_type
  key_name                    = var.manager_pool.key_name
  root_volume_size            = var.manager_pool.root_volume_size
  tags                        = var.manager_pool != null ? var.manager_pool.tags : {}
  user_data                   = var.manager_pool.user_data != null ? var.manager_pool.user_data : ""
  vpc_security_group_ids      = var.manager_pool.vpc_security_group_ids
}

module "worker_pools" {
  for_each = var.worker_pools
  source   = "./worker_pool"

  cluster_name = var.cluster_name
  environment  = var.environment
  region       = var.region

  subnet_map   = local.subnet_map
  worker_count = each.value.worker_count

  name                        = each.value.name
  ami                         = each.value.ami
  associate_public_ip_address = each.value.associate_public_ip_address != null ? each.value.associate_public_ip_address : false
  availability_zones          = each.value.availability_zones
  disable_api_stop            = each.value.disable_api_stop != null ? each.value.disable_api_stop : false
  disable_api_termination     = each.value.disable_api_termination != null ? each.value.disable_api_termination : false
  instance_type               = each.value.instance_type
  key_name                    = each.value.key_name
  root_volume_size            = each.value.root_volume_size
  tags                        = each.value.tags != null ? each.value.tags : {}
  user_data                   = var.manager_pool.user_data != null ? var.manager_pool.user_data : ""
  vpc_security_group_ids      = each.value.vpc_security_group_ids
}
