# kube-test

Collection of tools to test a kubernetes cluster.

## Content

- *probes* \
This directory contains some probes deployment useful to catch network partitions between pods or at DNS level. \
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

- *loadtest* \
This directory contains yaml and helm charts for various testing tools / scenario
    - fio : provision a PVC, a pod and run fio
    - kube-burner-api-intensive : job file to be run with kube-burner v1.0 and stress test kube-apiserver
    ```
    for i in {1..100}; do kube-burner init -c api-intensive.yml 2>&1 | tee kube-burner-api-intensive_$(date '+%y%m%d')_$(date '+%H%M%S').log ; done
    ```
    Depending on the size of your Kubernetes cluster you should adjust parameters in api-intensive.yml. More specifically, raise the the number of jobIterations of the first job to populate you cluster with more pods and raise the QPS according to the size of the client running kube-burner and capacity of your apiserver.
    - nperf-helm : helm chart to run network bandwith test between pods
    - warp-minio-helm : helm chart to run warp S3 stress test
