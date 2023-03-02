resource "aws_s3_object" "create_databases_sh" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/dataworks-aws-collections-rehydration/create-collections-rehydration-databases.sh"
  content = templatefile("${path.module}/steps/create-collections-rehydration-databases.sh",
    {
      collections_rehydration_db = local.collections_rehydration_db
      hive_metastore_location    = local.hive_metastore_location
      published_bucket           = format("s3://%s", data.terraform_remote_state.common.outputs.published_bucket.id)
    }
  )
}

resource "aws_s3_object" "run_collections_rehydration" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/dataworks-aws-collections-rehydration/run-collections-rehydration.sh"
  content = templatefile("${path.module}/steps/run-collections-rehydration.sh",
    {
      target_db                                = local.collections_rehydration_db
      serde                                    = local.serde
      data_path                                = local.data_path
      published_bucket                         = format("s3://%s", data.terraform_remote_state.common.outputs.published_bucket.id)
      collections_rehydration_processes        = local.collections_rehydration_processes[local.environment]
      collections_rehydration_scripts_location = local.collections_rehydration_scripts_location
    }
  )
}

