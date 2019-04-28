#!/bin/bash

cd $(dirname $0)

echo Tune shell options && {
    set -o errexit
    set -o nounset
    set -o xtrace
}

: Define Variables && {
    readonly PROJECT="${1:?}"
    readonly CLUSTER="${2:?}"
    readonly REGION="${3:?}"
    readonly NAMESPACE="${4:?}"

    readonly PROMETHEUS_CHART_VERSION=8.8.0
}

: Set target project/cluser and tiller && {
    gcloud config set project "${PROJECT}"
    gcloud container clusters get-credentials ${CLUSTER} --region "${REGION}"
    kubectl config set-context $(kubectl config current-context) --namespace="${NAMESPACE}"
    helm init --client-only
}

: Deploy Prometheus using Helm && {
    helm upgrade --install \
        --namespace="${NAMESPACE}" \
        --version="${PROMETHEUS_CHART_VERSION}" \
        -f="values.yaml" \
        "prometheus" \
        stable/prometheus
}
