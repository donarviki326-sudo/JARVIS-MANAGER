#!/bin/bash
set -e

# Jarvis AI Manager - Docker Swarm Deployment Script
# Usage: bash deploy-swarm.sh

echo "🚀 Jarvis AI Manager - Docker Swarm Deployment"
echo "=============================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
  echo "❌ This script must be run as root"
  exit 1
fi

# Step 1: Update system
echo "📦 Updating system packages..."
apt-get update > /dev/null 2>&1
apt-get upgrade -y > /dev/null 2>&1

# Step 2: Install Docker
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh > /dev/null 2>&1
  rm get-docker.sh
else
  echo "   Docker already installed"
fi

# Step 3: Initialize Swarm
echo "🔄 Initializing Docker Swarm..."
if ! docker info | grep -q "Swarm: active"; then
  docker swarm init > /dev/null 2>&1
  echo "   ✓ Swarm initialized"
else
  echo "   Swarm already active"
fi

# Step 4: Create .env if it doesn't exist
if [ ! -f /root/.env ]; then
  echo "📝 Creating .env file..."
  cat > /root/.env << 'EOF'
# Domain Configuration
ONYX_DOMAIN=onyx.yourdomain.com
N8N_DOMAIN=n8n.yourdomain.com
INBOX_DOMAIN=inbox.yourdomain.com

# Timezone
TIMEZONE=UTC

# Onyx Configuration
ONYX_DB_PASSWORD=change_me_strong_password
ONYX_MINIO_PASSWORD=change_me_strong_password
ONYX_SECRET=change_me_strong_secret
GOOGLE_OAUTH_CLIENT_ID=
GOOGLE_OAUTH_CLIENT_SECRET=
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=
SMTP_PASSWORD=
SMTP_FROM_EMAIL=noreply@yourdomain.com

# n8n Configuration
N8N_DB_PASSWORD=change_me_strong_password
N8N_ENCRYPTION_KEY=change_me_strong_encryption_key
ADMIN_EMAIL=admin@yourdomain.com
N8N_DEFAULT_PASSWORD=change_me_strong_password

# Inbox Zero Configuration
INBOX_DB_PASSWORD=change_me_strong_password
INBOX_SECRET=change_me_strong_secret
OPENAI_API_KEY=
EOF
  echo "   ⚠️  .env created with defaults. Edit /root/.env with your values!"
  echo "   Then run this script again."
  exit 0
fi

# Step 5: Load environment variables
echo "🔐 Loading environment variables..."
export $(cat /root/.env | xargs)

# Step 6: Deploy stack
echo "🚀 Deploying Jarvis stack..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
docker stack deploy -c "$SCRIPT_DIR/deployment/docker-compose.yml" jarvis > /dev/null 2>&1

# Step 7: Wait for services to start
echo "⏳ Waiting for services to start (this may take 2-3 minutes)..."
sleep 5

# Step 8: Check status
echo ""
echo "📊 Stack Status:"
docker stack ps jarvis --no-trunc

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Configure DNS for your domains:"
echo "      - onyx.$ONYX_DOMAIN → $(hostname -I | awk '{print $1}')"
echo "      - n8n.$N8N_DOMAIN → $(hostname -I | awk '{print $1}')"
echo "      - inbox.$INBOX_DOMAIN → $(hostname -I | awk '{print $1}')"
echo ""
echo "   2. Wait for DNS propagation (5-15 minutes)"
echo ""
echo "   3. Access your services:"
echo "      - Onyx: https://$ONYX_DOMAIN"
echo "      - n8n: https://$N8N_DOMAIN"
echo "      - Inbox Zero: https://$INBOX_DOMAIN"
echo ""
echo "   4. View logs: docker service logs jarvis_SERVICE_NAME"
echo ""
echo "📚 Full guide: See DOCKER_SWARM_SETUP.md"

