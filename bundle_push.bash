#!/usr/bin/bash
export REGISTRY_URL='https://10.55.49.162:5000/partnerdemo'
export REGISTRY_USERNAME='admin'
export REGISTRY_PASSWORD=$(kubectl get secrets -n ncr-system harbor-admin-password -o jsonpath='{.data.HARBOR_ADMIN_PASSWORD}' | base64 -d)

nkp push bundle \
	--bundle /home/nutanix/nkp-v2.17.0/container-images/kommander-image-bundle-v2.17.0.tar \
	--bundle /home/nutanix/nkp-v2.17.0/container-images/konvoy-image-bundle-v2.17.0.tar \
	--to-registry=${REGISTRY_URL} \
	--to-registry-username=${REGISTRY_USERNAME} \
	--to-registry-password=${REGISTRY_PASSWORD} \
	--to-registry-insecure-skip-tls-verify

