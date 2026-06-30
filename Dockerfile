# Jarvis AI Manager SaaS - Docker Compose Stack
# This is a multi-service application (Onyx, n8n, Inbox Zero, Caddy)
# Railway does not natively support docker-compose, so each service must be deployed separately.
#
# For Railway deployment, deploy each service individually:
# 1. Onyx (Chat AI) - ghcr.io/onyx-ai/onyx-backend:0.3-v0
# 2. n8n (Automation) - n8n/n8n:1.60.0-latest
# 3. Inbox Zero (Email) - ghcr.io/elie222/inbox-zero:latest
# 4. PostgreSQL databases (one per service)
# 5. Redis instances (one per service)
# 6. MinIO (for Onyx file storage)
#
# See deployment/docker-compose.yml for the full stack configuration.
# See DEPLOYMENT_GUIDE.md for detailed setup instructions.

FROM alpine:latest
RUN echo "Jarvis AI Manager SaaS - Multi-service stack" && \
    echo "See DEPLOYMENT_GUIDE.md for Railway deployment instructions"
CMD ["echo", "This is a multi-service application. Deploy each service separately to Railway."]

