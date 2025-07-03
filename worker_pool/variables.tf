variable "cluster_name" {
  description = "The name of this cluster"
  type        = string
  default     = "swarm"

  validation {
    condition     = length(var.cluster_name) > 0 && length(var.cluster_name) <= 63
    error_message = "Cluster name must be between 1 and 63 characters long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.cluster_name))
    error_message = "Cluster name must start and end with alphanumeric characters and can only contain letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "The name of the environment this cluster targets"
  type        = string
  default     = "dev"

  validation {
    condition     = length(var.environment) > 0 && length(var.environment) <= 50
    error_message = "Environment name must be between 1 and 50 characters long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]*[a-zA-Z0-9]$", var.environment))
    error_message = "Environment name must start and end with alphanumeric characters and can only contain letters, numbers, hyphens, and underscores."
  }
}

variable "region" {
  description = "Region where this cluster will be managed"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.region))
    error_message = "Region must be a valid AWS region format (lowercase letters, numbers, and hyphens only)."
  }
}


variable "subnet_map" {
  description = "Map of AZ letters to subnet IDs"
  type        = map(any)
}

variable "name" {
  description = "The name of this worker pool"
  type        = string
  default     = "default"

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 50
    error_message = "Worker pool name must be between 1 and 50 characters long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]*[a-zA-Z0-9]$", var.name))
    error_message = "Worker pool name must start and end with alphanumeric characters and can only contain letters, numbers, hyphens, and underscores."
  }
}

variable "worker_type" {
  description = "The type of this worker pool"
  type        = string
  default     = "compute"

  validation {
    condition     = length(var.worker_type) > 0 && length(var.worker_type) <= 50
    error_message = "Worker pool type must be between 1 and 50 characters long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]*[a-zA-Z0-9]$", var.worker_type))
    error_message = "Worker pool type must start and end with alphanumeric characters and can only contain letters, numbers, hyphens, and underscores."
  }
}

variable "worker_count" {
  description = "Number of cluster worker instance(s)"
  type        = number
  default     = 1

  validation {
    condition     = var.worker_count >= 0 && var.worker_count <= 1000
    error_message = "Worker count must be between 0 and 1000. Worker nodes don't participate in raft consensus and can be any reasonable number."
  }
}

variable "ami" {
  description = "AMI to use for the cluster worker instance(s)"
  type        = string

  validation {
    condition     = can(regex("^ami-[0-9a-f]{8}([0-9a-f]{9})?$", var.ami))
    error_message = "AMI must be a valid AMI ID format (ami-xxxxxxxx or ami-xxxxxxxxxxxxxxxxx)."
  }
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC"
  type        = bool
}

variable "availability_zones" {
  description = "List of AZ to start the cluster worker instance(s) in"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) > 0 && length(var.availability_zones) <= 10
    error_message = "Availability zones list must contain between 1 and 10 zones."
  }

  validation {
    condition = alltrue([
      for az in var.availability_zones : can(regex("[a-z]$", az))
    ])
    error_message = "All availability zones must end with a letter (e.g., a, b, c)."
  }
}

variable "disable_api_stop" {
  description = "If true, enables EC2 Instance Stop Protection"
  type        = bool
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  type        = bool
}

variable "instance_type" {
  description = "Instance type to use for the worker instance(s)"
  type        = string
  default     = "t3a.small"

  validation {
    condition     = can(regex("^[a-z][0-9]+[a-z]*\\.[a-z0-9]+$", var.instance_type))
    error_message = "Instance type must be a valid AWS instance type format (e.g., t3a.small, m5.large)."
  }
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the instance"
  type        = string

  validation {
    condition     = length(var.key_name) > 0 && length(var.key_name) <= 255
    error_message = "Key name must be between 1 and 255 characters long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9._-]*$", var.key_name))
    error_message = "Key name must start with alphanumeric character and can only contain letters, numbers, periods, underscores, and hyphens."
  }
}

variable "root_volume_size" {
  description = "Size of the worker instance(s)' root volume in gibibytes (GiB)"
  type        = number
  default     = 30

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 16384
    error_message = "Root volume size must be between 8 and 16384 GiB."
  }
}

variable "tags" {
  description = "Map of tags to assign to the worker instance(s)"
  type        = map(any)
}

variable "user_data" {
  description = "User data to provide when launching the instance"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to associate worker instance(s) with"
  type        = list(string)
}
