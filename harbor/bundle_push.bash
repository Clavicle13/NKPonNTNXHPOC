#!/usr/bin/bash
export REGISTRY_URL=$(echo "https://$(kubectl -n kommander get kommandercluster practice1 -o jsonpath='{.status.ingress.address}'):5000/nkpdemo")
export REGISTRY_USERNAME='admin'
export REGISTRY_PASSWORD=$(kubectl get secrets -n ncr-system harbor-admin-password -o jsonpath='{.data.HARBOR_ADMIN_PASSWORD}' | base64 -d)

echo "Detected Harbor Registry URL is ${REGISTRY_URL}"
echo "Detected Harbor Registry Password is  ${REGISTRY_PASSWORD}"
echo "Proceeding to push bundles ..."

nkp push bundle \
	--bundle ${HOME}/nkp-v2.19.0/container-images/kommander-image-bundle-v2.19.0.tar \
	--bundle ${HOME}/nkp-v2.19.0/container-images/konvoy-image-bundle-v2.19.0.tar \
	--bundle ${HOME}/nkp-v2.19.0/container-images/nkp-ai-applications-catalog-image-bundle-2.19.tar \
	--bundle ${HOME}/nkp-v2.19.0/container-images/nkp-nutanix-product-catalog-image-bundle-2.19.tar \
	--bundle ${HOME}/nkp-v2.19.0/container-images/kubernetes-os-ubuntu-24.04-nkp-v2.19.0-v1.36.2_linux_amd64.tar \
	--bundle ${HOME}/nkp-v2.19.0/container-images/nkp-release-specs-v2.19.0.tar \
	--to-registry=${REGISTRY_URL} \
	--to-registry-username=${REGISTRY_USERNAME} \
	--to-registry-password=${REGISTRY_PASSWORD} \
	--to-registry-insecure-skip-tls-verify

