#!/bin/bash

VM_NAME=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")
ZONE=$(gcloud compute instances list --filter="name=${VM_NAME}" --format="value(zone)")
TOKEN=$(gcloud compute instances describe ${VM_NAME} --zone=${ZONE} --format="value(metadata.token)")
REPO_URL=$(gcloud compute instances describe ${VM_NAME} --zone=${ZONE} --format="value(metadata.repo_url)")
LABELS=$(cat /home/runner/runner_labels)

cd /home/runner/actions-runner && \
./config.sh --url ${REPO_URL} \
            --token ${TOKEN} \
            --ephemeral \
            --unattended \
            --name ${VM_NAME} \
            --disableupdate \
            --labels ${LABELS} \
            && \
./run.sh
