# Jarvis AI Manager SaaS

A productized AI agent for business managers to review data visually, automate emails, manage tasks, and orchestrate workflows—all through a single conversational interface.

**Open-source, self-hosted, ready to rebrand and resell.**

---

## What It Does

Imagine your manager logs in and asks:

> *"Show me Q2 revenue by region, send a reminder to the sales team about the pipeline review, and draft an email to the Acme account about the contract renewal."*

Jarvis handles all three in seconds:
1. **Queries the database**, generates a chart, and displays it inline
2. **Sends a Slack message** (or WhatsApp/email) to the team
3. **Drafts an email** in the manager's tone and files it for review

No custom workflows. No coding. Just natural language + a conversational AI.

---

## The Stack

| Component | Purpose | License | Why This One |
|-----------|---------|---------|--------------|
| **Onyx** | Chat interface, code execution, charting | MIT | Built for teams, RBAC, SSO, native tool integration |
| **n8n** | Automation engine (webhooks, task triggers) | Sustainable Use* | 400+ integrations, visual workflows, easy Slack/WhatsApp/CRM |
| **Inbox Zero** | Email automation + AI drafting | Open Source | Lightweight, integrates Gmail natively, MIT-friendly |
| **Caddy** | Reverse proxy, automatic HTTPS | Apache 2.0 | Free cert issuance, zero-config |

*See [licensing note](#licensing--resale) below.*

---

## 🚀 Quick Start (5 Minutes)

### Option 1: Docker Swarm (Recommended) — $6/mo

Deploy to a **Hetzner CX22** VPS (2 vCPU, 4GB RAM, €5.90/mo):

```bash
# 1. Create Hetzner account & CX22 server
# 2. SSH into server
ssh root@YOUR_VPS_IP

# 3. Clone & deploy
git clone https://github.com/donarviki326-sudo/JARVIS-MANAGER.git
cd JARVIS-MANAGER
bash scripts/deploy-swarm.sh

# 4. Edit .env with your domains & passwords
nano /root/.env
bash scripts/deploy-swarm.sh

# 5. Point DNS to your VPS IP
# onyx.yourdomain.com → YOUR_VPS_IP
# n8n.yourdomain.com → YOUR_VPS_IP
# inbox.yourdomain.com → YOUR_VPS_IP

# 6. Access (after DNS propagates, 5-15 min)
# https://onyx.yourdomain.com
# https://n8n.yourdomain.com
# https://inbox.yourdomain.com
```

**See [HETZNER_QUICKSTART.md](./HETZNER_QUICKSTART.md) for detailed guide.**

### Option 2: Traditional VPS Setup

For manual setup on any Linux VPS:

```bash
git clone https://github.com/donarviki326-sudo/JARVIS-MANAGER.git
cd JARVIS-MANAGER
bash scripts/setup.sh
```

**See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for detailed guide.**

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **[HETZNER_QUICKSTART.md](./HETZNER_QUICKSTART.md)** | 5-minute Docker Swarm setup on Hetzner |
| **[DOCKER_SWARM_SETUP.md](./DOCKER_SWARM_SETUP.md)** | Detailed Docker Swarm guide with monitoring & backups |
| **[DEPLOYMENT_SUMMARY.md](./DEPLOYMENT_SUMMARY.md)** | Overview, architecture, and cost breakdown |
| **[DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md)** | Step-by-step deployment tracking |
| **[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)** | Traditional VPS setup guide |
| **[GITPOD_QUICK_START.md](./GITPOD_QUICK_START.md)** | Development setup in Gitpod |

---

## 💰 Cost Comparison

| Platform | Services | Cost | Setup |
|----------|----------|------|-------|
| **Docker Swarm (Hetzner)** | Unlimited | €5.90/mo | 5 min |
| **Railway** | 5 max | $20+/mo | Easy |
| **Kubernetes** | Unlimited | $12+/mo | Complex |
| **AWS** | Unlimited | $50+/mo | Very complex |

**Recommendation:** Start with Docker Swarm on Hetzner. Scale to Kubernetes later if needed.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Hetzner CX22 VPS                     │
│                  (2 vCPU, 4GB RAM, €5.90)               │
├─────────────────────────────────────────────────────────┤
│                    Docker Swarm                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │    Caddy     │  │    Onyx      │  │     n8n      │ │
│  │  (Reverse    │  │   (Chat AI)  │  │ (Automation) │ │
│  │   Proxy)     │  │              │  │              │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ Inbox Zero   │  │  PostgreSQL  │  │    Redis     │ │
│  │   (Email)    │  │  (Database)  │  │   (Cache)    │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│                                                         │
│  ┌──────────────────────────────────────────────────┐ │
│  │              MinIO (Object Storage)              │ │
│  └──────────────────────────────────────────────────┘ │
│                                                         │
└─────────────────────────────────────────────────────────┘
         ↓
    Internet (HTTPS)
         ↓
┌─────────────────────────────────────────────────────────┐
│              Your Domain (yourdomain.com)               │
│  onyx.yourdomain.com → Onyx                            │
│  n8n.yourdomain.com → n8n                              │
│  inbox.yourdomain.com → Inbox Zero                     │
└─────────────────────────────────────────────────────────┘
```

---

## 🔧 Wire Services Together

Once deployed, connect Onyx to n8n:

1. Go to **Onyx Admin → Custom Tools**
2. Paste the content of `config/onyx-n8n-integration.openapi.yaml`
3. Click **Validate** → **Save**

Now Onyx can trigger n8n automations. In chat:

> *"Send a WhatsApp reminder to +919876543210 about the meeting tomorrow"*

It works.

---

## 📋 Features

### Onyx (Chat AI)
- ✅ Natural language interface
- ✅ Code execution (Python, SQL, etc.)
- ✅ Chart generation
- ✅ Role-based access control (RBAC)
- ✅ SSO support (Google OAuth, OIDC)
- ✅ Custom tool integration

### n8n (Automation)
- ✅ 400+ integrations (Slack, WhatsApp, Gmail, Salesforce, etc.)
- ✅ Visual workflow builder
- ✅ Webhooks & triggers
- ✅ Scheduled tasks
- ✅ Error handling & retries

### Inbox Zero (Email)
- ✅ Gmail integration
- ✅ Email automation rules
- ✅ AI-powered drafting
- ✅ Bulk actions
- ✅ Analytics

### Caddy (Reverse Proxy)
- ✅ Automatic HTTPS (Let's Encrypt)
- ✅ Zero-config SSL
- ✅ Load balancing
- ✅ Reverse proxy

---

## 🔐 Security

- ✅ Automatic SSL certificates (Let's Encrypt)
- ✅ Environment-based secrets (no hardcoding)
- ✅ Database passwords encrypted
- ✅ OAuth support for SSO
- ✅ Firewall rules (allow only 22, 80, 443)
- ✅ Health checks on all services

**See [DOCKER_SWARM_SETUP.md](./DOCKER_SWARM_SETUP.md#security-best-practices) for security best practices.**

---

## 📊 Monitoring & Maintenance

### View Logs
```bash
docker service logs jarvis_onyx_web
docker service logs -f jarvis_n8n_web
```

### Monitor Resources
```bash
docker stats
```

### Scale Services
```bash
docker service scale jarvis_onyx_web=2
```

### Update Services
```bash
docker service update --image onyx/onyx-backend:0.3-v0 jarvis_onyx_web
```

### Backup Data
```bash
docker run --rm -v jarvis_onyx_data:/data -v /backup:/backup \
  alpine tar czf /backup/onyx_data.tar.gz -C /data .
```

**See [DOCKER_SWARM_SETUP.md](./DOCKER_SWARM_SETUP.md#monitoring--maintenance) for detailed monitoring guide.**

---

## 🐛 Troubleshooting

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
Upgrade to CX32 (8GB RAM, €11.90/mo) in Hetzner console.

### Need to redeploy
```bash
docker stack rm jarvis
bash scripts/deploy-swarm.sh
```

**See [DOCKER_SWARM_SETUP.md](./DOCKER_SWARM_SETUP.md#troubleshooting) for detailed troubleshooting.**

---

## 📦 What's Included

- ✅ Complete docker-compose.yml with all services
- ✅ Automated deployment script
- ✅ Environment configuration template
- ✅ Caddy reverse proxy config
- ✅ Health checks on all services
- ✅ Persistent volumes for data
- ✅ Comprehensive documentation
- ✅ Deployment checklist

---

## 🚀 Next Steps

1. **Read [HETZNER_QUICKSTART.md](./HETZNER_QUICKSTART.md)** (5 min)
2. **Create Hetzner account** (2 min)
3. **Provision CX22 server** (2 min)
4. **Run deployment script** (5 min)
5. **Configure DNS** (1 min)
6. **Access services** ✅

---

## 📄 License

This project is open-source and available under the MIT License. See individual service licenses:
- **Onyx**: MIT
- **n8n**: Sustainable Use License (free for self-hosted)
- **Inbox Zero**: MIT
- **Caddy**: Apache 2.0

---

## 🤝 Support

- **Onyx Docs**: https://docs.onyx.app
- **n8n Docs**: https://docs.n8n.io
- **Inbox Zero**: https://github.com/elie222/inbox-zero
- **Caddy Docs**: https://caddyserver.com/docs
- **Docker Swarm Docs**: https://docs.docker.com/engine/swarm/

---

## 🎯 Roadmap

- [ ] Multi-tenant support
- [ ] Kubernetes deployment guide
- [ ] Automated backups to S3
- [ ] Monitoring dashboard (Grafana)
- [ ] Uptime monitoring (Uptime Kuma)
- [ ] Custom branding guide
- [ ] API documentation

---

**Ready to deploy?** Start with [HETZNER_QUICKSTART.md](./HETZNER_QUICKSTART.md) 🚀

