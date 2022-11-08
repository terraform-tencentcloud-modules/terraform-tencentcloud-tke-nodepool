/**
 * Copyright 2020 Tencent Cloud, LLC
 *
 * Licensed under the Mozilla Public License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.mozilla.org/en-US/MPL/2.0/
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {

  nodepools = {
    for x in var.nodepools :
    "${x.name}-nodepool" => x
  }
}

resource "tencentcloud_kubernetes_node_pool" "mynodepool" {
  for_each = local.nodepools

  name                 = each.value.name
  cluster_id           = var.cluster_id
  max_size             = each.value.max_size
  min_size             = each.value.min_size
  vpc_id               = var.vpc_id
  subnet_ids           = each.value.subnet_ids
  retry_policy         = each.value.retry_policy
  desired_capacity     = each.value.desired_capacity
  enable_auto_scale    = each.value.enable_auto_scale
  delete_keep_instance = each.value.delete_keep_instance
  default_cooldown     = each.value.default_cooldown

  dynamic "node_config" {
    for_each = each.value.node_config[*]

    content {
      dynamic "data_disk" {
        for_each = node_config.value.data_disk[*]

        content {
          auto_format_and_mount = data_disk.value.auto_format_and_mount
          disk_partition        = data_disk.value.disk_partition
          disk_type             = data_disk.value.disk_type
          disk_size             = data_disk.value.disk_size
          file_system           = data_disk.value.file_system
          mount_target          = data_disk.value.mount_target
        }
      }

      /*
      //If cluster is podCIDR
      desired_pod_num   = node_config.value.desired_pod_num
      docker_graph_path = node_config.value.docker_graph_path
      extra_args        = node_config.value.extra_args
      is_schedule       = node_config.value.is_schedule
      mount_target      = node_config.value.mount_target
      user_data         = node_config.value.user_data
      */
    }
  }

  node_os_type             = each.value.node_os_type
  node_os                  = each.value.node_os
  scaling_group_project_id = each.value.scaling_group_project_id
  scaling_group_name       = each.value.scaling_group_name
  scaling_mode             = each.value.scaling_mode

  dynamic "auto_scaling_config" {
    for_each = each.value.auto_scaling_config[*]

    content {
      instance_type         = auto_scaling_config.value.instance_type
      backup_instance_types = auto_scaling_config.value.backup_instance_types
      bandwidth_package_id  = auto_scaling_config.value.bandwidth_package_id

      # If password set, can't set key_ids
      key_ids = auto_scaling_config.value.password == null ? auto_scaling_config.value.key_ids : null

      system_disk_type   = auto_scaling_config.value.system_disk_type
      system_disk_size   = auto_scaling_config.value.system_disk_size
      security_group_ids = auto_scaling_config.value.security_group_ids

      dynamic "data_disk" {
        for_each = auto_scaling_config.value.data_disk[*]

        content {
          disk_type   = data_disk.value.disk_type
          disk_size   = data_disk.value.disk_size
          snapshot_id = data_disk.value.snapshot_id
        }
      }

      internet_charge_type       = auto_scaling_config.value.internet_charge_type
      internet_max_bandwidth_out = auto_scaling_config.value.internet_max_bandwidth_out
      public_ip_assigned         = auto_scaling_config.value.public_ip_assigned
      password                   = auto_scaling_config.value.password
      enhanced_security_service  = auto_scaling_config.value.enhanced_security_service
      enhanced_monitor_service   = auto_scaling_config.value.enhanced_monitor_service
    }
  }

  dynamic "taints" {
    for_each = each.value.taints

    content {
      effect = taints.value.effect
      key    = taints.value.key
      value  = taints.value.value
    }
  }

  termination_policies = each.value.termination_policies
  unschedulable        = each.value.unschedulable
  //zones                = each.value.zones

  labels = each.value.labels
}
