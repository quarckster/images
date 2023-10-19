#!/bin/sh

set -ex

HOME="/home/runner/"
BASE_URL="http://metadata.google.internal/computeMetadata/v1/instance/"
VM_NAME=$(curl -s "${BASE_URL}/name" -H "Metadata-Flavor: Google")
TOKEN=$(curl -s "${BASE_URL}/attributes/token" -H "Metadata-Flavor: Google")
REPO_URL=$(curl -s "${BASE_URL}/attributes/repo_url" -H "Metadata-Flavor: Google")
LABELS=$(cat ${HOME}/runner_labels)

cd ${HOME}/actions-runner && \
./config.sh --url ${REPO_URL} \
            --token ${TOKEN} \
            --ephemeral \
            --unattended \
            --name ${VM_NAME} \
            --disableupdate \
            --labels ${LABELS} \
            && \
./run.sh
