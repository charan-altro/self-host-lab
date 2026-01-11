# 🏠 Self-Hosted Home Lab

This repository documents a self-hosted home lab running on a **Raspberry Pi 4 (8GB)**. It features a secure, automated HTTPS setup using Traefik, Let's Encrypt, and Cloudflare DDNS to handle dynamic IPs from the ISP (Airtel).

## 🏗️ Architecture & Security Flow

We use **Traefik** as the central entry point (Reverse Proxy) which automatically manages SSL certificates. Since our ISP provides a dynamic IP, a **DDNS script** ensures our domain always points to the correct home address.

```mermaid
%%{init: {
  'theme': 'base',
  'themeVariables': {
    'background': '#F5F7FA',
    'primaryTextColor': '#1F2937',
    'lineColor': '#64748B',
    'fontSize': '14px'
  },
  'flowchart': { 'rankSpacing': 20, 'nodeSpacing': 20 }
}}%%
flowchart LR
    %% --- STYLES ---
    classDef base fill:#FFFFFF,stroke:#CBD5E1,stroke-width:1px,color:#1F2937,rx:4,ry:4,shadow:true
    classDef script fill:#F8FAFC,stroke:#2563EB,stroke-width:2px,color:#1E3A8A,rx:4,ry:4,font-family:monospace,align:left
    classDef cloud fill:#FFFFFF,stroke:#EA580C,stroke-width:2px,color:#1F2937,rx:4,ry:4,shadow:true

    %% --- STRUCTURE ---
    subgraph Maintenance ["🔄 DDNS Auto-Sync Loop - Keep DNS Always Updated"]
        direction LR
        
        %% RASPBERRY PI SIDE
        subgraph Pi ["Raspberry Pi 4 (Local)"]
            direction TB
            DDNS_Script["🐍 <b>DDNS Script</b>
            ──────────────
            ⏰ Runs every 5 mins
            🔍 Detects Public IP
            📊 Compares with DNS"]:::script
        end

        %% CLOUDFLARE SIDE
        subgraph Cloud ["Cloudflare Cloud (Remote)"]
            direction TB
            API["☁️ <b>Cloudflare API</b>
            ──────────────
            🔐 Secure Update
            📍 Updates 'A' Record
            ✅ Confirms Change"]:::cloud
        end
    end

    %% --- LOGIC FLOW ---
    DDNS_Script ==>|"If IP Changed"| API
    API -.->|"Success Response"| DDNS_Script

    %% --- STYLES ---
    class Maintenance masterZone
    classDef masterZone fill:#F5F7FA,stroke:#E2E8F0,stroke-width:2px,rx:10,ry:10,color:#334155
    linkStyle 0 stroke:#2563EB,stroke-width:3px
    linkStyle 1 stroke:#94A3B8,stroke-width:2px,stroke-dasharray: 4 4
```

```mermaid
%%{init: {
  'theme': 'base',
  'themeVariables': {
    'background': '#F5F7FA',
    'primaryTextColor': '#1F2937',
    'lineColor': '#64748B',
    'fontSize': '14px'
  },
  'flowchart': { 'rankSpacing': 15, 'nodeSpacing': 15 }
}}%%
flowchart LR
    %% --- STYLES ---
    classDef client fill:#FFFFFF,stroke:#2563EB,stroke-width:2px,color:#1E3A8A,rx:4,ry:4,font-weight:bold,shadow:true
    classDef netStack fill:#FFFFFF,stroke:#EA580C,stroke-width:2px,color:#1F2937,rx:4,ry:4,shadow:true,align:center
    classDef appStack fill:#F8FAFC,stroke:#2563EB,stroke-width:1px,color:#1E293B,rx:4,ry:4,align:left,font-family:monospace
    classDef lock fill:#DCFCE7,stroke:#15803D,stroke-width:2px,color:#15803D,rx:4,ry:4,font-weight:bold
    
    %% --- STRUCTURE ---
    subgraph Traffic ["🔒 End-to-End Encrypted HTTPS Traffic Path"]
        direction LR

        %% 1. USER
        User["💻 <b>User / Client</b>
        <i>(External Request)</i>"]:::client

        %% 2. NETWORK STACK
        subgraph NetLayer ["Network Path (Secure)"]
            Stack["🌐 <b>Cloudflare DNS</b>
            ⬇️ <i>(Resolves to IP)</i>
            🏠 <b>Home Router</b>
            ⬇️ <i>(Port Forward :443)</i>
            🚦 <b>Traefik</b>"]:::netStack
        end

        %% 3. APPS
        subgraph Server ["🐳 Docker Container Stack"]
            Apps["
            🖥️ Dashboard (Heimdall)
            🎬 Media (Jellyfin)
            📁 Storage (Nextcloud)
            🛡️ DNS/Security (Pi-hole)"]:::appStack
        end

        %% 4. SSL
        SSL["🔐 <b>SSL/TLS</b>
        <i>(Let's Encrypt)</i>"]:::lock
    end

    %% --- CONNECTIONS ---
    User ==>|"HTTPS Request :443"| Stack
    SSL -.->|"Certificates"| Stack
    Stack ==>|"Secure Route"| Apps

    %% --- STYLES ---
    linkStyle 0 stroke:#EA580C,stroke-width:3px
    linkStyle 1 stroke:#15803D,stroke-width:2px,stroke-dasharray: 4 4
    linkStyle 2 stroke:#2563EB,stroke-width:3px
    
    classDef masterZone fill:#F5F7FA,stroke:#E2E8F0,stroke-width:2px,rx:10,ry:10,color:#334155
    classDef innerZone fill:#FFFFFF,stroke:#94A3B8,stroke-width:1px,stroke-dasharray: 6 4
    class Traffic masterZone
    class NetLayer,Server innerZone
```

## 🌐 Connectivity & Security Logic

### 1. Dynamic DNS (DDNS) - Keep Your Domain Updated
**Problem:** Airtel Broadband changes the Public IP address frequently (no static IP).

**Solution:** [Cloudflare DDNS Updater](https://github.com/K0p1-Git/cloudflare-ddns-updater)
- **How it works:** 
  - Runs as a scheduled Cron job (every 5 minutes)
  - Detects the current Public IP
  - Compares it with the DNS `A` record in Cloudflare
  - If changed, automatically updates via Cloudflare API
- **Result:** `*.example.com` always resolves to your home network, even when ISP changes your IP

### 2. Reverse Proxy & HTTPS (Traefik) - Secure Gateway
**Role:** Manages all incoming traffic and SSL certificates.
- **Listens on:** Ports 80 (HTTP) and 443 (HTTPS)
- **Let's Encrypt Integration:** 
  - Automatically requests SSL certificates for all subdomains
  - Handles certificate renewal before expiration
- **HTTP → HTTPS Redirect:** All unencrypted traffic is redirected to secure HTTPS

### 3. Cloudflare DNS & Security (Optional Tunnel Alternative)
You can optionally use **Cloudflare Tunnel** instead of manual port forwarding:

| Method | Pros | Cons |
|--------|------|------|
| **DDNS + Port Forward** (Current) | Full control, Lower latency, Self-hosted | Manual port setup, ISP may block ports, Dynamic IP updates needed |
| **Cloudflare Tunnel** | No port forwarding needed, NAT bypass, Zero Trust Security | Added latency, Cloudflare dependency, Slower for local users |

**Current Setup:** Uses DDNS + Port Forward (443) → More performant for home network access

## 🛠️ Hardware & Software Stack

| Component | Role | Key Services |
|-----------|------|--------------|
| **Raspberry Pi 4 (8GB)** | Central Server | Docker Engine, Traefik Reverse Proxy, Let's Encrypt, DDNS Script, Cron Scheduler |
| **Cloudflare DNS** | DNS Management | Domain Resolution, DDNS Updates via API, DDoS Protection |
| **Docker Containers** | Applications | Jellyfin (Media), Nextcloud (Cloud Storage), Pi-hole (DNS/Security), Heimdall (Dashboard) |
| **Traefik** | Entry Point | SSL Termination, Load Balancing, Automatic Certificate Management |
