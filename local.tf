locals {
  emr_cluster_name = "dataworks-aws-collections-rehydration"
  common_emr_tags = merge(
    local.common_tags,
    {
      for-use-with-amazon-emr-managed-policies = "true"
    },
  )
  common_tags = {
    Environment  = local.environment
    Application  = local.emr_cluster_name
    CreatedBy    = "terraform"
    Owner        = "dataworks platform"
    Persistence  = "Ignore"
    AutoShutdown = "False"
  }
  env_certificate_bucket = "dw-${local.environment}-public-certificates"
  mgt_certificate_bucket = "dw-${local.management_account[local.environment]}-public-certificates"
  dks_endpoint           = data.terraform_remote_state.crypto.outputs.dks_endpoint[local.environment]

  crypto_workspace = {
    management-dev = "management-dev"
    management     = "management"
  }

  management_workspace = {
    management-dev = "default"
    management     = "management"
  }

  management_account = {
    development = "management-dev"
    qa          = "management-dev"
    integration = "management-dev"
    preprod     = "management"
    production  = "management"
  }

  root_dns_name = {
    development = "dev.dataworks.dwp.gov.uk"
    qa          = "qa.dataworks.dwp.gov.uk"
    integration = "int.dataworks.dwp.gov.uk"
    preprod     = "pre.dataworks.dwp.gov.uk"
    production  = "dataworks.dwp.gov.uk"
  }

  dataworks_aws_collections_rehydration_log_level = {
    development = "DEBUG"
    qa          = "DEBUG"
    integration = "DEBUG"
    preprod     = "INFO"
    production  = "INFO"
  }

  dataworks_aws_collections_rehydration_version = {
    development = "0.0.1"
    qa          = "0.0.1"
    integration = "0.0.1"
    preprod     = "0.0.1"
    production  = "0.0.1"
  }

  dataworks_collections_rehydration_version = {
    development = "0.0.12"
    qa          = "0.0.12"
    integration = "0.0.12"
    preprod     = "0.0.12"
    production  = "0.0.12"
  }

  collections_rehydration_alerts = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  data_pipeline_metadata = data.terraform_remote_state.internal_compute.outputs.data_pipeline_metadata_dynamo.name

  collections_rehydration_db               = "uc_collections_rehydration"
  hive_metastore_location                  = "data/uc_collections_rehydration"
  serde                                    = "org.openx.data.jsonserde.JsonSerDe"
  data_path                                = "analytical-dataset/full/"
  collections_rehydration_scripts_location = "/opt/emr/dataworks-collections-rehydration"

  amazon_region_domain = "${data.aws_region.current.name}.amazonaws.com"
  endpoint_services    = ["dynamodb", "ec2", "ec2messages", "glue", "kms", "logs", "monitoring", ".s3", "s3", "secretsmanager", "ssm", "ssmmessages"]
  no_proxy             = "169.254.169.254,${local.collections_rehydration_pushgateway_hostname},${join(",", formatlist("%s.%s", local.endpoint_services, local.amazon_region_domain))}"
  ebs_emrfs_em = {
    EncryptionConfiguration = {
      EnableInTransitEncryption = false
      EnableAtRestEncryption    = true
      AtRestEncryptionConfiguration = {

        S3EncryptionConfiguration = {
          EncryptionMode             = "CSE-Custom"
          S3Object                   = "s3://${data.terraform_remote_state.management_artefact.outputs.artefact_bucket.id}/emr-encryption-materials-provider/encryption-materials-provider-all.jar"
          EncryptionKeyProviderClass = "uk.gov.dwp.dataworks.dks.encryptionmaterialsprovider.DKSEncryptionMaterialsProvider"
        }
        LocalDiskEncryptionConfiguration = {
          EnableEbsEncryption       = true
          EncryptionKeyProviderType = "AwsKms"
          AwsKmsKey                 = aws_kms_key.dataworks_aws_collections_rehydration_ebs_cmk.arn
        }
      }
    }
  }

  keep_cluster_alive = {
    development = true
    qa          = false
    integration = false
    preprod     = false
    production  = false
  }

  step_fail_action = {
    development = "CONTINUE"
    qa          = "TERMINATE_CLUSTER"
    integration = "TERMINATE_CLUSTER"
    preprod     = "TERMINATE_CLUSTER"
    production  = "TERMINATE_CLUSTER"
  }

  cw_agent_namespace                   = "/app/dataworks_aws_collections_rehydration"
  cw_agent_log_group_name              = "/app/dataworks_aws_collections_rehydration"
  cw_agent_bootstrap_loggrp_name       = "/app/dataworks_aws_collections_rehydration/bootstrap_actions"
  cw_agent_steps_loggrp_name           = "/app/dataworks_aws_collections_rehydration/step_logs"
  cw_agent_tests_loggrp_name           = "/app/dataworks-aws-collections-rehydration/tests_logs"
  cw_agent_yarnspark_loggrp_name       = "/app/dataworks-aws-collections-rehydration/yarn-spark_logs"
  cw_agent_metrics_collection_interval = 60

  s3_log_prefix = "emr/dataworks_aws_collections_rehydration"

  use_capacity_reservation = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = false
  }

  emr_capacity_reservation_preference = local.use_capacity_reservation[local.environment] == true ? "open" : "none"

  emr_capacity_reservation_usage_strategy = local.use_capacity_reservation[local.environment] == true ? "use-capacity-reservations-first" : ""

  emr_subnet_non_capacity_reserved_environments = data.terraform_remote_state.common.outputs.aws_ec2_non_capacity_reservation_region

  hive_tez_container_size = {
    development = "2688"
    qa          = "2688"
    integration = "2688"
    preprod     = "15360"
    production  = "15360"
  }

  # 0.8 of hive_tez_container_size
  hive_tez_java_opts = {
    development = "-Xmx2150m"
    qa          = "-Xmx2150m"
    integration = "-Xmx2150m"
    preprod     = "-Xmx12288m"
    production  = "-Xmx12288m"
  }

  # 0.33 of hive_tez_container_size
  hive_auto_convert_join_noconditionaltask_size = {
    development = "896"
    qa          = "896"
    integration = "896"
    preprod     = "5068"
    production  = "5068"
  }

  hive_bytes_per_reducer = {
    development = "13421728"
    qa          = "13421728"
    integration = "13421728"
    preprod     = "13421728"
    production  = "13421728"
  }

  tez_runtime_unordered_output_buffer_size_mb = {
    development = "268"
    qa          = "268"
    integration = "268"
    preprod     = "2148"
    production  = "2148"
  }

  # 0.4 of hive_tez_container_size
  tez_runtime_io_sort_mb = {
    development = "1075"
    qa          = "1075"
    integration = "1075"
    preprod     = "6144"
    production  = "6144"
  }

  tez_grouping_min_size = {
    development = "1342177"
    qa          = "1342177"
    integration = "1342177"
    preprod     = "52428800"
    production  = "52428800"
  }

  tez_grouping_max_size = {
    development = "268435456"
    qa          = "268435456"
    integration = "268435456"
    preprod     = "1073741824"
    production  = "1073741824"
  }

  tez_am_resource_memory_mb = {
    development = "1024"
    qa          = "1024"
    integration = "1024"
    preprod     = "12288"
    production  = "12288"
  }

  # 0.8 of hive_tez_container_size
  tez_task_resource_memory_mb = {
    development = "1024"
    qa          = "1024"
    integration = "1024"
    preprod     = "8196"
    production  = "8196"
  }

  # 0.8 of tez_am_resource_memory_mb
  tez_am_launch_cmd_opts = {
    development = "-Xmx819m"
    qa          = "-Xmx819m"
    integration = "-Xmx819m"
    preprod     = "-Xmx6556m"
    production  = "-Xmx6556m"
  }

  // This value should be the same as yarn.scheduler.maximum-allocation-mb
  llap_daemon_yarn_container_mb = {
    development = "57344"
    qa          = "57344"
    integration = "57344"
    preprod     = "385024"
    production  = "385024"
  }

  llap_number_of_instances = {
    development = "5"
    qa          = "5"
    integration = "5"
    preprod     = "20"
    production  = "29"
  }

  map_reduce_vcores_per_node = {
    development = "5"
    qa          = "5"
    integration = "5"
    preprod     = "15"
    production  = "15"
  }

  map_reduce_vcores_per_task = {
    development = "1"
    qa          = "1"
    integration = "1"
    preprod     = "5"
    production  = "5"
  }

  hive_max_reducers = {
    development = "1099"
    qa          = "1099"
    integration = "1099"
    preprod     = "3000"
    production  = "3000"
  }

  hive_tez_sessions_per_queue = {
    development = "10"
    qa          = "10"
    integration = "10"
    preprod     = "35"
    production  = "35"
  }

  retry_max_attempts = {
    development = "10"
    qa          = "10"
    integration = "10"
    preprod     = "12"
    production  = "12"
  }

  retry_attempt_delay_seconds = {
    development = "5"
    qa          = "5"
    integration = "5"
    preprod     = "5"
    production  = "5"
  }

  retry_enabled = {
    development = "true"
    qa          = "true"
    integration = "true"
    preprod     = "true"
    production  = "true"
  }

  collections_rehydration_processes = {
    development = "10"
    qa          = "10"
    integration = "10"
    preprod     = "20"
    production  = "20"
  }

  final_step = "run-collections-rehydration"

  collections_rehydration_pushgateway_hostname = "${aws_service_discovery_service.collections_rehydration_services.name}.${aws_service_discovery_private_dns_namespace.collections_rehydration_services.name}"

  collections_rehydration_max_retry_count = {
    development = "0"
    qa          = "0"
    integration = "0"
    preprod     = "0"
    production  = "1"
  }

  # See https://aws.amazon.com/blogs/big-data/best-practices-for-successfully-managing-memory-for-apache-spark-applications-on-amazon-emr/
  spark_executor_cores = {
    development = 1
    qa          = 1
    integration = 1
    preprod     = 1
    production  = 1
  }

  spark_executor_memory = {
    development = 10
    qa          = 10
    integration = 10
    preprod     = 35
    production  = 35 # At least 20 or more per executor core
  }

  spark_yarn_executor_memory_overhead = {
    development = 2
    qa          = 2
    integration = 2
    preprod     = 7
    production  = 7
  }

  spark_driver_memory = {
    development = 5
    qa          = 5
    integration = 5
    preprod     = 10
    production  = 10 # Doesn't need as much as executors
  }

  spark_driver_cores = {
    development = 1
    qa          = 1
    integration = 1
    preprod     = 1
    production  = 1
  }

  spark_executor_instances  = var.spark_executor_instances[local.environment]
  spark_default_parallelism = local.spark_executor_instances * local.spark_executor_cores[local.environment] * 2
  spark_kyro_buffer         = var.spark_kyro_buffer[local.environment]

  tenable_install = {
    development    = "true"
    qa             = "true"
    integration    = "true"
    preprod        = "true"
    production     = "true"
    management-dev = "true"
    management     = "true"
  }

  trend_install = {
    development    = "true"
    qa             = "true"
    integration    = "true"
    preprod        = "true"
    production     = "true"
    management-dev = "true"
    management     = "true"
  }

  tanium_install = {
    development    = "true"
    qa             = "true"
    integration    = "true"
    preprod        = "true"
    production     = "true"
    management-dev = "true"
    management     = "true"
  }


  ## Tanium config
  ## Tanium Servers
  tanium1 = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium[local.environment].server_1
  tanium2 = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium[local.environment].server_2

  ## Tanium Env Config
  tanium_env = {
    development    = "pre-prod"
    qa             = "prod"
    integration    = "prod"
    preprod        = "prod"
    production     = "prod"
    management-dev = "pre-prod"
    management     = "prod"
  }

  ## Tanium prefix list for TGW for Security Group rules
  tanium_prefix = {
    development    = [data.aws_ec2_managed_prefix_list.list.id]
    qa             = [data.aws_ec2_managed_prefix_list.list.id]
    integration    = [data.aws_ec2_managed_prefix_list.list.id]
    preprod        = [data.aws_ec2_managed_prefix_list.list.id]
    production     = [data.aws_ec2_managed_prefix_list.list.id]
    management-dev = [data.aws_ec2_managed_prefix_list.list.id]
    management     = [data.aws_ec2_managed_prefix_list.list.id]
  }

  tanium_log_level = {
    development    = "41"
    qa             = "41"
    integration    = "41"
    preprod        = "41"
    production     = "41"
    management-dev = "41"
    management     = "41"
  }

  ## Trend config
  tenant   = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).trend.tenant
  tenantid = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).trend.tenantid
  token    = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).trend.token

  policy_id = {
    development    = "1651"
    qa             = "1651"
    integration    = "1651"
    preprod        = "1717"
    production     = "1717"
    management-dev = "1651"
    management     = "1717"
  }
}
