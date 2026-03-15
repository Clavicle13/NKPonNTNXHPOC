#!/bin/bash

# Configuration
HARBOR_URL="10.38.244.20:5000"
PROJECT="partnerdemo"

echo "Logging into Harbor at $HARBOR_URL..."
podman login $HARBOR_URL --tls-verify=false

# Get all images that have 'ndk' in the name, excluding those already tagged for Harbor
# This grabs localhost/ndk/manager, localhost/ndk/infra-manager, etc.
IMAGES=$(podman images --format "{{.Repository}}:{{.Tag}}" | grep "ndk" | grep -v "$HARBOR_URL")

for IMAGE in $IMAGES; do
    echo "------------------------------------------------"
    # IMAGE looks like "localhost/ndk/manager:2.1.0"
    
    # Strip the local prefix to get just the name and tag
    # e.g., manager:2.1.0
    IMAGE_NAME_TAG=$(echo $IMAGE | awk -F'/' '{print $NF}')
    
    # Construct the new tag for Harbor
    NEW_TAG="$HARBOR_URL/$PROJECT/$IMAGE_NAME_TAG"
    
    echo "Processing: $IMAGE"
    echo "  New Tag:  $NEW_TAG"
    
    # Tagging
    podman tag $IMAGE $NEW_TAG
    
    # Pushing
    echo "  Pushing to Harbor..."
    podman push $NEW_TAG --tls-verify=false
done

echo "------------------------------------------------"
echo "All NDK images have been synced to Harbor!"
