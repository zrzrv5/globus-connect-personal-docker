#!/bin/bash
set -euo pipefail

echo "=== Globus Connect Personal NAS Setup ==="
echo

# Check if required params provided  
if [ $# -lt 3 ]; then
    echo "Usage: $0 <ENDPOINT_NAME> <DESCRIPTION> <OWNER_EMAIL> [CONFIG_DIR] [DATA_DIR]"
    echo
    echo "Examples:"
    echo "  $0 'MyNAS-Endpoint' 'Home NAS for data transfer' user@domain.com"
    echo "  $0 'Lab-Storage' 'Lab data storage endpoint' user@university.edu /volume1/globus-config /volume1/data"
    echo
    exit 1
fi

ENDPOINT_NAME="$1"
DESCRIPTION="$2"  
OWNER_EMAIL="$3"
CONFIG_DIR="${4:-./globus-config}"
DATA_DIR="${5:-./globus-data}"

echo "Endpoint Name: $ENDPOINT_NAME"
echo "Description: $DESCRIPTION"
echo "Owner: $OWNER_EMAIL"
echo "Config Directory: $CONFIG_DIR"
echo "Data Directory: $DATA_DIR"
echo

# Create directories
mkdir -p "$CONFIG_DIR"
mkdir -p "$DATA_DIR"

echo "=== Step 1: Interactive Setup ==="
echo "The setup will display an auth URL. You need to:"
echo "1. Copy the URL to your browser"
echo "2. Log in with your Globus account"  
echo "3. Copy the auth code back here"
echo
read -p "Press Enter to start setup..."

# Run interactive setup
docker run -it --rm \
    -v "$CONFIG_DIR:/home/gcp/.globusonline" \
    globus-gcp:latest \
    gcp -setup --name "$ENDPOINT_NAME" --description "$DESCRIPTION" --owner "$OWNER_EMAIL"

if [ $? -eq 0 ]; then
    echo
    echo "=== Step 2: Starting GCP Service ==="
    
    # Start the service with data directory access
    docker run -d --name globus-gcp \
        --restart unless-stopped \
        -v "$CONFIG_DIR:/home/gcp/.globusonline" \
        -v "$DATA_DIR:/data" \
        globus-gcp:latest \
        gcp -start -restrict-paths "rw/data"
        
    echo "Waiting for service to start..."
    sleep 3
    
    # Check status
    docker exec globus-gcp gcp -status
    
    echo
    echo "=== Setup Complete! ==="
    echo "Your endpoint '$ENDPOINT_NAME' should now be visible at:"
    echo "https://app.globus.org/file-manager"
    echo
    echo "Data directory: $DATA_DIR"
    echo "Config directory: $CONFIG_DIR"
    echo
    echo "To manage the service:"
    echo "  docker logs globus-gcp         # View logs"
    echo "  docker exec globus-gcp gcp -status  # Check status"
    echo "  docker stop globus-gcp        # Stop service"
    echo "  docker start globus-gcp       # Start service"
    echo "  docker restart globus-gcp     # Restart service"
else
    echo "Setup failed. Check the error messages above."
    exit 1
fi
