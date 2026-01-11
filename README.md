# 🏠 Self-Hosted Home Lab

This repository documents a self-hosted home lab running on a **Raspberry Pi 4 (8GB)**. It features a secure, automated HTTPS setup using Traefik, Let's Encrypt, and Cloudflare DDNS to handle dynamic IPs from the ISP (Airtel).

## ️ Architecture & Security Flow

We use **Traefik** as the central entry point (Reverse Proxy) which automatically manages SSL certificates. Since our ISP provides a dynamic IP, a **DDNS script** ensures our domain always points to the correct home address.


```mermaid
flowchart LR
    %% --- Base Styles for a Clean, White Theme ---
    %% Specific Role Styles (Colors applied to border stroke only)
    classDef user fill:#EFF6FF,stroke:#2563EB,stroke-width:2px,color:#1F2937,rx:8,ry:8,font-family:sans-serif
    classDef internetNode fill:white,stroke:#9CA3AF,stroke-dasharray: 5 5,stroke-width:2px,color:#1F2937,rx:8,ry:8,font-family:sans-serif
    classDef routerGateway fill:white,stroke:#F97316,stroke-width:3px,color:#1F2937,rx:8,ry:8,font-family:sans-serif
    classDef dockerApp fill:white,stroke:#3B82F6,stroke-width:2px,color:#1F2937,rx:8,ry:8,font-family:sans-serif
    classDef scriptNode fill:white,stroke:#6366F1,stroke-dasharray: 5 5,stroke-width:2px,color:#1F2937,rx:8,ry:8,font-family:sans-serif

    %% Subgraph Styles to match reference image containers
    classDef subGraphContainer fill:#F9FAFB,stroke:#D1D5DB,stroke-width:2px,stroke-dasharray: 8 6,color:#374151,rx:10,ry:10
    classDef dockerSubGraph fill:#EFF6FF,stroke:#3B82F6,stroke-width:2px,color:#1F2937,rx:10,ry:10

    %% --- Nodes & Structure ---
    User[💻 User]:::user

    subgraph Internet ["☁️ Internet"]
        direction TB
        CF_DNS["Cloudflare DNS"]:::internetNode
        LE["Let's Encrypt"]:::internetNode
    end

    subgraph Home ["🏠 Home Network"]
        Router[Router]:::routerGateway
        
        subgraph Server ["Raspberry Pi 4 Server"]
            Traefik["Traefik Reverse Proxy"]:::routerGateway
            DDNS["🔄 DDNS Updater script"]:::scriptNode
            
            subgraph Docker ["🐳 Docker Containers"]
                direction TB
                Homepage["Homepage Dashboard"]:::dockerApp
                Jellyfin["🎬 Jellyfin Media"]:::dockerApp
                Nextcloud["📁 Nextcloud Storage"]:::dockerApp
                PiHole["🛡️ Pi-hole DNS"]:::dockerApp
                Tailscale["🔒 Tailscale VPN"]:::dockerApp
            end
        end
    end

    %% --- Traffic Flow ---
    %% Main Data Path (Thick Orange Lines)
    User ==>|HTTPS Request| CF_DNS
    CF_DNS ==>|Resolve to Home IP| Router
    Router ==>|Port 443 Forward| Traefik
    
    %% Internal Routing (Thinner standard lines)
    Traefik --> Homepage
    Traefik --> Jellyfin
    Traefik --> Nextcloud
    Traefik --> PiHole
    Traefik --> Tailscale

    %% Automation/Management Flows (Dotted lines)
    DDNS -.->|Periodic IP Update| CF_DNS
    Traefik -.->|ACME Challenge / Renew Certs| LE

    %% --- Applying Subgraph Styles ---
    class Internet subGraphContainer
    class Home subGraphContainer
    class Server subGraphContainer
    class Docker dockerSubGraph

    %% --- Link Styling to mimic reference image ---
    %% Style the first 3 main links to be thick and orange
    linkStyle 0,1,2 stroke:#F97316,stroke-width:4px,fill:none
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
