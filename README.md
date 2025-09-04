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
  ghcr.io/zrzrv5/globus-connect-personal-docker:latest \
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
  ghcr.io/zrzrv5/globus-connect-personal-docker:latest \
  gcp -start -restrict-paths rw/data
```

### 4. Check Status

```bash
# Check if GCP is running
docker exec globus-gcp gcp -status

# View logs
docker logs globus-gcp
```

## Docker Compose Deployment (Recommended)

The easiest way to deploy on your NAS using Docker Compose:

### 1. Setup
```bash
# Download the compose files
curl -O https://raw.githubusercontent.com/zrzrv5/globus-connect-personal-docker/main/docker-compose.yml
curl -O https://raw.githubusercontent.com/zrzrv5/globus-connect-personal-docker/main/docker-compose.setup.yml
curl -O https://raw.githubusercontent.com/zrzrv5/globus-connect-personal-docker/main/env.example

# Create environment file
cp env.example .env
# Edit .env with your details
```

### 2. Initial Setup
```bash
# Set your details
export ENDPOINT_NAME="MyNAS-Endpoint"
export DESCRIPTION="Home NAS storage"
export OWNER_EMAIL="user@example.com"

# Run interactive setup
docker compose -f docker-compose.setup.yml up
```

### 3. Start Service
```bash
# Start the GCP service
docker compose up -d

# Check status
docker compose exec globus-gcp gcp -status
```

## Manual NAS Deployment

For deployment without Docker Compose:

1. Pull the image: `docker pull ghcr.io/zrzrv5/globus-connect-personal-docker:latest`
2. Run setup and service as shown in Quick Start section above

Example NAS run command:
```bash
docker run -d --name globus-gcp \
  --restart unless-stopped \
  -v /volume1/globus-config:/home/gcp/.globusonline \
  -v /volume1/data:/data \
  ghcr.io/zrzrv5/globus-connect-personal-docker:latest \
  gcp -start -restrict-paths rw/data
```

## Useful Commands

```bash
# View GCP help
docker run --rm ghcr.io/zrzrv5/globus-connect-personal-docker:latest gcp -help

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

### Permission Issues
- **"Permission denied: '/home/gcp/.globusonline/lta'"**: Fix directory ownership:
  ```bash
  sudo chown -R 10001:10001 /path/to/your/config/directory
  sudo chown -R 10001:10001 /path/to/your/data/directory
  ```

### Common Issues
- **"No configuration found"**: Ensure you've run `-setup` and the config volume is mounted
- **"Permission denied"**: Check volume mount permissions and path restrictions  
- **Connection issues**: Verify network connectivity and firewall settings

### Docker Compose Permission Fix
If using Docker Compose, add this to your service definition:
```yaml
services:
  globus-gcp:
    # ... other settings ...
    user: "10001:10001"  # Match container user
```
