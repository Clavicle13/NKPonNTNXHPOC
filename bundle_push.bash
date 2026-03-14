#!/usr/bin/bash
export REGISTRY_URL=$(echo "https://$(kubectl -n kommander get kommandercluster host-cluster -o jsonpath='{.status.ingress.address}'):5000/partnerdemo")
export REGISTRY_USERNAME='admin'
export REGISTRY_PASSWORD=$(kubectl get secrets -n ncr-system harbor-admin-password -o jsonpath='{.data.HARBOR_ADMIN_PASSWORD}' | base64 -d)

echo "Detected Harbor Registry URL is ${REGISTRY_URL}"
echo "Detected Harbor Registry Password is  ${REGISTRY_PASSWORD}"
echo "Proceeding to push bundles ..."

nkp push bundle \
	--bundle ${HOME}/nkp-v2.17.1/container-images/kommander-image-bundle-v2.17.1.tar \
	--bundle ${HOME}/nkp-v2.17.1/container-images/konvoy-image-bundle-v2.17.1.tar \
	--to-registry=${REGISTRY_URL} \
	--to-registry-username=${REGISTRY_USERNAME} \
	--to-registry-password=${REGISTRY_PASSWORD} \
	--to-registry-insecure-skip-tls-verify

