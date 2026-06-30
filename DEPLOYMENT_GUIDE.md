# Jarvis AI Manager SaaS — Complete Deployment Guide

This deploys a productized AI agent for managers to review data visually, automate emails, and orchestrate business workflows via a single conversational interface.

**Tech stack (3 core systems, all open-source):**
- **Onyx** (chat + RBAC + Python code/charting) — the main interface
- **n8n** (automation engine) — WhatsApp, Slack, CRM, calendar actions
- **Inbox Zero** (email + AI draft) — email automation & management

Everything runs in Docker on a single $5-7/mo VPS. Total software cost: **$0**.

---

## Pre-Deployment Checklist

Before you start, have these ready:

- [ ] A Ubuntu 22.04 or 24.04 VPS (4GB RAM minimum; e.g., Hetzner CX22 ~$6/mo)
- [ ] A domain name (e.g., `myapp.com`)
- [ ] DNS access to point subdomains at your VPS IP
- [ ] SMTP credentials for sending email (Gmail App Password, Brevo free tier, etc.)
- [ ] Your VPS's public IP address

## Stage 0: VPS Setup (One-time, ~5 min)

### 0.1 SSH into your VPS and install Docker

```bash
ssh root@<YOUR_VPS_IP>

# Install Docker
curl -fsSL https://get.docker.com | sh

# Verify it's running
docker --version  # Should output Docker version

# Add current user to docker group (optional, lets you run without sudo)
usermod -aG docker $USER
```

**CHECKPOINT:** If `docker --version` shows a version number, Docker is installed. ✓

### 0.2 Point your DNS records at the VPS

You need three A records pointing at `<YOUR_VPS_IP>`:

```
onyx.yourdomain.com        A  <YOUR_VPS_IP>
n8n.yourdomain.com         A  <YOUR_VPS_IP>
inbox.yourdomain.com       A  <YOUR_VPS_IP>
```

This **must** be done **before** starting containers, or HTTPS cert issuance will fail.

**CHECKPOINT:** Run `nslookup onyx.yourdomain.com` on your local machine. It should return your VPS IP.

---

## Stage 1: Clone and Prepare Config (5 min)

### 1.1 Get the deployment files

```bash
# On your VPS:
cd /opt
git clone https://github.com/YOUR_ORG/jarvis-saas-complete.git
cd jarvis-saas-complete
```

Or if you're building locally first and uploading, copy the directory structure.

### 1.2 Generate secrets

```bash
# Generate n8n encryption key (24 hex chars)
N8N_KEY=$(openssl rand -hex 24)
echo "N8N_ENCRYPTION_KEY=$N8N_KEY"

# Generate Onyx secret (32 chars)
ONYX_SECRET=$(openssl rand -base64 32)
echo "ONYX_SECRET=$ONYX_SECRET"

# Generate Inbox Zero secret (32 chars)
INBOX_SECRET=$(openssl rand -base64 32)
echo "INBOX_SECRET=$INBOX_SECRET"
```

Copy these outputs — you'll need them in the next step.

### 1.3 Create and populate .env

```bash
cp deployment/.env.example deployment/.env
nano deployment/.env
```

Fill in these values (the script will tell you which lines):

```
# Domains
ONYX_DOMAIN=onyx.yourdomain.com
N8N_DOMAIN=n8n.yourdomain.com
INBOX_DOMAIN=inbox.yourdomain.com

# Secrets (from step 1.2)
N8N_ENCRYPTION_KEY=<paste the N8N_KEY from above>
ONYX_SECRET=<paste the ONYX_SECRET>
INBOX_SECRET=<paste the INBOX_SECRET>

# Email (for sending agent invites, password resets, notifications)
SMTP_SERVER=smtp.yourprovider.com  # e.g., smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your_app_password  # NOT your regular password; use Gmail App Password or provider equivalent
SMTP_FROM_EMAIL=noreply@yourdomain.com

# Timezone (for scheduling reminders, etc.)
TIMEZONE=Asia/Kolkata  # Change to your timezone

# Optional: Stripe for future billing (leave blank for now)
STRIPE_KEY=
STRIPE_SECRET=
```

**CHECKPOINT:** Run `cat deployment/.env` and confirm all values are filled in and non-empty. ✓

---

## Stage 2: Start the Stack (3-5 min, first-time slower)

### 2.1 Bring up all services

```bash
cd /opt/jarvis-saas-complete
docker compose -f deployment/docker-compose.yml up -d
```

This pulls 3 large images and starts containers. First time takes 2-3 minutes.

### 2.2 Wait for services to be ready

```bash
# Check if all containers are running and healthy
docker compose -f deployment/docker-compose.yml ps

# Watch the logs in real-time (press Ctrl+C to stop)
docker compose -f deployment/docker-compose.yml logs -f
```

Look for these signs of success in the logs:

- `onyx_web_*` container: `Uvicorn running on 0.0.0.0:8000`
- `n8n_*` container: `Server is now accessible via: http://localhost:5678`
- `inbox_web_*` container: `ready - started server on ...`

**CHECKPOINT:** All containers show `Up` status and healthy logs. If any show `Exited`, run:
```bash
docker compose -f deployment/docker-compose.yml logs <container_name>
```
to see the error.

### 2.3 Check HTTPS certificates (Caddy)

```bash
docker compose -f deployment/docker-compose.yml logs caddy | grep -i "success\|issuing"
```

Should show successful certificate issuance for all three domains. If you see DNS errors, go back to Stage 0 checkpoint — DNS isn't resolving yet, or it's cached. Wait a few minutes and retry.

**CHECKPOINT:** Caddy logs show `success` for all three domain certs. ✓

---

## Stage 3: Initialize Each Service (10-15 min)

### 3.1 Onyx First-Run Setup

Visit `https://onyx.yourdomain.com` in your browser.

1. **Create Admin Account**
   - Email: your@email.com
   - Password: strong password (12+ chars)
   - Click "Create Account"

2. **In the Onyx dashboard**
   - Go to **Admin Panel → Users** and note the "API Key" (you may need this later)
   - Go to **Admin Panel → Settings** and set the timezone to match your `.env` TIMEZONE value

**CHECKPOINT:** You can log in to Onyx dashboard and see an empty chat. ✓

### 3.2 n8n First-Run Setup

Visit `https://n8n.yourdomain.com` in your browser.

1. **Create Owner Account**
   - Email: your@email.com
   - Password: strong password
   - Click "Next"

2. **In the n8n dashboard**
   - Go to **Settings → API** and generate an API key
   - Copy and save it (you'll need this when wiring Onyx→n8n)

3. **Create a test webhook**
   - Go to **Workflows** and click **Create Workflow**
   - Name: "Test Webhook"
   - Drag in a **Webhook** node
   - Set it to **POST**, leave path as `test`
   - Add a **Respond to Webhook** node
   - Connect Webhook → Respond
   - **Save & Activate**

At the top, you should see a URL like:
```
https://n8n.yourdomain.com/webhook/test
```

**CHECKPOINT:** Webhook URL works. Test it:
```bash
curl -X POST https://n8n.yourdomain.com/webhook/test \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

Should get back a `200 OK` response (even if error message, the webhook received it).

### 3.3 Inbox Zero First-Run Setup

Visit `https://inbox.yourdomain.com` in your browser.

1. **Create Account**
   - Email: your@email.com
   - Password: strong password
   - Click "Sign Up"

2. **Connect Gmail** (first email inbox to manage)
   - Click **Integrations → Gmail**
   - Follow the OAuth flow to authorize Inbox Zero to access your inbox
   - Return to dashboard — Gmail inbox should be visible

**CHECKPOINT:** You can see your Gmail inbox inside Inbox Zero. ✓

---

## Stage 4: Wire Onyx ↔ n8n (5 min)

This teaches Onyx's chat agent how to trigger n8n automations.

### 4.1 Add n8n as a Custom Tool in Onyx

1. Log into **Onyx** dashboard
2. Go to **Admin Panel → Custom Tools**
3. Click **Add Custom Tool**
4. Paste the entire content of `config/onyx-n8n-integration.openapi.yaml` into the text field
5. Click **Validate** (should show "Valid OpenAPI schema")
6. Click **Save**

**CHECKPOINT:** Tool appears in the Custom Tools list as "Business automation actions". ✓

### 4.2 Test the Integration

In Onyx chat, type:

```
Tell me about the test automation. Can you run it?
```

The agent should:
1. Recognize the automation is available
2. Offer to run it
3. If you say "yes", make a POST request to your n8n webhook
4. Report back the result

If this works, Onyx ↔ n8n is wired correctly.

**CHECKPOINT:** Chat agent successfully calls n8n webhook and reports back. ✓

---

## Stage 5: Connect External Services (Optional, 15-30 min per service)

The stack is now running. Now teach it about your client's real data sources and systems.

### 5.1 Connect to a Database (for charts)

In **Onyx chat**, ask:

```
Connect me to my PostgreSQL database at hostname:5432, 
database "analytics", user "read_only", password "***"
```

Onyx will:
1. Store the credentials securely
2. Test the connection
3. Introspect the schema

Then you can ask Onyx questions like:
```
Show me total revenue by month from the "sales" table
```

And Onyx's built-in Python tool will query, process, and chart it.

### 5.2 Connect to Slack

In **Onyx admin panel**:
1. Go to **Connectors**
2. Click **Add Slack Workspace**
3. Authorize the Slack app in your workspace
4. Onyx can now read Slack channels and post messages

Then in chat:
```
Post a message to #sales: "Q2 report is ready"
```

### 5.3 Connect Gmail/Outlook to n8n

In **n8n**:
1. **Credentials** → **Create new** → **Gmail** (or Outlook)
2. Authorize via OAuth
3. Use these credentials in your automation workflows

### 5.4 Connect WhatsApp (via n8n)

Two options:

**Option A: Official WhatsApp Cloud API (recommended for production)**
1. Create a Meta app at developers.facebook.com
2. Add WhatsApp Business Platform product
3. Get your phone number verified
4. In n8n, create credentials: **WhatsApp Business Cloud API**
5. Paste your access token and phone number ID
6. Use a **WhatsApp Send Message** node in workflows

**Option B: Evolution API (faster demo, unofficial)**
See docs/evolution-api-setup.md for instructions.

---

## Stage 6: Deploy Client #1 (30-60 min)

Now you have a working Jarvis stack. To deploy for a paying client:

### 6.1 Re-brand (swap logos, colors, names)

See `docs/BRANDING.md` for exactly where to change:
- Onyx's logo and app name
- n8n's branding
- Inbox Zero's theme colors

### 6.2 Create a client account in Onyx

In **Onyx Admin → Users**:
1. Click **Add User**
2. Email: client@theircompany.com
3. Role: "Admin" (if they manage other users) or "User"
4. Send invite link

Client receives email, sets password, logs in.

### 6.3 Create Onyx API credentials for the client

In **Onyx Admin → API Keys**:
1. Click **Generate API Key**
2. Name: "Client Dashboard Integration"
3. Copy the key and send to client (or use it in your custom dashboard)

This lets you (or their own system) query Onyx programmatically — e.g., retrieve reports, export chat history.

### 6.4 Configure client data sources

In **Onyx chat** (as the client user):
```
Connect to my Salesforce instance...
```

Onyx asks for credentials, securely stores them in that user's profile, and now that user can ask about their Salesforce data.

---

## Troubleshooting

### Containers won't start

**Error:** `docker: Error response from daemon: Conflict. The container name "/onyx_web_1" is already in use`

**Fix:**
```bash
docker compose -f deployment/docker-compose.yml down  # Stop and remove all containers
docker compose -f deployment/docker-compose.yml up -d  # Start fresh
```

### HTTPS cert not issuing

**Error:** Caddy logs show `DNS lookup failed` or `Timeout`

**Fix:**
- Confirm DNS A records exist and point to your VPS: `nslookup onyx.yourdomain.com`
- Certificates take ~10-60 seconds after DNS starts resolving. Wait and retry.
- If stuck, restart Caddy: `docker compose -f deployment/docker-compose.yml restart caddy`

### n8n webhook not accessible from Onyx

**Error:** Onyx POST to n8n fails with `Connection refused` or `Timeout`

**Reason:** Containers can't reach each other.

**Fix:**
```bash
# Check they're on the same network
docker compose -f deployment/docker-compose.yml ps
docker network ls | grep compose
docker network inspect <network_name> | grep n8n_web
```

If n8n container isn't in the network, recreate the stack:
```bash
docker compose -f deployment/docker-compose.yml down
docker compose -f deployment/docker-compose.yml up -d
```

### Onyx can't send emails

**Error:** Onyx logs show SMTP authentication failure

**Fix:**
- If using Gmail: Go to myaccount.google.com → Security → App passwords. Generate a 16-char password and use that as SMTP_PASSWORD (not your account password).
- Test SMTP credentials independently:
  ```bash
  openssl s_client -connect smtp.gmail.com:587 -starttls smtp
  # Type: auth login
  # Paste base64-encoded username and password
  ```

---

## What's Next: Building for Multiple Clients

This setup runs one client per VPS. For multi-tenant SaaS (many clients on one instance), see `docs/MULTI_TENANT_ROADMAP.md`.

For now: one VPS = one client. Repeat this entire process for each new client, or automate the stack provisioning with the script in `scripts/provision-client.sh`.

---

## Support & Customization

- **Onyx docs:** https://docs.onyx.app
- **n8n docs:** https://docs.n8n.io
- **Inbox Zero:** https://github.com/elie222/inbox-zero

Each project is actively maintained. Check their changelogs when upgrading:
```bash
docker compose -f deployment/docker-compose.yml pull  # Pull latest images
docker compose -f deployment/docker-compose.yml up -d  # Restart with new versions
```
