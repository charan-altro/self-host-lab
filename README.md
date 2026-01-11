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
    'fontSize': '14px'
  }
}}%%
flowchart LR
    %% --- STYLE DEFINITIONS ---
    classDef base fill:#FFFFFF,stroke:#CBD5E1,stroke-width:1px,color:#1F2937,rx:4,ry:4,shadow:true
    classDef client fill:#FFFFFF,stroke:#2563EB,stroke-width:2px,color:#1E3A8A,rx:4,ry:4,font-weight:bold,shadow:true
    classDef transit fill:#FFFFFF,stroke:#EA580C,stroke-width:2px,color:#1F2937,rx:4,ry:4,shadow:true
    classDef appStack fill:#F8FAFC,stroke:#2563EB,stroke-width:1px,color:#1E293B,rx:4,ry:4,align:left,font-family:monospace

    %% --- CONTAINER STYLING ---
    classDef masterZone fill:#F5F7FA,stroke:#E2E8F0,stroke-width:1px,rx:10,ry:10,color:#334155
    classDef innerZone fill:#FFFFFF,stroke:#94A3B8,stroke-width:1px,stroke-dasharray: 6 4,color:#475569

    %% --- DIAGRAM CONTENT ---

    subgraph HomeLab ["🏠 Self-Hosted Architecture"]
        direction LR

        %% 1. LEFT: Inputs
        subgraph Inputs ["Clients"]
            direction TB
            User["💻 Client / User"]:::client
            DDNS["🔄 DDNS Updater"]:::base
        end

        %% 2. MIDDLE: Network Stack (Forced Vertical)
        subgraph Network ["☁️ Network Layer"]
            direction TB
            %% We define the nodes here to group them strictly
            DNS["🌐 Cloudflare DNS"]:::transit
            Router["🏠 Home Router"]:::transit
            Traefik["🚦 Traefik Proxy"]:::transit
            
            %% Force the vertical connection INSIDE the subgraph
            DNS ==> Router ==> Traefik
        end

        %% 3. RIGHT: Server
        subgraph Server ["Raspberry Pi 4"]
            direction TB
            Docker["🐳 Docker Apps
            ──────────────
            🖥️ Dashboard
            🎬 Media Server
            📁 Personal Cloud
            🛡️ DNS & VPN"]:::appStack
        end
    end

    %% --- EXTERNAL CONNECTIONS ---
    %% Connecting the layers together
    User ==>|"HTTPS"| DNS
    Traefik ==>|"Route"| Docker

    %% Maintenance Path
    DDNS -.-o|"Update IP"| DNS

    %% --- APPLY STYLES ---
    class HomeLab masterZone
    class Inputs,Network,Server innerZone

    %% Link Styling
    %% 0,1 are the vertical internal links (DNS->Router->Traefik)
    linkStyle 0,1 stroke:#EA580C,stroke-width:3px,fill:none
    
    %% 2 is User->DNS, 3 is Traefik->Docker
    linkStyle 2,3 stroke:#EA580C,stroke-width:3px,fill:none
    
    %% 4 is DDNS
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
