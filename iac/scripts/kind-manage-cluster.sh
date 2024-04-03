#!/usr/bin/env bash

SELF_PATH=$(cd "$(dirname "$0")" || return; pwd)
SELF_NAME="manage-cluster.sh"

########################################################################################################################
### LOAD BASH SOURCES ###
########################################################################################################################
# shellcheck source=/dev/null
source "${SELF_PATH}/k8s-utils-source.sh"

########################################################################################################################
### LOCAL VARS DEFINITION ###
########################################################################################################################
KIND_FOLDER_PATH="${SELF_PATH}/../kind"
KIND_CLUSTER_CONFIG="${KIND_FOLDER_PATH}/freepik-cluster-config.yaml"
KIND_CLUSTER_NAME=$(grep -m 1 'name:' "${KIND_CLUSTER_CONFIG}" | sed 's/name://g' | xargs)

########################################################################################################################
### SCRIPT FUNCTIONS DEFINITION ###
########################################################################################################################
function usage() {
    echo -e "Usage:"
    echo -e "  ${SELF_PATH}/${SELF_NAME} -o <option> [flags]"
    echo -e "Dependencies:"
    echo -e "  - kubectl"
    echo -e "  - docker"
    echo -e "  - kind"
    echo -e "Flags:"
    echo -e "  -o: flag option to 'create' or 'delete' the cluster (values: [create|delete])"
    echo -e "  -d: add this flag to install default k8s dashboard"
    echo -e "  -h: show help\n"
}

function create_cluster() {
    echo -e "\n\n======================== Create cluster ========================\n"
    EXIT_CODE=0

    kind create cluster --config "${KIND_CLUSTER_CONFIG}"

    return 0
}

function delete_cluster() {
    echo -e "\n\n======================== Delete cluster ========================\n"
    local EXIT_CODE=0

    kind delete cluster --name "${KIND_CLUSTER_NAME}"

    return 0
}

function install_kind_cluster_dependencies() {
    echo -e "\n\n======================== Install kind k8s cluster dependencies ========================\n"
    local EXIT_CODE=0

    ## Apply custom priorityClass
    kubectl apply -k "${KIND_FOLDER_PATH}/crs/priorityClass"

    ## Install metalLB
    kubectl apply -k "${KIND_FOLDER_PATH}/extensions/metallb"
    
    k8s_utils_source_wait_to_namespace_pods_be_ready "metallb-system" 3

    local kind_docker_cidr
    kind_docker_cidr=$(docker network inspect --format '{{json .IPAM.Config}}' kind | jq -r .[0].Subnet)

    local max_adress
    local min_adress
    max_adress="${kind_docker_cidr//.0.0\/16/.255.250}"
    min_adress="${kind_docker_cidr//.0.0\/16/.255.200}"
    
    kubectl apply -f - << EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - ${min_adress}-${max_adress}
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2advertisement01
  namespace: metallb-system
EOF

    # Install ingress NGINX
    kubectl apply -k "${KIND_FOLDER_PATH}/extensions/ingress-nginx"
    
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s

    return 0
}

function install_k8s_default_dashboard() {
    echo -e "\n\n======================== Install kind k8s cluster dependencies ========================\n"
    local EXIT_CODE=0

    ## Install kubernetes default dashboard

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

    kubectl create serviceaccount -n kubernetes-dashboard admin-user

    kubectl create clusterrolebinding -n kubernetes-dashboard admin-user --clusterrole cluster-admin --serviceaccount=kubernetes-dashboard:admin-user

    ## Generate token to the kubernetes dashboard
    
    local token
    token=$(kubectl -n kubernetes-dashboard create token admin-user)

    echo -e "Your token:"
    echo -e "${token}"

    echo -e "to service the dashboard run:"
    echo -e "kubectl proxy\n"

    echo -e "to see the dashboard go to:"
    echo -e "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"

    return 0
}

function main() {
    if [ "${SCRIPT_FLAG_OPERATION}" == "delete" ]; then
        delete_cluster
        EXIT_CODE=$?
        if [ $EXIT_CODE -ne 0 ]; then
            return $EXIT_CODE
        fi
        return 0
    fi

    if [ "${SCRIPT_FLAG_OPERATION}" == "create" ]; then
        create_cluster
        EXIT_CODE=$?
        if [ $EXIT_CODE -ne 0 ]; then
            return $EXIT_CODE
        fi

        install_kind_cluster_dependencies
        EXIT_CODE=$?
        if [ $EXIT_CODE -ne 0 ]; then
            return $EXIT_CODE
        fi
    fi

    if [ "${SCRIPT_FLAG_INSTALL_K8S_DASHBOARD}" == "true" ]; then
        install_k8s_default_dashboard
        EXIT_CODE=$?
        if [ $EXIT_CODE -ne 0 ]; then
            return $EXIT_CODE
        fi
    fi

    return 0
}

########################################################################################################################
### SCRIPT FUNCTIONS EXECUTION ###
########################################################################################################################

#### SCRIPT INITIAL CHECKS ####
while getopts ho:d option; do
    case "${option}" in
    o) SCRIPT_FLAG_OPERATION=${OPTARG};;
    d) SCRIPT_FLAG_INSTALL_K8S_DASHBOARD="true";;
    h) usage; exit 0;;
    *) usage; exit 1;;
    esac
done
if [ -z "${SCRIPT_FLAG_OPERATION}" ] || 
   [[ "${SCRIPT_FLAG_OPERATION}" != "create" && "${SCRIPT_FLAG_OPERATION}" != "delete" ]]; then
    usage
    echo -e "[x] option flag (-o) is mandatory"
    exit 1
fi

main
STATUS_CODE=$?
if [ $STATUS_CODE -ne 0 ]; then
    exit 1
fi

exit 0