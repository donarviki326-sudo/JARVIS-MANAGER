# Docker Swarm Deployment Guide for Jarvis AI Manager

This guide walks you through deploying the complete Jarvis stack on a single Hetzner CX22 VPS using Docker Swarm.

## Prerequisites

- **VPS**: Hetzner CX22 (2 vCPU, 4GB RAM, ~$6/mo) or similar
- **Domain**: A domain name pointing to your VPS IP
- **SSH Access**: Ability to SSH into your VPS
- **Time**: ~30 minutes

## Step 1: Provision a Hetzner CX22 VPS

1. Go to [Hetzner Cloud Console](https://console.hetzner.cloud)
2. Create a new project (or use existing)
3. Click **Create Server**
   - **Image**: Ubuntu 24.04 LTS
   - **Type**: CX22 (2 vCPU, 4GB RAM)
   - **Location**: Choose closest to you
   - **SSH Key**: Add your public key
   - **Name**: `jarvis-manager`
4. Click **Create & Buy Now**
5. Wait for server to boot (~1 minute)
6. Note the **IP address** (e.g., `192.0.2.1`)

## Step 2: SSH into Your VPS

```bash
ssh root@YOUR_VPS_IP
```

## Step 3: Install Docker & Initialize Swarm

```bash
# Update system
apt-get update && apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Initialize Docker Swarm
docker swarm init

# Verify Swarm is active
docker node ls
```

You should see one node with status `Ready` and role `Leader`.

## Step 4: Create Environment File

Create `.env` on your VPS:

```bash
cat > /root/.env << 'EOF'
# Domain Configuration
ONYX_DOMAIN=onyx.yourdomain.com
N8N_DOMAIN=n8n.yourdomain.com
INBOX_DOMAIN=inbox.yourdomain.com

# Timezone
TIMEZONE=UTC

# Onyx Configuration
ONYX_DB_PASSWORD=generate_a_strong_password_here
ONYX_MINIO_PASSWORD=generate_a_strong_password_here
ONYX_SECRET=generate_a_strong_secret_here
GOOGLE_OAUTH_CLIENT_ID=your_google_oauth_client_id
GOOGLE_OAUTH_CLIENT_SECRET=your_google_oauth_client_secret
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your_email@gmail.com
SMTP_PASSWORD=your_app_password
SMTP_FROM_EMAIL=noreply@yourdomain.com

# n8n Configuration
N8N_DB_PASSWORD=generate_a_strong_password_here
N8N_ENCRYPTION_KEY=generate_a_strong_encryption_key_here
ADMIN_EMAIL=admin@yourdomain.com
N8N_DEFAULT_PASSWORD=generate_a_strong_password_here

# Inbox Zero Configuration
INBOX_DB_PASSWORD=generate_a_strong_password_here
INBOX_SECRET=generate_a_strong_secret_here
OPENAI_API_KEY=your_openai_api_key_optional
EOF
```

**Important**: Replace all placeholder values with actual credentials.

## Step 5: Clone Repository & Deploy Stack

```bash
# Clone the repository
git clone https://github.com/donarviki326-sudo/JARVIS-MANAGER.git
cd JARVIS-MANAGER

# Load environment variables
export $(cat /root/.env | xargs)

# Deploy the stack
docker stack deploy -c deployment/docker-compose.yml jarvis
```

Verify deployment:

```bash
docker stack ls
docker stack ps jarvis
```

Wait for all services to reach `Running` state (~2-3 minutes).

## Step 6: Configure DNS

Point your domain subdomains to your VPS IP:

| Subdomain | Type | Value |
|-----------|------|-------|
| `onyx` | A | `YOUR_VPS_IP` |
| `n8n` | A | `YOUR_VPS_IP` |
| `inbox` | A | `YOUR_VPS_IP` |

**Example** (using Cloudflare):
- Create A record: `onyx.yourdomain.com` → `192.0.2.1`
- Create A record: `n8n.yourdomain.com` → `192.0.2.1`
- Create A record: `inbox.yourdomain.com` → `192.0.2.1`

DNS propagation takes 5-15 minutes.

## Step 7: Access Your Services

Once DNS propagates:

- **Onyx**: https://onyx.yourdomain.com
- **n8n**: https://n8n.yourdomain.com
- **Inbox Zero**: https://inbox.yourdomain.com

Caddy automatically provisions SSL certificates via Let's Encrypt.

## Monitoring & Maintenance

### View Logs

```bash
# All services
docker stack ps jarvis

# Specific service
docker service logs jarvis_onyx_web

# Follow logs
docker service logs -f jarvis_onyx_web
```

### Scale a Service

```bash
# Scale Onyx to 2 replicas
docker service scale jarvis_onyx_web=2
```

### Update a Service

```bash
# Pull latest image and redeploy
docker service update --image onyx/onyx-backend:0.3-v0 jarvis_onyx_web
```

### Backup Volumes

```bash
# Backup Onyx data
docker run --rm -v jarvis_onyx_data:/data -v /backup:/backup \
  alpine tar czf /backup/onyx_data.tar.gz -C /data .

# Backup PostgreSQL
docker exec jarvis_onyx_postgres_1 pg_dump -U onyx onyx > /backup/onyx.sql
```

### Remove Stack

```bash
docker stack rm jarvis
```

## Troubleshooting

### Service won't start

```bash
# Check service logs
docker service logs jarvis_SERVICE_NAME

# Inspect service
docker service inspect jarvis_SERVICE_NAME
```

### Database connection errors

Ensure all services are healthy:

```bash
docker stack ps jarvis --no-trunc
```

Wait for all services to reach `Running` state.

### Caddy certificate issues

```bash
# Check Caddy logs
docker service logs jarvis_caddy

# Verify DNS is resolving
nslookup onyx.yourdomain.com
```

### Out of memory

Monitor resource usage:

```bash
docker stats
```

If consistently over 3.5GB, upgrade to CX32 (8GB RAM, ~$12/mo).

## Security Best Practices

1. **Change default passwords** in `.env` before deployment
2. **Enable firewall** on Hetzner (allow only 22, 80, 443)
3. **Use strong OAuth credentials** for Onyx
4. **Rotate secrets regularly**
5. **Enable 2FA** on admin accounts
6. **Keep Docker updated**: `apt-get update && apt-get upgrade -y`

## Cost Breakdown

| Item | Cost |
|------|------|
| Hetzner CX22 | $6/mo |
| Domain (optional) | $10-15/yr |
| **Total** | **~$6/mo** |

## Next Steps

1. Set up automated backups (cron job)
2. Configure email integrations (Gmail, Slack, etc.)
3. Set up monitoring (Uptime Kuma, Grafana)
4. Create admin users in Onyx, n8n, Inbox Zero
5. Test workflows end-to-end

## Support

For issues:
- Check logs: `docker service logs jarvis_SERVICE_NAME`
- Review docker-compose.yml for service dependencies
- Consult individual service docs:
  - [Onyx Docs](https://docs.onyx.app)
  - [n8n Docs](https://docs.n8n.io)
  - [Inbox Zero Docs](https://github.com/elie222/inbox-zero)
  - [Caddy Docs](https://caddyserver.com/docs)

