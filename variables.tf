variable "cluster_name" {
  description = "The name of this cluster"
  type        = string
  default     = "swarm"
}

variable "environment" {
  description = "The name of the environment this cluster targets"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "Region where this cluster will be managed"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "ansible_host_use_private_ip" {
  description = "Use private IP addresses for Ansible host configuration"
  type        = bool
  default     = true
}

variable "manager_pool" {
  description = "Manager pool configuration"
  type = object({
    manager_count               = number
    ami                         = string
    associate_public_ip_address = optional(bool)
    availability_zones          = list(string)
    disable_api_stop            = optional(bool)
    disable_api_termination     = optional(bool)
    instance_type               = string
    key_name                    = string
    root_volume_size            = number
    tags                        = optional(map(any))
    user_data                   = optional(string)
    vpc_security_group_ids      = list(string)
  })
  default = {
    manager_count               = 1
    ami                         = ""
    associate_public_ip_address = false
    availability_zones          = ["a"]
    disable_api_stop            = true
    disable_api_termination     = true
    instance_type               = "t3a.small"
    key_name                    = ""
    root_volume_size            = 30
    tags                        = {}
    user_data                   = ""
    vpc_security_group_ids      = []
  }
}

variable "worker_pools" {
  description = "Map of worker pools to create"
  type = map(object({
    name                        = string
    worker_count                = number
    ami                         = string
    associate_public_ip_address = optional(bool)
    availability_zones          = list(string)
    disable_api_stop            = optional(bool)
    disable_api_termination     = optional(bool)
    instance_type               = string
    key_name                    = string
    root_volume_size            = number
    tags                        = optional(map(any))
    user_data                   = optional(string)
    vpc_security_group_ids      = list(string)
  }))
  default = {
    "default" = {
      name                        = "default"
      worker_count                = 1
      ami                         = ""
      associate_public_ip_address = false
      availability_zones          = ["a"]
      disable_api_stop            = true
      disable_api_termination     = true
      instance_type               = "t3a.small"
      key_name                    = ""
      root_volume_size            = 30
      tags                        = {}
      user_data                   = ""
      vpc_security_group_ids      = []
    }
  }
}
