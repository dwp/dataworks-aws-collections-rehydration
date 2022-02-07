#!/usr/bin/env bash
set -Eeuo pipefail

(
    # Import the logging functions
    source /opt/emr/logging.sh

    source /var/ci/resume_step.sh

    function log_wrapper_message() {
        log_dataworks_aws_collections_rehydration_message "$${1}" "run-collections-rehydration.sh" "Running as: ,$USER"
    }

    collections_rehydration_LOCATION="${collections_rehydration_scripts_location}" 

    chmod u+x "$collections_rehydration_LOCATION"/scripts/build_collections_rehydration.sh

    S3_PREFIX_FILE=/opt/emr/s3_prefix.txt
    S3_PREFIX=$(cat $S3_PREFIX_FILE)

    PUBLISHED_BUCKET="${published_bucket}"
    TARGET_DB=${target_db}
    SERDE="${serde}"
    RAW_DIR="$PUBLISHED_BUCKET"/"$S3_PREFIX"
    PROCESSES="${collections_rehydration_processes}"

    log_wrapper_message "Set the following. published_bucket: $PUBLISHED_BUCKET, target_db: $TARGET_DB, serde: $SERDE, raw_dir: $RAW_DIR, Retry_script: $RETRY_SCRIPT, processes: $PROCESSES, collections_rehydration_dir: $collections_rehydration_LOCATION"

    log_wrapper_message "Starting collections-rehydration job"

    log_wrapper_message "Finished collections-rehydration job"

) >> /var/log/dataworks-aws-collections-rehydration/run-collections-rehydration.log 2>&1
