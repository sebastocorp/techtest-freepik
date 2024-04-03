#!/usr/bin/env bash

########################################################################################################################
### LOCAL VARS DEFINITION ###
########################################################################################################################


########################################################################################################################
### SCRIPT FUNCTIONS DEFINITION ###
########################################################################################################################

function k8s_utils_source_wait_to_namespace_pods_be_ready() {
    echo -e "======================== waiting process ========================"
    local namespace=$1
    local pods_count=$2
    local pod_list

    echo -e "[INFO] namespace: ${namespace}"
    echo -e "[INFO] number of pods in namespace: ${pods_count}"

    pod_list=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" --namespace "${namespace}" | xargs)
    while [ "$(echo "$pod_list" | wc -w)" -lt "${pods_count}" ]; do
        pod_list=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" --namespace "${namespace}" | xargs)
        echo -e "[INFO] waiting to pods count..."
        sleep 10
    done

    echo -e "[INFO] pod list: ${pod_list}"
    
    local is_ready=0
    while [ $is_ready -eq 0 ]; do
        is_ready=1
        for value in $pod_list; do
            if [[ $(kubectl get pods "${value}" --namespace "${namespace}" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; then
                is_ready=0
            fi
        done

        echo -e "[INFO] waiting to pods be ready..."
        sleep 10
    done
}