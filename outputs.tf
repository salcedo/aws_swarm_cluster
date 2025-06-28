locals {
  all_workers = flatten([
    for pool_name, pool in module.worker_pools : [
      for idx, instance in pool.instances : {
        name       = instance.tags.Name
        private_ip = instance.private_ip
        public_ip  = instance.public_ip
        pool_name  = pool_name
      }
    ]
  ])
}

output "ansible_inventory_yaml" {
  description = "Ansible inventory in YAML format"
  value = yamlencode({
    all = {
      children = {
        managers = {
          hosts = {
            for idx, instance in module.manager.instances : instance.tags.Name => {
              ansible_host = instance.public_ip != "" ? instance.public_ip : instance.private_ip
              private_ip   = instance.private_ip
              public_ip    = instance.public_ip
            }
          }
        }
        workers = {
          hosts = {
            for worker in local.all_workers : worker.name => {
              ansible_host = worker.public_ip != "" ? worker.public_ip : worker.private_ip
              private_ip   = worker.private_ip
              public_ip    = worker.public_ip
              worker_pool  = worker.pool_name
            }
          }
        }
      }
    }
  })
}

# Additional outputs for convenience
output "manager_instances" {
  description = "Manager instance information"
  value = {
    for idx, instance in module.manager.instances : instance.tags.Name => {
      instance_id = instance.id
      private_ip  = instance.private_ip
      public_ip   = instance.public_ip
    }
  }
}

output "worker_instances" {
  description = "Worker instance information grouped by pool"
  value = {
    for pool_name, pool in module.worker_pools : pool_name => {
      for idx, instance in pool.instances : instance.tags.Name => {
        instance_id = instance.id
        private_ip  = instance.private_ip
        public_ip   = instance.public_ip
      }
    }
  }
}

output "all_worker_instances" {
  description = "All worker instances combined"
  value = {
    for worker in local.all_workers : worker.name => {
      private_ip  = worker.private_ip
      public_ip   = worker.public_ip
      worker_pool = worker.pool_name
    }
  }
}
