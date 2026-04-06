#!/usr/bin/bash
######################################################################################
# Revamped NKP Management Cluster Installation Script
# Supports: Inside VPC (Internal Bastion) and Outside VPC (External Bastion)
######################################################################################

# --- Help Function ---
usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message and exit."
    echo "  --dry-run      Execute a dry run to generate Kubernetes manifests (YAML)."
    echo ""
    echo "Description:"
    echo "  This script installs an NKP Workload cluster based on settings in"
    echo "  the configuration file (nkp-mgmt.conf). It handles both VPC and"
    echo "  standard installations automatically."
    echo ""
    exit 0
}

# Check for help parameter manually (as --help isn't natively handled by getopts)
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    usage
fi

# 1. Source the Configuration
CONFIG_FILE="${HOME}/scripts/nkp-workload-vpc.conf"
if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "Error: Configuration file ${CONFIG_FILE} not found."
    exit 1
fi
source "${CONFIG_FILE}"

# 2. Pre-flight Validation Checks
echo "--- Running Pre-flight Validations ---"

# Check SSH Public Key existence [cite: 5, 51]
SSH_KEY_PATH="${HOME}/.ssh/id_rsa.pub"
if [[ ! -f "${SSH_KEY_PATH}" ]]; then
    echo "ERROR: SSH Public Key not found at ${SSH_KEY_PATH}."
    echo "This key is required to configure nodes for troubleshooting. [cite: 5]"
    exit 2
fi
echo "✓ SSH Public Key found."

# Verify Prism Central Connectivity [cite: 5]
echo "Verifying connectivity to Prism Central (${PRISMCENTRAL_ENDPOINT}:9440)..."
if ! curl -sk --connect-timeout 5 "https://${PRISMCENTRAL_ENDPOINT}:9440" > /dev/null; then
    echo "ERROR: Unable to reach Prism Central at ${PRISMCENTRAL_ENDPOINT}:9440."
    echo "Please check your network path, VPC security groups, or routing. [cite: 5]"
    exit 3
fi
echo "✓ Prism Central connectivity verified."

# 3. Determine Run Mode 
MODE_FLAG=""
RUN_TYPE="ACTUAL INSTALLATION"
if [[ "$1" == "--dry-run" ]]; then
    MODE_FLAG="--dry-run --output=yaml" # Generate cluster manifests [cite: 116]
    RUN_TYPE="DRY RUN (Generating YAML)"
fi

# 4. Construct the Command Dynamically [cite: 1, 143]
CMD="${NKP_DIRECTORY}/cli/nkp create cluster nutanix \\
    --cluster-name=${NKP_WORKLOAD_CLUSTER_NAME} \\
    --airgapped \\
    --insecure \\
    --endpoint=https://${PRISMCENTRAL_ENDPOINT}:9440 \\
    --bundle=${NKP_BUNDLES} \\
    --namespace ${WORKSPACE_NAMESPACE} \\
    --control-plane-replicas=3 \\
    --control-plane-endpoint-ip=${NKPAPISERVER_VIP} \\
    --control-plane-vm-image=${VM_IMAGE_NAME} \\
    --control-plane-prism-element-cluster=${HPOC_CLUSTER} \\
    --control-plane-subnets=${VPC_CONTROLPLANE_SUBNET} \\
    --control-plane-pc-project=${PC_PROJECT} \\
    --control-plane-pc-categories=${CONTROLPLANE_PC_CATEGORIES} \\
    --worker-replicas=4 \\
    --worker-vm-image=${VM_IMAGE_NAME} \\
    --worker-prism-element-cluster=${HPOC_CLUSTER} \\
    --worker-subnets=${VPC_WORKER_SUBNET} \\
    --worker-pc-project=${PC_PROJECT} \\
    --worker-pc-categories=${WORKERNODE_PC_CATEGORIES} \\
    --csi-storage-container=${CSI_STORAGE_CONTAINER} \\
    --kubernetes-service-load-balancer-ip-range=${LOAD_BALANCER_IP_RANGE} \\
    --ssh-username=konvoy \\
    --ssh-public-key-file=${SSH_KEY_PATH} \\
    --verbose=5"

# Add VPC-specific flags [cite: 122, 132]
if [[ "${INSIDE_VPC}" == "TRUE" ]]; then
    echo "Configuration Mode: [INSIDE VPC]"
    CMD="${CMD} \\
    --extra-sans="${FloatingIP_APIServer},${FloatingIP_LBFirstIP}" \\
    --cluster-hostname=${FloatingIP_LBFirstIP}"
else
    echo "Configuration Mode: [OUTSIDE VPC / STANDARD]"
fi

# Finalize command with dry-run/output flags if specified [cite: 116, 151]
CMD="${CMD} ${MODE_FLAG}"

# 5. Display Command and Request Approval
echo -e "\n-----------------------------------------------------------------------"
echo "PROPOSED ${RUN_TYPE} COMMAND:"
echo "-----------------------------------------------------------------------"
echo -e "${CMD}" | sed 's/--/\n    --/g' 
echo "-----------------------------------------------------------------------"
echo -n "Do you approve and wish to execute this command? (y/n): "
read user_approval

if [[ "${user_approval}" != "y" ]]; then
    echo "Aborted by user."
    exit 0
fi

# 6. Execution Primary Section
echo "Executing NKP Creation..."
eval "${CMD}"
