# kube-test

Collection of tools to test a kubernetes cluster.

## Content

### Probes

The *probes* directory contains some probes deployment useful to catch network partitions between pods or at DNS level. \
To install, run:
```
cd probes
./probes.sh install
```
To remove, run:
```
cd probes
./probes.sh clean
```
The settings of these probes uses a default timeout of 5s that can be adapted by editing the variable `timeout_sec=5` in probes.sh.

Server pods : 
- *myhttpserver* pods listening on 9000
    uses a kubernetes liveness probe (timeout=1s period=10s #failure=3)
    timeout does not depends on `timeout_sec` variable.
- *myreadyserver* pods listening on 9000
    uses regular kubernetes liveness probes with settings : timemout=`timeout_sec` & failure=1
    restarts of these pods should be monitored

Client pods :
- *netcat-ipdirect* 
    client connection every `timeout_sec` to all myhttpserver pods using pods IP and timeout=`timeout_sec`
    logs *ERROR netcat ipdirect* in case of error
- *netcat-lookup*
    client connection every `timeout_sec` to all myhttpserver pods using headless service and timeout=`timeout_sec`
    logs *ERROR netcat lookup* in case of error

In order to avoid spurious ERROR due to update of the myhttpserver setup it is recommended to perform updates of the configuration usinge clean and then install procedure. 

### util

The *util* directory contains tooling. \
For example, the script `util/node_local_dns.sh` can be used to enable/disable node local DNS on an IBM IKS cluster

### load tests

The *loadtest* directory contains yaml and helm charts for various testing tools / scenario

- fio : provision a PVC, a pod and run fio
- kube-burner-api-intensive : job file to be run with kube-burner v1.0 and stress test kube-apiserver
    ```
    for i in {1..100}; do
        kube-burner init -c api-intensive.yml 2>&1 | tee kube-burner-api-intensive_$(date '+%y%m%d')_$(date '+%H%M%S').log
    done
    ```
    Depending on the size of your Kubernetes cluster you should adjust parameters in api-intensive.yml. More specifically, raise the the number of jobIterations of the first job to populate you cluster with more pods and raise the QPS according to the size of the client running kube-burner and capacity of your apiserver. 
- nperf-helm : helm chart to run network bandwith test between pods
- warp-minio-helm : helm chart to run warp S3 stress test
