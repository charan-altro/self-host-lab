# 🏠 Self-Hosted Home Lab

This repository documents a self-hosted home lab running on a **Raspberry Pi 4 (8GB)**. It features a secure, automated HTTPS setup using Traefik, Let's Encrypt, and Cloudflare DDNS to handle dynamic IPs from the ISP (Airtel).

## ️ Architecture & Security Flow

We use **Traefik** as the central entry point (Reverse Proxy) which automatically manages SSL certificates. Since our ISP provides a dynamic IP, a **DDNS script** ensures our domain always points to the correct home address.


```mermaid
%%{init: {
  'theme': 'base',
  'themeVariables': {
    'background': '#F5F7FA',
    'primaryTextColor': '#1F2937',
    'lineColor': '#64748B',
    'fontSize': '16px'
  }
}}%%
flowchart TB
    %% --- STYLE DEFINITIONS ---
    %% 1. Basic White Nodes (Shadow effect for depth)
    classDef base fill:#FFFFFF,stroke:#CBD5E1,stroke-width:1px,color:#1F2937,rx:5,ry:5,font-family:sans-serif,shadow:true
    
    %% 2. Blue Accents (Endpoints) - Added padding logic to styles
    classDef client fill:#FFFFFF,stroke:#2563EB,stroke-width:2px,color:#1E3A8A,rx:5,ry:5,font-weight:bold,shadow:true
    
    %% 3. Orange Accents (Routing Nodes)
    classDef transit fill:#FFFFFF,stroke:#EA580C,stroke-width:2px,color:#1F2937,rx:5,ry:5,shadow:true

    %% 4. The Docker List Box (MONOSPACE font for perfect alignment)
    classDef listBox fill:#F8FAFC,stroke:#2563EB,stroke-width:1px,color:#1E293B,rx:5,ry:5,align:left,font-family:monospace

    %% --- CONTAINER STYLING ---
    classDef masterZone fill:#F5F7FA,stroke:#E2E8F0,stroke-width:1px,rx:10,ry:10,color:#334155
    classDef innerZone fill:#FFFFFF,stroke:#94A3B8,stroke-width:1px,stroke-dasharray: 6 4,color:#475569

    %% --- DIAGRAM CONTENT ---

    %% !!! MASTER CONTAINER !!!
    %% Added spaces to title to prevent edge clipping
    subgraph HomeLab ["🏠 Self-Hosted Home Lab Architecture&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"]
        direction TB

        %% 1. TOP LAYER
        %% Added non-breaking spaces (&nbsp;) to widen the nodes
        User["&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;💻 Client / User&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"]:::client
        DDNS["&nbsp;&nbsp;&nbsp;🔄 DDNS Updater&nbsp;&nbsp;&nbsp;"]:::base

        %% 2. MIDDLE LAYER: Routing
        subgraph Routing ["☁️ Ingress & Routing Layer"]
            direction TB
            DNS["🌐 Cloudflare DNS"]:::transit
            Router["🏠 Home Router"]:::transit
            Traefik["🚦 Traefik Proxy"]:::transit
        end

        %% 3. BOTTOM LAYER: Server
        subgraph Server ["Raspberry Pi 4 - Docker Host"]
            direction TB
            
            %% MONOSPACE FORMATTING
            %% Using unicode line char (─) for the separator
            DockerList["🐳 Docker Service Stack
            Containerized Applications
            ──────────────────────────
            🖥️ Homepage  | Dashboard
            🎬 Jellyfin  | Media Server
            📁 Nextcloud | Storage
            🛡️ Pi-hole   | AdBlocking
            🔒 Tailscale | VPN Mesh
            &nbsp;"]:::listBox
        end
    end

    %% --- CONNECTIONS ---
    User ==>|"HTTPS (443)"| DNS
    DNS ==>|"Resolve IP"| Router
    Router ==>|"Port Forward"| Traefik
    Traefik ==>|"Reverse Proxy"| DockerList

    DDNS -.-o|"Update API"| DNS

    %% --- APPLY STYLES ---
    class HomeLab masterZone
    class Routing,Server innerZone

    %% Link Styling
    linkStyle 0,1,2,3 stroke:#EA580C,stroke-width:3px,fill:none
    linkStyle 4 stroke:#94A3B8,stroke-width:2px,stroke-dasharray: 4 4
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
