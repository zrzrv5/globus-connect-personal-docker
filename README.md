# Globus Connect Personal Docker Container

A minimal, headless Docker container for running Globus Connect Personal (GCP) on your NAS or any Linux system.

## Quick Start

### 1. Build the Image

```bash
docker build -t globus-gcp:latest .
```

### 2. Initial Setup

Create a config directory on your host and run the interactive setup:

```bash
# Create persistent config directory
mkdir -p ~/globus-config

# Run interactive setup (replace with your details)
docker run -it --rm \
  -v ~/globus-config:/home/gcp/.globusonline \
  globus-gcp:latest \
  gcp -setup --name "My NAS Endpoint" --description "NAS data transfer" --owner your-email@domain.com
```

The setup process will:
1. Display an auth URL - copy this to your browser
2. Log in with your Globus account 
3. Copy the auth code from the browser
4. Paste it back into the terminal to complete setup

### 3. Start GCP Service

After setup, start the service with restricted paths:

```bash
# Start with access to a specific data directory
mkdir -p ~/globus-data

docker run -d --name globus-gcp \
  -v ~/globus-config:/home/gcp/.globusonline \
  -v ~/globus-data:/data \
  globus-gcp:latest \
  gcp -start -restrict-paths rw/data
```

### 4. Check Status

```bash
# Check if GCP is running
docker exec globus-gcp gcp -status

# View logs
docker logs globus-gcp
```

## NAS Deployment

For deployment on your NAS:

1. Build the image on your development machine
2. Export the image: `docker save globus-gcp:latest | gzip > globus-gcp.tar.gz`
3. Transfer to your NAS
4. Load on NAS: `docker load < globus-gcp.tar.gz`
5. Run with appropriate volume mounts for your NAS directories

Example NAS run command:
```bash
docker run -d --name globus-gcp \
  --restart unless-stopped \
  -v /volume1/globus-config:/home/gcp/.globusonline \
  -v /volume1/data:/data \
  globus-gcp:latest \
  gcp -start -restrict-paths rw/data
```

## Useful Commands

```bash
# View GCP help
docker run --rm globus-gcp:latest gcp -help

# Stop the service
docker exec globus-gcp gcp -stop

# Get detailed status
docker exec globus-gcp gcp -trace

# Restart container
docker restart globus-gcp
```

## Security Notes

- The container runs as a non-root user (`gcp`, UID 10001)
- Use `-restrict-paths` to limit filesystem access
- Keep your `~/.globusonline` config directory secure and backed up
- Consider firewall rules for your NAS if needed

## Troubleshooting

- **"No configuration found"**: Ensure you've run `-setup` and the config volume is mounted
- **"Permission denied"**: Check volume mount permissions and path restrictions
- **Connection issues**: Verify network connectivity and firewall settings
