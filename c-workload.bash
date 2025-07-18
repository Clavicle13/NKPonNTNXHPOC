#!/usr/bin/bash +x
######################################################################################
#
# Date			Changes
# -------		------------
# 22nd June 2025	Creation
#
#
######################################################################################

######################################################################################

CONFIG_FILE="${HOME}/scripts/nkp-workload-config.conf"

if [[ ! -f "${CONFIG_FILE}" ]]; then
        echo "Unable to locate default configuration file ${CONFIG_FILE}" >&2
        exit 3
fi

source ${CONFIG_FILE}

######################################################################################

if [[ "${DRYRUN}" == "TRUE" ]]; then

	/home/rocky/nkp-v2.15.0/cli/nkp create cluster nutanix --cluster-name=${NKPCLUSTER_NAME} \
		--airgapped \
		--additional-trust-bundle="$(base64 -w0 ${COMBINED_TRUST_BUNDLE})" \
		--endpoint="https://${PRISMCENTRAL_ENDPOINT}:9440" \
		--control-plane-replicas=3 \
		--control-plane-endpoint-ip=${NKPAPISERVER_VIP} \
		--control-plane-vm-image="${VM_IMAGE_NAME}" \
		--control-plane-prism-element-cluster="${HPOC_CLUSTER}" \
		--control-plane-subnets="aux-1" \
		--kubernetes-service-load-balancer-ip-range="${LOAD_BALANCER_IP_RANGE}" \
		--control-plane-pc-project=${PC_PROJECT} \
		--control-plane-pc-categories='environment=development,nodetype=controlplane' \
		--control-plane-vcpus=4 \
		--control-plane-memory=16 \
		--worker-replicas=4 \
		--worker-vm-image="${VM_IMAGE_NAME}" \
		--worker-prism-element-cluster=${HPOC_CLUSTER} \
		--worker-subnets="aux-1" \
		--worker-pc-project=${PC_PROJECT} \
		--worker-pc-categories='environment=development,nodetype=worker' \
		--worker-vcpus=8 \
		--worker-memory=32 \
		--csi-storage-container="${CSI_STORAGE_CONTAINER}" \
		--ssh-username=konvoy \
		--ssh-public-key-file=/home/rocky/.ssh/id_rsa.pub \
		--registry-url="${LOCAL_REGISTRY}" \
		--registry-username=dummy \
		--registry-password=dummy \
		--registry-mirror-url="${MIRROR_REGISTRY}" \
		--extra-sans='prism.nutanix.local' \
		--verbose=5 \
		--dry-run \
		--output=yaml 

else
	/home/rocky/nkp-v2.15.0/cli/nkp create cluster nutanix --cluster-name=${NKPCLUSTER_NAME} \
		--airgapped \
		--additional-trust-bundle="$(base64 -w0 ${COMBINED_TRUST_BUNDLE})" \
		--endpoint="https://${PRISMCENTRAL_ENDPOINT}:9440" \
		--control-plane-replicas=3 \
		--control-plane-endpoint-ip=${NKPAPISERVER_VIP} \
		--control-plane-vm-image="${VM_IMAGE_NAME}" \
		--control-plane-prism-element-cluster="${HPOC_CLUSTER}" \
		--control-plane-subnets="primary-${HPOC_CLUSTER}" \
		--kubernetes-service-load-balancer-ip-range="${LOAD_BALANCER_IP_RANGE}" \
		--control-plane-pc-project=${PC_PROJECT} \
		--control-plane-pc-categories='environment=development,nodetype=controlplane' \
		--control-plane-vcpus=4 \
		--control-plane-memory=16 \
		--worker-replicas=4 \
		--worker-vm-image="${VM_IMAGE_NAME}" \
		--worker-prism-element-cluster=${HPOC_CLUSTER} \
		--worker-subnets="primary-${HPOC_CLUSTER}" \
		--worker-pc-project=${PC_PROJECT} \
		--worker-pc-categories='environment=development,nodetype=worker' \
		--worker-vcpus=8 \
		--worker-memory=32 \
		--csi-storage-container="${CSI_STORAGE_CONTAINER}" \
		--ssh-username=konvoy \
		--ssh-public-key-file=/home/rocky/.ssh/id_rsa.pub \
		--registry-url="${LOCAL_REGISTRY}" \
		--registry-username=dummy \
		--registry-password=dummy \
		--registry-mirror-url="${MIRROR_REGISTRY}" \
		--extra-sans='prism.nutanix.local' \
		--verbose=5 
fi

######################################################################################
