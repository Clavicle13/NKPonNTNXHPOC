#!/usr/bin/bash +x
######################################################################################
#
# Date			Changes
# -------		------------
# 22nd June 2025	Creation
#
#
######################################################################################

export NUTANIX_USER='admin'
export NUTANIX_PASSWORD='nx2Tech814!'
export NUTANIX_PORT=9440

/home/rocky/nkp-v2.15.0/cli/nkp create cluster nutanix --cluster-name=demoworkload1 \
        --airgapped \
        --insecure \
	--namespace='myworkspace-8cf8w-spjfw' \
        --endpoint=https://10.55.39.7:9440 \
        --control-plane-replicas=3 \
        --control-plane-endpoint-ip=10.55.39.140 \
        --control-plane-vm-image=nkp-rocky-9.5-release-1.32.3-20250430150550 \
        --control-plane-prism-element-cluster="DM3-POC039" \
        --control-plane-subnets="aux-1" \
        --kubernetes-service-load-balancer-ip-range=10.55.39.141-10.55.39.145 \
        --control-plane-pc-project=stevensim \
        --control-plane-pc-categories='environment=development,nodetype=controlplane,clustertype=workload' \
        --control-plane-vcpus=4 \
        --control-plane-memory=16 \
        --worker-replicas=3 \
        --worker-vm-image=nkp-rocky-9.5-release-1.32.3-20250430150550 \
        --worker-prism-element-cluster=DM3-POC039 \
        --worker-subnets="aux-1" \
        --worker-pc-project=stevensim \
        --worker-pc-categories='environment=development,nodetype=worker,clustertype=workload' \
        --worker-vcpus=8 \
        --worker-memory=32 \
        --csi-storage-container="nkp" \
        --ssh-username=konvoy \
        --ssh-public-key-file=/home/rocky/.ssh/id_rsa.pub \
        --registry-url=http://10.55.39.9:5000 \
        --registry-username=dummy \
        --registry-password=dummy \
        --extra-sans 10.55.39.7 \
        --verbose=5

#        --dry-run \
#        --output=yaml 

