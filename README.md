# 🏠 Self-Hosted Home Lab

This repository documents a self-hosted home lab running on a **Raspberry Pi 4 (8GB)**. It features a secure, automated HTTPS setup using Traefik, Let's Encrypt, and Cloudflare DDNS to handle dynamic IPs from the ISP (Airtel).

## ️ Architecture & Security Flow

We use **Traefik** as the central entry point (Reverse Proxy) which automatically manages SSL certificates. Since our ISP provides a dynamic IP, a **DDNS script** ensures our domain always points to the correct home address.

```mermaid
flowchart LR
    %% Define Styles
    classDef user fill:#2563EB,stroke:#1D4ED8,stroke-width:2px,color:white,rx:10,ry:10
    classDef cloud fill:#F3F4F6,stroke:#6B7280,stroke-width:2px,color:#1F2937,rx:5,ry:5
    classDef router fill:#F97316,stroke:#C2410C,stroke-width:2px,color:white,rx:5,ry:5
    classDef proxy fill:#F59E0B,stroke:#B45309,stroke-width:2px,color:white,rx:5,ry:5
    
    %% App specific colors
    classDef dashboard fill:#3B82F6,stroke:#1D4ED8,stroke-width:2px,color:white,rx:5,ry:5
    classDef media fill:#8B5CF6,stroke:#5B21B6,stroke-width:2px,color:white,rx:5,ry:5
    classDef storage fill:#10B981,stroke:#047857,stroke-width:2px,color:white,rx:5,ry:5
    classDef dns fill:#EF4444,stroke:#B91C1C,stroke-width:2px,color:white,rx:5,ry:5
    classDef vpn fill:#EC4899,stroke:#BE185D,stroke-width:2px,color:white,rx:5,ry:5
    classDef script fill:#6366F1,stroke:#4338CA,stroke-width:2px,color:white,rx:5,ry:5,stroke-dasharray: 5 5

    User[💻 User]:::user
    
    subgraph Internet [☁️ Internet]
        direction TB
        CF_DNS[Cloudflare DNS]:::cloud
        LE[Let's Encrypt]:::cloud
    end
    
    subgraph Home [🏠 Home Network]
        Router[Router]:::home
        
        subgraph Server [Raspberry Pi 4]
            Traefik[Traefik Proxy]:::proxy
            DDNS[DDNS Updater]:::script
            
            subgraph Docker [Docker Apps]
                direction TB
                Homepage[Homepage]:::dashboard
                Jellyfin[Jellyfin]:::media
                Nextcloud[Nextcloud]:::storage
                PiHole[Pi-hole]:::dns
                Tailscale[Tailscale]:::vpn
            end
        end
    end

    %% Main Traffic Flow
    User ==>|HTTPS| CF_DNS
    CF_DNS ==>|Home IP| Router
    Router ==>|Port 443| Traefik
    
    Traefik --> Homepage
    Traefik --> Jellyfin
    Traefik --> Nextcloud
    Traefik --> PiHole
    Traefik --> Tailscale

    %% Automation Flows
    DDNS -.->|Update IP| CF_DNS
    Traefik -.->|Renew Certs| LE
```

## 🌐 Connectivity Logic

### 1. Dynamic DNS (DDNS)
**Problem:** Airtel Broadband changes the Public IP address frequently.
**Solution:** We use the [Cloudflare DDNS Updater](https://github.com/K0p1-Git/cloudflare-ddns-updater) script.
- **Function:** It runs periodically to check the current Public IP.
- **Action:** If the IP has changed, it updates the `A` records in Cloudflare DNS via API.
- **Result:** `*.example.com` always resolves to the home network.

### 2. Reverse Proxy & HTTPS (Traefik)
**Role:** Secure Gateway.
- **Traefik** listens on ports 80 and 443.
- **Let's Encrypt Integration:** Traefik automatically communicates with Let's Encrypt to generate and renew valid SSL certificates for all subdomains.
- **Force HTTPS:** All HTTP (Port 80) traffic is automatically redirected to HTTPS (Port 443).

## 🛠️ Hardware & Software

| Device | Role | Key Services |
|--------|------|--------------|
| **Raspberry Pi 4 (8GB)** | All-in-One Server | Docker, Traefik, Jellyfin, Nextcloud, DDNS Script |
