# Jarvis AI Manager - Deployment Checklist

Use this checklist to track your deployment progress.

## Pre-Deployment (5 min)

- [ ] Read HETZNER_QUICKSTART.md
- [ ] Have a domain name ready (or plan to use IP-based access)
- [ ] Have SSH key pair ready (or will create one)
- [ ] Gather credentials:
  - [ ] Google OAuth credentials (optional but recommended)
  - [ ] SMTP credentials for email (optional)
  - [ ] OpenAI API key (optional, for Inbox Zero AI)

## Hetzner Setup (5 min)

- [ ] Create Hetzner Cloud account (https://www.hetzner.com/cloud)
- [ ] Create new project
- [ ] Create CX22 server
  - [ ] Image: Ubuntu 24.04 LTS
  - [ ] Type: CX22 (2 vCPU, 4GB RAM)
  - [ ] Location: Closest to you
  - [ ] SSH Key: Added
  - [ ] Name: `jarvis-manager`
- [ ] Copy server IP address: `___________________`
- [ ] Test SSH connection: `ssh root@YOUR_IP`

## Deployment (5 min)

- [ ] SSH into server: `ssh root@YOUR_IP`
- [ ] Clone repository:
  ```bash
  git clone https://github.com/donarviki326-sudo/JARVIS-MANAGER.git
  cd JARVIS-MANAGER
  ```
- [ ] Run deployment script:
  ```bash
  bash scripts/deploy-swarm.sh
  ```
- [ ] Script creates `/root/.env` file
- [ ] Edit `.env` with your configuration:
  ```bash
  nano /root/.env
  ```
  - [ ] Set `ONYX_DOMAIN` (e.g., `onyx.yourdomain.com`)
  - [ ] Set `N8N_DOMAIN` (e.g., `n8n.yourdomain.com`)
  - [ ] Set `INBOX_DOMAIN` (e.g., `inbox.yourdomain.com`)
  - [ ] Set `ONYX_DB_PASSWORD` (strong password)
  - [ ] Set `N8N_DB_PASSWORD` (strong password)
  - [ ] Set `INBOX_DB_PASSWORD` (strong password)
  - [ ] Set `ONYX_SECRET` (random string)
  - [ ] Set `N8N_ENCRYPTION_KEY` (random string)
  - [ ] Set `INBOX_SECRET` (random string)
  - [ ] (Optional) Set Google OAuth credentials
  - [ ] (Optional) Set SMTP credentials
  - [ ] (Optional) Set OpenAI API key
  - [ ] Save and exit (Ctrl+X, Y, Enter)
- [ ] Re-run deployment script:
  ```bash
  bash scripts/deploy-swarm.sh
  ```
- [ ] Wait for all services to reach `Running` status (2-3 min)
- [ ] Verify deployment:
  ```bash
  docker stack ps jarvis
  ```

## DNS Configuration (5 min)

- [ ] Go to your domain registrar (Cloudflare, Namecheap, GoDaddy, etc.)
- [ ] Create A record: `onyx.yourdomain.com` → `YOUR_IP`
- [ ] Create A record: `n8n.yourdomain.com` → `YOUR_IP`
- [ ] Create A record: `inbox.yourdomain.com` → `YOUR_IP`
- [ ] Wait for DNS propagation (5-15 minutes)
- [ ] Verify DNS is live:
  ```bash
  nslookup onyx.yourdomain.com
  ```

## Post-Deployment (5 min)

- [ ] Access Onyx: https://onyx.yourdomain.com
  - [ ] Verify SSL certificate is valid
  - [ ] Log in with default credentials
  - [ ] Create admin user
- [ ] Access n8n: https://n8n.yourdomain.com
  - [ ] Verify SSL certificate is valid
  - [ ] Set up admin user
  - [ ] Configure integrations
- [ ] Access Inbox Zero: https://inbox.yourdomain.com
  - [ ] Verify SSL certificate is valid
  - [ ] Connect Gmail account
  - [ ] Configure AI features (optional)

## Monitoring & Maintenance

- [ ] Set up log monitoring:
  ```bash
  docker service logs -f jarvis_onyx_web
  ```
- [ ] Monitor resource usage:
  ```bash
  docker stats
  ```
- [ ] Set up automated backups (see DOCKER_SWARM_SETUP.md)
- [ ] Configure firewall on Hetzner (allow 22, 80, 443)
- [ ] Enable 2FA on admin accounts
- [ ] Schedule regular updates

## Troubleshooting

If services won't start:
- [ ] Check logs: `docker service logs jarvis_SERVICE_NAME`
- [ ] Check status: `docker stack ps jarvis --no-trunc`
- [ ] Verify DNS: `nslookup yourdomain.com`
- [ ] Check memory: `docker stats`
- [ ] Review DOCKER_SWARM_SETUP.md troubleshooting section

If DNS isn't resolving:
- [ ] Wait longer (DNS can take 15+ minutes)
- [ ] Verify A records are created correctly
- [ ] Check with: `nslookup onyx.yourdomain.com`
- [ ] Try from different network/device

If out of memory:
- [ ] Check usage: `docker stats`
- [ ] Upgrade to CX32 (8GB RAM) in Hetzner console
- [ ] Or reduce replicas: `docker service scale jarvis_SERVICE=1`

## Security Checklist

- [ ] Changed all default passwords in `.env`
- [ ] Enabled firewall on Hetzner (allow only 22, 80, 443)
- [ ] Set strong Google OAuth credentials
- [ ] Enabled 2FA on admin accounts
- [ ] Reviewed DOCKER_SWARM_SETUP.md security section
- [ ] Set up automated backups
- [ ] Scheduled regular Docker updates

## Cost Verification

- [ ] Hetzner CX22: €5.90/mo (~$6.50)
- [ ] Domain: $10-15/yr (optional)
- [ ] Total: ~$6.50/mo ✅

## Documentation

- [ ] Read HETZNER_QUICKSTART.md ✅
- [ ] Read DOCKER_SWARM_SETUP.md ✅
- [ ] Bookmarked service documentation:
  - [ ] [Onyx Docs](https://docs.onyx.app)
  - [ ] [n8n Docs](https://docs.n8n.io)
  - [ ] [Inbox Zero Repo](https://github.com/elie222/inbox-zero)
  - [ ] [Caddy Docs](https://caddyserver.com/docs)

## Deployment Complete! 🎉

- [ ] All services running
- [ ] DNS configured
- [ ] Services accessible via HTTPS
- [ ] Admin users created
- [ ] Backups configured
- [ ] Monitoring set up

**Next steps:**
1. Configure integrations (Slack, Gmail, etc.)
2. Set up automation workflows in n8n
3. Create email rules in Inbox Zero
4. Invite team members to Onyx
5. Monitor logs and performance

---

**Questions?** Check DOCKER_SWARM_SETUP.md or the service documentation.

**Ready to deploy?** Start with HETZNER_QUICKSTART.md!

