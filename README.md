# 🏠 Self-Hosted Home Lab

This repository documents a self-hosted home lab running on a **Raspberry Pi 4 (8GB)**. It features a secure, automated HTTPS setup using Traefik, Let's Encrypt, and Cloudflare DDNS to handle dynamic IPs from the ISP (Airtel).

## ️ Architecture & Security Flow

We use **Traefik** as the central entry point (Reverse Proxy) which automatically manages SSL certificates. Since our ISP provides a dynamic IP, a **DDNS script** ensures our domain always points to the correct home address.

```mermaid
graph LR
    %% Define Styles
    classDef user fill:#ffffff,stroke:#2962ff,stroke-width:2px,rx:10,ry:10,color:#2962ff
    classDef cloud fill:#fff3e0,stroke:#ef6c00,stroke-width:2px,rx:5,ry:5,color:#e65100
    classDef home fill:#e3f2fd,stroke:#1565c0,stroke-width:2px,rx:5,ry:5,color:#0d47a1
    classDef proxy fill:#fff8e1,stroke:#ff8f00,stroke-width:2px,rx:5,ry:5,color:#ef6c00
    classDef app fill:#ffffff,stroke:#1565c0,stroke-width:1px,rx:5,ry:5,color:#0d47a1
    classDef auto fill:#f3e5f5,stroke:#ab47bc,stroke-width:1px,rx:5,ry:5,stroke-dasharray: 5 5,color:#7b1fa2

    User[💻 User]:::user
    
    subgraph Cloud [☁️ Cloudflare Network]
        direction TB
        CF_DNS[Cloudflare DNS]:::cloud
        LE[Let's Encrypt]:::auto
    end
    
    subgraph Home [🏠 Home Network]
        direction LR
        Router[Router]:::home
        
        subgraph Server [Raspberry Pi 4]
            direction LR
            Traefik[Traefik Proxy]:::proxy
            DDNS[DDNS Updater]:::auto
            
            subgraph Docker [Docker Apps]
                direction TB
                Homepage[Homepage]:::app
                Jellyfin[Jellyfin]:::app
                Nextcloud[Nextcloud]:::app
                PiHole[Pi-hole]:::app
                Tailscale[Tailscale]:::app
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
