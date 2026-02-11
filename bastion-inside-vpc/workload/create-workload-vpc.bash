#!/usr/bin/bash +x
######################################################################################
#
# Date			Changes
# -------		------------
# 22nd June 2025	Creation
# 23rd Nov 2025	Updated to v2.16.1
#
######################################################################################

######################################################################################

if [[ -z "$(echo ${VPC} |grep '^vpc[1-9]$')" ]]; then
        echo "Mandatory VPC parameter missing"
        exit 5
fi

CONFIG_FILE="${HOME}/scripts/bastion-inside-vpc/workload/${VPC}/nkp-workload-${VPC}.conf"

if [[ ! -f "${CONFIG_FILE}" ]]; then
        echo "Unable to locate default configuration file ${CONFIG_FILE}" >&2
        exit 3
fi

######################################################################################

echo "Using ${CONFIG_FILE} ..."
source ${CONFIG_FILE}

######################################################################################

if [[ "${DRYRUN}" == "TRUE" ]]; then

        echo "Executing Dry Run with parameters"
        echo "vpc=${VPC}"
        echo "NKPCLUSTER_NAME=${NKPCLUSTER_NAME}"
        echo "NKPAPISERVER_VIP=${NKPAPISERVER_VIP}"
        echo "FloatingIP_APIServer=${FloatingIP_APIServer}"
        echo "LOAD_BALANCER_IP_RANGE=${LOAD_BALANCER_IP_RANGE}"
        echo "VPC_CONTROLPLANE_SUBNET=${VPC_CONTROLPLANE_SUBNET}"
        echo "PC_PROJECT = ${PC_PROJECT}"
        echo "HPOC_CLUSTER=${HPOC_CLUSTER}"
        echo "CSI_STORAGE_CONTAINER=${CSI_STORAGE_CONTAINER}"
        echo "CONTROLPLANE_PC_CATEGORIES=${CONTROLPLANE_PC_CATEGORIES}"
        echo "WORKERNODE_PC_CATEGORIES=${WORKERNODE_PC_CATEGORIES}"

	${NKP_DIRECTORY}/cli/nkp create cluster nutanix \
		--cluster-name=${NKPCLUSTER_NAME} \
		--airgapped \
		--insecure \
		--endpoint="https://${PRISMCENTRAL_ENDPOINT}:9440" \
		--bundle="${NKP_BUNDLES}" \
		--control-plane-replicas=3 \
		--control-plane-endpoint-ip=${NKPAPISERVER_VIP} \
		--namespace="${WORKSPACE_NAMESPACE}" \
		--control-plane-vm-image="${VM_IMAGE_NAME}" \
		--control-plane-prism-element-cluster="${HPOC_CLUSTER}" \
		--control-plane-subnets="${VPC_CONTROLPLANE_SUBNET}" \
		--kubernetes-service-load-balancer-ip-range="${LOAD_BALANCER_IP_RANGE}" \
		--control-plane-pc-project=${PC_PROJECT} \
		--control-plane-pc-categories="${CONTROLPLANE_PC_CATEGORIES}" \
		--control-plane-vcpus=4 \
		--control-plane-memory=16 \
		--worker-replicas=4 \
		--worker-vm-image="${VM_IMAGE_NAME}" \
		--worker-prism-element-cluster=${HPOC_CLUSTER} \
		--worker-subnets=${VPC_WORKER_SUBNET} \
		--worker-pc-project=${PC_PROJECT} \
		--worker-pc-categories="${WORKERNODE_PC_CATEGORIES}" \
		--worker-vcpus=8 \
		--worker-memory=32 \
		--csi-storage-container="${CSI_STORAGE_CONTAINER}" \
		--ssh-username=konvoy \
		--ssh-public-key-file=${HOME}/.ssh/id_rsa.pub \
		--extra-sans=${FloatingIP_APIServer} \
		--verbose=5 \
		--dry-run \
		--output=yaml 

else
        echo "Executing Actual Run with parameters"
        echo "vpc=${VPC}"
        echo "NKPCLUSTER_NAME=${NKPCLUSTER_NAME}"
        echo "NKPAPISERVER_VIP=${NKPAPISERVER_VIP}"
        echo "FloatingIP_APIServer=${FloatingIP_APIServer}"
        echo "LOAD_BALANCER_IP_RANGE=${LOAD_BALANCER_IP_RANGE}"
        echo "VPC_CONTROLPLANE_SUBNET=${VPC_CONTROLPLANE_SUBNET}"
        echo "PC_PROJECT = ${PC_PROJECT}"
        echo "HPOC_CLUSTER=${HPOC_CLUSTER}"
        echo "CSI_STORAGE_CONTAINER=${CSI_STORAGE_CONTAINER}"
        echo "CONTROLPLANE_PC_CATEGORIES=${CONTROLPLANE_PC_CATEGORIES}"
        echo "WORKERNODE_PC_CATEGORIES=${WORKERNODE_PC_CATEGORIES}"

	${NKP_DIRECTORY}/cli/nkp create cluster nutanix \
		--cluster-name=${NKPCLUSTER_NAME} \
		--airgapped \
		--insecure \
		--endpoint="https://${PRISMCENTRAL_ENDPOINT}:9440" \
		--bundle="${NKP_BUNDLES}" \
		--control-plane-replicas=3 \
		--control-plane-endpoint-ip=${NKPAPISERVER_VIP} \
		--namespace="${WORKSPACE_NAMESPACE}" \
		--control-plane-vm-image="${VM_IMAGE_NAME}" \
		--control-plane-prism-element-cluster="${HPOC_CLUSTER}" \
		--control-plane-subnets="${VPC_CONTROLPLANE_SUBNET}" \
		--kubernetes-service-load-balancer-ip-range="${LOAD_BALANCER_IP_RANGE}" \
		--control-plane-pc-project=${PC_PROJECT} \
		--control-plane-pc-categories="${CONTROLPLANE_PC_CATEGORIES}" \
		--control-plane-vcpus=4 \
		--control-plane-memory=16 \
		--worker-replicas=4 \
		--worker-vm-image="${VM_IMAGE_NAME}" \
		--worker-prism-element-cluster=${HPOC_CLUSTER} \
		--worker-subnets=${VPC_WORKER_SUBNET} \
		--worker-pc-project=${PC_PROJECT} \
		--worker-pc-categories="${WORKERNODE_PC_CATEGORIES}" \
		--worker-vcpus=8 \
		--worker-memory=32 \
		--csi-storage-container="${CSI_STORAGE_CONTAINER}" \
		--ssh-username=konvoy \
		--ssh-public-key-file=${HOME}/.ssh/id_rsa.pub \
		--extra-sans=${FloatingIP_APIServer} \
		--verbose=5 
fi

######################################################################################
