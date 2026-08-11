# VPS Reference

## Table of Contents
1. [Initial Server Setup](#initial-server-setup)
2. [nginx](#nginx)
3. [SSL/TLS with Certbot](#ssltls-with-certbot)
4. [Docker on VPS](#docker-on-vps)
5. [Firewall (ufw)](#firewall-ufw)
6. [Process Management](#process-management)
7. [Monitoring & Alerting](#monitoring--alerting)

---

## Initial Server Setup

### First Login Checklist (Ubuntu/Debian)
```bash
# Update system
apt update && apt upgrade -y

# Create non-root user
adduser deploy
usermod -aG sudo deploy

# Copy SSH key to new user
rsync --archive --chown=deploy:deploy ~/.ssh /home/deploy

# Test login as deploy, then disable root SSH
```

### SSH Hardening (`/etc/ssh/sshd_config`)
```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
MaxAuthTries 3
LoginGraceTime 20
X11Forwarding no
AllowTcpForwarding no
```
```bash
systemctl restart sshd
```

### Fail2ban (brute force protection)
```bash
apt install fail2ban -y
# /etc/fail2ban/jail.local
[sshd]
enabled = true
maxretry = 3
bantime = 3600
findtime = 600
```

---

## nginx

### Reverse Proxy Config (standard API)
```nginx
server {
    listen 80;
    server_name api.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.example.com;

    ssl_certificate /etc/letsencrypt/live/api.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.example.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Strict-Transport-Security "max-age=31536000" always;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### nginx for SSE (AI streaming responses)
```nginx
location /stream {
    proxy_pass http://localhost:3000;
    proxy_buffering off;          # Critical for SSE
    proxy_cache off;
    proxy_set_header Connection '';
    proxy_http_version 1.1;
    chunked_transfer_encoding on;
    proxy_read_timeout 3600s;     # Long timeout for streaming
}
```

### Rate Limiting
```nginx
# In http block
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

# In location block
limit_req zone=api burst=20 nodelay;
```

---

## SSL/TLS with Certbot

```bash
# Install
apt install certbot python3-certbot-nginx -y

# Issue cert (nginx plugin handles everything)
certbot --nginx -d example.com -d www.example.com

# Auto-renewal (already set up by certbot, but verify)
certbot renew --dry-run

# Wildcard cert (requires DNS challenge)
certbot certonly --manual --preferred-challenges dns -d "*.example.com"
```

---

## Docker on VPS

### Install Docker (Ubuntu)
```bash
curl -fsSL https://get.docker.com | sh
usermod -aG docker deploy
```

### docker-compose for Production
```yaml
version: '3.8'
services:
  app:
    image: myapp:latest
    restart: unless-stopped
    environment:
      - NODE_ENV=production
    env_file: .env.production
    ports:
      - "127.0.0.1:3000:3000"   # Bind to localhost only — nginx proxies
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  postgres:
    image: postgres:16-alpine
    restart: unless-stopped
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt

volumes:
  pgdata:
```

### Container Security
- Never run containers as root — add `user: "1000:1000"` or use `USER` in Dockerfile
- Use read-only root filesystem: `read_only: true`
- Drop capabilities: `cap_drop: [ALL]`, add back only what's needed
- Pin image versions — never use `latest` in production

### Docker Cleanup & Disk Hygiene

Docker silently accumulates garbage: stopped containers, dangling images, orphaned volumes, build cache. On active VPS this easily reaches 50-100GB.

#### Manual Cleanup
```bash
# Nuclear option — remove ALL unused resources (containers, images, networks, build cache)
docker system prune -a --volumes -f

# Selective cleanup (safer for production)
docker image prune -a -f                    # Remove unused images
docker container prune -f                   # Remove stopped containers
docker volume prune -f                      # Remove orphaned volumes (⚠️ check first!)
docker builder prune -a -f                  # Remove build cache (biggest offender with multi-stage)

# Check what's eating disk BEFORE pruning
docker system df                            # Overview: images, containers, volumes, build cache
docker system df -v                         # Detailed breakdown per image/volume
```

#### Automated Cron Cleanup
```bash
# /etc/cron.d/docker-cleanup
# Run daily at 3am — prune images older than 72h, remove stopped containers and build cache
0 3 * * * root docker image prune -a --filter "until=72h" -f >> /var/log/docker-cleanup.log 2>&1
0 3 * * * root docker container prune -f >> /var/log/docker-cleanup.log 2>&1
0 3 * * * root docker builder prune -a --filter "until=72h" -f >> /var/log/docker-cleanup.log 2>&1
```

#### Disk Alert (add to existing monitoring cron)
```bash
#!/bin/bash
# /opt/scripts/disk-alert.sh
THRESHOLD=80
DISK=$(df / | awk 'NR==2{print $5}' | tr -d '%')
DOCKER_DISK=$(docker system df --format '{{.Size}}' | head -1)

if [ "$DISK" -gt "$THRESHOLD" ]; then
  curl -s -X POST "$SLACK_WEBHOOK" \
    -d "{\"text\":\"🚨 Disk at ${DISK}% — Docker using ${DOCKER_DISK}. Run: docker system prune -a --volumes -f\"}"
fi
```

#### Prevent Garbage at Build Time
```dockerfile
# Multi-stage build — final image has NO build deps, no cache layers
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN corepack enable && pnpm install --frozen-lockfile --ignore-scripts
COPY . .
RUN pnpm build

FROM node:20-alpine AS runner
WORKDIR /app
RUN addgroup -g 1001 -S app && adduser -S app -u 1001
COPY --from=builder --chown=app:app /app/dist ./dist
COPY --from=builder --chown=app:app /app/node_modules ./node_modules
COPY --from=builder --chown=app:app /app/package.json ./
USER app
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

#### Variante Bun — más rápido para APIs y scripts
```dockerfile
# Variante Bun — más rápido para APIs y scripts
FROM oven/bun:1-alpine AS deps-bun
WORKDIR /app
COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile --production

FROM oven/bun:1-alpine AS builder-bun
WORKDIR /app
COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile
COPY . .
RUN bun run build

FROM oven/bun:1-alpine AS runner-bun
WORKDIR /app
COPY --from=deps-bun /app/node_modules ./node_modules
COPY --from=builder-bun /app/dist ./dist
COPY package.json .
USER bun
EXPOSE 3000
CMD ["bun", "run", "dist/index.js"]
```

### Monorepo Docker Builds (pnpm/turborepo/nx)

Monorepos break Docker builds because dependencies live at the root, not inside each app. The key problems:

1. **Lockfile is at root** — `pnpm-lock.yaml` / `package-lock.json` is in `/`, not in `/apps/web`
2. **Workspace resolution** — packages reference each other via `workspace:*`
3. **Build context** — Dockerfile in `apps/web/` can't see `../pnpm-lock.yaml`

#### Solution: Build context = root, Dockerfile in app

```yaml
# docker-compose.yml
services:
  web:
    build:
      context: ..              # Root of monorepo
      dockerfile: apps/web/Dockerfile.prod  # Dockerfile inside app
```

#### Monorepo Dockerfile Pattern (pnpm)
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
RUN npm install -g pnpm

# 1. Copy workspace config + lockfile from root
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# 2. Copy only this app's package.json (for cache efficiency)
COPY apps/web/package.json ./apps/web/

# 3. Install from root (resolves workspace deps)
RUN pnpm install --frozen-lockfile

# 4. Copy app source
COPY apps/web/ ./apps/web/

# 5. Build from app directory
WORKDIR /app/apps/web
RUN pnpm build

# --- Production stage ---
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# For Next.js standalone output
COPY --from=builder /app/apps/web/.next/standalone ./
COPY --from=builder /app/apps/web/.next/static ./apps/web/.next/static
EXPOSE 3000
CMD ["node", "apps/web/server.js"]

# For NestJS / generic Node
# COPY --from=builder /app/apps/api/dist ./dist
# COPY --from=builder /app/apps/api/node_modules ./node_modules
# COPY --from=builder /app/apps/api/package.json ./
# CMD ["node", "dist/main.js"]
```

#### Common Monorepo Docker Mistakes
| Mistake | Symptom | Fix |
|---------|---------|-----|
| Context is `apps/web/` not root | `pnpm-lock.yaml` not found, deps missing | Set `context: ..` in compose |
| Using `--frozen-lockfile` without lockfile | Build fails on `pnpm install` | Use `--no-frozen-lockfile` or copy lockfile |
| Not copying `pnpm-workspace.yaml` | workspace protocol `workspace:*` fails | Copy it in step 1 |
| `.dockerignore` at wrong level | Sends GB of `node_modules` as context | Put `.dockerignore` at monorepo root |
| Missing shared packages | `@myorg/shared` not found | Copy `packages/` dir before install |

#### .dockerignore (monorepo root)
```
**/node_modules
**/.next
**/dist
**/.turbo
.git
.env*
```

#### Shared Packages Pattern
If apps depend on internal `packages/*`:
```dockerfile
# After copying workspace config, also copy shared packages
COPY packages/ ./packages/
```

#### Turbo Prune (optimal for large monorepos)
```bash
# Generates minimal workspace for just one app
npx turbo prune web --docker

# Then build from the pruned output
# See: https://turbo.build/repo/docs/guides/tools/docker
```

---

#### .dockerignore (reduce context, smaller images)
```
node_modules
.git
.env*
dist
*.md
.github
coverage
.next
```

#### Common Disk Hogs to Watch
| Source | Typical waste | Fix |
|--------|--------------|-----|
| Build cache | 10-40GB on active CI | `docker builder prune -a --filter "until=48h"` |
| Dangling images | 5-20GB per old deploy | `docker image prune -a` |
| Orphaned volumes | Varies — DB data survives container removal | `docker volume ls` then remove unused |
| Container logs | Unbounded without config | Set `max-size: "10m"` + `max-file: "3"` in compose |
| `/tmp` inside containers | Accumulates if not cleaned | Use `tmpfs` mount or clean in entrypoint |

---

## Firewall (ufw)

```bash
# Default policy
ufw default deny incoming
ufw default allow outgoing

# Allow SSH (change 22 to your port if custom)
ufw allow 22/tcp

# Allow HTTP/HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Allow specific IPs only (e.g., office IP for admin panel)
ufw allow from 203.0.113.0/24 to any port 8080

# Enable
ufw enable
ufw status verbose
```

### iptables for Advanced Rules
```bash
# Block outbound to metadata service from containers (prevents SSRF)
iptables -I DOCKER-USER -d 169.254.169.254 -j DROP
```

---

## Process Management

### systemd service for Node.js app
```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My App
After=network.target

[Service]
User=deploy
WorkingDirectory=/home/deploy/app
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=myapp
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
```
```bash
systemctl enable myapp
systemctl start myapp
journalctl -u myapp -f  # Follow logs
```

---

## Monitoring & Alerting

### Lightweight Stack (single VPS)
- **Metrics**: Prometheus + Node Exporter + Grafana (docker-compose)
- **Logs**: Loki + Promtail (if not shipping to CloudWatch)
- **Uptime**: Uptime Kuma (self-hosted) or Betterstack (managed)
- **Alerts**: Grafana alerts → Slack/PagerDuty webhook

### Quick Health Monitoring Script
```bash
#!/bin/bash
# Check disk, memory, CPU — alert if critical
DISK=$(df / | awk 'NR==2{print $5}' | tr -d '%')
[ "$DISK" -gt 85 ] && curl -s -X POST "$SLACK_WEBHOOK" \
  -d '{"text":"⚠️ Disk usage above 85% on prod server"}'
```

### Log Rotation (logrotate)
```
/var/log/myapp/*.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
    sharedscripts
    postrotate
        systemctl reload myapp
    endscript
}
```
