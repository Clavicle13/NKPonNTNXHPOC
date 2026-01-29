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

CONFIG_FILE="${HOME}/scripts/nkp-config.conf"

if [[ ! -f "${CONFIG_FILE}" ]]; then
        echo "Unable to locate default configuration file ${CONFIG_FILE}" >&2
        exit 3
fi

source ${CONFIG_FILE}

######################################################################################

if [[ "${DRYRUN}" == "TRUE" ]]; then

	${NKP_DIRECTORY}/cli/nkp create cluster nutanix --cluster-name=${NKPCLUSTER_NAME} \
		--airgapped \
		--self-managed \
		--insecure \
		--endpoint="https://${PRISMCENTRAL_ENDPOINT}:9440" \
		--bundle="${NKP_DIRECTORY}/container-images/kommander-image-bundle-v2.17.0.tar,${NKP_DIRECTORY}/container-images/konvoy-image-bundle-v2.17.0.tar" \
		--control-plane-replicas=3 \
		--control-plane-endpoint-ip=${NKPAPISERVER_VIP} \
		--control-plane-vm-image="${VM_IMAGE_NAME}" \
		--control-plane-prism-element-cluster="${HPOC_CLUSTER}" \
		--control-plane-subnets="primary-${HPOC_CLUSTER}" \
		--kubernetes-service-load-balancer-ip-range="${LOAD_BALANCER_IP_RANGE}" \
		--control-plane-pc-project=${PC_PROJECT} \
		--control-plane-pc-categories='Environment=Dev,nodetype=controlplane' \
		--control-plane-vcpus=4 \
		--control-plane-memory=16 \
		--worker-replicas=4 \
		--worker-vm-image="${VM_IMAGE_NAME}" \
		--worker-prism-element-cluster=${HPOC_CLUSTER} \
		--worker-subnets="primary-${HPOC_CLUSTER}" \
		--worker-pc-project=${PC_PROJECT} \
		--worker-pc-categories='Environment=Dev,nodetype=worker' \
		--worker-vcpus=8 \
		--worker-memory=32 \
		--csi-storage-container="${CSI_STORAGE_CONTAINER}" \
		--ssh-username=konvoy \
		--ssh-public-key-file=/home/rocky/.ssh/id_rsa.pub \
		--extra-sans=${FloatingIP_APIServer} \
		--cluster-hostname=${FloatingIP_LBFirstIP}\
		--verbose=5 \
		--dry-run \
		--output=yaml 

else
	${NKP_DIRECTORY}/cli/nkp create cluster nutanix --cluster-name=${NKPCLUSTER_NAME} \
		--airgapped \
		--self-managed \
		--insecure \
		--endpoint="https://${PRISMCENTRAL_ENDPOINT}:9440" \
		--bundle="${NKP_DIRECTORY}/container-images/kommander-image-bundle-v2.17.0.tar,${NKP_DIRECTORY}/container-images/konvoy-image-bundle-v2.17.0.tar" \
		--control-plane-replicas=3 \
		--control-plane-endpoint-ip=${NKPAPISERVER_VIP} \
		--control-plane-vm-image="${VM_IMAGE_NAME}" \
		--control-plane-prism-element-cluster="${HPOC_CLUSTER}" \
		--control-plane-subnets="primary-${HPOC_CLUSTER}" \
		--kubernetes-service-load-balancer-ip-range="${LOAD_BALANCER_IP_RANGE}" \
		--control-plane-pc-project=${PC_PROJECT} \
		--control-plane-pc-categories='Environment=Dev,nodetype=controlplane' \
		--control-plane-vcpus=4 \
		--control-plane-memory=16 \
		--worker-replicas=4 \
		--worker-vm-image="${VM_IMAGE_NAME}" \
		--worker-prism-element-cluster=${HPOC_CLUSTER} \
		--worker-subnets="primary-${HPOC_CLUSTER}" \
		--worker-pc-project=${PC_PROJECT} \
		--worker-pc-categories='Environment=Dev,nodetype=worker' \
		--worker-vcpus=8 \
		--worker-memory=32 \
		--csi-storage-container="${CSI_STORAGE_CONTAINER}" \
		--ssh-username=konvoy \
		--ssh-public-key-file=/home/rocky/.ssh/id_rsa.pub \
		--extra-sans=${FloatingIP_APIServer} \
		--cluster-hostname=${FloatingIP_LBFirstIP}\
		--verbose=5 
fi

######################################################################################
