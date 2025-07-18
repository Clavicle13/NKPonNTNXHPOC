#!/usr/bin/bash
####################################################################
#
####################################################################

####################################################################
#
# Look for the default cofiguration file and source it to get
# the configuration variables
#
####################################################################

CONFIG_FILE="${HOME}/scripts/nkp-config.conf"

if [[ ! -f "${CONFIG_FILE}" ]]; then
	echo "Unable to locate default configuration file ${CONFIG_FILE}" >&2
	exit 3
fi

source ${CONFIG_FILE}

####################################################################

if [[ ! -f "${NKPSERVE_TLS_PRIVATE_KEY_FILE}" ]]; then
	echo "Unable to locate NKP Serve Private KEY File ${NKPSERVE_TLS_PRIVATE_KEY_FILE}" >&2
	exit 4
fi

if [[ ! -f "${NKPSERVE_TLS_CERT}" ]]; then
	echo "Unable to locate NKP Serve TLS Cert File ${NKPSERVE_TLS_CERT}" >&2
	exit 5
fi

####################################################################

nkp serve bundle --listen-port 5000 --listen-address 0.0.0.0 \
	--tls-cert-file="${NKPSERVE_TLS_CERT}" \
	--tls-private-key-file="${NKPSERVE_TLS_PRIVATE_KEY_FILE}" \
	--bundle ${NKP_DIRECTORY}/container-images/konvoy-image-bundle-v2.15.0.tar \
	--bundle ${NKP_DIRECTORY}/kib/artifacts/images/kubernetes-images-1.32.3-d2iq.1-fips.tar \
	--bundle ${NKP_DIRECTORY}/container-images/kommander-image-bundle-v2.15.0.tar \
	--bundle ${NKP_DIRECTORY}/nkp-image-builder-image-v2.15.0.tar \
	--bundle ${NKP_DIRECTORY}/kib/artifacts/images/kubernetes-images-1.32.3-d2iq.1.tar \
	--bundle ${NKP_DIRECTORY}/konvoy-bootstrap-image-v2.15.0.tar \
	--bundle ${NDK_DIRECTORY}/ndk-1.3.0.tar
