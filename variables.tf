variable "emr_release" {
  default = {
    development = "6.2.0"
    qa          = "6.2.0"
    integration = "6.2.0"
    preprod     = "6.2.0"
    production  = "6.2.0"
  }
}

variable "truststore_aliases" {
  description = "comma seperated truststore aliases"
  type        = list(string)
  default     = ["dataworks_root_ca", "dataworks_mgt_root_ca"]
}

variable "emr_instance_type_master" {
  default = {
    development = "m5.4xlarge"
    qa          = "m5.4xlarge"
    integration = "m5.4xlarge"
    preprod     = "m5.8xlarge"
    production  = "m5.8xlarge"
  }
}

variable "emr_instance_type_core_one" {
  default = {
    development = "m5.xlarge"
    qa          = "m5.xlarge"
    integration = "m5.xlarge"
    preprod     = "m5.4xlarge"
    production  = "m5.4xlarge"
  }
}

# Count of instances
variable "emr_core_instance_count" {
  default = {
    development = "5"
    qa          = "5"
    integration = "5"
    preprod     = "10"
    production  = "10"
  }
}

variable "emr_ami_id" {
  description = "AMI ID to use for the HBase EMR nodes"
}

variable "spark_kyro_buffer" {
  default = {
    development = "128m"
    qa          = "128m"
    integration = "128m"
    preprod     = "2047m"
    production  = "2047m" # Max amount allowed
  }
}

variable "spark_executor_instances" {
  default = {
    development = 50
    qa          = 50
    integration = 50
    preprod     = 600
    production  = 600 # More than possible as it won't create them if no core or memory available
  }
}

variable "tanium_port_1" {
  description = "tanium port 1"
  type        = string
  default     = "16563"
}

variable "tanium_port_2" {
  description = "tanium port 2"
  type        = string
  default     = "16555"
}