# AWS Swarm Cluster Terraform Module

A Terraform module for deploying Docker Swarm clusters on AWS EC2 instances with high availability and flexible worker pool configuration.

## Features

- **High Availability**: Deploy Docker Swarm managers across multiple availability zones
- **Flexible Worker Pools**: Create multiple worker pools with different configurations
- **Security**: Encrypted EBS volumes, IMDSv2 enforcement, and configurable security groups
- **Ansible Integration**: Automatic generation of Ansible inventory for cluster management
- **Instance Protection**: Configurable API stop and termination protection
- **Custom User Data**: Support for custom initialization scripts

## Architecture

This module creates:

- **Manager Nodes**: 1, 3, 5, or 7 manager instances (following Docker Swarm raft consensus requirements)
- **Worker Pools**: One or more groups of worker instances with independent configurations
- **Networking**: Automatic subnet selection across availability zones
- **Outputs**: Structured instance information and Ansible inventory

## Usage

### Basic Example

```hcl
module "swarm_cluster" {
  source = "github.com/salcedo/aws_swarm_cluster"

  cluster_name = "my-swarm"
  environment  = "production"
  region       = "us-east-1"
  vpc_id       = "vpc-12345678"

  manager_pool = {
    manager_count               = 3
    ami                         = "ami-0c02fb55956c7d316"
    instance_type               = "t3a.medium"
    key_name                    = "my-key-pair"
    availability_zones          = ["a", "b", "c"]
    vpc_security_group_ids      = ["sg-manager123"]
    associate_public_ip_address = true
    root_volume_size            = 50
  }

  worker_pools = {
    "web" = {
      name                        = "web"
      worker_type                 = "web-server"
      worker_count                = 3
      ami                         = "ami-0c02fb55956c7d316"
      instance_type               = "t3a.large"
      key_name                    = "my-key-pair"
      availability_zones          = ["a", "b", "c"]
      vpc_security_group_ids      = ["sg-worker123"]
      associate_public_ip_address = true
      root_volume_size            = 100
    }
    "api" = {
      name                        = "api"
      worker_type                 = "api-server"
      worker_count                = 2
      ami                         = "ami-0c02fb55956c7d316"
      instance_type               = "c5.xlarge"
      key_name                    = "my-key-pair"
      availability_zones          = ["a", "b"]
      vpc_security_group_ids      = ["sg-api123"]
      associate_public_ip_address = false
      root_volume_size            = 200
    }
  }
}
```

### Advanced Example with Custom User Data

```hcl
module "swarm_cluster" {
  source = "github.com/salcedo/aws_swarm_cluster"

  cluster_name = "production-swarm"
  environment  = "prod"
  region       = "us-west-2"
  vpc_id       = "vpc-87654321"

  manager_pool = {
    manager_count               = 3
    ami                         = "ami-0c02fb55956c7d316"
    instance_type               = "t3a.medium"
    key_name                    = "prod-key"
    availability_zones          = ["a", "b", "c"]
    vpc_security_group_ids      = ["sg-manager-prod"]
    associate_public_ip_address = true
    disable_api_stop            = true
    disable_api_termination     = true
    root_volume_size            = 50
    user_data                   = <<-EOF
      # Install Docker
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh get-docker.sh
      usermod -aG docker ec2-user
      systemctl enable docker
      systemctl start docker

      # Configure Docker daemon
      mkdir -p /etc/docker
      cat > /etc/docker/daemon.json <<JSON
      {
        "log-driver": "json-file",
        "log-opts": {
          "max-size": "10m",
          "max-file": "3"
        }
      }
      JSON
      systemctl restart docker
    EOF
    tags = {
      Environment = "production"
      Team        = "infrastructure"
      SwarmRole   = "manager"
    }
  }

  worker_pools = {
    "compute" = {
      name                        = "compute"
      worker_type                 = "compute-intensive"
      worker_count                = 5
      ami                         = "ami-0c02fb55956c7d316"
      instance_type               = "c5.2xlarge"
      key_name                    = "prod-key"
      availability_zones          = ["a", "b", "c"]
      vpc_security_group_ids      = ["sg-worker-compute"]
      associate_public_ip_address = false
      disable_api_stop            = false
      disable_api_termination     = false
      root_volume_size            = 500
      tags = {
        Environment = "production"
        Team        = "infrastructure"
        SwarmRole   = "worker"
        WorkerType  = "compute-intensive"
      }
    }
  }
}
```

## Inputs

### Required Variables

| Name     | Description                               | Type     |
| -------- | ----------------------------------------- | -------- |
| `vpc_id` | VPC ID where the cluster will be deployed | `string` |

### Optional Variables

| Name                          | Description                                             | Type          | Default       |
| ----------------------------- | ------------------------------------------------------- | ------------- | ------------- |
| `cluster_name`                | The name of this cluster                                | `string`      | `"swarm"`     |
| `environment`                 | The name of the environment this cluster targets        | `string`      | `"dev"`       |
| `region`                      | Region where this cluster will be managed               | `string`      | `"us-east-1"` |
| `ansible_host_use_private_ip` | Use private IP addresses for Ansible host configuration | `bool`        | `true`        |
| `manager_pool`                | Manager pool configuration                              | `object`      | See below     |
| `worker_pools`                | Map of worker pools to create                           | `map(object)` | See below     |

### Manager Pool Configuration

| Name                          | Description                                 | Type           | Default       |
| ----------------------------- | ------------------------------------------- | -------------- | ------------- |
| `manager_count`               | Number of manager instances (1, 3, 5, or 7) | `number`       | `1`           |
| `ami`                         | AMI ID for manager instances                | `string`       | `""`          |
| `instance_type`               | EC2 instance type                           | `string`       | `"t3a.small"` |
| `key_name`                    | EC2 Key Pair name                           | `string`       | `""`          |
| `availability_zones`          | List of AZ letters (e.g., ["a", "b", "c"])  | `list(string)` | `["a"]`       |
| `vpc_security_group_ids`      | List of security group IDs                  | `list(string)` | `[]`          |
| `associate_public_ip_address` | Whether to assign public IP                 | `bool`         | `false`       |
| `disable_api_stop`            | Enable EC2 Instance Stop Protection         | `bool`         | `true`        |
| `disable_api_termination`     | Enable EC2 Instance Termination Protection  | `bool`         | `true`        |
| `root_volume_size`            | Root volume size in GiB                     | `number`       | `30`          |
| `user_data`                   | Custom user data script                     | `string`       | `""`          |
| `tags`                        | Additional tags for instances               | `map(any)`     | `{}`          |

### Worker Pool Configuration

Each worker pool in the `worker_pools` map supports the same configuration options as the manager pool, plus:

| Name           | Description                             | Type     | Default     |
| -------------- | --------------------------------------- | -------- | ----------- |
| `name`         | Name of the worker pool                 | `string` | Required    |
| `worker_type`  | Type/category of the worker pool        | `string` | `"compute"` |
| `worker_count` | Number of worker instances in this pool | `number` | `1`         |

#### Default Worker Pool

If no `worker_pools` are specified, the module creates a default worker pool with the following configuration:

```hcl
worker_pools = {
  "default" = {
    name                        = "default"
    worker_type                 = "compute"
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
```

## Outputs

| Name                      | Description                                 |
| ------------------------- | ------------------------------------------- |
| `ansible_inventory_yaml`  | Complete Ansible inventory in YAML format   |
| `manager_instances`       | Manager instance information                |
| `worker_instances`        | Worker instance information grouped by pool |
| `all_worker_instances`    | All worker instances combined               |
| `manager_placement_group` | Manager placement group information         |
| `worker_placement_groups` | Worker placement group information by pool  |

### Ansible Inventory Output

The module generates a complete Ansible inventory with the following structure:

```yaml
all:
  children:
    managers:
      hosts:
        swarm-prod-mgr-a1:
          ansible_host: "10.0.1.10"
          ansible_ssh_common_args: "-o StrictHostKeyChecking=no"
          private_ip: "10.0.1.10"
          public_ip: "1.2.3.4"
    workers:
      hosts:
        swarm-prod-wkr-web-a1:
          ansible_host: "10.0.1.11"
          ansible_ssh_common_args: "-o StrictHostKeyChecking=no"
          private_ip: "10.0.1.11"
          public_ip: "1.2.3.5"
          worker_pool: "web"
          worker_type: "web-server"
```

#### Ansible Host IP Selection

The `ansible_host` field in the inventory is controlled by the `ansible_host_use_private_ip` variable:

- **When `ansible_host_use_private_ip = true` (default)**: The `ansible_host` field uses the private IP address for all instances
- **When `ansible_host_use_private_ip = false`**: The `ansible_host` field uses the public IP address if available, otherwise falls back to the private IP address

This allows you to control whether Ansible connects to instances via their public or private IP addresses, which is important for different network configurations:

- **Private IP (default)**: Recommended for instances in private subnets or when connecting from within the VPC
- **Public IP**: Useful when connecting from outside the VPC or for instances in public subnets

Example with public IP preference:

```hcl
module "swarm_cluster" {
  # ... other configuration ...
  ansible_host_use_private_ip = false
}
```

## Instance Naming Convention

Instances are automatically named using the following pattern:

- **Managers**: `{cluster_name}-{environment}-mgr-{az}{instance_number}`
- **Workers**: `{cluster_name}-{environment}-wkr-{pool_name}-{az}{instance_number}`

Examples:

- `myapp-prod-mgr-a1`, `myapp-prod-mgr-b2`, `myapp-prod-mgr-c3`
- `myapp-prod-wkr-web-a1`, `myapp-prod-wkr-api-b1`

## Security Features

- **Encrypted Storage**: All EBS root volumes are encrypted
- **IMDSv2**: Instance Metadata Service v2 is enforced (http_tokens = "required")
- **Security Groups**: Configurable security groups for managers and worker pools
- **Instance Protection**: Optional API stop and termination protection
- **Network Isolation**: Support for private subnets with no public IP assignment

## Best Practices

### High Availability

- Use odd numbers of managers (1, 3, 5, or 7) for raft consensus
- Distribute managers across multiple availability zones
- Use at least 3 managers for production workloads

### Security

- Use private subnets for worker nodes when possible
- Implement least-privilege security group rules
- Enable instance protection for production environments
- Use encrypted AMIs and enable EBS encryption

### Scaling

- Create separate worker pools for different workload types
- Use appropriate instance types for each workload
- Monitor and adjust worker pool sizes based on demand

### Networking

- Ensure security groups allow necessary Docker Swarm ports:
  - TCP 2377 (cluster management)
  - TCP/UDP 7946 (node communication)
  - UDP 4789 (overlay network traffic)

## Troubleshooting

### Common Issues

1. **Subnet Selection**: Ensure your VPC has subnets in the specified availability zones
2. **Security Groups**: Verify security groups exist and have appropriate rules
3. **AMI Availability**: Confirm the specified AMI is available in your region
4. **Key Pairs**: Ensure the specified key pair exists in the target region

### Validation Errors

The module includes extensive validation for:

- **Manager count**: Must be 1, 3, 5, or 7 (Docker Swarm raft consensus requirements)
- **AMI ID format**: Must match pattern `ami-xxxxxxxx` or `ami-xxxxxxxxxxxxxxxxx`
- **Instance type format**: Must be valid AWS instance type (e.g., `t3a.small`, `m5.large`)
- **Availability zone format**: Must end with a letter (e.g., `a`, `b`, `c`)
- **Cluster and environment naming**: Must be alphanumeric with hyphens/underscores, 1-63 characters for cluster name, 1-50 for environment
- **Key name**: Must be 1-255 characters, alphanumeric with periods, underscores, and hyphens
- **Root volume size**: Must be between 8 and 16384 GiB
- **Worker count**: Must be between 0 and 1000 instances per pool

## Contributing

When contributing to this module:

1. Follow Terraform best practices
2. Add appropriate variable validation
3. Update documentation for any new features
4. Test with multiple configurations

## License

```
            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO.
```
