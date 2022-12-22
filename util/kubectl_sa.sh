#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "2 inputs are needed : "
    echo "name of serviceaccount"
    echo "namespace"
    exit 9
fi

sa=$1
ns=$2

cluster=satest-cluster
ctx=satest-context
endpoint=`grep -B 1 "name: $(kubectx -c)" ~/.kube/config | grep server | awk '{print $NF}'`
# kubectx $ctx=$(kubectx -c)

kubectl config delete-context ${ctx}
kubectl config delete-cluster ${cluster}

tokenname=`kubectl -n ${ns} get serviceaccount/${sa} -o jsonpath='{.secrets[0].name}'`
token=`kubectl -n ${ns} get secret ${tokenname} -o jsonpath='{.data.token}'| base64 --decode`
cacrt=`kubectl -n ${ns} get secret ${tokenname} -o jsonpath='{.data.ca\.crt}' | base64 --decode`
kubectl config set-cluster ${cluster} --server=${endpoint}
kubectl config set-credentials ${sa} --token=$token
kubectl config set-context ${ctx} --user=${sa} --cluster=${cluster}
kubectl config set-cluster ${cluster} --embed-certs --certificate-authority <(echo ${cacrt})
# kubectl config use-context ${ctx}
kubectx ${ctx}
