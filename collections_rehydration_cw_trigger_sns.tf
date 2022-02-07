resource "aws_sns_topic" "collections_rehydration_cw_trigger_sns" {
  name = "collections_rehydration_cw_trigger_sns"

  tags = merge(
    local.common_tags,
    {
      "Name" = "collections_rehydration_cw_trigger_sns"
    },
  )
}

output "collections_rehydration_cw_trigger_sns_topic" {
  value = aws_sns_topic.collections_rehydration_cw_trigger_sns
}
