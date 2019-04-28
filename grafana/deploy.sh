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

    # set secret env
    # readonly ADMIN_USER="${5:?}"
    # readonly ADMIN_PASSWORD="${6:?}"
    # readonly AUTH_GITHUB_CLIENT_ID="${7:?}"
    # readonly AUTH_GITHUB_CLIENT_SECRET="${8:?}"
    # readonly AUTH_GOOGLE_CLIENT_ID="${9:?}"
    # readonly AUTH_GOOGLE_CLIENT_SECRET="${10:?}"
    readonly GRAFANA_CHART_VERSION=2.2.1
}

: Set target project/cluser and tiller && {
    gcloud config set project "${PROJECT}"
    gcloud container clusters get-credentials ${CLUSTER} --region "${REGION}"
    kubectl config set-context $(kubectl config current-context) --namespace="${NAMESPACE}"
    helm init --client-only
}

: Create Secrets && {
    sigil -p -f secrets.yaml \
        NAMESPACE="${NAMESPACE}" \
        ADMIN_USER="$(echo ${ADMIN_USER} | base64 -w0)" \
        ADMIN_PASSWORD="$(echo ${ADMIN_PASSWORD} | base64 -w0)" \
    | kubectl apply -f - --record
}

: Deploy Grafana using Helm && {
    sigil -p -f grafana_values.yaml \
        DOMAIN_URL="${DOMAIN_URL}" \
        AUTH_GITHUB_CLIENT_ID="${AUTH_GITHUB_CLIENT_ID}" \
        AUTH_GITHUB_CLIENT_SECRET="${AUTH_GITHUB_CLIENT_SECRET}" \
        AUTH_GOOGLE_CLIENT_ID="${AUTH_GOOGLE_CLIENT_ID}" \
        AUTH_GOOGLE_CLIENT_SECRET="${AUTH_GOOGLE_CLIENT_SECRET}" \
        SECRET_CHECKSUM=$(echo \
            ${ADMIN_USER} \
            ${ADMIN_PASSWORD} \
            ${AUTH_GITHUB_CLIENT_ID} \
            ${AUTH_GITHUB_CLIENT_SECRET} \
            ${AUTH_GOOGLE_CLIENT_ID} \
            ${AUTH_GOOGLE_CLIENT_SECRET} \
        | sha256sum) \
    | helm upgrade --install \
        --namespace="${NAMESPACE}" \
        --version="${GRAFANA_CHART_VERSION}" \
        --values=- \
        "grafana" \
        stable/grafana
}
