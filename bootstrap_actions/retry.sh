#!/usr/bin/bash

source /opt/emr/logging.sh

retry::with_retries() {

    #shellcheck disable=SC2034
    local command=("$@")

    declare -i attempts=0

    #shellcheck disable=SC2288
    until "$${command[@]}"; do

        ((attempts++))

        log_dataworks_aws_collections_rehydration_message "Retryable attempt failed" "retry.sh" "$$" \
                        "command," "$${command[@]}" \
                        "attempts_made,$attempts" \
                        "max_attempts,$(retry::max_attempts)"

        if retry::max_attempts_made "$attempts"; then
            log_dataworks_aws_collections_rehydration_message "Max retries attempted, exiting" "retry.sh" "$$" \
                            "command," "$${command[@]}" \
                            "attempts,$attempts" \
                            "max_attempts,$(retry::max_attempts)"
            return 10
        fi

        sleep "$(retry::delay)"
    done
}

retry::max_attempts_made() {
    local attempts_made="$${1:?}"
    [[ $attempts_made -ge $(retry::max_attempts) ]]
}

retry::max_attempts() {
    if retry::enabled; then
        if [[ -n ${retry_max_attempts} ]]; then
            echo "${retry_max_attempts}"
        else
            echo 5
        fi
    else
        echo 1
    fi
}

retry::delay() {
    if [[ -n ${retry_attempt_delay_seconds} ]]; then
        echo "${retry_attempt_delay_seconds}"
    else
        echo 1
    fi
}

retry::enabled() {
  if [[ -n ${retry_enabled} ]]; then
      [[ ${retry_enabled} == 'true' ]]
  else
      false
  fi
}
