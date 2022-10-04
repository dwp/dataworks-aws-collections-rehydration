output "dataworks_aws_collections_rehydration_common_sg" {
  value = {
    id = aws_security_group.dataworks_aws_collections_rehydration_common.id
  }
}

output "dataworks_aws_collections_rehydration_emr_launcher_lambda" {
  value = aws_lambda_function.dataworks_aws_collections_rehydration_emr_launcher
}

output "private_dns" {
  value = {
    collections_rehydration_service_discovery_dns = aws_service_discovery_private_dns_namespace.collections_rehydration_services
    collections_rehydration_service_discovery     = aws_service_discovery_service.collections_rehydration_services
  }
  sensitive = true
}
