# Little Atlas — Oracle Cloud Deployment Design Spec

Deploy the full Little Atlas stack (FastAPI + PostgreSQL/PostGIS + Redis + crawlers) on an Oracle Cloud Always Free ARM VM with Docker Compose and automatic HTTPS via Caddy.

---

## 1. Infrastructure

### Oracle Cloud VM

- **Shape:** VM.Standard.A1.Flex (ARM Ampere A1)
- **Resources:** 4 OCPUs, 24GB RAM (Always Free tier max)
- **OS:** Ubuntu 22.04 LTS (Canonical aarch64 image)
- **Storage:** 200GB boot volume (Always Free allows up to 200GB total)
- **Network:** Public IP assigned, VCN with security list

### Firewall / Security List Rules

| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 22 | TCP | Your IP only | SSH access |
| 80 | TCP | 0.0.0.0/0 | HTTP (Caddy redirects to HTTPS) |
| 443 | TCP | 0.0.0.0/0 | HTTPS (Caddy + Let's Encrypt) |

All other ports blocked. PostgreSQL (5432) and Redis (6379) are NOT exposed — only accessible within Docker network.

---

## 2. Docker Compose Stack

### Services

| Service | Image | Port | Notes |
|---------|-------|------|-------|
| `api` | Built from `backend/Dockerfile` | 8000 (internal) | FastAPI + APScheduler crawlers |
| `db` | `postgis/postgis:15-3.3` | 5432 (internal) | PostgreSQL + PostGIS, persistent volume |
| `redis` | `redis:7-alpine` | 6379 (internal) | Cache, persistent volume |
| `caddy` | `caddy:2-alpine` | 80, 443 (public) | Reverse proxy, auto-SSL |

### Volumes

| Volume | Mount | Purpose |
|--------|-------|---------|
| `postgres_data` | `/var/lib/postgresql/data` | Database persistence |
| `redis_data` | `/data` | Redis persistence |
| `caddy_data` | `/data` | SSL certificates |
| `caddy_config` | `/config` | Caddy config cache |

### Network

Single Docker bridge network `littleatlas`. All services communicate internally. Only Caddy exposes ports 80/443.

### Restart Policy

All services: `restart: unless-stopped` — auto-restart on crash or VM reboot.

---

## 3. Caddy Configuration

```
{$DOMAIN} {
    reverse_proxy api:8000
}
```

Caddy automatically:
- Obtains Let's Encrypt SSL certificate for the domain
- Redirects HTTP → HTTPS
- Auto-renews certificates before expiry
- Handles TLS termination

The domain is set via `DOMAIN` environment variable in `.env`.

---

## 4. Environment Variables

Production `.env` file on the VM (never committed):

```
# Domain
DOMAIN=littleatlas.example.com

# Database
POSTGRES_USER=atlas
POSTGRES_PASSWORD=<strong-random-password>
POSTGRES_DB=littleatlas
DATABASE_URL=postgresql://atlas:<password>@db:5432/littleatlas

# Redis
REDIS_URL=redis://redis:6379/0

# API Keys
GOOGLE_PLACES_API_KEY=<key>
OPENWEATHERMAP_API_KEY=<key>

# App
API_HOST=0.0.0.0
API_PORT=8000
ENVIRONMENT=production
```

---

## 5. Files to Create

| File | Purpose |
|------|---------|
| `docker-compose.oracle.yml` | Production Docker Compose with Caddy, volumes, restart policies |
| `Caddyfile` | Reverse proxy configuration |
| `docs/deployment-oracle.md` | Step-by-step VM setup guide |

### docker-compose.oracle.yml

Based on existing `docker-compose.prod.yml` but adds:
- Caddy service with ports 80/443
- Named volumes for all persistent data
- `restart: unless-stopped` on all services
- Internal Docker network (no exposed DB/Redis ports)
- Platform `linux/arm64` for ARM compatibility
- Environment variables from `.env` file

### Caddyfile

3-line config: domain → reverse_proxy to api:8000.

### docs/deployment-oracle.md

Step-by-step guide covering:

1. **Create Oracle Cloud account** (free tier, credit card required but not charged)
2. **Create VM instance** — select Always Free A1 shape, Ubuntu 22.04 aarch64, download SSH key
3. **Configure security list** — open ports 22, 80, 443
4. **SSH into VM** — `ssh -i key.pem ubuntu@<public-ip>`
5. **Install Docker** — `curl -fsSL https://get.docker.com | sh && sudo usermod -aG docker $USER`
6. **Install Docker Compose** — `sudo apt install docker-compose-plugin`
7. **Clone repo** — `git clone https://github.com/LaurenceNicolaou89/littleAtlas.git`
8. **Create .env** — copy template, fill in secrets
9. **Set up domain DNS** — A record pointing to VM's public IP
10. **Configure Ubuntu firewall** — `sudo iptables` rules to match security list
11. **Deploy** — `docker compose -f docker-compose.oracle.yml up -d`
12. **Verify** — `curl https://yourdomain.com/api/v1/health`
13. **Updates** — `git pull && docker compose -f docker-compose.oracle.yml up -d --build`

---

## 6. What Does NOT Change

- Backend code — no changes needed, same FastAPI app
- Dockerfile — existing `backend/Dockerfile` works (may need multi-arch build if currently x86-only)
- Database schema — same PostgreSQL + PostGIS
- Crawler schedule — same APScheduler config
- Mobile app — just update `API_BASE_URL` to the new domain

## 7. Risks

- **ARM compatibility:** The `postgis/postgis` image supports ARM. Verify `backend/Dockerfile` base image also supports `linux/arm64` (most Python images do).
- **Oracle Free Tier limits:** 4 OCPUs / 24GB RAM shared across all free VMs. If you create other VMs, resources are split.
- **Let's Encrypt rate limits:** 50 certs per domain per week. Not an issue for a single domain.
