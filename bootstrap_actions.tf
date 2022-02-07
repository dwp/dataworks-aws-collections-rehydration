resource "aws_s3_bucket_object" "metadata_script" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  key        = "component/dataworks-aws-collections-rehydration/metadata.sh"
  content    = file("${path.module}/bootstrap_actions/metadata.sh")
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
}

resource "aws_s3_bucket_object" "download_scripts_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/dataworks-aws-collections-rehydration/download_scripts.sh"
  content = templatefile("${path.module}/bootstrap_actions/download_scripts.sh",
    {
      VERSION                                         = local.dataworks_aws_collections_rehydration_version[local.environment]
      dataworks_aws_collections_rehydration_LOG_LEVEL = local.dataworks_aws_collections_rehydration_log_level[local.environment]
      ENVIRONMENT_NAME                                = local.environment
      S3_COMMON_LOGGING_SHELL                         = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, data.terraform_remote_state.common.outputs.application_logging_common_file.s3_id)
      S3_LOGGING_SHELL                                = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.logging_script.key)
      scripts_location                                = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, "component/dataworks-aws-collections-rehydration")
      collections_rehydration_scripts_location        = local.collections_rehydration_scripts_location
  })
}

resource "aws_s3_bucket_object" "download_sql_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/dataworks-aws-collections-rehydration/download_sql.sh"
  content = templatefile("${path.module}/bootstrap_actions/download_sql.sh",
    {
      version                                         = local.dataworks_collections_rehydration_version[local.environment]
      s3_artefact_bucket_id                           = data.terraform_remote_state.management_artefact.outputs.artefact_bucket.id
      s3_config_bucket_id                             = format("s3://%s", data.terraform_remote_state.common.outputs.config_bucket.id)
      dataworks_aws_collections_rehydration_log_level = local.dataworks_aws_collections_rehydration_log_level[local.environment]
      environment_name                                = local.environment
      collections_rehydration_scripts_location        = local.collections_rehydration_scripts_location
    }
  )
}

resource "aws_s3_bucket_object" "emr_setup_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/dataworks-aws-collections-rehydration/emr-setup.sh"
  content = templatefile("${path.module}/bootstrap_actions/emr-setup.sh",
    {
      dataworks_aws_collections_rehydration_LOG_LEVEL = local.dataworks_aws_collections_rehydration_log_level[local.environment]
      aws_default_region                              = "eu-west-2"
      full_proxy                                      = data.terraform_remote_state.internal_compute.outputs.internet_proxy.url
      full_no_proxy                                   = local.no_proxy
      acm_cert_arn                                    = aws_acm_certificate.dataworks_aws_collections_rehydration.arn
      private_key_alias                               = "private_key"
      truststore_aliases                              = join(",", var.truststore_aliases)
      truststore_certs                                = "s3://${local.env_certificate_bucket}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem"
      dks_endpoint                                    = data.terraform_remote_state.crypto.outputs.dks_endpoint[local.environment]
      cwa_metrics_collection_interval                 = local.cw_agent_metrics_collection_interval
      cwa_namespace                                   = local.cw_agent_namespace
      cwa_log_group_name                              = aws_cloudwatch_log_group.dataworks_aws_collections_rehydration.name
      S3_CLOUDWATCH_SHELL                             = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.cloudwatch_sh.key)
      cwa_bootstrap_loggrp_name                       = aws_cloudwatch_log_group.dataworks_aws_collections_rehydration_cw_bootstrap_loggroup.name
      cwa_steps_loggrp_name                           = aws_cloudwatch_log_group.dataworks_aws_collections_rehydration_cw_steps_loggroup.name
      name                                            = local.emr_cluster_name
      cwa_tests_loggrp_name                           = aws_cloudwatch_log_group.dataworks_aws_collections_rehydration_cw_tests_loggroup.name
  })
}

resource "aws_s3_bucket_object" "ssm_script" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "component/dataworks-aws-collections-rehydration/start_ssm.sh"
  content = file("${path.module}/bootstrap_actions/start_ssm.sh")
}


resource "aws_s3_bucket_object" "logging_script" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "component/dataworks-aws-collections-rehydration/logging.sh"
  content = file("${path.module}/bootstrap_actions/logging.sh")
}

resource "aws_cloudwatch_log_group" "dataworks_aws_collections_rehydration" {
  name              = local.cw_agent_log_group_name
  retention_in_days = 180
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "dataworks_aws_collections_rehydration_cw_bootstrap_loggroup" {
  name              = local.cw_agent_bootstrap_loggrp_name
  retention_in_days = 180
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "dataworks_aws_collections_rehydration_cw_steps_loggroup" {
  name              = local.cw_agent_steps_loggrp_name
  retention_in_days = 180
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "dataworks_aws_collections_rehydration_cw_tests_loggroup" {
  name              = local.cw_agent_tests_loggrp_name
  retention_in_days = 180
  tags              = local.common_tags
}

resource "aws_s3_bucket_object" "cloudwatch_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/dataworks-aws-collections-rehydration/cloudwatch.sh"
  content = templatefile("${path.module}/bootstrap_actions/cloudwatch.sh",
    {
      emr_release = var.emr_release[local.environment]
    }
  )
}

resource "aws_s3_bucket_object" "metrics_setup_sh" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/dataworks-aws-collections-rehydration/metrics-setup.sh"
  content = templatefile("${path.module}/bootstrap_actions/metrics-setup.sh",
    {
      proxy_url         = data.terraform_remote_state.internal_compute.outputs.internet_proxy.url
      metrics_pom       = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.metrics_pom.key)
      prometheus_config = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.prometheus_config.key)
    }
  )
}

resource "aws_s3_bucket_object" "metrics_pom" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/dataworks-aws-collections-rehydration/metrics/pom.xml"
  content    = file("${path.module}/bootstrap_actions/metrics_config/pom.xml")
}

resource "aws_s3_bucket_object" "prometheus_config" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/dataworks-aws-collections-rehydration/metrics/prometheus_config.yml"
  content    = file("${path.module}/bootstrap_actions/metrics_config/prometheus_config.yml")
}

resource "aws_s3_bucket_object" "update_dynamo_sh" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/dataworks-aws-collections-rehydration/update_dynamo.sh"
  content = templatefile("${path.module}/bootstrap_actions/update_dynamo.sh",
    {
      dynamodb_table_name = local.data_pipeline_metadata
      final_step          = local.final_step
    }
  )
}

resource "aws_s3_bucket_object" "dynamo_json_file" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/dataworks-aws-collections-rehydration/dynamo_schema.json"
  content    = file("${path.module}/bootstrap_actions/dynamo_schema.json")
}


resource "aws_s3_bucket_object" "status_metrics_sh" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/dataworks-aws-collections-rehydration/status_metrics.sh"
  content = templatefile("${path.module}/bootstrap_actions/status_metrics.sh",
    {
      collections_rehydration_pushgateway_hostname = local.collections_rehydration_pushgateway_hostname
      final_step                                   = local.final_step
    }
  )
}

resource "aws_s3_bucket_object" "retry_utility" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/dataworks-aws-collections-rehydration/retry.sh"
  content = templatefile("${path.module}/bootstrap_actions/retry.sh",
    {
      retry_max_attempts          = local.retry_max_attempts[local.environment]
      retry_attempt_delay_seconds = local.retry_attempt_delay_seconds[local.environment]
      retry_enabled               = local.retry_enabled[local.environment]
    }
  )
}

resource "aws_s3_bucket_object" "retry_script" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/dataworks-aws-collections-rehydration/with_retry.sh"
  content = templatefile("${path.module}/bootstrap_actions/with_retry.sh",
    {
    }
  )
}

resource "aws_s3_bucket_object" "resume_step_script" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "component/dataworks-aws-collections-rehydration/resume_step.sh"
  content = file("${path.module}/bootstrap_actions/resume_step.sh")
}

