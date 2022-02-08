#!/usr/bin/env bash
set -Eeuo pipefail

(

    # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_dataworks_aws_collections_rehydration_message "$${1}" "create-collections-rehydration-databases.sh" "Running as: ,$USER"
    }


    CORRELATION_ID="$2"
    S3_PREFIX="$4"
    SNAPSHOT_TYPE="$6"
    EXPORT_DATE="$8"
    
    echo "$CORRELATION_ID" >>     /opt/emr/correlation_id.txt
    echo "$S3_PREFIX" >>          /opt/emr/s3_prefix.txt
    echo "$SNAPSHOT_TYPE" >>      /opt/emr/snapshot_type.txt
    echo "$EXPORT_DATE" >>        /opt/emr/export_date.txt

) >> /var/log/dataworks-aws-collections-rehydration/create-collections-rehydration-databases.log 2>&1
