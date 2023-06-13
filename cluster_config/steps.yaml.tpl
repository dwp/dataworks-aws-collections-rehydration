---
BootstrapActions:
- Name: "download_scripts"
  ScriptBootstrapAction:
    Path: "s3://${s3_config_bucket}/component/dataworks-aws-collections-rehydration/download_scripts.sh"
- Name: "start_ssm"
  ScriptBootstrapAction:
    Path: "file:/var/ci/start_ssm.sh"
- Name: "metadata"
  ScriptBootstrapAction:
    Path: "file:/var/ci/metadata.sh"
- Name: "config_hcs"
  ScriptBootstrapAction:
    Path: "file:/var/ci/config_hcs.sh"
    Args: [
      "${environment}", 
      "${proxy_http_host}",
      "${proxy_http_port}",
      "${tanium_server_1}",
      "${tanium_server_2}",
      "${tanium_env}",
      "${tanium_port}",
      "${tanium_log_level}",
      "${install_tenable}",
      "${install_trend}",
      "${install_tanium}",
      "${tenantid}",
      "${token}",
      "${policyid}",
      "${tenant}"
    ]
- Name: "emr-setup"
  ScriptBootstrapAction:
    Path: "file:/var/ci/emr-setup.sh"
- Name: "metrics-setup"
  ScriptBootstrapAction:
    Path: "file:/var/ci/metrics-setup.sh"
- Name: "download_sql"
  ScriptBootstrapAction:
    Path: "file:/var/ci/download_sql.sh"
Steps:
- Name: "run-collections-rehydration"
  HadoopJarStep:
    Args:
    - "file:/var/ci/run-collections-rehydration.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "${action_on_failure}"


