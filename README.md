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

## Quick Start

### Prerequisites
- A VPS with 4GB RAM (e.g., Hetzner CX22 ~$6/mo, DigitalOcean Basic ~$24/mo)
- A domain name
- 30 minutes

### 1. Clone and Setup

```bash
git clone https://github.com/YOUR_ORG/jarvis-saas-complete.git
cd jarvis-saas-complete

# Generate secrets and create .env
bash scripts/setup.sh
# Choose option 2 (generate secrets)
# Then choose option 3 (validate .env after filling it in)
```

### 2. Deploy

```bash
# Point your DNS A records at your VPS first:
#   onyx.yourdomain.com    A  <YOUR_VPS_IP>
#   n8n.yourdomain.com     A  <YOUR_VPS_IP>
#   inbox.yourdomain.com   A  <YOUR_VPS_IP>

# Then:
bash scripts/setup.sh
# Choose option 8 (full setup: check prereqs, pull images, start services)
```

### 3. Access

After 1-2 minutes:
- **Onyx chat:** https://onyx.yourdomain.com
- **n8n automation:** https://n8n.yourdomain.com
- **Inbox Zero email:** https://inbox.yourdomain.com

Create an admin account on first visit.

### 4. Wire Them Together

In Onyx:
1. Go to **Admin → Custom Tools**
2. Paste the content of `config/onyx-n8n-integration.openapi.yaml`
3. Click **Validate** → **Save**

Now Onyx can trigger n8n automations. In chat, you can ask things like:
> *"Send a WhatsApp reminder to +919876543210 about the meeting tomorrow"*

And it works.

---

## Full Documentation

1. **[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)** — Step-by-step setup with troubleshooting (start here)
2. **[BRANDING.md](./docs/BRANDING.md)** — How to customize logos, colors, and names for your clients
3. **[docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md)** — How the pieces fit together (data flow, security)
4. **[docs/MULTI_TENANT_ROADMAP.md](./docs/MULTI_TENANT_ROADMAP.md)** — Scaling to many clients

---

## What You Can Do Today (v1)

✅ **Chat with AI about business data** (natural language queries + charting)
✅ **Automate repetitive tasks** (WhatsApp reminders, CRM updates, Slack posts, email drafts)
✅ **Manage email efficiently** (AI-organized inbox, tone-matched drafts)
✅ **Team collaboration** (share chats, RBAC, audit logs)
✅ **Custom integrations** (add any service n8n supports: Salesforce, HubSpot, Stripe, etc.)

---

## What You Can Build Next (v2+)

- **Multi-tenant SaaS** (one stack per client → shared infrastructure + billing)
- **Mobile app** (React Native wrapper around the web UI)
- **Deeper BI** (add WrenAI for governed SQL + dashboards across multiple DBs)
- **Custom LLM** (swap Claude for an open-source model like Llama)
- **Marketplace** (pre-built agent templates for common verticals: real estate, B2B SaaS, healthcare)

---

## Licensing & Resale

**TL;DR:** You can build a SaaS product, but be mindful of n8n's licensing.

### Open-Source Components
- **Onyx:** MIT licensed → no restrictions on resale
- **Inbox Zero:** Open source (check LICENSE) → safe to resale
- **Caddy:** Apache 2.0 → no restrictions

### n8n Licensing ⚠️
- **n8n runs under the "Sustainable Use License"** — it restricts commercial use in specific scenarios
- **You CAN:** Host n8n as a backend service for your SaaS (customers don't directly access it)
- **You CANNOT:** White-label n8n itself or charge specifically for "access to n8n"
- **Best practice:** Position n8n as "automation engine inside Jarvis," not a separate product

If this is unclear or you plan large-scale resale, reach out to n8n for an enterprise/embed license (they offer this).

---

## Comparison: "Jarvis" vs. Building From Scratch

| Aspect | Jarvis (This Stack) | Build From Scratch |
|--------|-------------------|-------------------|
| **Time to MVP** | 2 hours | 3-6 months |
| **Maintenance** | Patch 3 projects | Build + maintain everything |
| **Features** | 50+ integrations included | Start with zero integrations |
| **Cost to deploy** | $5-7/mo VPS | $5-7/mo + dev time |
| **Can resell to clients** | Yes (with licensing care) | Yes (if you own code) |

---

## Architecture at a Glance

```
┌─────────────────────────────────────────────────┐
│          Manager (Chat Interface)               │
│             (Onyx Web UI)                       │
└──────────────────┬──────────────────────────────┘
                   │ Natural language
                   ▼
        ┌──────────────────────┐
        │    Onyx Backend      │  ← Orchestrator
        │  - Parse intent      │
        │  - Execute SQL/Python│
        │  - Generate charts   │
        └──────────┬───────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
        ▼                     ▼
    ┌────────────┐      ┌──────────────┐
    │  n8n       │      │ Inbox Zero   │
    │ Webhooks   │      │ Email + AI   │
    │ Automations│      │ Drafting     │
    └────┬───────┘      └──────────────┘
         │
    ┌────┴────────────────────────┐
    │                             │
    ▼                             ▼
[WhatsApp] [Slack]           [CRM/HubSpot]
[Email]    [Calendar]        [Salesforce]
```

---

## Support & Community

- **Onyx:** https://github.com/onyx-dot-app/onyx (Discussions, Issues)
- **n8n:** https://docs.n8n.io + Community Forum
- **Inbox Zero:** https://github.com/elie222/inbox-zero (Issues, PRs welcome)

Each project is actively maintained. We recommend checking for updates monthly.

---

## Next Steps

1. **[Read DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)** to deploy Stage 0-3
2. **Customize branding** using [docs/BRANDING.md](./docs/BRANDING.md)
3. **Connect your first client's data** (database, CRM, email)
4. **Build 2-3 sample automations** (WhatsApp reminder, CRM update, Slack alert)
5. **Test the full flow:** Chat → trigger automation → see result

Then you have a working AI manager assistant ready to show clients.

---

## License & Legal

This project bundles open-source software. Each component retains its original license (see above). By using this stack, you agree to comply with the licenses of:
- Onyx (MIT)
- n8n (Sustainable Use License — review carefully if reselling)
- Inbox Zero (OSS, verify current license)
- Caddy (Apache 2.0)

**This is not legal advice.** For commercial use or resale, consult a lawyer familiar with open-source licensing.

---

## Questions?

- See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) **Troubleshooting** section first
- Check Docker logs: `docker compose logs -f`
- Open an issue on the respective project's GitHub
- Reach out to the Onyx, n8n, or Inbox Zero communities

Good luck! 🚀

---

**Ready to build?** Start with:
```bash
bash scripts/setup.sh
```
