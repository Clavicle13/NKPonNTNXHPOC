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

CONFIG_FILE="${HOME}/scripts/bastion-inside-vpc/management/${VPC}/nkp-mgmt-${VPC}.conf"

if [[ ! -f "${CONFIG_FILE}" ]]; then
        echo "Unable to locate default configuration file ${CONFIG_FILE}" >&2
        exit 3
fi

######################################################################################

echo "Using ${CONFIG_FILE} ..."
source ${CONFIG_FILE}

######################################################################################

if [[ "${DRYRUN}" == "TRUE" ]]; then

	set +x

	${NKP_DIRECTORY}/cli/nkp create cluster nutanix --cluster-name=${NKPCLUSTER_NAME} \
		--airgapped \
		--self-managed \
		--insecure \
		--endpoint="https://${PRISMCENTRAL_ENDPOINT}:9440" \
		--bundle="${NKP_BUNDLES}" \
		--control-plane-replicas=3 \
		--control-plane-endpoint-ip=${NKPAPISERVER_VIP} \
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

	set -x

else

	set +x

	${NKP_DIRECTORY}/cli/nkp create cluster nutanix --cluster-name=${NKPCLUSTER_NAME} \
		--airgapped \
		--self-managed \
		--insecure \
		--endpoint="https://${PRISMCENTRAL_ENDPOINT}:9440" \
		--bundle="${NKP_BUNDLES}" \
		--control-plane-replicas=3 \
		--control-plane-endpoint-ip=${NKPAPISERVER_VIP} \
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

	set -x
fi

######################################################################################
