# Globus Connect Personal Docker Container

A lightweight Docker container for running Globus Connect Personal on NAS devices and Linux systems.

This is my personal setup for running Globus Connect Personal on my UGREEN NAS using Docker. I created this after struggling with the official Globus documentation and wanting a simple, containerized solution that works reliably on ARM64/AMD64 NAS devices. The container is designed to be lightweight, secure, and easy to manage.

**My Setup:** UGREEN DXP4800 Plus NAS running Docker, but this should work on any system with Docker support (Synology, QNAP, etc.).

I followed the original tutorial from here: https://gitlab.kuleuven.be/setit/rdm/globus-connect#globus-connect-personal-on-docker

## Prerequisites

### 0. Pre-setup Requirements

1. **Non-root Docker access**
   ```bash
   # Add your user to docker group
   sudo usermod -aG docker $USER
   
   # Log out and back in, or run:
   newgrp docker
   
   # Verify docker works without sudo
   docker ps
   ```

2. **Create configuration directory**
   ```bash
   mkdir configs
   chmod 700 configs
   ```

3. **Globus Account**
   - Sign up at [globus.org](https://globus.org) if you don't have an account

## Installation

### 1. Build the Docker Image

Match your user's UID/GID for proper file permissions:
```bash
docker build --build-arg GCP_UID=$(id -u) --build-arg GCP_GID=$(id -g) -t gcp-docker .
```

### 2. Initial Setup (One-time)

Run the container interactively to configure Globus Connect Personal:

```bash
docker run -it \
  --platform linux/amd64 \
  -v ./configs:/home/globus/.globusonline \
  gcp-docker bash
```

Inside the container, run the setup command:
```bash
globusconnectpersonal -setup -n 'YourNASName' --description 'My NAS Description' --owner your-email@example.com
```


The setup will:
1. Display a login URL - open it in your browser
2. Ask you to paste back an authorization code
3. Show "registered new endpoint, id: xxx setup completed successfully"
4. Exit the container with `exit`

### 3. Run Globus Connect Personal

**Start the service in detached mode:**
```bash
docker run -d --rm --name globus-service \
  -v ./configs:/home/globus/.globusonline \
  -v /volume1/work:/data \
  gcp-docker start
```

**Adjust the data path for your system:**


## Management

### Check if running
```bash
docker ps
```

### View logs
```bash
docker logs globus-service
docker logs -f globus-service  # Follow logs in real-time
```

### Stop the service
```bash
docker stop globus-service
# Container auto-removes due to --rm flag
```

### Restart the service
```bash
# Same command as step 3
docker run -d --rm --name globus-service \
  -v ./configs:/home/globus/.globusonline \
  -v /volume1/work:/data \
  gcp-docker start
```

### Clean up old containers
```bash
# Remove all stopped containers
docker container prune -f

# Or remove specific containers
docker rm -f $(docker ps -aq --filter ancestor=gcp-docker)
```

## Troubleshooting

### Debug mode
If you're having issues, run in debug mode:
```bash
docker run -it \
  -v ./configs:/home/globus/.globusonline \
  -v /volume1/work:/data \
  gcp-docker debug
```

### Interactive shell for debugging
```bash
docker run -it \
  -v ./configs:/home/globus/.globusonline \
  -v /volume1/work:/data \
  gcp-docker bash
```
