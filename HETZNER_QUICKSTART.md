# Hetzner + Docker Swarm Quick Start (5 Minutes)

## 1. Create Hetzner Account & VPS

1. Go to https://www.hetzner.com/cloud
2. Sign up (free account, no credit card required initially)
3. Create a new project
4. Click **Create Server**
   - **Image**: Ubuntu 24.04 LTS
   - **Type**: CX22 (2 vCPU, 4GB RAM, €5.90/mo)
   - **Location**: Pick closest to you
   - **SSH Key**: Add your public key (or create one)
   - **Name**: `jarvis-manager`
5. Click **Create & Buy Now**
6. **Copy the IP address** (e.g., `192.0.2.1`)

## 2. SSH into Your Server

```bash
ssh root@192.0.2.1
```

## 3. Run Deployment Script

```bash
# Clone repo
git clone https://github.com/donarviki326-sudo/JARVIS-MANAGER.git
cd JARVIS-MANAGER

# Run deployment script
bash scripts/deploy-swarm.sh
```

The script will:
- ✅ Install Docker
- ✅ Initialize Docker Swarm
- ✅ Create `.env` file
- ✅ Deploy all services

## 4. Configure `.env`

Edit `/root/.env` with your settings:

```bash
nano /root/.env
```

**Minimum required:**
- `ONYX_DOMAIN`, `N8N_DOMAIN`, `INBOX_DOMAIN` (your subdomains)
- `ONYX_DB_PASSWORD`, `N8N_DB_PASSWORD`, `INBOX_DB_PASSWORD` (strong passwords)
- `ONYX_SECRET`, `N8N_ENCRYPTION_KEY`, `INBOX_SECRET` (random strings)

**Optional but recommended:**
- `GOOGLE_OAUTH_CLIENT_ID` & `GOOGLE_OAUTH_CLIENT_SECRET` (for Onyx login)
- `SMTP_*` variables (for email notifications)
- `OPENAI_API_KEY` (for Inbox Zero AI features)

Save and exit (Ctrl+X, Y, Enter).

## 5. Re-run Deployment

```bash
bash scripts/deploy-swarm.sh
```

Wait for all services to show `Running` status.

## 6. Point DNS to Your VPS

At your domain registrar (Cloudflare, Namecheap, GoDaddy, etc.):

Create **A records**:
- `onyx.yourdomain.com` → `192.0.2.1`
- `n8n.yourdomain.com` → `192.0.2.1`
- `inbox.yourdomain.com` → `192.0.2.1`

**Wait 5-15 minutes for DNS to propagate.**

## 7. Access Your Services

Once DNS is live:
- **Onyx** (Chat AI): https://onyx.yourdomain.com
- **n8n** (Automation): https://n8n.yourdomain.com
- **Inbox Zero** (Email): https://inbox.yourdomain.com

SSL certificates are auto-provisioned by Caddy.

## 8. Monitor & Manage

```bash
# View all services
docker stack ps jarvis

# View logs
docker service logs jarvis_onyx_web

# Scale a service
docker service scale jarvis_onyx_web=2

# Update a service
docker service update --image onyx/onyx-backend:0.3-v0 jarvis_onyx_web
```

## Costs

- **Hetzner CX22**: €5.90/mo (~$6.50)
- **Domain**: $10-15/yr (optional)
- **Total**: ~$6.50/mo

## Troubleshooting

### Services won't start
```bash
docker stack ps jarvis --no-trunc
docker service logs jarvis_SERVICE_NAME
```

### DNS not resolving
```bash
nslookup onyx.yourdomain.com
```

### Out of memory
Upgrade to CX32 (8GB RAM, €11.90/mo):
```bash
# In Hetzner console, resize server
```

### Need to redeploy
```bash
docker stack rm jarvis
bash scripts/deploy-swarm.sh
```

## Full Documentation

See `DOCKER_SWARM_SETUP.md` for detailed setup, backups, security, and troubleshooting.

---

**That's it!** You now have a production-ready Jarvis AI Manager stack running on Docker Swarm. 🎉

