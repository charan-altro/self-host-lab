# 🏠 Self-Hosted Home Lab - Technical Architecture

A production-grade self-hosted home lab on **Raspberry Pi 4 (8GB)** with containerized services, automated TLS/SSL, reverse proxy routing, and secure DNS management using industry-standard tools: **Traefik**, **Let's Encrypt**, **Cloudflare**, and **Docker**.

## 🏗️ System Architecture Overview

```mermaid
flowchart TB
    classDef external fill:#FEF3C7,stroke:#D97706,stroke-width:2px,color:#1F2937
    classDef cloudflare fill:#DBEAFE,stroke:#0284C7,stroke-width:2px,color:#1E3A8A
    classDef router fill:#E0E7FF,stroke:#4F46E5,stroke-width:2px,color:#1E3A8A
    classDef traefik fill:#F0FDF4,stroke:#16A34A,stroke-width:2px,color:#15803D
    classDef docker fill:#F3E8FF,stroke:#A855F7,stroke-width:2px,color:#6B21A8
    classDef storage fill:#FECACA,stroke:#DC2626,stroke-width:1px,color:#7F1D1D
    classDef letsencrypt fill:#CCFBF1,stroke:#0D9488,stroke-width:2px,color:#134E4A

    Client["👥 External Clients<br/>(HTTPS Requests)"]:::external

    subgraph DNS["🌐 DNS Resolution Layer"]
        CF_DNS["☁️ Cloudflare DNS<br/>A Record: example.com"]:::cloudflare
        DDNS["🔄 DDNS Updater<br/>Cron: every 5 mins"]:::router
    end

    subgraph Network["🏠 Home Network Layer"]
        ISP["🌍 ISP Airtel<br/>Dynamic Public IP"]:::external
        RRouter["🚀 Home Router<br/>Port Forward :80/443"]:::router
    end

    subgraph Reverse["🚦 Traefik Reverse Proxy"]
        Traefik["Traefik Service<br/>Listen: :80, :443"]:::traefik
        LE["🔐 Let's Encrypt<br/>ACME v2 Client"]:::letsencrypt
    end

    subgraph Containers["🐳 Docker Container Stack"]
        Jellyfin["🎬 Jellyfin<br/>:8096"]:::docker
        Nextcloud["☁️ Nextcloud<br/>:80"]:::docker
        Heimdall["🖥️ Heimdall<br/>:80"]:::docker
        Pihole["🛡️ Pi-hole<br/>:80"]:::docker
        
        Vol["💾 Volumes<br/>/media /nextcloud /traefik"]:::storage
    end

    Client -->|"HTTPS :443"| CF_DNS
    CF_DNS -->|"Resolves IP"| ISP
    DDNS -->|"Updates A record"| CF_DNS
    ISP -->|"Port Forward"| RRouter
    RRouter -->|"Routes :443"| Traefik
    Traefik -->|"TLS + Routing"| LE
    LE -->|"ACME Challenge"| CF_DNS
    Traefik -->|"Service Discovery"| Jellyfin
    Traefik -->|"Service Discovery"| Nextcloud
    Traefik -->|"Service Discovery"| Heimdall
    Traefik -->|"Service Discovery"| Pihole
    Jellyfin --> Vol
    Nextcloud --> Vol
```

## 🔐 Traefik + Let's Encrypt Certificate Lifecycle

```mermaid
flowchart LR
    classDef boot fill:#FEE2E2,stroke:#DC2626,stroke-width:2px,color:#7F1D1D
    classDef acme fill:#CCFBF1,stroke:#0D9488,stroke-width:2px,color:#134E4A
    classDef challenge fill:#F3E8FF,stroke:#A855F7,stroke-width:2px,color:#6B21A8
    classDef stored fill:#DBEAFE,stroke:#0284C7,stroke-width:2px,color:#1E3A8A

    Start["🚀 Traefik Starts<br/>Reads docker-compose.yml<br/>Discovers services"]:::boot
    ACME["📋 ACME Account<br/>Check or Create<br/>Store in acme.json"]:::acme
    Discover["🔍 Service Discovery<br/>Read Docker labels<br/>traefik.http.routers"]:::boot
    Domain["🌍 Collect Domains<br/>Extract from rules<br/>Host('jellyfin.example.com')"]:::challenge
    Challenge["⚡ DNS-01 Challenge<br/>Create TXT record<br/>_acme-challenge.example.com"]:::challenge
    Verify["✅ Let's Encrypt<br/>Validates TXT record<br/>Issues certificate"]:::acme
    Store["💾 Store Cert<br/>Save to acme.json<br/>Docker volume"]:::stored
    Load["🔑 Load Certificate<br/>TLS ready<br/>Listen :443"]:::boot
    Renew["🔄 Auto-Renew<br/>Check every 24h<br/>Renew 30 days before expiry"]:::acme

    Start --> ACME
    ACME --> Discover
    Discover --> Domain
    Domain --> Challenge
    Challenge --> Verify
    Verify --> Store
    Store --> Load
    Load --> Renew
    Renew -.->|"Loop"| Challenge
```

## 🔄 DDNS Update Flow with Cloudflare API

```mermaid
flowchart LR
    classDef cron fill:#FEE2E2,stroke:#DC2626,stroke-width:2px,color:#7F1D1D
    classDef detect fill:#FEF3C7,stroke:#D97706,stroke-width:2px,color:#1F2937
    classDef compare fill:#F3E8FF,stroke:#A855F7,stroke-width:2px,color:#6B21A8
    classDef api fill:#DBEAFE,stroke:#0284C7,stroke-width:2px,color:#1E3A8A
    classDef success fill:#C7D2FE,stroke:#4F46E5,stroke-width:2px,color:#1E3A8A
    classDef error fill:#CCFBF1,stroke:#0D9488,stroke-width:2px,color:#134E4A

    Trigger["⏰ Cron Job<br/>*/5 * * * *<br/>Every 5 minutes"]:::cron
    GetIP["🔍 Detect Public IP<br/>curl ifconfig.me<br/>OR api.ipify.org"]:::detect
    GetDNS["📡 Query Cloudflare<br/>GET /zones/{id}<br/>Current A record"]:::api
    Compare["⚖️ Compare IPs<br/>Local vs DNS<br/>Match?"]:::compare
    NoMatch{"IPs Match?"}:::compare
    Skip["⏭️ Skip<br/>No change needed"]:::detect
    Prepare["🔀 Prepare Update<br/>New IP payload"]:::detect
    APICall["🌐 Cloudflare API<br/>PUT /dns_records/{id}<br/>Update A record"]:::api
    Check{"200 OK?"}:::api
    Success["✅ Success<br/>A record updated<br/>Log: SUCCESS"]:::success
    Fail["❌ Failed<br/>Log error<br/>Retry next cycle"]:::error

    Trigger --> GetIP
    GetIP --> GetDNS
    GetDNS --> Compare
    Compare --> NoMatch
    NoMatch -->|Yes| Skip
    NoMatch -->|No| Prepare
    Prepare --> APICall
    APICall --> Check
    Check -->|Yes| Success
    Check -->|No| Fail
```

## ☁️ Cloudflare Tunnel vs DDNS + Port Forward Comparison

```mermaid
flowchart TB
    classDef current fill:#C7D2FE,stroke:#4F46E5,stroke-width:2px,color:#1E3A8A
    classDef step fill:#DBEAFE,stroke:#0284C7,stroke-width:2px,color:#1E3A8A
    classDef benefit fill:#CCFBF1,stroke:#0D9488,stroke-width:2px,color:#134E4A
    classDef issue fill:#FEF3C7,stroke:#D97706,stroke-width:2px,color:#1F2937

    subgraph Current["✅ CURRENT: DDNS + Port Forward"]
        CF1["☁️ Cloudflare DNS"]:::step
        DDNS1["🔄 DDNS Script"]:::step
        PF["🚀 Port Forward"]:::step
        TRK["🚦 Traefik"]:::step
        B1["✅ Low latency"]:::benefit
        B2["✅ Full control"]:::benefit
        I1["⚠️ ISP blocks ports"]:::issue
    end

    subgraph Alternative["❌ ALTERNATIVE: Cloudflare Tunnel"]
        CT["🌐 cloudflared daemon"]:::step
        CTO["📤 Outbound tunnel"]:::step
        CFEDGE["☁️ Cloudflare Edge"]:::step
        B4["✅ No port forward"]:::benefit
        B5["✅ NAT bypass"]:::benefit
        I4["⚠️ Higher latency"]:::issue
    end

    CF1 --> DDNS1
    DDNS1 --> PF
    PF --> TRK
    TRK --> B1
    TRK --> B2
    TRK --> I1

    CT --> CTO
    CTO --> CFEDGE
    CFEDGE --> B4
    CFEDGE --> B5
    CFEDGE --> I4
```

## 🐳 Docker Compose Service Architecture

Your services are orchestrated via Docker with labels that Traefik reads automatically:

```yaml
# Key Services & Traefik Integration

# 1. TRAEFIK - Reverse Proxy & Load Balancer
traefik:
  image: traefik:v2.10
  ports:
    - "80:80"
    - "443:443"
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - ./traefik/acme.json:/acme.json
    - ./traefik/traefik.yml:/traefik.yml
  labels:
    traefik.http.routers.traefik.rule: "Host(`traefik.example.com`)
    traefik.http.routers.traefik.service: "api@internal"
    traefik.http.routers.traefik.tls.certresolver: "letsencrypt"

# 2. JELLYFIN - Media Server
jellyfin:
  image: jellyfin/jellyfin:latest
  ports:
    - "8096:8096"
  volumes:
    - ./media:/media
  labels:
    traefik.http.routers.jellyfin.rule: "Host(`jellyfin.example.com`)
    traefik.http.routers.jellyfin.tls: "true"
    traefik.http.routers.jellyfin.tls.certresolver: "letsencrypt"
    traefik.http.services.jellyfin.loadbalancer.server.port: "8096"

# 3. NEXTCLOUD - Cloud Storage
nextcloud:
  image: nextcloud:latest
  ports:
    - "8080:80"
  volumes:
    - ./nextcloud:/var/www/html
  labels:
    traefik.http.routers.nextcloud.rule: "Host(`cloud.example.com`)
    traefik.http.routers.nextcloud.tls.certresolver: "letsencrypt"
    traefik.http.services.nextcloud.loadbalancer.server.port: "80"

# 4. HEIMDALL - Dashboard
heimdall:
  image: linuxserver/heimdall:latest
  labels:
    traefik.http.routers.heimdall.rule: "Host(`home.example.com`)
    traefik.http.routers.heimdall.tls.certresolver: "letsencrypt"
    traefik.http.services.heimdall.loadbalancer.server.port: "80"

# 5. PI-HOLE - DNS & Ad Blocking
pihole:
  image: pihole/pihole:latest
  labels:
    traefik.http.routers.pihole.rule: "Host(`dns.example.com`)
    traefik.http.routers.pihole.tls.certresolver: "letsencrypt"
    traefik.http.services.pihole.loadbalancer.server.port: "80"
```

## 🔑 Let's Encrypt Certificate Management

### How Traefik Manages Certificates Automatically:

1. **Initialization:** Traefik reads `traefik.yml` with Let's Encrypt ACME provider (Cloudflare DNS challenge)
2. **Service Discovery:** Reads Docker labels from running containers
3. **Domain Collection:** Extracts all domains from router rules
4. **ACME Challenge:** For each domain, Traefik:
   - Requests Let's Encrypt for a challenge
   - Uses Cloudflare API to create DNS TXT record
   - Let's Encrypt validates domain ownership
   - Certificate issued
5. **Storage:** Certificates stored in `acme.json` (encrypted volume)
6. **Renewal:** Automatic check every 24h, renewal 30 days before expiry
7. **Rotation:** Traefik reloads certs without restart

### acme.json Structure:
```json
{
  "letsencrypt": {
    "Account": { "Email": "admin@example.com" },
    "Certificates": [
      {
        "Domain": { 
          "Main": "example.com", 
          "SANs": ["jellyfin.example.com", "cloud.example.com"]
        },
        "Certificate": "-----BEGIN CERTIFICATE-----...",
        "Key": "-----BEGIN RSA PRIVATE KEY-----..."
      }
    ]
  }
}
```

## 🛠️ Technical Stack & Components

| Component | Version | Role | Configuration |
|-----------|---------|------|---------------|
| **Raspberry Pi 4** | 8GB RAM | Host Machine | Debian/Ubuntu, Docker Engine |
| **Docker Engine** | Latest | Container Runtime | docker.sock volume, Docker Compose |
| **Traefik** | v2.10+ | Reverse Proxy | Ports :80, :443, Docker provider |
| **Let's Encrypt** | ACME v2 | Certificate Authority | DNS-01 challenge, auto-renewal |
| **Cloudflare** | Free Plan | DNS + API | Zone API, DDNS updates |
| **Jellyfin** | Latest | Media Server | Port 8096, media volumes |
| **Nextcloud** | Latest | Cloud Storage | Port 80, data volumes |
| **Heimdall** | Latest | Dashboard | Port 80, bookmark management |
| **Pi-hole** | Latest | DNS/Ad-Blocker | Port 80, gravity database |

## 📋 Configuration Files Required

```
project-root/
├── docker-compose.yml           # All services definition
├── .env                         # Environment variables
├── traefik/
│   ├── traefik.yml             # Static config (providers, ACME)
│   ├── acme.json               # Let's Encrypt certificates
│   └── config.yml              # Dynamic routes (optional)
├── media/                       # Jellyfin media library
├── nextcloud/                   # Nextcloud data storage
├── pihole/                      # Pi-hole configuration
└── scripts/
    └── ddns-updater.sh          # DDNS update script
```

## 🚀 Deployment & Traffic Flow

### Request Journey (user.example.com):

1. **Client sends HTTPS request** → `user.example.com:443`
2. **DNS Resolution:**
   - Cloudflare DNS lookup
   - Returns Public IP (updated by DDNS script)
3. **Network Routing:**
   - Home Router receives connection on :443
   - Port Forward: `:443 → Traefik container :443`
4. **Traefik Processing:**
   - TLS Handshake (uses Let's Encrypt cert from acme.json)
   - HTTP Host header: `Host('user.example.com')`
   - Router rule matching
   - Load balancing to container
5. **Container Response:**
   - Routes to appropriate container
   - Container processes request
   - Response sent back through Traefik
6. **HTTPS Response:**
   - Traefik encrypts response
   - Sends to client over TLS 1.2/1.3

## 🔒 Security Considerations

✅ **Implemented:**
- TLS 1.2+ only (no legacy protocols)
- Let's Encrypt certificates (free, auto-renewed)
- DNS validation (more secure than HTTP)
- Traefik automatic HTTPS redirect
- Cloudflare DDoS protection
- Encrypted certificate storage

⚠️ **Recommendations:**
- Use strong Cloudflare API tokens
- Restrict tokens to DNS-only permissions
- Enable Cloudflare's "Always Use HTTPS"
- Backup `acme.json` regularly
- Monitor DDNS script logs
- Use Cloudflare Tunnel for additional NAT security
