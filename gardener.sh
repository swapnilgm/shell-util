#!/bin/bash
# Author: Swapnil Mhamane <swapnilgmhamane@gmail.com>

# Purpose: Bash helper utilties for github.com/gardener
# Usage:
#   source gardener.sh <shoot_name> <garden_namespace>
# Description:
#   This script is collection of commonaly required
#   helper/utility function for writing bash script against gardener.
#
#   It assumes the KUBECONFIG is pointing to garden cluster.
#
###############################################################################

##################################################################
#                         TODO                              #
##################################################################
# Error handling
##################################################################

## import library
source $(dirname $0)/common.sh

##################################################################
#                         CONSTANTS                              #
##################################################################
# Types constants
declare -r TRUE=0
declare -r FALSE=1

## Initialize global variable
declare -i count=0
declare -r PROCESS_SHOOT=$1
declare -r GARDEN_NAMESPACE=${2:-"all"}
declare -r TEMP_BACKUP_DIR="temp-store"
declare -r GARDEN_KUBECONFIG=
declare -r SEED_KUBECONFIG=
declare -r SHOOT_KUBECONFIG=
##################################################################

##################################################################
#                       garden                                   #
##################################################################
# Purpose:
#   Targets the SEED_KUBECONFIG variable to for provdied <seed>.
# Arguments:
#   $1 -> seed name
# Return:
#   SEED_KUBECONFIG = kubeconfig of seed
function target_seed_kubeconfig () {
    local seed=$1

    secretName=$(kubectl get seed $seed -o=jsonpath={.spec.secretRef.name})
    secretNamespace=$(kubectl get seed $seed -o=jsonpath={.spec.secretRef.namespace})
    kubectl -n $secretNamespace get secret $secretName -o=jsonpath={.data.kubeconfig} | base64 -d > $SEED_KUBECONFIG
    SEED_KUBCONFIG=$TEMP_BACKUP_DIR/current_seed.kubeconfig
    arrow "Update seed kubeconfig in $SEED_KUBECONFIG"
}

###############################################################################
# Purpose:
#   Targets the SEED_KUBECONFIG variable to seed associted with shoot.
# Arguments:
#   $1 -> Shoot name
#   $2 -> Shoot namespace
# Return:
#   SEED_KUBECONFIG = kubeconfig of seed associated with shoot
function target_seed_kubeconfig_from_shoot () {
    local shootName=$1
    local namespace=$2

    seed=$(kubectl --kubeconfig=$GARDEN_KUBECONFIG get shoot $shootName -n $namespace -o=jsonpath={.spec.seedName})
    target_seed_kubeconfig $seed
}

###############################################################################

###############################################################################
function process_all_shoots () {
    local shootList
    if [ $GARDEN_NAMESPACE == "all" ]
    then
      shootList=$(kubectl --kubeconfig=$GARDEN_KUBECONFIG get shoots --all-namespaces -o custom-columns=Name:.metadata.name,Namespace:.metadata.namespace )
    else
      shootList=$(kubectl --kubeconfig=$GARDEN_KUBECONFIG get shoots -n $GARDEN_NAMESPACE -o custom-columns=Name:.metadata.name,Namespace:.metadata.namespace )
    fi

    # Start processing list
    while read -r shoot
    do
        local name=$(echo $shoot | awk '{print $1}')
        local namespace=$(echo $shoot | awk '{print $2}')
        if [ $name == "Name" ] && [ $namespace == "Namespace" ]
        then
            #echo "Ignoring first line."
            continue
        else
            separator
            arrow "Processing shoot: $name from namespace: $namespace"
            process_shoot $name $namespace
            count=$((count+1))
        fi
    done <<< "$shootList"
}

###############################################################################
#                   Main code starts here                                     #
###############################################################################
function main () {
header "Main scripts starts here"
arrow "Verifying the kubeconfig: $KUBECONFIG"
kubectl cluster-info
new_line
must_confirm "Apply script for above garden cluster"

must_confirm "Apply script for project namespace: \"$GARDEN_NAMESPACE\""
separator

# Create temporary directory
set -e
local tempDir=$(mktemp -d)
set +e

if [ -z $PROCESS_SHOOT ] || [ $PROCESS_SHOOT == "all" ]
then
    must_confirm "Apply script for shoot: \"all\""
    process_all_shoots
else
    must_confirm "Apply script for shoot: \"$PROCESS_SHOOT\""
    process_shoot $PROCESS_SHOOT $GARDEN_NAMESPACE
fi

banner "Total processed Shoots: $count"

rm -rf $TEMP_BACKUP_DIR
}