#!/bin/bash
# https://cloud.ibm.com/docs/containers?topic=containers-cluster_dns#dns_cache

mode=enable

if [[ $# -eq 1 ]]; then
    mode=$1
fi

kubectl get nodes -L "ibm-cloud.kubernetes.io/node-local-dns-enabled"

if [[ "$mode" = "disable" ]]; then
    for node in $(kubectl get nodes --no-headers | awk '{ print $1 }') ;do 
        echo $node; kubectl label node $node --overwrite "ibm-cloud.kubernetes.io/node-local-dns-enabled-"
    done
elif [[ "$mode" = "enable" ]]; then
    for node in $(kubectl get nodes --no-headers | awk '{ print $1 }') ;do 
        echo $node; kubectl label node $node --overwrite "ibm-cloud.kubernetes.io/node-local-dns-enabled=true" 
    done
else
    echo "ERROR ! incorrect value for mode : $mode ; should be in [enable,disable]"
fi
