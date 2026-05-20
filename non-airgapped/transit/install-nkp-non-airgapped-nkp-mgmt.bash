
#!/usr/bin/bash
######################################################################################
# Revamped NKP Management Cluster Installation Script
# Supports: Custom Config Files, Dry-runs, and VPC/Standard modes
# Updated for: Non-Air-Gapped Installation
######################################################################################

# --- Default Values ---
CONFIG_FILE=""
DRY_RUN=false

# --- Help Function ---
usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -f, --file FILE   Path to the configuration file (Required)."
    echo "  -h, --help        Show this help message and exit."
    echo "  --dry-run         Execute a dry run to generate Kubernetes manifests (YAML)."
    echo ""
    echo "Example:"
    echo "  $0 -f my-nkp-config.conf --dry-run"
    echo ""
    exit 0
}

# --- Manual Argument Parsing ---
# We use a loop to handle both short (-f) and long (--file) flags
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--file)
            CONFIG_FILE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# 1. Validation: Ensure Config File is provided and exists
if [[ -z "${CONFIG_FILE}" ]]; then
    echo "ERROR: No configuration file specified. Use -f <filename>."
    usage
fi

if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "ERROR: Configuration file '${CONFIG_FILE}' not found."
    exit 1
fi

# 2. Source and Validate Configuration Content
source "${CONFIG_FILE}"

# Check if the critical variable PRISMCENTRAL_ENDPOINT is defined and not empty
if [[ -z "${PRISMCENTRAL_ENDPOINT}" ]]; then
    echo "ERROR: PRISMCENTRAL_ENDPOINT is not defined or is empty in ${CONFIG_FILE}."
    echo "Please ensure the configuration file is correct."
    exit 1
fi

echo "✓ Configuration file loaded: ${CONFIG_FILE}"

# 3. Pre-flight Validation Checks
echo "--- Running Pre-flight Validations ---"

# Check SSH Public Key existence
SSH_KEY_PATH="${HOME}/.ssh/id_rsa.pub"
if [[ ! -f "${SSH_KEY_PATH}" ]]; then
    echo "ERROR: SSH Public Key not found at ${SSH_KEY_PATH}."
    exit 2
fi
echo "✓ SSH Public Key found."

# Verify Prism Central Connectivity
echo "Verifying connectivity to Prism Central (${PRISMCENTRAL_ENDPOINT}:9440)..."
if ! curl -sk --connect-timeout 5 "https://${PRISMCENTRAL_ENDPOINT}:9440" > /dev/null; then
    echo "ERROR: Unable to reach Prism Central at ${PRISMCENTRAL_ENDPOINT}:9440."
    exit 3
fi
echo "✓ Prism Central connectivity verified."

# 4. Determine Run Mode
MODE_FLAG=""
RUN_TYPE="ACTUAL INSTALLATION"
if [ "$DRY_RUN" = true ]; then
    MODE_FLAG="--dry-run --output=yaml"
    RUN_TYPE="DRY RUN (Generating YAML)"
fi

# 5. Construct the Command Dynamically
CMD="${NKP_NONAIRGAPPED_DIR}/nkp create cluster nutanix \\
    --cluster-name=${NKPCLUSTER_NAME} \\
    --self-managed \\
    --insecure \\
    --endpoint=https://${PRISMCENTRAL_ENDPOINT}:9440 \\
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

# Add VPC-specific flags
if [[ "${INSIDE_VPC}" == "TRUE" ]]; then
    echo "Configuration Mode: [INSIDE VPC]"
    CMD="${CMD} \\
    --extra-sans="${FloatingIP_APIServer},${NKPAPISERVER_VIP},${FloatingIP_LBFirstIP}" \\
    --cluster-hostname=${FloatingIP_LBFirstIP}"
else
    echo "Configuration Mode: [OUTSIDE VPC / STANDARD]"
fi

# Finalize command
CMD="${CMD} \\
    ${MODE_FLAG}"

# 6. Display Command and Request Approval
echo -e "\n-----------------------------------------------------------------------"
echo "PROPOSED ${RUN_TYPE} COMMAND:"
echo "-----------------------------------------------------------------------"
# Pretty print for the user
echo -e "${CMD}" | sed 's/--/\n    --/g'
echo "-----------------------------------------------------------------------"
echo -n "Do you approve and wish to execute this command? (y/n): "
read user_approval

if [[ "${user_approval}" != "y" ]]; then
    echo "Aborted by user."
    exit 0
fi

# 7. Execution
echo "Executing NKP Creation..."
eval "${CMD}"

