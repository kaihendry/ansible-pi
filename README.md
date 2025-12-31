# Raspberry Pi 5 "five" - AI-Driven Device Maintenance

This repository tracks the configuration and maintenance of the Raspberry Pi 5 device named "five".

## Device Overview

- **Hostname**: five
- **Hardware**: Raspberry Pi 5
- **OS**: Debian Trixie (Raspberry Pi OS)
- **Local IP**: 192.168.1.34 (statically assigned by Ubiquiti router)
- **Tailscale IP**: 100.92.18.102
- **Access**: `ssh pi@192.168.1.34` or `ssh pi@five` (via Tailscale)

## Network Configuration

The device is behind a Ubiquiti network at **81.187.243.70** with port forwarding configured:

- **Port 80** → 192.168.1.34:80
- **Port 443** → 192.168.1.34:443

## Current Setup

### 1. SSH Access

SSH is configured with:
- No password authentication (key-based only)
- Direct access via `ssh pi@192.168.1.34`
- Alternative access via Tailscale: `ssh pi@five`

Security configuration:
- Password authentication disabled via `/etc/ssh/sshd_config.d/disable-password-auth.conf`
- Public key authentication enabled

Test SSH security:
```bash
ssh pi@192.168.1.34 "/home/pi/test-ssh-security.sh"
```

### 2. Tailscale

- **Version**: 1.92.3
- **Configuration**: Exit node (advertised)
- **Network**: kaihendry.github tailnet
- **IP forwarding**: Enabled for IPv4 and IPv6
- **Auto-start**: Enabled via systemd

Configuration files:
- IP forwarding: `/etc/sysctl.d/99-tailscale.conf`
- Service: `tailscaled.service`

Verify status:
```bash
ssh pi@192.168.1.34 "sudo tailscale status"
```

### 3. Docker

- **Version**: 29.1.3
- **Auto-start**: Enabled via systemd
- **User access**: pi user is in docker group (no sudo required)
- **Services**: containerd + docker

Verify status:
```bash
ssh pi@192.168.1.34 "sudo systemctl status docker"
ssh pi@192.168.1.34 "docker ps"  # (requires new login to activate group)
```

### 4. Caddy

- **Version**: Latest (from Debian repositories)
- **Configuration**: `/etc/caddy/Caddyfile`
- **Auto-start**: Enabled via systemd
- **TLS**: Automatic Let's Encrypt certificates

Configured sites:
- **home.prazefarm.co.uk** → Reverse proxy to 192.168.1.34:8123 (Home Assistant)
  - TLS email: hendry@iki.fi
  - X-Robots-Tag: noindex (prevents search engine indexing)

Verify status:
```bash
ssh pi@192.168.1.34 "sudo systemctl status caddy"
ssh pi@192.168.1.34 "sudo journalctl -u caddy -n 20"
```

### 5. Home Assistant

- **Version**: Latest stable (from ghcr.io/home-assistant/home-assistant)
- **Deployment**: Docker Compose
- **Configuration**: `/home/pi/homeassistant/`
- **Access**: http://192.168.1.34:8123 or https://home.prazefarm.co.uk
- **Database**: SQLite (home-assistant_v2.db)
- **Zigbee**: Connected via /dev/ttyUSB0

Docker Compose location: `/home/pi/homeassistant/docker-compose.yaml`

Custom integrations:
- Octopus Energy
- HACS
- Hildebrand Glow DCC
- LocalTuya
- UK Bin Collection

Verify status:
```bash
ssh pi@192.168.1.34 "docker ps | grep homeassistant"
ssh pi@192.168.1.34 "docker logs homeassistant --tail 50"
```

Manage container:
```bash
cd /home/pi/homeassistant
docker compose down    # Stop
docker compose up -d   # Start
docker compose restart # Restart
```

## AI-Driven Maintenance

This repository uses **beads (bd)** for issue tracking and AI-driven maintenance workflows.

### Getting Started

```bash
# View available tasks
bd ready

# View all issues
bd list

# View specific issue
bd show <issue-id>

# Update issue status
bd update <issue-id> --status in_progress

# Close completed work
bd close <issue-id>

# Sync with git
bd sync
```

### Maintenance Tasks

Common maintenance tasks can be tracked and executed through beads:

1. **System Updates**: Update Debian packages
2. **Docker Management**: Update containers, prune unused images
3. **Tailscale Updates**: Update Tailscale client
4. **Service Monitoring**: Check service health
5. **Network Configuration**: Update firewall rules, port forwarding

### Adding New Services

When adding new services to "five":

1. Create a beads issue: `bd create`
2. Document the service configuration
3. Ensure auto-start on boot (systemd)
4. Update this README with service details
5. Close the issue and sync: `bd close <id> && bd sync`

## Fresh Installation

If reinstalling from scratch (Debian Trixie Raspberry Pi OS):

### 1. Secure SSH
```bash
# Disable password authentication
echo 'PasswordAuthentication no' | sudo tee /etc/ssh/sshd_config.d/disable-password-auth.conf
sudo systemctl reload ssh

# Create security test script
cat > /home/pi/test-ssh-security.sh <<'EOF'
#!/bin/bash
echo "Testing SSH Security Configuration..."
echo "======================================"
echo
PASS_AUTH=$(sudo sshd -T | grep '^passwordauthentication' | awk '{print $2}')
PUBKEY_AUTH=$(sudo sshd -T | grep '^pubkeyauthentication' | awk '{print $2}')
echo "Current SSH Settings:"
echo "  Password Authentication: $PASS_AUTH"
echo "  Public Key Authentication: $PUBKEY_AUTH"
echo
if [ "$PASS_AUTH" = "no" ] && [ "$PUBKEY_AUTH" = "yes" ]; then
    echo "✓ All SSH security tests PASSED"
    exit 0
else
    echo "✗ SSH security tests FAILED"
    exit 1
fi
EOF
chmod +x /home/pi/test-ssh-security.sh

# Run test
/home/pi/test-ssh-security.sh
```

### 2. Install Tailscale
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --advertise-exit-node --hostname=five
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
```

### 3. Install Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker pi
```

### 4. Install Caddy
```bash
sudo apt-get update
sudo apt-get install -y caddy
sudo systemctl enable caddy
```

Configure Caddyfile at `/etc/caddy/Caddyfile`:
```
home.prazefarm.co.uk {
    tls hendry@iki.fi
    reverse_proxy 192.168.1.34:8123
    header / {
        X-Robots-Tag "noindex"
    }
}
```

Reload Caddy:
```bash
sudo systemctl reload caddy
```

### 5. Install Home Assistant
```bash
cd /home/pi
mkdir -p homeassistant
cd homeassistant

# Create docker-compose.yaml
cat > docker-compose.yaml <<'EOF'
version: "3"
services:
  homeassistant:
    image: "ghcr.io/home-assistant/home-assistant:stable"
    container_name: homeassistant
    volumes:
      - /home/pi/homeassistant:/config
      - /etc/localtime:/etc/localtime:ro
      - /run/dbus:/run/dbus:ro
    restart: unless-stopped
    privileged: true
    network_mode: host
    devices:
      - /dev/ttyUSB0:/dev/ttyUSB0
    environment:
      - TZ=Europe/London
EOF

# Start Home Assistant
docker compose up -d
```

### 6. Verify Services
```bash
sudo systemctl is-enabled tailscaled docker caddy
sudo tailscale status
docker --version
docker ps
```

## Troubleshooting

### SSH Access Issues
- Verify network connectivity: `ping 192.168.1.34`
- Check SSH service: `ssh pi@192.168.1.34 "sudo systemctl status ssh"`
- Use Tailscale as fallback: `ssh pi@five`

### Tailscale Issues
- Check service: `sudo systemctl status tailscaled`
- View logs: `sudo journalctl -u tailscaled -n 50`
- Verify IP forwarding: `sudo sysctl net.ipv4.ip_forward net.ipv6.conf.all.forwarding`

### Docker Issues
- Check service: `sudo systemctl status docker`
- View logs: `sudo journalctl -u docker -n 50`
- Restart service: `sudo systemctl restart docker`

### Caddy Issues
- Check service: `sudo systemctl status caddy`
- View logs: `sudo journalctl -u caddy -n 50`
- Test configuration: `sudo caddy validate --config /etc/caddy/Caddyfile`
- Reload configuration: `sudo systemctl reload caddy`
- Check TLS certificate status: Look for "certificate obtained" in logs

### Home Assistant Issues
- Check container status: `docker ps | grep homeassistant`
- View logs: `docker logs homeassistant --tail 100`
- Restart container: `cd /home/pi/homeassistant && docker compose restart`
- Configuration file: `/home/pi/homeassistant/configuration.yaml`
- Database: `/home/pi/homeassistant/home-assistant_v2.db`
- Common issue: Wrong volume mount in docker-compose.yaml (must be `/home/pi/homeassistant:/config`)

## Project History

This repository was originally an Ansible-based infrastructure project but has been refactored for AI-driven maintenance using direct SSH commands and beads issue tracking. This approach provides more flexibility and transparency for AI agents while reducing bureaucracy.

## References

- [Tailscale Exit Nodes](https://tailscale.com/kb/1103/exit-nodes)
- [Docker on Raspberry Pi](https://docs.docker.com/engine/install/debian/)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [Home Assistant Docker Installation](https://www.home-assistant.io/installation/linux#docker-compose)
- [Beads Issue Tracker](https://github.com/beadsinc/beads)
