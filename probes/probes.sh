#!/bin/bash

timeout_sec=5
list="netcat-ip-template.yaml netcat-lookup-template.yaml readyserver-template.yaml"
ns_kube=default
mode=install

if [[ $# -eq 1 ]]; then
    mode=$1
fi

kubectx=kubectx
if [[ -z $(which kubectx 2>/dev/null) ]] ; then
    kubectx="kubectl ctx"
fi
cluster=`$kubectx -c | awk -F '/' '{print$1}'`

if [[ "$mode" = "clean" ]]; then
    list="netcat-ip-template.yaml netcat-lookup-template.yaml readyserver-template.yaml"
    ns_kube=default

    for tpl in httpserver-template.yaml ${list}; do
        dep=${tpl%%-template.yaml}-${cluster}.yaml
        kubectl delete -n ${ns_kube} -f $(pwd)/${dep}
        rm -f $dep
    done
    kubectl wait --for=delete pod -l app=httpserver -n ${ns_kube} --timeout=180s
    
elif [[ "$mode" = "install" ]]; then

    # set number of replicas in yaml
    replicas=$(kubectl get nodes -l 'node-role.kubernetes.io/control-plane!=' --no-headers | wc -l)
    for tpl in httpserver-template.yaml ${list}; do
        dep=${tpl%%-template.yaml}-${cluster}.yaml
        sed "s/@@replicas@@/${replicas}/g" ${tpl} > ${dep}
        sed -i "s/@@timeout_sec@@/${timeout_sec}/g" ${dep}
    done

    # be aware httpserver-template.yaml should be first !!!
    kubectl apply -f $(pwd)/httpserver-${cluster}.yaml -n ${ns_kube}
    kubectl wait --for=condition=ready pod -l app=httpserver -n ${ns_kube}

    # set pod IP in netcat-ip deployment
    ips=$(kubectl get pod -o=custom-columns=NAME:.metadata.name,IP:.status.podIP --no-headers -n default | grep myhttpserver | awk '{print $NF}')
    for ip in $ips; do
        sed -i "/^\ \ \ \ @@ip@@/i \ \ \ \ ${ip}" netcat-ip-${cluster}.yaml
    done
    sed -i -e "s/@@ip@@//g" netcat-ip-${cluster}.yaml

    for tpl in ${list}; do
        dep=${tpl%%-template.yaml}-${cluster}.yaml
        kubectl apply -n ${ns_kube} -f $(pwd)/${dep}
    done

    echo ""
    echo "Commands to inspect logs : "
    echo "kubectl logs -n ${ns_kube} -l app=netcat-ipdirect ; kubectl logs -n ${ns_kube} -l app=netcat-lookup"

else
    echo "ERROR ! incorrect value for mode : $mode ; should be in [install,clean]"
fi
