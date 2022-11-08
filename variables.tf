variable "region" {
  default = ""
}

variable "vpc_id" {
  default = ""
}

variable "cluster_id" {
  default = ""
}

variable "nodepools" {
  type = list(object({
    name                 = string
    max_size             = number
    min_size             = number
    subnet_ids           = list(string)
    retry_policy         = string
    desired_capacity     = number
    enable_auto_scale    = bool
    delete_keep_instance = bool
    default_cooldown     = number
    node_config = object({
      data_disk = object({
        auto_format_and_mount = bool
        disk_partition        = string
        disk_type             = string
        disk_size             = number
        file_system           = string
        mount_target          = string
      })

      //If cluster is podCIDR
      desired_pod_num   = number
      docker_graph_path = string
      extra_args        = list(string)
      is_schedule       = bool
      mount_target      = string
      user_data         = string
    })
    node_os_type             = string
    node_os                  = string
    scaling_group_project_id = number
    scaling_group_name       = string
    scaling_mode             = string

    auto_scaling_config = object({
      instance_type         = string
      backup_instance_types = list(string)
      bandwidth_package_id  = string

      # If password set, can't set key_ids
      key_ids            = list(string)
      system_disk_type   = string
      system_disk_size   = string
      security_group_ids = list(string)

      data_disk = object({
        disk_type   = string
        disk_size   = number
        snapshot_id = string
      })

      internet_charge_type       = string
      internet_max_bandwidth_out = number
      public_ip_assigned         = bool
      password                   = string
      enhanced_security_service  = bool
      enhanced_monitor_service   = bool
    })

    taints = list(object({
      effect = string
      key    = string
      value  = string
    }))

    termination_policies = list(string)
    unschedulable        = number
    zones                = list(string)
    labels               = map(string)
  }))
  default = []
}
