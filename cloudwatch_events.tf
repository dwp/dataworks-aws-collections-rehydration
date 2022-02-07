resource "aws_cloudwatch_event_rule" "collections_rehydration_failed" {
  name          = "collections_rehydration_failed"
  description   = "Sends failed message to slack when collections-rehydration cluster terminates with errors"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "TERMINATED_WITH_ERRORS"
    ],
    "name": [
      "dataworks-aws-collections-rehydration"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "collections_rehydration_terminated" {
  name          = "collections_rehydration_terminated"
  description   = "Sends terminated message to slack when collections-rehydration cluster terminates by user request"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "TERMINATED"
    ],
    "name": [
      "dataworks-aws-collections-rehydration"
    ],
    "stateChangeReason": [
      "{\"code\":\"USER_REQUEST\",\"message\":\"User request\"}"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "collections_rehydration_success" {
  name          = "collections_rehydration_success"
  description   = "checks that all steps complete"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "TERMINATED"
    ],
    "name": [
      "dataworks-aws-collections-rehydration"
    ],
    "stateChangeReason": [
      "{\"code\":\"ALL_STEPS_COMPLETED\",\"message\":\"Steps completed\"}"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "collections_rehydration_success_with_errors" {
  name          = "collections_rehydration_success_with_errors"
  description   = "checks that all steps complete but with failures on non mandatory steps"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "TERMINATED"
    ],
    "name": [
      "dataworks-aws-collections-rehydration"
    ],
    "stateChangeReason": [
      "{\"code\":\"STEP_FAILURE\",\"message\":\"Steps completed with errors\"}"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "collections_rehydration_running" {
  name          = "collections_rehydration_running"
  description   = "checks that collections-rehydration has started running"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "RUNNING"
    ],
    "name": [
      "dataworks-aws-collections-rehydration"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_metric_alarm" "collections_rehydration_failed" {
  count                     = local.collections_rehydration_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "collections_rehydration_failed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors cluster termination with errors"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.collections_rehydration_failed.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "collections_rehydration_failed",
      notification_type = "Error",
      severity          = "Critical"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "collections_rehydration_terminated" {
  count                     = local.collections_rehydration_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "collections_rehydration_terminated"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors cluster terminated by user request"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.collections_rehydration_terminated.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "collections_rehydration_terminated",
      notification_type = "Information",
      severity          = "High"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "collections_rehydration_success" {
  count                     = local.collections_rehydration_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "collections_rehydration_success"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring collections-rehydration completion"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.collections_rehydration_success.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "collections_rehydration_success",
      notification_type = "Information",
      severity          = "Critical"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "collections_rehydration_success_with_errors" {
  count                     = local.collections_rehydration_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "collections_rehydration_success_with_errors"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring collections-rehydration completion with non-critical errors"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.collections_rehydration_success_with_errors.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "collections_rehydration_success_with_errors",
      notification_type = "Warning",
      severity          = "High"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "collections_rehydration_running" {
  count                     = local.collections_rehydration_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "collections_rehydration_running"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring collections-rehydration completion"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.collections_rehydration_running.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "collections_rehydration_running",
      notification_type = "Information",
      severity          = "Critical"
    },
  )
}

# AWS IAM for Cloudwatch event triggers
data "aws_iam_policy_document" "cloudwatch_events_assume_role" {
  statement {
    sid    = "CloudwatchEventsAssumeRolePolicy"
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "allow_batch_job_submission" {
  name               = "DataWorksCollectionsRehydrationAllowBatchJobSubmission"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_events_assume_role.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "allow_batch_job_submission" {
  statement {
    sid    = "AllowBatchJobSubmission"
    effect = "Allow"

    actions = [
      "batch:SubmitJob",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "allow_batch_job_submission" {
  name   = "DataWorksCollectionsRehydrationAllowBatchJobSubmission"
  policy = data.aws_iam_policy_document.allow_batch_job_submission.json
}

resource "aws_iam_role_policy_attachment" "allow_batch_job_submission" {
  role       = aws_iam_role.allow_batch_job_submission.name
  policy_arn = aws_iam_policy.allow_batch_job_submission.arn
}
