We are freshly installing Debian Trixie version of Raspberry PI OS https://www.raspberrypi.com/software/ onto a Raspberry Pi 5.

The baseline for the device is to have:

* Docker server on boot
* sshd with no password authentication `ssh pi@192.168.1.34` should work already
* Tailscale, it was previously a exit node configured as "five" on kaihendry.github 
* use rg for searching and fd for listing files

My Ubiquiti network at 81.187.243.70 has been forwarding to the Pi 5 on a "statically" assigned IP address:

* 192.168.1.34:443
* 192.168.1.34:80

# Agent Instructions

This project uses **bd** (beads) for issue tracking. Run `bd onboard` to get started.

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
```

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds

