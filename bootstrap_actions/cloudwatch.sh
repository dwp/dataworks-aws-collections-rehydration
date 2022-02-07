#!/bin/bash

set -Eeuo pipefail

cwa_metrics_collection_interval="$1"
cwa_namespace="$2"
cwa_log_group_name="$3"
cwa_bootstrap_loggrp_name="$5"
cwa_steps_loggrp_name="$6"
cwa_tests_loggrp_name="$7"


export AWS_DEFAULT_REGION="$${4}"

# Create config file required for CloudWatch Agent
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<CWAGENTCONFIG
{
  "agent": {
    "metrics_collection_interval": $${cwa_metrics_collection_interval},
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log",
            "log_group_name": "$${cwa_log_group_name}",
            "log_stream_name": "{instance_id}-amazon-cloudwatch-agent.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/messages",
            "log_group_name": "$${cwa_log_group_name}",
            "log_stream_name": "{instance_id}-messages",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/secure",
            "log_group_name": "$${cwa_log_group_name}",
            "log_stream_name": "{instance_id}-secure",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "$${cwa_log_group_name}",
            "log_stream_name": "{instance_id}-cloud-init-output.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/dataworks-aws-collections-rehydration/acm-cert-retriever.log",
            "log_group_name": "$${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-acm-cert-retriever.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/dataworks-aws-collections-rehydration/emr-setup.log",
            "log_group_name": "$${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-emr-setup.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/dataworks-aws-collections-rehydration/update_dynamo_sh.log",
            "log_group_name": "$${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-update_dynamo_sh.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/dataworks-aws-collections-rehydration/download_scripts.log",
            "log_group_name": "$${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-download-scripts.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/dataworks-aws-collections-rehydration/status_metrics.log",
            "log_group_name": "$${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-status-metrics.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/dataworks-aws-collections-rehydration/metrics-setup.log",
            "log_group_name": "$${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-metrics-setup.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/dataworks-aws-collections-rehydration/e2e.log",
            "log_group_name": "$${cwa_tests_loggrp_name}",
            "log_stream_name": "{instance_id}-e2e.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/dataworks-aws-collections-rehydration/run-collections-rehydration.log",
            "log_group_name": "$${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-run-collections-rehydration.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/dataworks-aws-collections-rehydration/create-collections-rehydration-databases.log",
            "log_group_name": "$${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-create-collections-rehydration-databases.log",
            "timezone": "UTC"
          }
        ]
      }
    },
    "log_stream_name": "$${cwa_namespace}",
    "force_flush_interval" : 15
  }
}
CWAGENTCONFIG

%{ if emr_release == "5.29.0" ~}
# Download and install CloudWatch Agent
curl https://s3.$${AWS_DEFAULT_REGION}.amazonaws.com/amazoncloudwatch-agent-$${AWS_DEFAULT_REGION}/centos/amd64/latest/amazon-cloudwatch-agent.rpm -O
rpm -U ./amazon-cloudwatch-agent.rpm
# To maintain CIS compliance
usermod -s /sbin/nologin cwagent

start amazon-cloudwatch-agent
%{ else ~}
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
systemctl start amazon-cloudwatch-agent
%{ endif ~}
