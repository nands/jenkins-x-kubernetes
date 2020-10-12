#!/bin/bash
set -e

service_name=${1:-'null'}

function upgrade_skaffold() {
    curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/v1.15.0/skaffold-linux-amd64
    echo "Upgraded skaffold"
    chmod +x skaffold
    mv skaffold /usr/local/bin
    skaffold version
}

function ok_to_build_service() {
    #$PULL_BASE_SHA
    changed_folders=`git diff --name-only $PULL_BASE_SHA..HEAD | grep jux-microservices/ | awk 'BEGIN {FS="/"} {print $2}' | uniq`
    echo "$changed_folders"
}

function run_skaffold() {
    result=$(ok_to_build_service)
    services=""
    if [ ! -z "$result" ]; then
        echo $result | while read line; do
            for service in $line; do
                services+="$service,"
            done
            skaffold build -f skaffold.yaml --build-image=[$(echo ${services%$})] --cache-artifacts=false
        done
    fi
}

upgrade_skaffold
run_skaffold
