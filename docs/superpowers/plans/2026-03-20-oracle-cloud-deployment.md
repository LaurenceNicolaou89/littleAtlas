# Oracle Cloud Deployment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create deployment configs and docs to run Little Atlas on Oracle Cloud Always Free ARM VM with Docker Compose and automatic HTTPS via Caddy.

**Architecture:** Docker Compose stack with 4 services (API, PostgreSQL/PostGIS, Redis, Caddy). Caddy handles SSL termination and reverse proxying. All services on an internal Docker network — only ports 80/443 exposed.

**Tech Stack:** Docker Compose, Caddy 2, PostgreSQL 16 + PostGIS 3.4, Redis 7, Let's Encrypt

**Spec:** `docs/superpowers/specs/2026-03-20-oracle-cloud-deployment-design.md`

---

## File Structure

### New Files

| File | Responsibility |
|------|---------------|
| `Caddyfile` | Caddy reverse proxy config — domain → api:8000 |
| `docker-compose.oracle.yml` | Production Docker Compose with Caddy, persistent volumes, restart policies, no exposed DB/Redis ports |
| `docs/deployment-oracle.md` | Step-by-step guide for Oracle Cloud VM setup and deployment |

### No Modified Files

Existing code is unchanged. The Dockerfile and backend work as-is.

---

### Task 1: Caddyfile

**Files:**
- Create: `Caddyfile`

- [ ] **Step 1: Create Caddyfile**

```
{$DOMAIN} {
    reverse_proxy api:8000
}
```

This is the entire file. Caddy reads the `DOMAIN` env var, obtains a Let's Encrypt cert, and proxies all traffic to the `api` service on port 8000.

- [ ] **Step 2: Commit**

```bash
git add Caddyfile
git commit -m "chore: add Caddyfile for Caddy reverse proxy"
```

---

### Task 2: Docker Compose Oracle

**Files:**
- Create: `docker-compose.oracle.yml`

- [ ] **Step 1: Create docker-compose.oracle.yml**

```yaml
# Oracle Cloud Always Free deployment
#
# Prerequisites:
#   - Oracle Cloud ARM VM (A1.Flex, 4 OCPUs, 24GB RAM)
#   - Docker + Docker Compose installed
#   - Domain DNS A record pointing to VM's public IP
#   - .env file with required variables (see docs/deployment-oracle.md)
#
# Usage:
#   docker compose -f docker-compose.oracle.yml up -d
#   docker compose -f docker-compose.oracle.yml logs -f

services:
  caddy:
    image: caddy:2-alpine
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    environment:
      - DOMAIN=${DOMAIN}
    depends_on:
      - api
    networks:
      - littleatlas

  api:
    build: ./backend
    restart: unless-stopped
    expose:
      - "8000"
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    environment:
      - DATABASE_URL=postgresql+asyncpg://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/littleatlas
      - REDIS_URL=redis://redis:6379
      - OPENWEATHERMAP_API_KEY=${OPENWEATHERMAP_API_KEY}
      - GOOGLE_PLACES_API_KEY=${GOOGLE_PLACES_API_KEY}
      - ENVIRONMENT=production
    command: uvicorn main:app --host 0.0.0.0 --port 8000 --workers 2
    networks:
      - littleatlas

  db:
    image: postgis/postgis:16-3.4
    restart: unless-stopped
    environment:
      POSTGRES_DB: littleatlas
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d littleatlas"]
      interval: 5s
      timeout: 5s
      retries: 5
    networks:
      - littleatlas

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes
    networks:
      - littleatlas

volumes:
  postgres_data:
  redis_data:
  caddy_data:
  caddy_config:

networks:
  littleatlas:
    driver: bridge
```

Key differences from `docker-compose.prod.yml`:
- Caddy service added (ports 80/443)
- API uses `expose` instead of `ports` (not publicly accessible, only via Caddy)
- DB and Redis have NO exposed ports
- Redis has persistent volume + AOF persistence
- All services have `restart: unless-stopped`
- Explicit bridge network `littleatlas`

- [ ] **Step 2: Verify compose file is valid**

```bash
docker compose -f docker-compose.oracle.yml config --quiet
```

Expected: no output (valid file).

- [ ] **Step 3: Commit**

```bash
git add docker-compose.oracle.yml
git commit -m "chore: add Oracle Cloud Docker Compose with Caddy SSL"
```

---

### Task 3: Deployment Guide

**Files:**
- Create: `docs/deployment-oracle.md`

- [ ] **Step 1: Create docs/deployment-oracle.md**

Write a step-by-step deployment guide with these sections:

**1. Prerequisites**
- Oracle Cloud account (Always Free tier)
- A domain name (free options: afraid.org, duckdns.org, or your own)
- API keys: OpenWeatherMap, Google Places

**2. Create the VM**
- Log into Oracle Cloud Console → Compute → Instances → Create Instance
- Name: `littleatlas`
- Image: Canonical Ubuntu 22.04 (aarch64)
- Shape: VM.Standard.A1.Flex → 4 OCPUs, 24GB RAM
- Networking: Create new VCN, assign public IP
- SSH key: Upload your public key or let Oracle generate one
- Click Create

**3. Configure Firewall**

Oracle Cloud has TWO firewalls — the Security List (cloud-level) AND iptables (VM-level). Both must allow traffic.

Security List (Cloud Console → Networking → VCN → Security Lists → Default):
- Add ingress rule: Source `0.0.0.0/0`, TCP, Port 80
- Add ingress rule: Source `0.0.0.0/0`, TCP, Port 443

VM iptables (after SSH):
```bash
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
sudo netfilter-persistent save
```

**4. Install Docker**
```bash
sudo apt update && sudo apt upgrade -y
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# Log out and back in for group change
sudo apt install -y docker-compose-plugin
docker --version
```

**5. Clone and Configure**
```bash
git clone https://github.com/LaurenceNicolaou89/littleAtlas.git
cd littleAtlas
```

Create `.env`:
```bash
cat > .env << 'EOF'
DOMAIN=littleatlas.yourdomain.com
POSTGRES_USER=atlas
POSTGRES_PASSWORD=CHANGE_ME_TO_RANDOM_STRING
OPENWEATHERMAP_API_KEY=your_key_here
GOOGLE_PLACES_API_KEY=your_key_here
EOF
```

Generate a secure password:
```bash
sed -i "s/CHANGE_ME_TO_RANDOM_STRING/$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)/" .env
```

**6. Set Up DNS**
- Go to your domain provider
- Create an A record: `littleatlas.yourdomain.com` → `<VM public IP>`
- Wait for DNS propagation (usually 5-15 minutes)
- Verify: `dig littleatlas.yourdomain.com` should return your VM's IP

**7. Deploy**
```bash
docker compose -f docker-compose.oracle.yml up -d
```

Wait ~30 seconds for all services to start. Caddy will automatically obtain an SSL certificate.

**8. Seed the Database**
```bash
docker compose -f docker-compose.oracle.yml exec api python -m db.seed
docker compose -f docker-compose.oracle.yml exec api alembic upgrade head
```

**9. Verify**
```bash
# Check all services are running
docker compose -f docker-compose.oracle.yml ps

# Test the API
curl https://littleatlas.yourdomain.com/api/v1/health

# Check logs
docker compose -f docker-compose.oracle.yml logs -f api
```

**10. Update Mobile App**
In the Flutter app, update the API base URL:
```
API_BASE_URL=https://littleatlas.yourdomain.com/api/v1
```
This is set via `String.fromEnvironment` in `mobile/lib/config/api_config.dart`.

**11. Updating**
```bash
cd ~/littleAtlas
git pull
docker compose -f docker-compose.oracle.yml up -d --build
```

**12. Troubleshooting**

| Issue | Fix |
|-------|-----|
| Caddy can't get SSL cert | Verify DNS points to VM IP, ports 80/443 open in BOTH security list and iptables |
| DB connection refused | Check `docker compose ps` — db should be "healthy". Check POSTGRES_PASSWORD in .env |
| Crawlers not running | Check `docker compose logs api` — APScheduler should log "Scheduler started" |
| Out of disk space | `docker system prune -a` to clean old images |

- [ ] **Step 2: Commit**

```bash
git add docs/deployment-oracle.md
git commit -m "docs: add Oracle Cloud deployment guide"
```

---

## Summary

| Task | Files | Description |
|------|-------|-------------|
| 1 | `Caddyfile` | 3-line reverse proxy config |
| 2 | `docker-compose.oracle.yml` | Production compose with Caddy, volumes, network |
| 3 | `docs/deployment-oracle.md` | Complete VM setup + deployment guide |

**Total: 3 tasks, ~8 steps**
