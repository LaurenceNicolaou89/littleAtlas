# Little Atlas — Oracle Cloud Deployment Guide

## Prerequisites
- Oracle Cloud account (Always Free tier — credit card required but never charged)
- A domain name (free options: afraid.org, duckdns.org, or your own)
- API keys: OpenWeatherMap (free tier), Google Places

## 1. Create the VM
- Oracle Cloud Console → Compute → Instances → Create Instance
- Name: `littleatlas`
- Image: Canonical Ubuntu 22.04 (aarch64)
- Shape: VM.Standard.A1.Flex → 4 OCPUs, 24GB RAM
- Networking: Create new VCN, assign public IP
- SSH key: Upload your public key or let Oracle generate one
- Boot volume: 50GB (default, free up to 200GB)

## 2. Configure Firewall
Oracle has TWO firewalls that both must allow traffic.

**Security List** (Cloud Console → Networking → VCN → Security Lists → Default):
- Add ingress: Source `0.0.0.0/0`, TCP, Port 80
- Add ingress: Source `0.0.0.0/0`, TCP, Port 443

**VM iptables** (after SSH):
```bash
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
sudo netfilter-persistent save
```

## 3. Install Docker
```bash
sudo apt update && sudo apt upgrade -y
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
logout
# SSH back in
sudo apt install -y docker-compose-plugin
docker --version
```

## 4. Clone and Configure
```bash
git clone https://github.com/LaurenceNicolaou89/littleAtlas.git
cd littleAtlas
```

Create `.env`:
```bash
cat > .env << 'ENVEOF'
DOMAIN=littleatlas.yourdomain.com
POSTGRES_USER=atlas
POSTGRES_PASSWORD=CHANGE_ME
OPENWEATHERMAP_API_KEY=your_key_here
GOOGLE_PLACES_API_KEY=your_key_here
ENVEOF
```

Generate a secure DB password:
```bash
sed -i "s/CHANGE_ME/$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)/" .env
```

## 5. Set Up DNS
- Create A record: `littleatlas.yourdomain.com` → `<VM public IP>`
- Wait 5-15 minutes for propagation
- Verify: `dig littleatlas.yourdomain.com`

## 6. Deploy
```bash
docker compose -f docker-compose.oracle.yml up -d
```
Wait ~60 seconds. Caddy automatically obtains SSL certificate.

## 7. Initialize Database
```bash
docker compose -f docker-compose.oracle.yml exec api alembic upgrade head
docker compose -f docker-compose.oracle.yml exec api python -m db.seed
```

## 8. Verify
```bash
docker compose -f docker-compose.oracle.yml ps
curl https://littleatlas.yourdomain.com/api/v1/health
docker compose -f docker-compose.oracle.yml logs -f api
```

## 9. Update Mobile App
Set the API base URL in the Flutter app:
```
API_BASE_URL=https://littleatlas.yourdomain.com/api/v1
```
This is configured via `String.fromEnvironment` in `mobile/lib/config/api_config.dart`.

## Updating
```bash
cd ~/littleAtlas
git pull
docker compose -f docker-compose.oracle.yml up -d --build
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Caddy can't get SSL cert | Verify DNS points to VM IP. Check both Security List AND iptables allow ports 80/443 |
| DB connection refused | Run `docker compose ps` — db must show "healthy". Check POSTGRES_PASSWORD in .env |
| Crawlers not running | Run `docker compose logs api` — look for "Scheduler started" |
| Out of disk space | Run `docker system prune -a` to clean old images |
| API unreachable | Check `docker compose logs caddy` for errors. Verify domain resolves correctly |

## Cost
Fully free on Oracle Cloud Always Free tier:
- VM: A1.Flex (4 OCPUs, 24GB RAM) — $0/mo
- Storage: 200GB boot volume — $0/mo
- Network: 10TB outbound — $0/mo
- No time limits, no credit expiry
