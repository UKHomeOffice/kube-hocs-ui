#!/bin/bash

export KUBE_NAMESPACE=${KUBE_NAMESPACE}
export KUBE_SERVER=${KUBE_SERVER}

if [[ -z ${VERSION} ]] ; then
    export VERSION=${IMAGE_VERSION}
fi

export IP_WHITELIST=${POISE_WHITELIST}

if [[ ${ENVIRONMENT} == "prod" ]] ; then
    echo "deploy ${VERSION} to prod namespace, using HOCS_UI_PROD drone secret"
    export KUBE_TOKEN=${HOCS_UI_PROD}
    export REPLICAS="2"
    export DNS_PREFIX=alf.alf.
    export CA_URL="https://raw.githubusercontent.com/UKHomeOffice/acp-ca/master/acp-prod.crt"
else
    export DNS_PREFIX=${ENVIRONMENT}.alf-notprod.
    export CA_URL="https://raw.githubusercontent.com/UKHomeOffice/acp-ca/master/acp-notprod.crt"
    if [[ ${ENVIRONMENT} == "qa" ]] ; then
        echo "deploy ${VERSION} to test namespace, using HOCS_UI_QA drone secret"
        export KUBE_TOKEN=${HOCS_UI_QA}
        export REPLICAS="2"
    else
        echo "deploy ${VERSION} to dev namespace, HOCS_UI_DEV drone secret"
        export KUBE_TOKEN=${HOCS_UI_DEV}
        export REPLICAS="1"
    fi
fi

export DOMAIN_NAME=${DNS_PREFIX}homeoffice.gov.uk

if [[ -z ${KUBE_TOKEN} ]] ; then
    echo "[error] Failed to find a value for KUBE_TOKEN - exiting"
    exit -1
elif [ ${#KUBE_TOKEN} -ne 36 ] ; then
    echo "[error] Kubernetes token wrong length (expected 36, got ${#KUBE_TOKEN})"
    exit 78
fi

cd kd || exit 1

kd --insecure-skip-tls-verify \
   --timeout 10m \
   -f ingress.yaml \
   -f service.yaml \
   -f deployment.yaml
