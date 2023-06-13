data "aws_iam_policy_document" "dataworks_aws_collections_rehydration_read_write_data" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      data.terraform_remote_state.common.outputs.published_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/pdm-dataset/*",
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/metrics/*",
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/common-model-inputs/*",
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/analytical-dataset/*",
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/data",
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/data/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:DeleteObject*",
      "s3:Put*",
    ]

    resources = [
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/dataworks-aws-collections-rehydration/*",
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/e2e-test-collections-rehydration-dataset/*",
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
      data.terraform_remote_state.common.outputs.published_bucket_cmk.arn,
    ]
  }
}

resource "aws_iam_policy" "dataworks_aws_collections_rehydration_read_write_data" {
  name        = "DataWorksCollectionsRehydrationReadData"
  description = "Allow writing of dataworks-aws-collections-rehydration files and metrics"
  policy      = data.aws_iam_policy_document.dataworks_aws_collections_rehydration_read_write_data.json
}

data "aws_ec2_managed_prefix_list" "list" {
  name = "dwp-*-aws-cidrs-*"
}