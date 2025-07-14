resource "aws_placement_group" "manager" {
  name     = "${var.cluster_name}-${var.environment}-manager"
  strategy = "spread"
  tags = merge(var.tags, {
    Name = "${var.cluster_name}-${var.environment}-manager"
  })
}

resource "aws_instance" "manager" {
  count = var.manager_count

  ami                         = var.ami
  associate_public_ip_address = var.associate_public_ip_address

  disable_api_stop        = var.disable_api_stop
  disable_api_termination = var.disable_api_termination

  instance_type = var.instance_type
  key_name      = var.key_name

  placement_group = aws_placement_group.manager.id

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
    tags = merge(var.tags, {
      Instance         = "${var.cluster_name}-${var.environment}-mgr-${var.availability_zones[count.index % length(var.availability_zones)]}${count.index + 1}"
      AvailabilityZone = "${var.region}${var.availability_zones[count.index % length(var.availability_zones)]}"
    })
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  subnet_id = var.subnet_map[var.availability_zones[count.index % length(var.availability_zones)]]

  tags = merge(var.tags, {
    Name             = "${var.cluster_name}-${var.environment}-mgr-${var.availability_zones[count.index % length(var.availability_zones)]}${count.index + 1}"
    AvailabilityZone = "${var.region}${var.availability_zones[count.index % length(var.availability_zones)]}"
    SwarmRole        = "manager"
    InstanceType     = var.instance_type
  })

  user_data = <<-EOF
              #!/bin/bash
              HOSTNAME="${var.cluster_name}-${var.environment}-mgr-${var.availability_zones[count.index % length(var.availability_zones)]}${count.index + 1}"

              echo "$HOSTNAME" > /etc/hostname
              hostnamectl set-hostname "$HOSTNAME"
              echo "127.0.0.1 $HOSTNAME" >> /etc/hosts
              ${var.user_data}
              EOF

  vpc_security_group_ids = var.vpc_security_group_ids
}
