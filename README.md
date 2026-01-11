# 🏠 Self-Hosted Home Lab

This repository documents a self-hosted home lab running on a **Raspberry Pi 4 (8GB)**. It features a secure, automated HTTPS setup using Traefik, Let's Encrypt, and Cloudflare DDNS to handle dynamic IPs from the ISP (Airtel).

## ️ Architecture & Security Flow

We use **Traefik** as the central entry point (Reverse Proxy) which automatically manages SSL certificates. Since our ISP provides a dynamic IP, a **DDNS script** ensures our domain always points to the correct home address.

```mermaid
graph LR
    %% Define Styles
    classDef user fill:#2962FF,stroke:#0039CB,stroke-width:2px,color:white,rx:50,ry:50
    classDef cloud fill:#E1F5FE,stroke:#0288D1,stroke-width:2px,rx:10,ry:10
    classDef router fill:#FFF3E0,stroke:#EF6C00,stroke-width:2px,rx:10,ry:10
    classDef proxy fill:#FFFDE7,stroke:#FBC02D,stroke-width:2px,rx:10,ry:10
    classDef app fill:#F3E5F5,stroke:#8E24AA,stroke-width:2px,rx:5,ry:5
    classDef net fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px,rx:5,ry:5

    User((User)):::user
    
    subgraph Cloud [Internet & Cloud]
        CF_DNS{Cloudflare DNS}:::cloud
        LE[Let's Encrypt]:::cloud
    end
    
    subgraph Home [Home Network]
        Router[Router]:::router
        
        subgraph RPi [Raspberry Pi 4]
            Traefik[Traefik Proxy]:::proxy
            DDNS[DDNS Updater]:::net
            
            subgraph Docker [Docker Apps]
                direction TB
                Homepage[Homepage]:::app
                Jellyfin[Jellyfin]:::app
                Nextcloud[Nextcloud]:::app
                PiHole[Pi-hole]:::net
                Tailscale[Tailscale]:::net
            end
        end
    end

    %% Main Traffic Flow
    User -->|HTTPS| CF_DNS
    CF_DNS -->|Home IP| Router
    Router -->|Port 443| Traefik
    
    Traefik --> Homepage
    Traefik --> Jellyfin
    Traefik --> Nextcloud
    Traefik --> PiHole

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
