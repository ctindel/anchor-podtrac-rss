#!/bin/bash

verbose=true

# These variables must be set external to this script
declare -a USER_REQUIRED_EXT_ENV_VARS=(
    "AWS_S3_RSS_URL"
    "ANCHOR_RSS_FEED_URL"
)

function cleanup() {
    echo "Invoking cleanup, please wait..."
}

function ctrl_c_handler() {
    cleanup
    exit 1
}

function debug_print() {
    if [ "$verbose" = true ] ; then
        echo $1
    fi
}

function debug_print_ne() {
    if [ "$verbose" = true ] ; then
        echo -ne $1
    fi
}

function err_exit_usage() {
    echo $1
    exit 1
}

function check_run_cmd() {
    cmd=$1
    local error_str="ERROR: Failed to run \"$cmd\""
    if [[ $# -gt 1 ]]; then
        error_str=$2
    fi
    debug_print "About to run: $cmd"
    eval $cmd
    rc=$?; if [[ $rc != 0 ]]; then echo "$error_str"; cleanup; exit $rc; fi
}

run_cmd() {
    cmd=$1
    debug_print "About to run: $cmd"
    eval "$cmd"
    rc=$?
    return $rc
}

retry_run_cmd() {
    cmd=$1
    rc=0

    n=0
    until [ $n -ge $RETRY_COUNT ]
    do
        if [ "$verbose" = true ] ; then
            echo "Invocation $n of $cmd"
        fi
        eval "$cmd"
        rc=$?
        if [[ $rc == 0 ]]; then break; fi
        n=$[$n+1]
        sleep 1
    done
    if [[ $rc != 0 ]]; then cleanup_and_fail; fi
    return $rc
}

# http://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
function trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

function validate_aws_cli() {
    check_run_cmd "aws s3 ls > /dev/null 2>&1" "ERROR: You need to install the awscli, more information here: http://docs.aws.amazon.com/cli/latest/userguide/installing.html"
}

function validate_xsltproc_binary_exists() {
    check_run_cmd "xsltproc --profile > /dev/null" "ERROR: You need to install the xsltproc binary"
}

# http://stackoverflow.com/questions/9714902/how-to-use-a-variables-value-as-other-variables-name-in-bash
function validate_user_required_external_environment() {
    for var in "${USER_REQUIRED_EXT_ENV_VARS[@]}"
    do
        # http://stackoverflow.com/questions/307503/whats-a-concise-way-to-check-that-environment-variables-are-set-in-unix-shellsc
        # combined with this for the !var notation:
        # http://stackoverflow.com/a/11065196/4672086
        : ${!var?\"$var is a required external environment variable, set these in your bash .profile\"}
        trimmed_var=$(trim ${!var})
        eval $var=\$trimmed_var
    done

    validate_aws_cli
}

function process_anchor_rss_feed() {
    local tmp_old_rss="/tmp/anchor_rss.xml"
    local tmp_new_rss="/tmp/anchor_podtrac_rss.xml"

    check_run_cmd "curl -o $tmp_old_rss ${ANCHOR_RSS_FEED_URL}"
    check_run_cmd "xsltproc transform.xsl $tmp_old_rss > $tmp_new_rss"
    check_run_cmd "aws s3 cp $tmp_new_rss ${AWS_S3_RSS_URL} --acl public-read"
    # Need to remember to escape the asterisk in the path 
    #  https://kylewbanks.com/blog/invalidate-entire-cloudfront-distribution-from-command-line
    if [[ -n "${CF_DISTRIBUTION_ID}" ]]; then
        check_run_cmd "aws cloudfront create-invalidation --distribution-id ${CF_DISTRIBUTION_ID} --paths "/\\*.xml" "
    fi
}

function upload_to_s3() {
    check_run_cmd "aws s3 cp "
}

trap ctrl_c_handler INT
validate_user_required_external_environment
process_anchor_rss_feed
