#!/usr/bin/env bash

SELF_NAME=$(basename "$0")
SELF_PATH=$(pwd)

########################################################################################################################
### SCRIPT VARIABLES DEFINITION ###
########################################################################################################################

########################################################################################################################
### SCRIPT FUNCTIONS DEFINITION ###
########################################################################################################################
# Functions oriented to the script
function usage() {
    echo -e "\nusage:"
    echo -e "  ${SELF_NAME} [-c] [-t] [-o] [flags]"
    echo -e "dependencies:"
    echo -e "  - terraform"
    echo -e "  - doctl"
    echo -e "  - jq"
    echo -e "environment: (none)"
    echo -e "flags:"
    echo -e "  -c: chdir flag to get the tf code directory"
    echo -e "  -t: tfvars flag to get the name of the tfvars"
    echo -e "  -o: operation flag execute terraform command {plan, apply, destroy}"
    echo -e "  -h: help flag to show the help\n"
}

function exec_operation() {
    echo -e "\n================================ exec_operation ================================\n"
    local STATUS_CODE=0

    if [ "${TF_MANAGE_OPTION}" != "plan" ] &&
       [ "${TF_MANAGE_OPTION}" != "apply" ] &&
       [ "${TF_MANAGE_OPTION}" != "destroy" ]; then
        echo -e "[x] STEP: 'check operation' FAIL"
        return 1
    fi
    echo -e "[ok] STEP: 'check operation' PASS"

    terraform -chdir="${TF_MANAGE_CHDIR}" init
    STATUS_CODE=$?
    if [ "${STATUS_CODE}" -ne 0 ]; then
        echo -e "[x] STEP: 'perform terraform init' FAIL"
        return "${STATUS_CODE}"
    fi
    echo -e "[ok] STEP: 'perform terraform init' PASS"
    
    terraform -chdir="${TF_MANAGE_CHDIR}" "${TF_MANAGE_OPTION}" -var-file="../tfvars/${TF_MANAGE_TFVARS}"
    STATUS_CODE=$?
    if [ "${STATUS_CODE}" -ne 0 ]; then
        echo -e "[x] STEP: 'perform terraform operation' FAIL"
        return "${STATUS_CODE}"
    fi
    echo -e "[ok] STEP: 'perform terraform operation' PASS"

    return 0
}

function save_tfstate() {
    echo -e "\n================================ save_tfstate ================================\n"
    local STATUS_CODE=0
    # TODO: save the tfstate
    return 0
}

function set_kubeconfig() {
    echo -e "\n================================ set_kubeconfig ================================\n"
    local STATUS_CODE=0

    mv "${HOME}/.kube/config" "${HOME}/.kube/config.bak"
    STATUS_CODE=$?
    if [ "${STATUS_CODE}" -ne 0 ]; then
        echo -e "[x] STEP: 'save old kubeconfig' FAIL"
        return "${STATUS_CODE}"
    fi
    echo -e "[ok] STEP: 'save old kubeconfig' PASS"

    terraform -chdir="${TF_MANAGE_CHDIR}" output --raw k8s_kubeconfig > $HOME/.kube/config
    STATUS_CODE=$?
    if [ "${STATUS_CODE}" -ne 0 ]; then
        echo -e "[x] STEP: 'create new kubeconfig' FAIL"
        return "${STATUS_CODE}"
    fi
    echo -e "[ok] STEP: 'create new kubeconfig' PASS"

    return 0
}

function main() {
    local STATUS_CODE=0

    exec_operation
    STATUS_CODE=$?
    if [ "${STATUS_CODE}" -ne 0 ]; then
        return "${STATUS_CODE}"
    fi

    if [ "${TF_MANAGE_OPTION}" == "apply" ] || [ "${TF_MANAGE_OPTION}" == "destroy" ]; then
        save_tfstate
        STATUS_CODE=$?
        if [ "${STATUS_CODE}" -ne 0 ]; then
            return "${STATUS_CODE}"
        fi
    fi

    
    if [ "${TF_MANAGE_OPTION}" == "apply" ]; then
        set_kubeconfig
        STATUS_CODE=$?
        if [ "${STATUS_CODE}" -ne 0 ]; then
            return "${STATUS_CODE}"
        fi
    fi

    return 0
}

########################################################################################################################
### SCRIPT EXECUTION ###
########################################################################################################################
while getopts hc:t:o: option; do
    case "${option}" in
    c) TF_MANAGE_CHDIR="${SELF_PATH}/${OPTARG}";;
    t) TF_MANAGE_TFVARS="${OPTARG}";;
    o) TF_MANAGE_OPTION="${OPTARG}";;
    h) usage; exit 0;;
    *) usage; exit 1;;
    esac
done

main
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo -e "[x] SCRIPT: '${SELF_NAME}' FAIL"
    usage
    exit $EXIT_CODE
fi
echo -e "[ok] SCRIPT: '${SELF_NAME}' PASS"
exit 0
