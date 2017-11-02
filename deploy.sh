#!/usr/bin/env bash
export WHITELIST=${WHITELIST:-0.0.0.0/0}

if [ $ENVIRONMENT == "prod" ]
then
    export KUBE_TOKEN=${PROD_KUBE_TOKEN}
    export DNS_PREFIX=
else
    export DNS_PREFIX=${ENVIRONMENT}.notprod.
fi

cd kd
kd --insecure-skip-tls-verify --timeout 5m0s \
   --file ingress.yaml \
   --file service.yaml \
   --file deployment.yaml
