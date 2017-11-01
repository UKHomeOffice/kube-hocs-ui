#!/usr/bin/env bash

if [ $ENVIRONMENT == "prod" ]
then
    export KUBE_TOKEN=${PROD_KUBE_TOKEN}
fi

env
cd kd
kd --insecure-skip-tls-verify --timeout 5m0s \
   --file service.yaml \
   --file deployment.yaml