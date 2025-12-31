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

### 1. Install Tailscale
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --advertise-exit-node --hostname=five
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
```

### 2. Install Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker pi
```

### 3. Verify Services
```bash
sudo systemctl is-enabled tailscaled docker
sudo tailscale status
docker --version
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

## Project History

This repository was originally an Ansible-based infrastructure project but has been refactored for AI-driven maintenance using direct SSH commands and beads issue tracking. This approach provides more flexibility and transparency for AI agents while reducing bureaucracy.

## References

- [Tailscale Exit Nodes](https://tailscale.com/kb/1103/exit-nodes)
- [Docker on Raspberry Pi](https://docs.docker.com/engine/install/debian/)
- [Beads Issue Tracker](https://github.com/beadsinc/beads)
