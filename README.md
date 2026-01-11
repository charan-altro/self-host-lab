# 🏠 Self-Hosted Home Lab

This repository documents a self-hosted home lab running on a **Raspberry Pi 4 (8GB)**. It features a secure, automated HTTPS setup using Traefik, Let's Encrypt, and Cloudflare DDNS to handle dynamic IPs from the ISP (Airtel).

## ️ Architecture & Security Flow

We use **Traefik** as the central entry point (Reverse Proxy) which automatically manages SSL certificates. Since our ISP provides a dynamic IP, a **DDNS script** ensures our domain always points to the correct home address.

```mermaid
graph TD
    %% Define Styles
    classDef user fill:#2196f3,stroke:#0d47a1,stroke-width:2px,color:white
    classDef cloud fill:#e3f2fd,stroke:#1565c0,stroke-width:2px
    classDef router fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef proxy fill:#fff9c4,stroke:#fbc02d,stroke-width:2px
    classDef media fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef net fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px
    classDef dash fill:#fce4ec,stroke:#c2185b,stroke-width:2px

    User((User)):::user
    
    subgraph Cloud [Internet & Cloud Services]
        CF_DNS{Cloudflare DNS}:::cloud
        LE[Let's Encrypt]:::cloud
    end
    
    subgraph Home [Home Network - Airtel Broadband]
        Router["Router<br/>Ports 80/443"]:::router
        
        subgraph RPi [Raspberry Pi 4 - 8GB]
            Traefik["Traefik Proxy<br/>(Auto HTTPS)"]:::proxy
            DDNS["DDNS Updater<br/>(Python Script)"]:::net
            
            subgraph Services [Docker Apps]
                Jellyfin[Jellyfin Media]:::media
                Nextcloud[Nextcloud Storage]:::media
                Homepage[Homepage Dashboard]:::dash
                PiHole[Pi-hole DNS]:::net
                Tailscale[Tailscale VPN]:::net
            end
        end
    end

    %% Main Traffic Flow
    User -->|1. https://app.example.com| CF_DNS
    CF_DNS -->|2. Resolve to Home IP| Router
    Router -->|3. Forward Traffic| Traefik
    Traefik -->|"4. Route (Internal Network)"| Jellyfin
    Traefik --> Homepage
    Traefik --> Nextcloud
    Traefik --> PiHole

    %% Automation Flows
    DDNS -.->|Monitor & Update IP| CF_DNS
    Traefik -.->|Get/Renew Certificates| LE
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
