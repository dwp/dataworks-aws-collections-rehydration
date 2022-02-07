resource "aws_acm_certificate" "dataworks_aws_collections_rehydration" {
  certificate_authority_arn = data.terraform_remote_state.aws_certificate_authority.outputs.root_ca.arn
  domain_name               = "dataworks-aws-collections-rehydration.${local.env_prefix[local.environment]}${local.dataworks_domain_name}"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
}

data "aws_iam_policy_document" "dataworks_aws_collections_rehydration_acm" {
  statement {
    effect = "Allow"

    actions = [
      "acm:ExportCertificate",
    ]

    resources = [
      aws_acm_certificate.dataworks_aws_collections_rehydration.arn
    ]
  }
}

resource "aws_iam_policy" "dataworks_aws_collections_rehydration_acm" {
  name        = "ACMExport-dataworks-aws-collections-rehydration-Cert"
  description = "Allow export of dataworks-aws-collections-rehydration certificate"
  policy      = data.aws_iam_policy_document.dataworks_aws_collections_rehydration_acm.json
}

data "aws_iam_policy_document" "dataworks_aws_collections_rehydration_certificates" {
  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "arn:aws:s3:::${local.mgt_certificate_bucket}*",
      "arn:aws:s3:::${local.env_certificate_bucket}/*",
    ]
  }
}

resource "aws_iam_policy" "dataworks_aws_collections_rehydration_certificates" {
  name        = "dataworks_aws_collections_rehydrationGetCertificates"
  description = "Allow read access to the Crown-specific subset of the dataworks_aws_collections_rehydration"
  policy      = data.aws_iam_policy_document.dataworks_aws_collections_rehydration_certificates.json
}


