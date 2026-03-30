kubectl create secret generic gitea-credentials \
  --from-literal=username=nkpadmin \
  --from-literal=password=wrBhYAy3V44Payy \
  --namespace=kommander-default-workspace

#Install flux cli
curl -s https://fluxcd.io/install.sh | sudo bash

# This tells Flux: "Don't wait for the timer, pull the Git changes NOW."
flux reconcile kustomization management-gitops-demo -n kommander-default-workspace
