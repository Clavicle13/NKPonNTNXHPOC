#!/usr/bin/bash
helm upgrade --install nutanix-flow-cni oci://ghcr.io/nutanix-cloud-native/helm-releases/nutanix-flow-cni \
  --version 1.0.0 \
  --namespace flow-cni-system \
  --create-namespace \
  -f flow-cni-values.yaml
