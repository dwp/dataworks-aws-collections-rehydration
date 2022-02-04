#!/bin/bash
(
    # Import the logging functions
    source /opt/emr/logging.sh

    SCRIPT_DIR="${collections_rehydration_scripts_location}" 
    DOWNLOAD_DIR=/opt/emr/downloads

    echo "Creating directories"
    sudo mkdir -p "$DOWNLOAD_DIR"
    sudo mkdir -p "$SCRIPT_DIR"
    sudo chown hadoop:hadoop "$DOWNLOAD_DIR"
    sudo chown hadoop:hadoop "$SCRIPT_DIR"

    function log_wrapper_message() {
        log_dataworks_aws_collections_rehydration_message "$${1}" "download_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "Download & install latest dataworks-collections-rehydration scripts"
    log_wrapper_message "Downloading & install latest dataworks-collections-rehydration scripts"

    VERSION="${version}"
    URL="s3://${s3_artefact_bucket_id}/dataworks-collections-rehydration/dataworks-collections-rehydration-$VERSION.zip"
    "$(which aws)" s3 cp "$URL" "$DOWNLOAD_DIR"

    echo "dataworks-collections_rehydration_VERSION: $VERSION"
    log_wrapper_message "dataworks-collections_rehydration_version: $VERSION"

    echo "SCRIPT_DOWNLOAD_URL: $URL"
    log_wrapper_message "script_download_url: $URL"

    echo "Unzipping location: $SCRIPT_DIR"
    log_wrapper_message "script unzip location: $SCRIPT_DIR"

    echo "$version" > /opt/emr/version
    echo "${dataworks_aws_collections_rehydration_log_level}" > /opt/emr/log_level
    echo "${environment_name}" > /opt/emr/environment

    echo "START_UNZIPPING ......................"
    log_wrapper_message "start unzipping ......................."

    unzip "$DOWNLOAD_DIR"/dataworks-collections-rehydration-"$VERSION".zip -d "$SCRIPT_DIR"  >> /var/log/dataworks-aws-collections-rehydration/download_unzip_sql.log 2>&1

    echo "FINISHED UNZIPPING ......................"
    log_wrapper_message "finished unzipping ......................."

)  >> /var/log/dataworks-aws-collections-rehydration/download_sql.log 2>&1
