#!/bin/bash

# 1. Get the Internal IPs of all worker nodes
NODES=$(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}')

# 2. Define the path to your private key and image directory
KEY="${HOME}/.ssh/id_rsa"
IMG_DIR="${HOME}/ndk-images"
USER="konvoy"

for ip in $NODES; do
    echo "----------------------------------------------------------"
    echo "Processing Node: $ip"
    echo "----------------------------------------------------------"

    # Step A: Transfer the tar files to the node's /tmp folder
    echo "Pushing images to /tmp on $ip as $USER..."
    scp -i "$KEY" -o StrictHostKeyChecking=no "$IMG_DIR"/*.tar $USER@$ip:/tmp/

    # Step B: Import images into containerd storage
    # We MUST use '-n k8s.io' or Kubernetes won't see them!
    echo "Importing images into containerd storage namespace 'k8s.io'..."
    ssh -i "$KEY" -o StrictHostKeyChecking=no $USER@$ip "for f in /tmp/*.tar; do sudo ctr -n k8s.io images import \$f; done"

    # Step C: Cleanup the temporary tar files on the node
    echo "Cleaning up /tmp on $ip..."
    ssh -i "$KEY" -o StrictHostKeyChecking=no $USER@$ip "rm -f /tmp/*.tar"
    
    echo "Done with node $ip"
    echo ""
done

echo "All nodes processed. Images are now local to the nodes."
