# Gitpod Quick Start (5 Minutes to Testing)

## Step 1: Push to GitHub (If Not Already There)

You need your files on GitHub for Gitpod to work.

### Option A: If you already have a GitHub repo with these files

Just use your repo URL.

### Option B: Quick setup (2 min)

```bash
# Create a new GitHub repo at github.com/new
# Name it: jarvis-saas-complete

# Then locally:
git init
git add .
git commit -m "Initial Jarvis SaaS setup"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/jarvis-saas-complete.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your actual GitHub username.

---

## Step 2: Click the Gitpod Link

Replace `YOUR_USERNAME` in this URL and click:

```
https://gitpod.io/#https://github.com/YOUR_USERNAME/jarvis-saas-complete
```

**Example:**
If your username is `john_doe`, the link is:
```
https://gitpod.io/#https://github.com/john_doe/jarvis-saas-complete
```

### Or use this button (customize after):

```markdown
[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/YOUR_USERNAME/jarvis-saas-complete)
```

---

## Step 3: Wait for Setup (3-5 Minutes)

You'll see:

```
🚀 Starting workspace...
📦 Installing dependencies...
🐳 Starting Docker...
🔧 Generating secrets...
⏳ Starting services (60 seconds)...
✅ Done!
```

**The terminal will show:**

```
════════════════════════════════════════════════════════
✓ JARVIS SAAS STACK IS RUNNING
════════════════════════════════════════════════════════

Access the services at:
  • Onyx Chat:      http://localhost:8000
  • n8n Automation: http://localhost:5678
  • Inbox Zero:     http://localhost:3000

Default login:
  Email: admin@test.com
  Password: test123!
════════════════════════════════════════════════════════
```

---

## Step 4: Access Services

Gitpod automatically opens browser tabs for:
- **Onyx** (http://localhost:8000) — main chat interface
- **n8n** (http://localhost:5678) — automation builder
- **Inbox Zero** (http://localhost:3000) — email management

If tabs don't open, click the port numbers in Gitpod's bottom panel.

---

## Step 5: Log In & Test

### All Services Use Same Credentials:
```
Email: admin@test.com
Password: test123!
```

### Quick Test:

1. **Onyx:** Go to chat, type `"Hello"`
2. **n8n:** Create a test workflow
3. **Inbox Zero:** Check email dashboard
4. **Wire them:** Import OpenAPI spec in Onyx admin

---

## Editing & Changes

### Make Changes in Gitpod

1. Click Files panel (left side)
2. Edit any file
3. Save (Ctrl+S)
4. Restart service:
   ```bash
   docker compose -f deployment/docker-compose.yml restart onyx_web
   ```

### Common Edits:

**Change .env:**
```bash
nano deployment/.env
# Edit, save, restart service
```

**Edit docker-compose.yml:**
```bash
nano deployment/docker-compose.yml
# Edit, save, restart all
docker compose -f deployment/docker-compose.yml down
docker compose -f deployment/docker-compose.yml up -d
```

**Edit OpenAPI spec:**
```bash
nano config/onyx-n8n-integration.openapi.yaml
# Re-import in Onyx Admin → Custom Tools
```

---

## Stop & Resume

### Pause (Keep Data)
```bash
docker compose -f deployment/docker-compose.yml down
```

**Next session:** Services restart automatically OR run:
```bash
docker compose -f deployment/docker-compose.yml up -d
```

### Clean Slate
```bash
docker compose -f deployment/docker-compose.yml down -v
```

---

## Troubleshooting

### Services Not Starting?

```bash
# Check status
docker compose -f deployment/docker-compose.yml ps

# Check logs
docker compose -f deployment/docker-compose.yml logs --tail=50

# Restart all
docker compose -f deployment/docker-compose.yml restart
```

### Can't Access Service?

```bash
# Check if it's running
docker ps | grep onyx_web  # or n8n_web, inbox_web

# Restart it
docker compose -f deployment/docker-compose.yml restart onyx_web
```

### Connection Refused?

```bash
# Wait 30 more seconds (services take time to be ready)
sleep 30

# Then access again
```

### Out of Free Hours?

Free tier = 40 hours/month.
- Stop services when not using: `docker compose down`
- Restart when testing: `docker compose up -d`

---

## Commit Changes Before Leaving

When you make changes in Gitpod, save them to GitHub:

```bash
git add .
git commit -m "Describe your changes here"
git push
```

Then when you deploy to production, pull the same files:

```bash
git clone https://github.com/YOUR_USERNAME/jarvis-saas-complete.git
cd jarvis-saas-complete
# Follow DEPLOYMENT_GUIDE.md
```

---

## Next: Deploy to Production

Once tested in Gitpod and happy with changes:

1. **Download/commit all files**
2. **Get a $6/mo VPS** (Hetzner, DigitalOcean, etc.)
3. **Follow DEPLOYMENT_GUIDE.md**
4. **Same stack, no changes needed**

---

## Complete Gitpod Checklist

- [ ] GitHub account created
- [ ] Files pushed to GitHub repo
- [ ] Gitpod link working
- [ ] Environment spins up (5 min)
- [ ] All 3 services running
- [ ] Can access Onyx, n8n, Inbox Zero
- [ ] Logged into each service
- [ ] Imported OpenAPI spec
- [ ] Tested Onyx ↔ n8n integration
- [ ] Made and tested changes
- [ ] Committed changes to GitHub
- [ ] Ready to deploy to VPS

---

## Support

- **Gitpod Help:** https://www.gitpod.io/docs
- **Docker Issues:** `docker compose logs`
- **Onyx Docs:** https://docs.onyx.app
- **n8n Docs:** https://docs.n8n.io

---

**Ready? Click your Gitpod link and start testing! 🚀**

```
https://gitpod.io/#https://github.com/YOUR_USERNAME/jarvis-saas-complete
```
