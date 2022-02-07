data "aws_iam_policy_document" "dataworks_aws_collections_rehydration_read_write" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      data.terraform_remote_state.common.outputs.processed_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "${data.terraform_remote_state.common.outputs.processed_bucket.arn}/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = [
      data.terraform_remote_state.common.outputs.processed_bucket_cmk.arn,
    ]
  }
}

resource "aws_iam_policy" "dataworks_aws_collections_rehydration_read_write_processed_bucket" {
  name        = "dataworks-aws-collections-rehydration-ReadWriteAccessToProcessedBucket"
  description = "Allow read and write access to the processed bucket"
  policy      = data.aws_iam_policy_document.dataworks_aws_collections_rehydration_read_write.json
}

